import 'package:firebase_auth/firebase_auth.dart';

import '../services/cloud_storage_service.dart';
import '../services/pending_sync_service.dart';

class SyncManager {
  final PendingSyncService _pendingSyncService;
  final CloudStorageService _cloudStorageService;
  final FirebaseAuth _firebaseAuth;

  bool _isSyncing = false;

  SyncManager({
    PendingSyncService? pendingSyncService,
    CloudStorageService? cloudStorageService,
    FirebaseAuth? firebaseAuth,
  })  : _pendingSyncService = pendingSyncService ?? PendingSyncService(),
        _cloudStorageService = cloudStorageService ?? CloudStorageService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  bool get isSyncing => _isSyncing;

  Future<int> syncPendingOperations() async {
    if (_isSyncing) {
      return 0;
    }

    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return 0;
    }

    _isSyncing = true;

    try {
      final operations =
          await _pendingSyncService.loadOperationsForUser(currentUser.uid);

      var successfulSyncs = 0;

      for (final operation in operations) {
        try {
          await _cloudStorageService.saveDocument(
            collection: operation.collection,
            documentId: operation.documentId,
            data: operation.data,
          );

          await _pendingSyncService.removeOperation(operation.id);

          successfulSyncs++;
        } catch (_) {
          await _pendingSyncService.increaseRetryCount(operation);
        }
      }

      return successfulSyncs;
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> getPendingCount() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return 0;
    }

    return _pendingSyncService.getPendingCount(currentUser.uid);
  }
}
