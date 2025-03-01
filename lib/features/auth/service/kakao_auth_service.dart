import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

final kakaoAuthServiceProvider = Provider<KakaoAuthService>((ref) {
  return KakaoAuthService();
});

class KakaoAuthService {
  Future<User?> login() async {
    try {
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡으로 로그인
          await UserApi.instance.loginWithKakaoTalk();
          return await UserApi.instance.me();
        } catch (error) {
          // 사용자가 카카오톡 로그인을 취소한 경우 웹뷰로 로그인 시도
          if (error is PlatformException && error.code == 'CANCELED') {
            return await _loginWithKakaoAccount();
          }
          // 다른 에러인 경우 다시 던짐
          rethrow;
        }
      } else {
        // 카카오톡이 설치되어 있지 않은 경우 웹뷰로 로그인
        return await _loginWithKakaoAccount();
      }
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      return null;
    }
  }

  Future<User?> _loginWithKakaoAccount() async {
    try {
      await UserApi.instance.loginWithKakaoAccount();
      return await UserApi.instance.me();
    } catch (error) {
      debugPrint('카카오 계정 로그인 실패: $error');
      // 사용자가 로그인을 취소한 경우 null 반환
      if (error is PlatformException && error.code == 'CANCELED') {
        return null;
      }
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (error) {
      debugPrint('카카오 로그아웃 실패: $error');
    }
  }
}
