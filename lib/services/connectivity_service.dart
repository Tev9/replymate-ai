import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasDisconnected = false;

  ConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  Future<void> startListening({
    required Future<void> Function() onConnectionRestored,
  }) async {
    await stopListening();

    final initialResults = await _connectivity.checkConnectivity();
    _wasDisconnected = !_hasConnection(initialResults);

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final hasConnection = _hasConnection(results);

        if (_wasDisconnected && hasConnection) {
          await onConnectionRestored();
        }

        _wasDisconnected = !hasConnection;
      },
    );
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
