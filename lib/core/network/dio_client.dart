import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

class DioClient {
  static final Dio dio = Dio(
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
      ),
    )
    ..interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );

  static Future<void> setToken(String token) async {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}

@riverpod
Dio dioClient(DioClientRef ref) {
  return DioClient.dio;
}
