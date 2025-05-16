// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) =>
    _ChatResponse(
      is_success: json['is_success'] as bool,
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$ChatResponseToJson(_ChatResponse instance) =>
    <String, dynamic>{
      'is_success': instance.is_success,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

_ChatItem _$ChatItemFromJson(Map<String, dynamic> json) => _ChatItem(
  id: json['id'] as String,
  content: json['content'] as String,
  type: json['type'] as String,
  audioUrl: json['audioUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ChatItemToJson(_ChatItem instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'type': instance.type,
  'audioUrl': instance.audioUrl,
  'imageUrl': instance.imageUrl,
  'createdAt': instance.createdAt?.toIso8601String(),
};
