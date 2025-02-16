import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shared_preferences/shared_preferences.dart';

part 'app_storage.g.dart';

class AppStorage {
  final SharedPreferences _prefs;

  AppStorage(this._prefs);

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

@riverpod
Future<AppStorage> appStorage(AppStorageRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AppStorage(prefs);
}
