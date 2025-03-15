import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';
part 'auth_response.freezed.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({required AccessToken accessToken}) =
      _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class AccessToken with _$AccessToken {
  const factory AccessToken({required String token}) = _AccessToken;

  factory AccessToken.fromJson(Map<String, dynamic> json) =>
      _$AccessTokenFromJson(json);
}
