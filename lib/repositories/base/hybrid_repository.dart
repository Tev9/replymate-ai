import '../../services/cloud_storage_service.dart';
import '../../services/pending_sync_service.dart';

abstract class HybridRepository<T> {
  final CloudStorageService cloudService;
  final PendingSyncService pendingSyncService;

  HybridRepository({
    CloudStorageService? cloudService,
    PendingSyncService? pendingSyncService,
  })  : cloudService = cloudService ?? CloudStorageService(),
        pendingSyncService = pendingSyncService ?? PendingSyncService();

  String normalizeDocumentId(String value) {
    return value.trim().toLowerCase();
  }

  Future<T?> loadDocumentLocalFirst({
    required String collection,
    required String documentId,
    required Future<T?> Function(String documentId) loadLocal,
    required Future<void> Function(
      String documentId,
      T value,
    ) saveLocal,
    required T Function(Map<String, dynamic> json) fromJson,
    bool Function(T value)? hasLocalData,
  }) async {
    final normalizedDocumentId = normalizeDocumentId(documentId);

    final localValue = await loadLocal(normalizedDocumentId);

    final localValueExists = localValue != null &&
        (hasLocalData == null || hasLocalData(localValue));

    if (localValueExists) {
      return localValue;
    }

    try {
      final cloudData = await cloudService.loadDocument(
        collection: collection,
        documentId: normalizedDocumentId,
      );

      if (cloudData == null) {
        return localValue;
      }

      final cloudValue = fromJson(cloudData);

      await saveLocal(
        normalizedDocumentId,
        cloudValue,
      );

      return cloudValue;
    } catch (_) {
      return localValue;
    }
  }

  Future<void> saveDocumentLocalFirst({
    required String collection,
    required String documentId,
    required T value,
    required Future<void> Function(
      String documentId,
      T value,
    ) saveLocal,
    required Map<String, dynamic> Function(T value) toJson,
  }) async {
    final normalizedDocumentId = normalizeDocumentId(documentId);

    await saveLocal(
      normalizedDocumentId,
      value,
    );

    final data = toJson(value);

    try {
      await cloudService.saveDocument(
        collection: collection,
        documentId: normalizedDocumentId,
        data: data,
      );
    } catch (_) {
      await pendingSyncService.addOperation(
        collection: collection,
        documentId: normalizedDocumentId,
        data: data,
      );
    }
  }

  Future<void> saveCloudDocumentWithFallback({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final normalizedDocumentId = normalizeDocumentId(documentId);

    try {
      await cloudService.saveDocument(
        collection: collection,
        documentId: normalizedDocumentId,
        data: data,
      );
    } catch (_) {
      await pendingSyncService.addOperation(
        collection: collection,
        documentId: normalizedDocumentId,
        data: data,
      );
    }
  }
}
