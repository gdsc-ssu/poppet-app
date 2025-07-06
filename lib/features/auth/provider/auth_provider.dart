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
import 'package:pet/core/storage/secure_storage_utils.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final ApiService _apiService;

  AuthNotifier(this._ref, this._apiService)
    : super(AuthState.unauthenticated());

  // 자동 로그인 체크 메서드 추가
  Future<void> checkAutoLogin() async {
    state = AuthState.loading();

    try {
      final token = await SecureStorageUtils.getAccessToken();
      if (token == null) {
        state = AuthState.unauthenticated();
        return;
      }

      // 토큰이 있으면 DioClient에 설정
      await DioClient.setToken(token);

      // 저장된 사용자 정보 불러오기
      final userName = await SecureStorageUtils.getUserName();
      if (userName != null) {
        final userInfo = UserInfo(name: userName);
        _ref.read(loginInfoProvider.notifier).setLoginInfo(userInfo);
        state = AuthState.authenticated(null);
      } else {
        // 사용자 정보가 없으면 로그아웃 처리
        await logout();
      }
    } catch (e) {
      debugPrint('자동 로그인 실패: $e');
      await logout();
    }
  }

  Future<void> signInWithKakao(BuildContext context) async {
    state = AuthState.kakaoLoading();

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

        // 사용자 정보 저장
        await SecureStorageUtils.setUserName(userName);
        _ref.read(loginInfoProvider.notifier).setLoginInfo(userInfo);

        state = AuthState.authenticated(null);

        if (!context.mounted) return;
        context.go('/home');
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
 Future<void> signInWithApple(BuildContext context) async {
  state = state.copyWith(isAppleLoading: true); // 로딩 표시

  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // 이 credential.userIdentifier 등을 서버로 전송하여 사용자 인증 처리
    String userIdentifier =  credential.identityToken!;
    print('애플 로그인 성공: ${credential.identityToken}');
    final authResponse = await ApiService(
        DioClient.dio,
      ).loginWithApple({'accessToken': userIdentifier});
    print(authResponse);
    state = AuthState.unauthenticated();
  } catch (e) {
    print('애플 로그인 실패: $e');
    state = state.copyWith(isAppleLoading: false);
  }
}

  Future<void> signInWithGoogle(BuildContext context) async {
    state = AuthState.googleLoading();

    final _googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('사용자가 Google 로그인을 취소했습니다.');
        state = AuthState.unauthenticated();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        debugPrint('Google 로그인 실패: accessToken 또는 idToken이 null입니다.');
        state = AuthState.unauthenticated();
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
        state = AuthState.unauthenticated();
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

      // 사용자 정보 저장
      await SecureStorageUtils.setUserName(userName);
      _ref.read(loginInfoProvider.notifier).setLoginInfo(userInfo);

      debugPrint('구글 로그인 성공: $userName');

      state = AuthState.authenticated(null);

      if (!context.mounted) return;
      context.go('/home');
    } catch (e, stackTrace) {
      debugPrint('Google 로그인 중 오류 발생: $e\n$stackTrace');
      state = AuthState.unauthenticated();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('구글 로그인 중 오류가 발생했습니다: $e')));
      }
    }
  }

  Future<void> logout() async {
    await SecureStorageUtils.clearAll();
    _ref.read(loginInfoProvider.notifier).clearLoginInfo();
    state = AuthState.unauthenticated();
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isKakaoLoading;
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final User? user;

  AuthState({
    required this.isAuthenticated,
    required this.isKakaoLoading,
    required this.isGoogleLoading,
    required this.isAppleLoading,
    this.user,
  });

  bool get isLoading => isKakaoLoading || isGoogleLoading || isAppleLoading;

  factory AuthState.unauthenticated() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: false,
      isGoogleLoading: false,
      isAppleLoading: false,
    );
  }

  factory AuthState.authenticated(User? user) {
    return AuthState(
      isAuthenticated: true,
      isKakaoLoading: false,
      isGoogleLoading: false,
      isAppleLoading: false,
      user: user,
    );
  }

  factory AuthState.kakaoLoading() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: true,
      isGoogleLoading: false,
      isAppleLoading: false,
    );
  }

  factory AuthState.googleLoading() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: false,
      isGoogleLoading: true,
      isAppleLoading: false,
    );
  }

  factory AuthState.appleLoading() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: false,
      isGoogleLoading: false,
      isAppleLoading: true,
    );
  }

  factory AuthState.loading() {
    return AuthState(
      isAuthenticated: false,
      isKakaoLoading: false,
      isGoogleLoading: false,
      isAppleLoading: false,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isKakaoLoading,
    bool? isGoogleLoading,
    bool? isAppleLoading,
    User? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isKakaoLoading: isKakaoLoading ?? this.isKakaoLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      user: user ?? this.user,
    );
  }
}

// ✅ StateNotifierProvider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(ref, apiService);
});