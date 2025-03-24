import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart';
import 'package:pet/core/api/api_service.dart';
import 'package:pet/core/network/dio_client.dart';
import 'package:pet/core/provider/login_provider.dart';
import 'package:pet/core/storage/app_storage.dart';
import '../service/kakao_auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// SecureStorage 유틸리티 클래스 추가
class SecureStorageUtils {
  static final _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
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
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final kakaoAuthService = ref.watch(kakaoAuthServiceProvider);
  final appStorage = ref.watch(appStorageProvider).valueOrNull;
  return AuthNotifier(kakaoAuthService, ref, appStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final KakaoAuthService _kakaoAuthService;
  final Ref _ref;
  final AppStorage? _storage;

  AuthNotifier(this._kakaoAuthService, this._ref, this._storage)
    : super(AuthState.unauthenticated());

  Future<void> signInWithKakao(BuildContext context) async {
    // 인가 코드 방식의 로그인 메서드를 사용
    await signInWithKakaoAuthCode(context);
  }

  Future<void> signInWithKakaoAuthCode(BuildContext context) async {
    state = AuthState.loading();

    try {
      // 카카오 인가 코드 방식으로 로그인 시도
      final success = await _kakaoAuthService.signInWithKakaoAuthCode(context);

      if (success) {
        try {
          // 백엔드 API 통신 제거 - 인가 코드 전송 이후 추가 API 호출 없음

          // 로그인 성공 시 홈 화면으로 항상 이동
          if (context.mounted) {
            // 기존 홈으로 가는 리스너 대신 즉시 홈으로 이동
            context.go('/home');
          }
        } catch (e) {
          debugPrint('인증 후처리 실패: $e');
          // 실패해도 인증 상태로 설정하고 홈으로 이동
          state = AuthState.authenticated(null);
          if (context.mounted) {
            context.go('/home');
          }
        }
      } else {
        // 로그인 실패 처리 (이미 KakaoAuthService에서 스낵바 표시)
        state = AuthState.unauthenticated();
      }
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      state = AuthState.unauthenticated();
      if (error is! PlatformException || error.code != 'CANCELED') {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('로그인 실패: $error')));
        }
      }
    }
  }

  Future<void> logout() async {
    await _kakaoAuthService.logout();
    await SecureStorageUtils.clearAll();
    state = AuthState.unauthenticated();
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
  });

  factory AuthState.unauthenticated() {
    return AuthState(isAuthenticated: false, isLoading: false);
  }

  factory AuthState.authenticated(User? user) {
    return AuthState(isAuthenticated: true, isLoading: false, user: user);
  }

  factory AuthState.loading() {
    return AuthState(isAuthenticated: false, isLoading: true);
  }
}
