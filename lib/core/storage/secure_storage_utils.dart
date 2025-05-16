import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class SecureStorageUtils {
  static final _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  static Future<void> setAccessToken(String token) async {
    debugPrint(
      '🔐 저장된 토큰: ${token.substring(0, math.min(20, token.length))}...',
    );
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      debugPrint(
        '🔐 불러온 토큰: ${token.substring(0, math.min(20, token.length))}...',
      );
    }
    return token;
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> setUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    debugPrint('🧹 모든 SecureStorage 데이터가 삭제되었습니다.');
  }
}
