import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import '../../../core/api/email_repository.dart';
import '../../../core/provider/login_provider.dart';

part 'email_setting_view_model.g.dart';

// 이메일 설정 상태를 관리하는 Provider
final emailSettingProvider =
    StateNotifierProvider<EmailSettingNotifier, List<String>>(
      (ref) => EmailSettingNotifier(),
    );

// 이메일 발송 주기를 관리하는 Provider
final emailFrequencyProvider =
    StateNotifierProvider<EmailFrequencyNotifier, int>(
      (ref) => EmailFrequencyNotifier(),
    );

class EmailFrequencyNotifier extends StateNotifier<int> {
  static const String _frequencyKey = 'email_frequency';

  EmailFrequencyNotifier() : super(7) {
    // 기본값 7일
    _loadFrequency();
  }

  Future<void> _loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final frequency = prefs.getInt(_frequencyKey) ?? 7;
    state = frequency;
  }

  Future<void> saveFrequency(int days) async {
    state = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_frequencyKey, days);
  }
}

class EmailSettingNotifier extends StateNotifier<List<String>> {
  static const String _emailsKey = 'guardian_emails';

  EmailSettingNotifier() : super([]) {
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList(_emailsKey) ?? [];
    state = emails;
  }

  Future<void> addEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) return;

    if (!state.contains(email)) {
      final newState = [...state, email];
      state = newState;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_emailsKey, newState);
    }
  }

  Future<void> removeEmail(String email) async {
    if (state.contains(email)) {
      final newState = [...state]..remove(email);
      state = newState;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_emailsKey, newState);
    }
  }

  Future<void> saveEmails(List<String> emails) async {
    state = emails;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_emailsKey, emails);
  }
}

@riverpod
class EmailSettingViewModel extends _$EmailSettingViewModel {
  String? _userEmail;
  bool _buttonEnabled = false;

  @override
  Future<void> build() async {
    _fetchUserEmail();
  }

  /// 로그인한 사용자의 이메일 가져오기
  Future<void> _fetchUserEmail() async {
    try {
      final loginInfo = ref.read(loginInfoProvider);
      if (loginInfo != null && loginInfo.name.isNotEmpty) {
        final emailRepository = ref.read(emailRepositoryProvider);

        // API 호출을 통해 이메일 가져오기
        final email = await emailRepository.getUserEmail(loginInfo.name);

        if (email != null) {
          debugPrint('사용자 이메일: $email');
          _userEmail = email;
          state = AsyncValue.data(null); // 상태 업데이트
        } else {
          debugPrint('사용자 이메일을 가져오지 못했습니다.');
        }
      } else {
        debugPrint('로그인 정보가 없습니다.');
      }
    } catch (e) {
      debugPrint('이메일 가져오기 중 오류: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 현재 저장된 이메일 반환
  String? get userEmail => _userEmail;

  bool get buttonEnabled => _buttonEnabled;

  void updateButtonState(bool enabled) {
    _buttonEnabled = enabled;
    state = AsyncData(null);
  }

  Future<void> saveEmail(String email) async {
    state = const AsyncLoading();

    try {
      final loginInfo = ref.read(loginInfoProvider);
      if (loginInfo == null) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final emailRepository = ref.read(emailRepositoryProvider);
      final savedEmail = await emailRepository.getUserEmail(loginInfo.name);

      if (savedEmail != email) {
        // 이메일이 변경된 경우에만 저장
        // TODO: 이메일 저장 API 구현 필요
      }

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
