import '../models/communication_profile.dart';
import 'cloud_storage_service.dart';
import 'communication_profile_service.dart';

class SyncManager {
  final CloudStorageService _cloudStorageService;
  final CommunicationProfileService _communicationProfileService;

  SyncManager({
    CloudStorageService? cloudStorageService,
    CommunicationProfileService? communicationProfileService,
  })  : _cloudStorageService =
            cloudStorageService ?? CloudStorageService(),
        _communicationProfileService =
            communicationProfileService ??
                CommunicationProfileService();

  Future<void> syncCommunicationProfileToCloud({
    required String contactName,
    required CommunicationProfile profile,
  }) async {
    final normalizedContactName =
        contactName.trim().toLowerCase();

    await _cloudStorageService.saveDocument(
      collection: 'communicationProfiles',
      documentId: normalizedContactName,
      data: profile.toJson(),
    );
  }

  Future<CommunicationProfile?>
      restoreCommunicationProfileFromCloud({
    required String contactName,
  }) async {
    final normalizedContactName =
        contactName.trim().toLowerCase();

    final cloudData =
        await _cloudStorageService.loadDocument(
      collection: 'communicationProfiles',
      documentId: normalizedContactName,
    );

    if (cloudData == null) {
      return null;
    }

    final profile =
        CommunicationProfile.fromJson(cloudData);

    await _communicationProfileService.saveProfile(
      normalizedContactName,
      profile,
    );

    return profile;
  }
}