import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_storage.dart';

final kakaoAuthServiceProvider = Provider<KakaoAuthService>((ref) {
  final appStorage = ref.watch(appStorageProvider).value;
  return KakaoAuthService(appStorage);
});

class KakaoAuthService {
  final AppStorage? _storage;
  final Dio dio = Dio(
    BaseOptions(baseUrl: "https://api.example.com"),
  ); // TODO: Replace with your API base URL

  KakaoAuthService(this._storage);

  Future<bool> signInWithKakao(BuildContext context) async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // 사용자가 카카오톡 로그인을 취소한 경우 웹뷰로 로그인 시도
          if (error is PlatformException && error.code == 'CANCELED') {
            token = await UserApi.instance.loginWithKakaoAccount();
          } else {
            rethrow;
          }
        }
      } else {
        // 카카오톡이 설치되어 있지 않은 경우 웹뷰로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 백엔드 서버가 준비되지 않았으므로 임시로 성공 처리
      // 실제 구현 시에는 아래 주석을 해제하고 백엔드 통신 코드를 사용해야 합니다
      /*
      // 백엔드로 로그인 요청
      final response = await dio.post(
        "/auth/kakao",
        data: {
          "accessToken": token.accessToken, // 카카오 액세스 토큰 전달
          "refreshToken": token.refreshToken ?? "", // 선택적
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String backendToken = data["backendToken"]; // 백엔드에서 발급한 자체 JWT 토큰

        // 백엔드 토큰을 안전하게 저장
        if (_storage != null) {
          await _storage.saveToken(backendToken);

          // 사용자 정보가 있다면 저장
          if (data["userId"] != null) {
            await _storage.saveUserId(data["userId"]);
          }
        }

        // 로그인 성공
        return true;
      } else {
        throw Exception("로그인 실패");
      }
      */

      // 임시 구현: 카카오 로그인 성공 시 토큰 정보만 저장
      if (_storage != null) {
        await _storage.saveToken(token.accessToken);

        // 사용자 ID 가져오기 시도
        try {
          final user = await UserApi.instance.me();
          await _storage.saveUserId(user.id.toString());
        } catch (e) {
          debugPrint('사용자 정보 가져오기 실패: $e');
        }
      }

      return true;
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 실패: $error')));
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      if (_storage != null) {
        await _storage.clearAll();
      }
    } catch (error) {
      debugPrint('카카오 로그아웃 실패: $error');
    }
  }
}
