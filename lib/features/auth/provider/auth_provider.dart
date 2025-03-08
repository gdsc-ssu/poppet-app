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
    state = AuthState.loading();

    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 토큰 정보 로그 출력
      debugPrint('토큰 : ${token}');
      debugPrint('액세스 토큰: ${token.accessToken}');
      debugPrint('리프레시 토큰: ${token.refreshToken}');
      debugPrint('ID 토큰: ${token.idToken}');
      debugPrint('==========================');

      // Secure Storage에 토큰 저장
      await SecureStorageUtils.setAccessToken(token.accessToken);
      if (token.refreshToken != null) {
        await SecureStorageUtils.setRefreshToken(token.refreshToken!);
      }

      // 백엔드 서버로 카카오 토큰 전송
      try {
        final authResponse = await ApiService(
          DioClient.dio,
        ).oAuthKakao({"accessToken": token.accessToken});

        // 백엔드 토큰 정보 로그 출력
        debugPrint('===== 백엔드 토큰 정보 =====');
        debugPrint('백엔드 토큰: ${authResponse.accessToken.token}');
        debugPrint('============================');

        // 백엔드 토큰 설정
        await DioClient.setToken(authResponse.accessToken.token);

        // 사용자 정보 가져오기
        try {
          // 백엔드에서 사용자 정보 가져오기
          final userInfo = await ApiService(DioClient.dio).getUserInfo();
          final loginInfoNotifier = _ref.read(loginInfoProvider.notifier);
          loginInfoNotifier.setLoginInfo(userInfo);

          // 카카오에서 사용자 정보 가져오기 (백업용)
          final kakaoUser = await UserApi.instance.me();
          await SecureStorageUtils.setUserId(kakaoUser.id.toString());

          state = AuthState.authenticated(kakaoUser);

          // 로그인 성공 시 홈 화면으로 이동
          if (context.mounted) {
            context.go('/home');
          }
        } catch (e) {
          debugPrint('사용자 정보 가져오기 실패: $e');
          state = AuthState.unauthenticated();
        }
      } catch (e) {
        debugPrint('백엔드 서버 통신 실패: $e');

        // 백엔드 서버 통신 실패 시에도 카카오 사용자 정보는 가져오기 시도
        try {
          final kakaoUser = await UserApi.instance.me();
          await SecureStorageUtils.setUserId(kakaoUser.id.toString());
          state = AuthState.authenticated(kakaoUser);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('백엔드 서버 연결 실패. 일부 기능이 제한될 수 있습니다.')),
            );
          }
        } catch (userError) {
          debugPrint('카카오 사용자 정보 가져오기 실패: $userError');
          state = AuthState.unauthenticated();
        }
      }
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      state = AuthState.unauthenticated();
      context.go('/home');
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

  factory AuthState.authenticated(User user) {
    return AuthState(isAuthenticated: true, isLoading: false, user: user);
  }

  factory AuthState.loading() {
    return AuthState(isAuthenticated: false, isLoading: true);
  }
}
