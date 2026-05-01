import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _prefix = 'neo_game_suit_';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveString(String key, String value) async {
    await _prefs.setString('$_prefix$key', value);
  }

  String? getString(String key) {
    return _prefs.getString('$_prefix$key');
  }

  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    await saveString(key, jsonEncode(json));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt('$_prefix$key', value);
  }

  int? getInt(String key) {
    return _prefs.getInt('$_prefix$key');
  }

  Future<void> remove(String key) async {
    await _prefs.remove('$_prefix$key');
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
