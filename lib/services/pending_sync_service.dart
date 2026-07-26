import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pending_sync_operation.dart';

class PendingSyncService {
  final FirebaseAuth _firebaseAuth;

  PendingSyncService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  static const String _storageKey = 'pending_sync_operations';

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
    } catch (_) {
      // Prevent damaged local queue data from crashing the app.
      return [];
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
  }) async {
    final currentUser = _firebaseAuth.currentUser;

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
  }

  Future<void> removeOperation(
    String operationId,
  ) async {
    final operations = await loadOperations();

    operations.removeWhere(
      (operation) => operation.id == operationId,
    );

    await _saveOperations(operations);
  }

  Future<void> increaseRetryCount(
    PendingSyncOperation operation,
  ) async {
    final nextRetryCount = operation.retryCount + 1;
    final delay = _calculateRetryDelay(nextRetryCount);

    final updatedOperation = operation.copyWith(
      retryCount: nextRetryCount,
      nextRetryAt: DateTime.now().add(delay),
    );

    final operations = await loadOperations();

    final updatedOperations = operations.map((item) {
      if (item.id == operation.id) {
        return updatedOperation;
      }

      return item;
    }).toList();

    await _saveOperations(updatedOperations);
  }

  Future<void> clearOperations() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
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

    await preferences.setString(
      _storageKey,
      encodedOperations,
    );
  }
}
