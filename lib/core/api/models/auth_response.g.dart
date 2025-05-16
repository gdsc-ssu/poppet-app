// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      accessToken: AccessToken.fromJson(
        json['accessToken'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{'accessToken': instance.accessToken};

_AccessToken _$AccessTokenFromJson(Map<String, dynamic> json) =>
    _AccessToken(token: json['token'] as String);

Map<String, dynamic> _$AccessTokenToJson(_AccessToken instance) =>
    <String, dynamic>{'token': instance.token};
