import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';

import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';

class MyPagePage extends ConsumerWidget {
  const MyPagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('마이페이지', style: AppTextStyle.pretendard_32_bold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            // User Profile Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(24.sp),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 2,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.sp,
                      bottom: 30.sp,
                      left: 8.sp,
                      right: 24.sp,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/poppet.png', width: 100.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '안녕하세요,',
                              style: AppTextStyle.pretendard_18_regular,
                            ),
                            SizedBox(height: 4.sp),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4.sp,
                              children: [
                                Text(
                                  '할머니',
                                  style: AppTextStyle.pretendard_32_bold
                                      .copyWith(color: AppColors.primary),
                                ),
                                Text(
                                  '님',
                                  style: AppTextStyle.pretendard_18_regular
                                      .copyWith(color: AppColors.darkGrey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(265.w, 40.h),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      '보호자 이메일 변경',
                      style: AppTextStyle.pretendard_18_medium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            // Menu Items
            _buildMenuItem(
              title: '개인정보처리방침',
              onTap: () => showPrivacyPolicy(context),
            ),
            SizedBox(height: 24.h),
            _buildMenuItem(
              title: '이용약관',
              onTap: () => showTermsOfService(context),
            ),
            SizedBox(height: 24.h),
            _buildMenuItem(
              title: '로그아웃',
              onTap: () {
                context.go('/login');
              },
            ),
            SizedBox(height: 24.h),
            _buildMenuItem(title: '회원탈퇴', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppTextStyle.pretendard_18_medium.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
