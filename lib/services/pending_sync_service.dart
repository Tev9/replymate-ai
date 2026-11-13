import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pending_sync_operation.dart';

class PendingSyncService {
  final FirebaseAuth? _firebaseAuth;

  PendingSyncService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  static const String _storageKey = 'pending_sync_operations';

  static Future<void> _queueLock = Future<void>.value();

  Future<T> _withQueueLock<T>(
    Future<T> Function() action,
  ) async {
    final previousOperation = _queueLock;
    final releaseLock = Completer<void>();

    _queueLock = releaseLock.future;

    await previousOperation;

    try {
      return await action();
    } finally {
      releaseLock.complete();
    }
  }

  Future<List<PendingSyncOperation>> loadOperations() async {
    final preferences = await SharedPreferences.getInstance();

    final encodedOperations = preferences.getString(_storageKey);

    if (encodedOperations == null || encodedOperations.isEmpty) {
      return [];
    }

    try {
      final decodedOperations = jsonDecode(encodedOperations) as List<dynamic>;

      return decodedOperations
          .map(
            (item) => PendingSyncOperation.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList();
    } catch (error) {
      throw StateError(
        'Unable to read pending sync operations: $error',
      );
    }
  }

  Future<List<PendingSyncOperation>> loadOperationsForUser(
    String userId,
  ) async {
    final operations = await loadOperations();

    return operations
        .where(
          (operation) => operation.userId == userId,
        )
        .toList();
  }

  Future<bool> addOperation({
    required String collection,
    required String documentId,
    String? subcollection,
    String? subdocumentId,
    required Map<String, dynamic> data,
  }) {
    return _withQueueLock(() async {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        return false;
      }

      final userId = currentUser.uid;
      final operations = await loadOperations();

      operations.removeWhere(
        (operation) =>
            operation.userId == userId &&
            operation.collection == collection &&
            operation.documentId == documentId &&
            operation.subcollection == subcollection &&
            operation.subdocumentId == subdocumentId,
      );

      final createdAt = DateTime.now();

      final operationParts = [
        userId,
        collection,
        documentId,
        if (subcollection != null) subcollection,
        if (subdocumentId != null) subdocumentId,
        createdAt.microsecondsSinceEpoch.toString(),
      ];

      operations.add(
        PendingSyncOperation(
          id: operationParts.join('_'),
          userId: userId,
          collection: collection,
          documentId: documentId,
          subcollection: subcollection,
          subdocumentId: subdocumentId,
          data: Map<String, dynamic>.from(data),
          createdAt: createdAt,
        ),
      );

      await _saveOperations(operations);

      return true;
    });
  }

  Future<void> removeOperation(
    String operationId,
  ) {
    return _withQueueLock(() async {
      final operations = await loadOperations();

      operations.removeWhere(
        (operation) => operation.id == operationId,
      );

      await _saveOperations(operations);
    });
  }

  Future<void> increaseRetryCount(
    PendingSyncOperation operation,
  ) {
    return _withQueueLock(() async {
      final operations = await loadOperations();

      final updatedOperations = operations.map((item) {
        if (item.id != operation.id) {
          return item;
        }

        final nextRetryCount = item.retryCount + 1;
        final delay = _calculateRetryDelay(nextRetryCount);

        return item.copyWith(
          retryCount: nextRetryCount,
          nextRetryAt: DateTime.now().add(delay),
        );
      }).toList();

      await _saveOperations(updatedOperations);
    });
  }

  Future<void> clearOperations() {
    return _withQueueLock(() async {
      final preferences = await SharedPreferences.getInstance();

      final removed = await preferences.remove(_storageKey);

      if (!removed) {
        throw StateError(
          'Failed to clear pending sync operations.',
        );
      }
    });
  }

  Future<int> getPendingCount(
    String userId,
  ) async {
    final operations = await loadOperationsForUser(userId);

    return operations.length;
  }

  Duration _calculateRetryDelay(int retryCount) {
    const maximumDelayMinutes = 60;

    final delaySeconds = 30 * (1 << (retryCount - 1));
    final maximumDelaySeconds =
        const Duration(minutes: maximumDelayMinutes).inSeconds;

    return Duration(
      seconds: delaySeconds > maximumDelaySeconds
          ? maximumDelaySeconds
          : delaySeconds,
    );
  }

  Future<void> _saveOperations(
    List<PendingSyncOperation> operations,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedOperations = jsonEncode(
      operations.map((operation) => operation.toJson()).toList(),
    );

    final saved = await preferences.setString(
      _storageKey,
      encodedOperations,
    );

    if (!saved) {
      throw StateError(
        'Failed to save pending sync operations.',
      );
    }
  }
}
