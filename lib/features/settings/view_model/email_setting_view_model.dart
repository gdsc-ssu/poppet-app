import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
