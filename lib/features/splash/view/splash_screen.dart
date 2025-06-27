import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 페이드 인 애니메이션 설정
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 애니메이션 시작
    _controller.forward();

    // 자동 로그인 체크 및 화면 이동
    _checkAutoLoginAndNavigate();
  }

  Future<void> _checkAutoLoginAndNavigate() async {
    // 애니메이션이 완료될 때까지 기다림
    await _controller.forward();

    // 최소 스플래시 표시 시간 보장
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // 자동 로그인 체크
    await ref.read(authStateProvider.notifier).checkAutoLogin();

    if (!mounted) return;

    // 인증 상태에 따라 화면 이동
    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2), // 크림색 배경
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고와 말풍선 아이콘을 포함하는 스택

              // 로고 이미지
              Image.asset(
                'assets/images/splash/PoppetLogo.png',
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 20), // 로고와 텍스트 사이 간격
              // 텍스트 이미지
              Image.asset(
                'assets/images/splash/PoppetText.png',
                width: 180,
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
