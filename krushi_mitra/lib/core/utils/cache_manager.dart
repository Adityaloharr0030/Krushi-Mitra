import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const String keyWeather = 'cached_weather';
  static const String keyMandi = 'cached_mandi';
  static const String keySchemes = 'cached_schemes';

  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cachePayload = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': data
    };
    await prefs.setString(key, jsonEncode(cachePayload));
  }

  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    
    if (jsonString != null) {
      try {
        final payload = jsonDecode(jsonString);
        final timestamp = DateTime.parse(payload['timestamp']);
        
        // Cache is valid for 24 hours
        if (DateTime.now().difference(timestamp).inHours < 24) {
          return payload['data'];
        } else {
          // Expired cache
          await prefs.remove(key);
        }
      } catch (e) {
        // Corrupted cache
        await prefs.remove(key);
      }
    }
    return null;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyWeather);
    await prefs.remove(keyMandi);
    await prefs.remove(keySchemes);
  }
}
