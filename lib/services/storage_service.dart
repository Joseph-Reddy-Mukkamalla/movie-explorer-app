import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String favoriteKey = "favorites";

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(favoriteKey) ?? [];
  }

  static Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(favoriteKey, favorites);
  }
}
