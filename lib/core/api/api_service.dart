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

  @POST('/auth/login/kakao')
  Future<AuthResponse> loginWithKakao(@Body() Map<String, String> loginData);
  @POST('/auth/login/google')
  Future<AuthResponse> loginWithGoogle(@Body() Map<String, String> loginData);
    @POST('/auth/login/apple/mobile')
  Future<AuthResponse> loginWithApple(@Body() Map<String, String> loginData);


  @GET('/user/me')
  Future<UserInfo> getUserInfo();

  @POST('/chats')
  @MultiPart()
  Future<ChatResponse> createChat({
    @Part(name: 'chat') required List<MultipartFile> chat,
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
  Future<dynamic> getEmailPeriod();

  @PATCH('/emails/period')
  Future<dynamic> updateEmailPeriod({@Query('period') required int period});

  @GET('/emails')
  Future<EmailResponse> getUserEmail();

  @DELETE('/emails/{id}')
  Future<CommonResponse> deleteUserEmail({@Path("id") required int id});

  @POST('/emails')
  Future<dynamic> addEmail({@Body() required Map<String, dynamic> data});
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

class CommonResponse {
  final bool isSuccess;
  final int code;
  final String message;

  CommonResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
  });

  factory CommonResponse.fromJson(Map<String, dynamic> json) {
    return CommonResponse(
      isSuccess: json['is_success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
