import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String favoriteKey = "favorites";

  // Profile keys
  static const String _profileNameKey = 'profile_name';
  static const String _profileGmailKey = 'profile_gmail';
  static const String _profileContactKey = 'profile_contact';
  static const String _profileSuggestionKey = 'profile_suggestion';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(favoriteKey) ?? [];
  }

  static Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(favoriteKey, favorites);
  }

  /// Returns saved profile values. If not present, returns empty strings.
  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_profileNameKey) ?? '',
      'gmail': prefs.getString(_profileGmailKey) ?? '',
      'contact': prefs.getString(_profileContactKey) ?? '',
      'suggestion': prefs.getString(_profileSuggestionKey) ?? '',
    };
  }

  /// Save profile fields into shared preferences.
  static Future<void> saveProfile({
    required String name,
    required String gmail,
    required String contact,
    required String suggestion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileNameKey, name);
    await prefs.setString(_profileGmailKey, gmail);
    await prefs.setString(_profileContactKey, contact);
    await prefs.setString(_profileSuggestionKey, suggestion);
  }
}
