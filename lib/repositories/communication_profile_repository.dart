import '../models/communication_profile.dart';

abstract class CommunicationProfileRepository {
  Future<CommunicationProfile?> loadProfile(
    String contactName,
  );

  Future<void> saveProfile(
    String contactName,
    CommunicationProfile profile,
  );
}