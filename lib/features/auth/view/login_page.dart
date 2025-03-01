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
      // 이전 상태가 로딩 중이었고, 현재 상태가 인증됨인 경우에만 홈으로 이동
      if (previous != null &&
          previous.isLoading &&
          !current.isLoading &&
          current.isAuthenticated) {
        // 사용자 정보 로그 출력
        final user = current.user;
        debugPrint('로그인 성공: 사용자 정보');
        debugPrint('ID: ${user?.id}');
        debugPrint('닉네임: ${user?.kakaoAccount?.profile?.nickname}');
        debugPrint('이메일: ${user?.kakaoAccount?.email}');
        debugPrint('프로필 이미지: ${user?.kakaoAccount?.profile?.profileImageUrl}');
        debugPrint('성별: ${user?.kakaoAccount?.gender}');
        debugPrint('연령대: ${user?.kakaoAccount?.ageRange}');
        debugPrint('전체 정보: $user');

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
                  'assets/images/poppet.png',
                  width: 240.w,
                  height: 240.h,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  // 카카오 로그인 실행
                  ref.read(authStateProvider.notifier).loginWithKakao();
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE500),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child:
                      authState.isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF191919),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/kakao.png',
                                width: 24.w,
                                height: 24.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '카카오로 로그인하기',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF191919),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
