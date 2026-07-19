import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/communication_profile.dart';

class CommunicationProfileService {
  String _key(String contactName) {
    final normalizedContactName =
        contactName.trim().toLowerCase();

    return 'communication_profile_$normalizedContactName';
  }

  Future<CommunicationProfile?> loadProfile(
    String contactName,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(
      _key(contactName),
    );

    if (data == null) {
      return null;
    }

    return CommunicationProfile.fromJson(
      jsonDecode(data) as Map<String, dynamic>,
    );
  }

  Future<void> saveProfile(
    String contactName,
    CommunicationProfile profile,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key(contactName),
      jsonEncode(profile.toJson()),
    );
  }
}