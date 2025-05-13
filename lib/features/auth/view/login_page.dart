import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../provider/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // 로그인 상태가 변경되면 홈 화면으로 이동
    ref.listen(authStateProvider, (previous, current) {
      // 현재 상태가 인증됨인 경우 홈으로 이동
      if (current.isAuthenticated && !current.isLoading) {
        // 로그인 성공 시 항상 홈으로 이동
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Text(
                '서비스 핵심 소개\n한 문장, POPPET',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/images/basicpopet.png',
                  width: 366.w,
                  height: 366.h,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (!authState.isGoogleLoading) {
                    ref
                        .read(authStateProvider.notifier)
                        .signInWithGoogle(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child:
                      authState.isGoogleLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF191919),
                            ),
                          )
                          : Row(
                            children: [
                              SizedBox(width: 23.w),
                              Image.asset(
                                'assets/images/googleLogo.png',
                                width: 24.w,
                                height: 24.w,
                              ),
                              Expanded(
                                child: Text(
                                  'Google 계정으로 로그인하기',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 23.w),
                            ],
                          ),
                ),
              ),
              Container(height: 10.h),
              InkWell(
                onTap: () {
                  // 카카오 로그인 실행 (인가 코드 방식)
                  if (!authState.isKakaoLoading) {
                    ref
                        .read(authStateProvider.notifier)
                        .signInWithKakao(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE500),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child:
                      authState.isKakaoLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF191919),
                            ),
                          )
                          : Row(
                            children: [
                              SizedBox(width: 23.w),
                              Image.asset(
                                'assets/images/kakao.png',
                                width: 18.w,
                                height: 18.w,
                              ),
                              Expanded(
                                child: Text(
                                  '카카오로 로그인하기',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 23.w),
                            ],
                          ),
                ),
              ),
              SizedBox(height: 78.h),
            ],
          ),
        ),
      ),
    );
  }
}
