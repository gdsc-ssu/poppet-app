import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/provider/login_provider.dart';

final kakaoAuthServiceProvider = Provider<KakaoAuthService>((ref) {
  final appStorage = ref.watch(appStorageProvider).value;
  final apiService = ref.watch(apiServiceProvider);
  return KakaoAuthService(appStorage, apiService, ref);
});

class KakaoAuthService {
  final AppStorage? _storage;
  final ApiService _apiService;
  final Ref _ref;
  String? lastAuthCode; // 마지막으로 받은 인가 코드 저장

  KakaoAuthService(this._storage, this._apiService, this._ref);

  // 인가 코드를 직접 얻는 방법 (실험적)
  Future<bool> signInWithKakaoAuthCode(BuildContext context) async {
    try {
      // 카카오톡 설치 여부 확인
      bool talkInstalled = await isKakaoTalkInstalled();
      String authCode = '';

      // 리다이렉트 URI 설정
      String redirectUri = 'kakaoa1e5cdadeae290397049e5b6c51829ca://oauth';

      try {
        if (talkInstalled) {
          // 카카오톡으로 인가 코드 요청
          authCode = await AuthCodeClient.instance.authorizeWithTalk(
            redirectUri: redirectUri,
          );
        } else {
          // 웹뷰로 인가 코드 요청
          authCode = await AuthCodeClient.instance.authorize(
            redirectUri: redirectUri,
          );
        }

        // 인가 코드 출력
        debugPrint('인가 코드: $authCode');
        lastAuthCode = authCode;

        // 인가 코드를 서버로 전송
        bool loginSuccess = await sendAuthCodeToServer(authCode);

        // 로그인 실패 시 화면을 넘어가지 않음
        if (!loginSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('백엔드 로그인에 실패했습니다. 인가 코드: $authCode')),
            );
          }
          return false;
        }

        return true;
      } catch (e) {
        debugPrint('인가 코드 요청 실패: $e');
        rethrow;
      }
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

  // 기존 로그인 방식 (인가 코드 사용)
  Future<bool> signInWithKakao(BuildContext context) async {
    // 인가 코드 방식으로 로그인 시도
    return await signInWithKakaoAuthCode(context);
  }

  // 인가 코드를 서버로 전송하는 메서드
  Future<bool> sendAuthCodeToServer(String authCode) async {
    try {
      try {
        // 백엔드 서버로 카카오 인가 코드 전송 (/auth/login/kakao?code=인가코드 형식)
        final response = await _apiService.loginWithKakao(authCode);
        final name = response.data.name;
        // 백엔드 응답 구조 확인 (단순 로깅 목적)
        debugPrint('백엔드 응답: $response');
        final userInfo = UserInfo(name: name);

        // ✅ Provider 등에 저장하고 싶다면 (예시)
        _ref.read(loginInfoProvider.notifier).state = userInfo;
        return true;
      } catch (apiError) {
        debugPrint('API 호출 중 오류: $apiError');

        rethrow;
      }
    } catch (e) {
      debugPrint('백엔드 서버 통신 실패: $e');

      // JSON 형식 오류이지만 로그인 성공으로 처리
      if (e.toString().contains(
        'type \'Null\' is not a subtype of type \'Map<String, dynamic>\'',
      )) {
        debugPrint('JSON 형식 오류지만 로그인 성공으로 처리');

        return true;
      }

      // 인가 코드를 콘솔에 출력 (디버깅 목적)
      debugPrint('로그인 실패 시 인가 코드: $authCode');

      // 백엔드 통신 실패 시 false 반환 (화면 전환 방지)
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
