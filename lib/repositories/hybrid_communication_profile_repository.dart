import '../models/communication_profile.dart';
import '../services/communication_profile_service.dart';
import 'base/hybrid_repository.dart';
import 'communication_profile_repository.dart';

class HybridCommunicationProfileRepository
    extends HybridRepository<CommunicationProfile>
    implements CommunicationProfileRepository {
  final CommunicationProfileService _localService;

  HybridCommunicationProfileRepository({
    CommunicationProfileService? localService,
    super.cloudService,
    super.pendingSyncService,
  }) : _localService = localService ?? CommunicationProfileService();

  @override
  Future<CommunicationProfile?> loadProfile(
    String contactName,
  ) {
    return loadDocumentLocalFirst(
      collection: 'communicationProfiles',
      documentId: contactName,
      loadLocal: _localService.loadProfile,
      saveLocal: _localService.saveProfile,
      fromJson: CommunicationProfile.fromJson,
    );
  }

  @override
  Future<void> saveProfile(
    String contactName,
    CommunicationProfile profile,
  ) {
    return saveDocumentLocalFirst(
      collection: 'communicationProfiles',
      documentId: contactName,
      value: profile,
      saveLocal: _localService.saveProfile,
      toJson: (value) => value.toJson(),
    );
  }
}
