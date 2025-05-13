import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart';
import 'package:pet/core/api/api_service.dart';
import 'package:pet/core/network/dio_client.dart';
import 'package:pet/core/provider/login_provider.dart';
import 'package:pet/core/storage/app_storage.dart';

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

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final AppStorage? _storage;
  final ApiService _apiService;

  AuthNotifier(this._ref, this._storage, this._apiService)
    : super(AuthState.unauthenticated());

  Future<void> signInWithKakao(BuildContext context) async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      await SecureStorageUtils.setAccessToken(token.accessToken);
      await SecureStorageUtils.setRefreshToken(token.idToken ?? '');

      final authResponse = await ApiService(
        DioClient.dio,
      ).loginWithKakao({"accessToken": token.accessToken});
      if (!context.mounted) return;
      context.go('/home');
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      if (error is! PlatformException || error.code != 'CANCELED') {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('로그인 실패: $error')));
        }
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('User canceled Google Sign-In');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String accessToken = googleAuth.accessToken!;
      final String idToken = googleAuth.idToken!;

      await SecureStorageUtils.setAccessToken(accessToken);
      await SecureStorageUtils.setRefreshToken(idToken);

      final authResponse = await ApiService(
        DioClient.dio,
      ).loginWithGoogle({"accessToken": accessToken, 'idToken': idToken});

      if (!context.mounted) return;
      context.go('/home');
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('구글 로그인 중 오류가 발생했습니다: $e')));
      }
    }
  }

  Future<void> logout() async {
    await SecureStorageUtils.clearAll();
    state = AuthState.unauthenticated();
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isKakaoLoading;
  final bool isGoogleLoading;
  final User? user;

  AuthState({
    required this.isAuthenticated,
    required this.isKakaoLoading,
    required this.isGoogleLoading,
    this.user,
  });

  bool get isLoading => isKakaoLoading || isGoogleLoading;

  factory AuthState.unauthenticated() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: false,
      isGoogleLoading: false,
    );
  }

  factory AuthState.authenticated(User? user) {
    return AuthState(
      isAuthenticated: true,
      isKakaoLoading: false,
      isGoogleLoading: false,
      user: user,
    );
  }

  factory AuthState.kakaoLoading() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: true,
      isGoogleLoading: false,
    );
  }

  factory AuthState.googleLoading() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: false,
      isGoogleLoading: true,
    );
  }
}

// Add the missing provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  // Handle AsyncValue case by passing null for storage
  // ApiService is already available directly
  return AuthNotifier(ref, null, apiService);
});
