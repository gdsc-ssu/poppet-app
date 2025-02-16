import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mypage_view_model.g.dart';

@riverpod
class MyPageViewModel extends _$MyPageViewModel {
  @override
  Future<void> build() async {
    // Initialize your state here
  }

  Future<void> logout() async {
    // Implement logout logic here
    // Clear user session, tokens, etc.
  }

  Future<void> updateUserProfile() async {
    // Implement profile update logic here
  }
}
