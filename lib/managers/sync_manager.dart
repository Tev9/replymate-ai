import 'package:firebase_auth/firebase_auth.dart';

import '../services/cloud_storage_service.dart';
import '../services/pending_sync_service.dart';

class SyncManager {
  final PendingSyncService _pendingSyncService;
  final CloudStorageService _cloudStorageService;
  final FirebaseAuth _firebaseAuth;

  SyncManager({
    PendingSyncService? pendingSyncService,
    CloudStorageService? cloudStorageService,
    FirebaseAuth? firebaseAuth,
  })  : _pendingSyncService = pendingSyncService ?? PendingSyncService(),
        _cloudStorageService = cloudStorageService ?? CloudStorageService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<int> syncPendingOperations() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return 0;
    }

    final operations = await _pendingSyncService.loadOperationsForUser(
      currentUser.uid,
    );

    var successfulSyncs = 0;

    for (final operation in operations) {
      try {
        await _cloudStorageService.saveDocument(
          collection: operation.collection,
          documentId: operation.documentId,
          data: operation.data,
        );

        await _pendingSyncService.removeOperation(
          operation.id,
        );

        successfulSyncs++;
      } catch (_) {
        await _pendingSyncService.increaseRetryCount(
          operation,
        );
      }
    }

    return successfulSyncs;
  }

  Future<int> getPendingCount() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return 0;
    }

    return _pendingSyncService.getPendingCount(
      currentUser.uid,
    );
  }
}
