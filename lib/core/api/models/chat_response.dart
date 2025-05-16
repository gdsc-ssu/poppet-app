import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_response.g.dart';
part 'chat_response.freezed.dart';

@freezed
abstract class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    required bool is_success,
    required int code,
    required String message,
    String? data,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
}

@freezed
abstract class ChatItem with _$ChatItem {
  const factory ChatItem({
    required String id,
    required String content,
    required String type,
    String? audioUrl,
    String? imageUrl,
    DateTime? createdAt,
  }) = _ChatItem;

  factory ChatItem.fromJson(Map<String, dynamic> json) =>
      _$ChatItemFromJson(json);
}
