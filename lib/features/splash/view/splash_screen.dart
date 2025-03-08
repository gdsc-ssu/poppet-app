import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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

    // 스플래시 화면 지속 시간 후 다음 화면으로 이동
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/');
      }
    });
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
