import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../service/kakao_auth_service.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final kakaoAuthService = ref.watch(kakaoAuthServiceProvider);
  return AuthNotifier(kakaoAuthService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final KakaoAuthService _kakaoAuthService;

  AuthNotifier(this._kakaoAuthService) : super(AuthState.unauthenticated());

  Future<void> loginWithKakao() async {
    state = AuthState.loading();

    final user = await _kakaoAuthService.login();

    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> logout() async {
    await _kakaoAuthService.logout();
    state = AuthState.unauthenticated();
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
  });

  factory AuthState.unauthenticated() {
    return AuthState(isAuthenticated: false, isLoading: false);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(isAuthenticated: true, isLoading: false, user: user);
  }

  factory AuthState.loading() {
    return AuthState(isAuthenticated: false, isLoading: true);
  }
}
