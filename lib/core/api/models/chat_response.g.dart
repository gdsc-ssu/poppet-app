// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatResponseImpl _$$ChatResponseImplFromJson(Map<String, dynamic> json) =>
    _$ChatResponseImpl(
      id: json['id'] as String,
      message: json['message'] as String,
      audioUrl: json['audioUrl'] as String?,
      chat: (json['chat'] as List<dynamic>?)
          ?.map((e) => ChatItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$ChatResponseImplToJson(_$ChatResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'audioUrl': instance.audioUrl,
      'chat': instance.chat,
      'name': instance.name,
    };

_$ChatItemImpl _$$ChatItemImplFromJson(Map<String, dynamic> json) =>
    _$ChatItemImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ChatItemImplToJson(_$ChatItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'type': instance.type,
      'audioUrl': instance.audioUrl,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
