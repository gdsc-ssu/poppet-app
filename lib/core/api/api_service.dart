import 'package:dio/dio.dart';
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

  @POST('/auth/kakao')
  Future<AuthResponse> oAuthKakao(@Body() Map<String, dynamic> data);

  @GET('/user/me')
  Future<UserInfo> getUserInfo();

  @POST('/chats')
  @MultiPart()
  Future<ChatResponse> createChat({
    @Query('chat') required String fileNames,
    @Part(name: 'chat') required List<MultipartFile> files,
  });

  @PATCH('/chats/{chatId}')
  Future<ChatResponse> updateChat(
    @Path() String chatId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/chats/{chatId}/name')
  Future<ChatResponse> setChatName({
    @Path() required String chatId,
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
  final AccessToken accessToken;

  AuthResponse({required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(accessToken: AccessToken.fromJson(json['accessToken']));
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
  final String id;
  final String name;
  final String? email;
  final String? profileImage;

  UserInfo({
    required this.id,
    required this.name,
    this.email,
    this.profileImage,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }
}
