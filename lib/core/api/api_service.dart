import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<AuthResponse> oAuthKakao(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/kakao', data: data);
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('카카오 로그인 실패: $e');
    }
  }

  Future<UserInfo> getUserInfo() async {
    try {
      final response = await _dio.get('/user/me');
      return UserInfo.fromJson(response.data);
    } catch (e) {
      throw Exception('사용자 정보 가져오기 실패: $e');
    }
  }
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
