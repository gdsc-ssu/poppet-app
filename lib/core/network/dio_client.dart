import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

class DioClient {
  static final Dio dio = Dio(
      BaseOptions(
        baseUrl:
            'https://api.example.com', // TODO: Replace with your API base URL
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
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
