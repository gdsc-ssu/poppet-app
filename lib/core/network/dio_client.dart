import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/storage/secure_storage_utils.dart';

part 'dio_client.g.dart';

class DioClient {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl:
                'https://poppet-sol4-server-162314042262.asia-northeast3.run.app',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            validateStatus: (status) {
              debugPrint('🔍 응답 상태 코드: $status');
              return true;
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              // 동적 Authorization 설정
              final token = dio.options.headers['Authorization'];
              if (token != null) {
                options.headers['Authorization'] = token;
              }
              debugPrint('🔶 요청 URL: ${options.uri}');
              debugPrint('🔶 요청 헤더: ${options.headers}');
              debugPrint('🔶 요청 데이터: ${options.data}');
              return handler.next(options);
            },
            onResponse: (response, handler) async {
              debugPrint('🔷 응답 상태 코드: ${response.statusCode}');

              if (response.data != null) {
                try {
                  if (response.data is Map<String, dynamic>) {
                    final data = response.data as Map<String, dynamic>;

                    if (data.containsKey('accessToken')) {
                      debugPrint('🔑 응답에 accessToken 필드 발견!');
                    }
                    if (data.containsKey('token')) {
                      debugPrint('🔑 응답에 token 필드 발견!');
                    }
                    if (data.containsKey('data') &&
                        data['data'] is Map<String, dynamic>) {
                      final innerData = data['data'] as Map<String, dynamic>;
                      if (innerData.containsKey('accessToken')) {
                        debugPrint('🔑 응답 data 객체 내에 accessToken 필드 발견!');
                        if (innerData['accessToken'] is String) {
                          final preview = innerData['accessToken'].toString();
                          debugPrint(
                            '🔑 토큰 값 (미리보기): ${preview.substring(0, preview.length > 20 ? 20 : preview.length)}',
                          );
                        }
                      }
                    }
                  }

                  // 헤더에 포함된 JWT가 있으면 저장
                  if (response.headers.map.containsKey('authorization')) {
                    final newToken = response.headers['authorization']?.first;
                    if (newToken != null) {
                      final cleanToken =
                          newToken.replaceFirst('Bearer ', '').trim();
                      await SecureStorageUtils.setAccessToken(cleanToken);
                      await setToken(cleanToken);
                      debugPrint('🟢 서버 응답에 따라 토큰 갱신됨');
                    }
                  }
                } catch (e) {
                  debugPrint('⚠️ 응답 데이터 분석 중 오류: $e');
                }
              }

              if (response.statusCode == 403) {
                debugPrint('🚫 403 Forbidden: 인증 오류 발생. 토큰을 확인하세요.');
                debugPrint('🚫 요청 URL: ${response.requestOptions.uri}');
                debugPrint('🚫 요청 헤더: ${response.requestOptions.headers}');
              }

              return handler.next(response);
            },
            onError: (error, handler) async {
              if (error.response?.statusCode == 401) {
                try {
                  // 토큰 갱신 API 호출
                  final refreshToken =
                      await SecureStorageUtils.getRefreshToken();
                  if (refreshToken != null) {
                    // 토큰 갱신 API 호출
                    final response = await dio.post(
                      '/auth/refresh-token',
                      data: {'refreshToken': refreshToken},
                    );

                    if (response.statusCode == 200 &&
                        response.data['accessToken'] != null) {
                      // 새 토큰 저장
                      await SecureStorageUtils.setAccessToken(
                        response.data['accessToken'],
                      );
                      // 요청 재시도
                      return handler.resolve(
                        await dio.fetch(error.requestOptions),
                      );
                    }
                  }
                } catch (e) {
                  // 토큰 갱신 실패, 로그인 화면으로 리다이렉트 필요
                }
              }
              return handler.next(error);
            },
          ),
        )
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            error: true,
            compact: false,
          ),
        );

  static Future<void> setToken(String? token) async {
    if (token != null && token.trim().isNotEmpty) {
      final clean = token.trim();
      final bearer = clean.startsWith('Bearer ') ? clean : 'Bearer $clean';
      dio.options.headers['Authorization'] = bearer;
      debugPrint(
        '🔑 인증 헤더 설정됨: ${bearer.substring(0, bearer.length > 30 ? 30 : bearer.length)}...',
      );
    } else {
      dio.options.headers.remove('Authorization');
      debugPrint('⚠️ 토큰이 없어 Authorization 헤더가 제거됨');
    }
  }
}

@riverpod
Dio dioClient(DioClientRef ref) {
  return DioClient.dio;
}
