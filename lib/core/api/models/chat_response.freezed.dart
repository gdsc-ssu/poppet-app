// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatResponse {

 bool get is_success; int get code; String get message; String? get data;
/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatResponseCopyWith<ChatResponse> get copyWith => _$ChatResponseCopyWithImpl<ChatResponse>(this as ChatResponse, _$identity);

  /// Serializes this ChatResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatResponse&&(identical(other.is_success, is_success) || other.is_success == is_success)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,is_success,code,message,data);

@override
String toString() {
  return 'ChatResponse(is_success: $is_success, code: $code, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatResponseCopyWith<$Res>  {
  factory $ChatResponseCopyWith(ChatResponse value, $Res Function(ChatResponse) _then) = _$ChatResponseCopyWithImpl;
@useResult
$Res call({
 bool is_success, int code, String message, String? data
});




}
/// @nodoc
class _$ChatResponseCopyWithImpl<$Res>
    implements $ChatResponseCopyWith<$Res> {
  _$ChatResponseCopyWithImpl(this._self, this._then);

  final ChatResponse _self;
  final $Res Function(ChatResponse) _then;

/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? is_success = null,Object? code = null,Object? message = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
is_success: null == is_success ? _self.is_success : is_success // ignore: cast_nullable_to_non_nullable
as bool,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ChatResponse implements ChatResponse {
  const _ChatResponse({required this.is_success, required this.code, required this.message, this.data});
  factory _ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);

@override final  bool is_success;
@override final  int code;
@override final  String message;
@override final  String? data;

/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatResponseCopyWith<_ChatResponse> get copyWith => __$ChatResponseCopyWithImpl<_ChatResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatResponse&&(identical(other.is_success, is_success) || other.is_success == is_success)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,is_success,code,message,data);

@override
String toString() {
  return 'ChatResponse(is_success: $is_success, code: $code, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class _$ChatResponseCopyWith<$Res> implements $ChatResponseCopyWith<$Res> {
  factory _$ChatResponseCopyWith(_ChatResponse value, $Res Function(_ChatResponse) _then) = __$ChatResponseCopyWithImpl;
@override @useResult
$Res call({
 bool is_success, int code, String message, String? data
});




}
/// @nodoc
class __$ChatResponseCopyWithImpl<$Res>
    implements _$ChatResponseCopyWith<$Res> {
  __$ChatResponseCopyWithImpl(this._self, this._then);

  final _ChatResponse _self;
  final $Res Function(_ChatResponse) _then;

/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? is_success = null,Object? code = null,Object? message = null,Object? data = freezed,}) {
  return _then(_ChatResponse(
is_success: null == is_success ? _self.is_success : is_success // ignore: cast_nullable_to_non_nullable
as bool,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatItem {

 String get id; String get content; String get type; String? get audioUrl; String? get imageUrl; DateTime? get createdAt;
/// Create a copy of ChatItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatItemCopyWith<ChatItem> get copyWith => _$ChatItemCopyWithImpl<ChatItem>(this as ChatItem, _$identity);

  /// Serializes this ChatItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatItem&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,type,audioUrl,imageUrl,createdAt);

@override
String toString() {
  return 'ChatItem(id: $id, content: $content, type: $type, audioUrl: $audioUrl, imageUrl: $imageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatItemCopyWith<$Res>  {
  factory $ChatItemCopyWith(ChatItem value, $Res Function(ChatItem) _then) = _$ChatItemCopyWithImpl;
@useResult
$Res call({
 String id, String content, String type, String? audioUrl, String? imageUrl, DateTime? createdAt
});




}
/// @nodoc
class _$ChatItemCopyWithImpl<$Res>
    implements $ChatItemCopyWith<$Res> {
  _$ChatItemCopyWithImpl(this._self, this._then);

  final ChatItem _self;
  final $Res Function(ChatItem) _then;

/// Create a copy of ChatItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? type = null,Object? audioUrl = freezed,Object? imageUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ChatItem implements ChatItem {
  const _ChatItem({required this.id, required this.content, required this.type, this.audioUrl, this.imageUrl, this.createdAt});
  factory _ChatItem.fromJson(Map<String, dynamic> json) => _$ChatItemFromJson(json);

@override final  String id;
@override final  String content;
@override final  String type;
@override final  String? audioUrl;
@override final  String? imageUrl;
@override final  DateTime? createdAt;

/// Create a copy of ChatItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatItemCopyWith<_ChatItem> get copyWith => __$ChatItemCopyWithImpl<_ChatItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatItem&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,type,audioUrl,imageUrl,createdAt);

@override
String toString() {
  return 'ChatItem(id: $id, content: $content, type: $type, audioUrl: $audioUrl, imageUrl: $imageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatItemCopyWith<$Res> implements $ChatItemCopyWith<$Res> {
  factory _$ChatItemCopyWith(_ChatItem value, $Res Function(_ChatItem) _then) = __$ChatItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String type, String? audioUrl, String? imageUrl, DateTime? createdAt
});




}
/// @nodoc
class __$ChatItemCopyWithImpl<$Res>
    implements _$ChatItemCopyWith<$Res> {
  __$ChatItemCopyWithImpl(this._self, this._then);

  final _ChatItem _self;
  final $Res Function(_ChatItem) _then;

/// Create a copy of ChatItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? type = null,Object? audioUrl = freezed,Object? imageUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_ChatItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
