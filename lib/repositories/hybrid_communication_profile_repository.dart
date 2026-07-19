import '../models/communication_profile.dart';
import '../services/cloud_storage_service.dart';
import '../services/communication_profile_service.dart';
import 'communication_profile_repository.dart';

class HybridCommunicationProfileRepository
    implements CommunicationProfileRepository {
  final CommunicationProfileService _localService;
  final CloudStorageService _cloudService;

  HybridCommunicationProfileRepository({
    CommunicationProfileService? localService,
    CloudStorageService? cloudService,
  })  : _localService =
            localService ?? CommunicationProfileService(),
        _cloudService =
            cloudService ?? CloudStorageService();

  String _normalizeContactName(String contactName) {
    return contactName.trim().toLowerCase();
  }

  @override
  Future<CommunicationProfile?> loadProfile(
    String contactName,
  ) async {
    final normalizedContactName =
        _normalizeContactName(contactName);

    // Use the local copy first for speed and offline support.
    final localProfile =
        await _localService.loadProfile(
      normalizedContactName,
    );

    if (localProfile != null) {
      return localProfile;
    }

    // If no local copy exists, try restoring it from Firestore.
    try {
      final cloudData = await _cloudService.loadDocument(
        collection: 'communicationProfiles',
        documentId: normalizedContactName,
      );

      if (cloudData == null) {
        return null;
      }

      final cloudProfile =
          CommunicationProfile.fromJson(cloudData);

      // Cache the restored profile locally.
      await _localService.saveProfile(
        normalizedContactName,
        cloudProfile,
      );

      return cloudProfile;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(
    String contactName,
    CommunicationProfile profile,
  ) async {
    final normalizedContactName =
        _normalizeContactName(contactName);

    // Local save is the primary save and supports offline use.
    await _localService.saveProfile(
      normalizedContactName,
      profile,
    );

    // Firestore acts as cloud backup and multi-device storage.
    try {
      await _cloudService.saveDocument(
        collection: 'communicationProfiles',
        documentId: normalizedContactName,
        data: profile.toJson(),
      );
    } catch (_) {
      // The local save has succeeded.
      // A retry system will be added later.
    }
  }
}