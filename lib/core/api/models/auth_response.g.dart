// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      accessToken:
          AccessToken.fromJson(json['accessToken'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
    };

_$AccessTokenImpl _$$AccessTokenImplFromJson(Map<String, dynamic> json) =>
    _$AccessTokenImpl(
      token: json['token'] as String,
    );

Map<String, dynamic> _$$AccessTokenImplToJson(_$AccessTokenImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
    };
