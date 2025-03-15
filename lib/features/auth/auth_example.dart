import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet/core/api/auth_repository.dart';
import 'package:pet/core/api/models/user_info.dart';

class AuthExample extends ConsumerWidget {
  const AuthExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('API 통신 예제')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // 카카오 로그인 예제
                // 실제로는 카카오 SDK를 통해 토큰을 얻어와야 합니다.
                final authRepository = ref.read(authRepositoryProvider);
                final success = await authRepository.loginWithKakao(
                  '카카오_액세스_토큰',
                );

                if (success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('로그인 성공!')));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('로그인 실패!')));
                }
              },
              child: const Text('카카오 로그인'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 사용자 정보 가져오기 예제
                final authRepository = ref.read(authRepositoryProvider);
              },
              child: const Text('사용자 정보 가져오기'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 로그아웃 예제
                final authRepository = ref.read(authRepositoryProvider);
                await authRepository.logout();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('로그아웃 완료!')));
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
