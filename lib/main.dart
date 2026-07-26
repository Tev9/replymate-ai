import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/service_locator.dart';
import 'firebase_options.dart';
import 'managers/sync_manager.dart';
import 'screens/auth_page.dart';
import 'screens/home_page.dart';
import 'services/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupServiceLocator();

  runApp(const ReplyMateApp());
}

class ReplyMateApp extends StatelessWidget {
  const ReplyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReplyMate AI',
      theme: ThemeData.dark(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastSyncedUserId;
  bool _connectivityListenerStarted = false;

  void _schedulePendingSync(User user) {
    if (_lastSyncedUserId == user.uid) {
      return;
    }

    _lastSyncedUserId = user.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runPendingSync());
      unawaited(_startConnectivityListener());
    });
  }

  Future<void> _runPendingSync() async {
    try {
      await serviceLocator<SyncManager>().syncPendingOperations();
    } catch (error) {
      debugPrint('Pending sync failed: $error');
    }
  }

  Future<void> _startConnectivityListener() async {
    if (_connectivityListenerStarted) {
      return;
    }

    _connectivityListenerStarted = true;

    try {
      await serviceLocator<ConnectivityService>().startListening(
        onConnectionRestored: _runPendingSync,
      );
    } catch (error) {
      _connectivityListenerStarted = false;
      debugPrint('Connectivity listener failed: $error');
    }
  }

  @override
  void dispose() {
    unawaited(
      serviceLocator<ConnectivityService>().stopListening(),
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          _schedulePendingSync(user);
          return const HomePage();
        }

        _lastSyncedUserId = null;
        return const AuthPage();
      },
    );
  }
}
