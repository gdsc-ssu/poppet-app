// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) {
  return _ChatResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatResponse {
  String get id => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  List<ChatItem>? get chat => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this ChatResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatResponseCopyWith<ChatResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatResponseCopyWith<$Res> {
  factory $ChatResponseCopyWith(
          ChatResponse value, $Res Function(ChatResponse) then) =
      _$ChatResponseCopyWithImpl<$Res, ChatResponse>;
  @useResult
  $Res call(
      {String id,
      String message,
      String? audioUrl,
      List<ChatItem>? chat,
      String? name});
}

/// @nodoc
class _$ChatResponseCopyWithImpl<$Res, $Val extends ChatResponse>
    implements $ChatResponseCopyWith<$Res> {
  _$ChatResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? audioUrl = freezed,
    Object? chat = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      chat: freezed == chat
          ? _value.chat
          : chat // ignore: cast_nullable_to_non_nullable
              as List<ChatItem>?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatResponseImplCopyWith<$Res>
    implements $ChatResponseCopyWith<$Res> {
  factory _$$ChatResponseImplCopyWith(
          _$ChatResponseImpl value, $Res Function(_$ChatResponseImpl) then) =
      __$$ChatResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String message,
      String? audioUrl,
      List<ChatItem>? chat,
      String? name});
}

/// @nodoc
class __$$ChatResponseImplCopyWithImpl<$Res>
    extends _$ChatResponseCopyWithImpl<$Res, _$ChatResponseImpl>
    implements _$$ChatResponseImplCopyWith<$Res> {
  __$$ChatResponseImplCopyWithImpl(
      _$ChatResponseImpl _value, $Res Function(_$ChatResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? audioUrl = freezed,
    Object? chat = freezed,
    Object? name = freezed,
  }) {
    return _then(_$ChatResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      chat: freezed == chat
          ? _value._chat
          : chat // ignore: cast_nullable_to_non_nullable
              as List<ChatItem>?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatResponseImpl implements _ChatResponse {
  const _$ChatResponseImpl(
      {required this.id,
      required this.message,
      this.audioUrl,
      final List<ChatItem>? chat,
      this.name})
      : _chat = chat;

  factory _$ChatResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String message;
  @override
  final String? audioUrl;
  final List<ChatItem>? _chat;
  @override
  List<ChatItem>? get chat {
    final value = _chat;
    if (value == null) return null;
    if (_chat is EqualUnmodifiableListView) return _chat;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? name;

  @override
  String toString() {
    return 'ChatResponse(id: $id, message: $message, audioUrl: $audioUrl, chat: $chat, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            const DeepCollectionEquality().equals(other._chat, _chat) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, message, audioUrl,
      const DeepCollectionEquality().hash(_chat), name);

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      __$$ChatResponseImplCopyWithImpl<_$ChatResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatResponseImplToJson(
      this,
    );
  }
}

abstract class _ChatResponse implements ChatResponse {
  const factory _ChatResponse(
      {required final String id,
      required final String message,
      final String? audioUrl,
      final List<ChatItem>? chat,
      final String? name}) = _$ChatResponseImpl;

  factory _ChatResponse.fromJson(Map<String, dynamic> json) =
      _$ChatResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get message;
  @override
  String? get audioUrl;
  @override
  List<ChatItem>? get chat;
  @override
  String? get name;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatItem _$ChatItemFromJson(Map<String, dynamic> json) {
  return _ChatItem.fromJson(json);
}

/// @nodoc
mixin _$ChatItem {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ChatItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatItemCopyWith<ChatItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatItemCopyWith<$Res> {
  factory $ChatItemCopyWith(ChatItem value, $Res Function(ChatItem) then) =
      _$ChatItemCopyWithImpl<$Res, ChatItem>;
  @useResult
  $Res call(
      {String id,
      String content,
      String type,
      String? audioUrl,
      String? imageUrl,
      DateTime? createdAt});
}

/// @nodoc
class _$ChatItemCopyWithImpl<$Res, $Val extends ChatItem>
    implements $ChatItemCopyWith<$Res> {
  _$ChatItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? type = null,
    Object? audioUrl = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatItemImplCopyWith<$Res>
    implements $ChatItemCopyWith<$Res> {
  factory _$$ChatItemImplCopyWith(
          _$ChatItemImpl value, $Res Function(_$ChatItemImpl) then) =
      __$$ChatItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      String type,
      String? audioUrl,
      String? imageUrl,
      DateTime? createdAt});
}

/// @nodoc
class __$$ChatItemImplCopyWithImpl<$Res>
    extends _$ChatItemCopyWithImpl<$Res, _$ChatItemImpl>
    implements _$$ChatItemImplCopyWith<$Res> {
  __$$ChatItemImplCopyWithImpl(
      _$ChatItemImpl _value, $Res Function(_$ChatItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? type = null,
    Object? audioUrl = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ChatItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatItemImpl implements _ChatItem {
  const _$ChatItemImpl(
      {required this.id,
      required this.content,
      required this.type,
      this.audioUrl,
      this.imageUrl,
      this.createdAt});

  factory _$ChatItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatItemImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final String type;
  @override
  final String? audioUrl;
  @override
  final String? imageUrl;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ChatItem(id: $id, content: $content, type: $type, audioUrl: $audioUrl, imageUrl: $imageUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, content, type, audioUrl, imageUrl, createdAt);

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatItemImplCopyWith<_$ChatItemImpl> get copyWith =>
      __$$ChatItemImplCopyWithImpl<_$ChatItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatItemImplToJson(
      this,
    );
  }
}

abstract class _ChatItem implements ChatItem {
  const factory _ChatItem(
      {required final String id,
      required final String content,
      required final String type,
      final String? audioUrl,
      final String? imageUrl,
      final DateTime? createdAt}) = _$ChatItemImpl;

  factory _ChatItem.fromJson(Map<String, dynamic> json) =
      _$ChatItemImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  String get type;
  @override
  String? get audioUrl;
  @override
  String? get imageUrl;
  @override
  DateTime? get createdAt;

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatItemImplCopyWith<_$ChatItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
