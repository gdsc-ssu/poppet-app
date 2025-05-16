import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:go_router/go_router.dart';
import 'package:pet/core/api/api_service.dart';
import 'package:pet/core/network/dio_client.dart';
import 'package:pet/core/provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

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
  final ApiService _apiService;

  AuthNotifier(this._ref, this._apiService)
    : super(AuthState.unauthenticated());

  Future<void> signInWithKakao(BuildContext context) async {
    try {
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      await SecureStorageUtils.setAccessToken(token.accessToken);
      await SecureStorageUtils.setRefreshToken(token.idToken ?? '');

      // Use DioClient directly for access to response headers
      final response = await DioClient.dio.post(
        '/auth/login/kakao',
        data: {"accessToken": token.accessToken},
      );

      // Process response headers for authorization token
      final bearer = response.headers['authorization']?.first;
      if (bearer != null) {
        final jwtToken = bearer.replaceFirst('Bearer ', '').trim();
        await SecureStorageUtils.setAccessToken(jwtToken);
        await DioClient.setToken(jwtToken);
      }

      // Process response data
      if (response.data != null && response.data['data'] != null) {
        final userName = response.data['data']['name'];
        final userInfo = UserInfo(name: userName);
        _ref.read(loginInfoProvider.notifier).setLoginInfo(userInfo);
      }

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
        debugPrint('사용자가 Google 로그인을 취소했습니다.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        debugPrint('Google 로그인 실패: accessToken 또는 idToken이 null입니다.');
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('구글 로그인에 실패했습니다. 다시 시도해주세요.')));
        }
        return;
      }

      // Secure storage에 토큰 저장
      await SecureStorageUtils.setAccessToken(accessToken);
      await SecureStorageUtils.setRefreshToken(idToken);

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      // Firebase로 인증
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        debugPrint('Firebase 인증 실패: 사용자 정보를 가져올 수 없습니다.');
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('인증에 실패했습니다. 다시 시도해주세요.')));
        }
        return;
      }

      // 서버에 로그인 요청
      final authResponse = await ApiService(
        DioClient.dio,
      ).loginWithGoogle({'accessToken': accessToken, 'idToken': idToken});

      final userName = authResponse.data.name;
      final userInfo = UserInfo(name: userName);
      _ref.read(loginInfoProvider.notifier).setLoginInfo(userInfo);

      debugPrint('구글 로그인 성공: $userName');

      if (!context.mounted) return;
      context.go('/home');
    } catch (e, stackTrace) {
      debugPrint('Google 로그인 중 오류 발생: $e\n$stackTrace');
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
  return AuthNotifier(ref, apiService);
});
