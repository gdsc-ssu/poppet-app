import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/mypage/view/mypage_page.dart';
import '../../features/onboarding/view/onboarding_page.dart';
import '../../features/settings/view/email_setting_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/mypage', builder: (context, state) => const MyPagePage()),
      GoRoute(
        path: '/email-setting',
        builder: (context, state) => const EmailSettingPage(),
      ),
    ],
  );
}
