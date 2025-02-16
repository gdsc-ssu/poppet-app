import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/mypage/view/mypage_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            path: 'mypage',
            builder: (context, state) => const MyPagePage(),
          ),
        ],
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  );
}
