import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';
part 'user_info.freezed.dart';

@freezed
abstract class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String id,
    required String name,
    String? email,
    String? profileImage,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}
