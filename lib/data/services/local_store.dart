import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON/string wrapper around [SharedPreferences].
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  Object? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeJson(String key, Object value) => _prefs.setString(key, jsonEncode(value));

  String? readString(String key) => _prefs.getString(key);
  Future<void> writeString(String key, String value) => _prefs.setString(key, value);

  bool? readBool(String key) => _prefs.getBool(key);
  Future<void> writeBool(String key, bool value) => _prefs.setBool(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}

abstract final class StoreKeys {
  static const theme = 'settings.theme';
  static const language = 'settings.language';
  static const onboardingSeen = 'settings.onboardingSeen';
  static const users = 'auth.users';
  static const session = 'auth.session';
  static const lastRoute = 'nav.lastRoute';
  static const notifications = 'settings.notifications';

  // Per-user data: suffix with the user id.
  static String cart(String uid) => 'cart:$uid';
  static String favorites(String uid) => 'favorites:$uid';
  static String orders(String uid) => 'orders:$uid';
  static String addresses(String uid) => 'addresses:$uid';
  static String recentSearches(String uid) => 'recentSearches:$uid';
}
