import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet/core/api/api_service.dart';

final loginInfoProvider = StateNotifierProvider<LoginInfoNotifier, UserInfo?>((
  ref,
) {
  return LoginInfoNotifier();
});

class LoginInfoNotifier extends StateNotifier<UserInfo?> {
  LoginInfoNotifier() : super(null);

  void setLoginInfo(UserInfo userInfo) {
    state = userInfo;
  }

  void clearLoginInfo() {
    state = null;
  }
}
