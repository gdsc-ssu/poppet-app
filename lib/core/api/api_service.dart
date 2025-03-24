import 'package:dio/dio.dart';
import 'package:pet/core/api/email_repository.dart';
import 'package:retrofit/retrofit.dart';
import 'package:pet/core/api/models/auth_response.dart';
import 'package:pet/core/api/models/user_info.dart';
import 'package:pet/core/api/models/chat_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/network/dio_client.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  @GET('/auth/login/kakao')
  Future<AuthResponse> loginWithKakao(@Query('code') String code);

  @GET('/user/me')
  Future<UserInfo> getUserInfo();

  @POST('/chats')
  @MultiPart()
  Future<ChatResponse> createChat({
    @Part(name: 'chat') required List<MultipartFile> chat,
    @Query('name') String? name,
  });

  @PATCH('/chats/{chatId}')
  Future<ChatResponse> updateChat(
    @Path('chatId') String chatId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/chats/{chatId}/name')
  Future<ChatResponse> setChatName({
    @Path('chatId') required String chatId,
    @Body() required Map<String, dynamic> data,
  });

  @GET('/emails/period')
  Future<dynamic> getEmailPeriod({@Query('name') required String name});

  @PATCH('/emails/period')
  Future<dynamic> updateEmailPeriod({
    @Query('name') required String name,
    @Query('period') required int period,
  });

  @GET('/emails')
  Future<EmailResponse> getUserEmail({@Query('name') required String name});

  @POST('/emails')
  Future<dynamic> addEmail({
    @Query('name') required String name,
    @Body() required Map<String, dynamic> data,
  });
}

@riverpod
ApiService apiService(ApiServiceRef ref) {
  final dio = ref.watch(dioClientProvider);
  return ApiService(dio);
}

class AuthResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final Data data;

  AuthResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      isSuccess: json['is_success'],
      code: json['code'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }

  @override
  String toString() {
    return 'AuthResponse(isSuccess: $isSuccess, code: $code, message: $message, data: $data)';
  }
}

class Data {
  final String name;

  Data({required this.name});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(name: json['name']);
  }

  @override
  String toString() {
    return 'Data(name: $name)';
  }
}

class AccessToken {
  final String token;

  AccessToken({required this.token});

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(token: json['token']);
  }
}

class UserInfo {
  final String name;

  UserInfo({required this.name});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(name: json['name']);
  }
}
