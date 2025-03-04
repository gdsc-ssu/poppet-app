import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../view_model/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final recordingState = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'POPPET',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person_outline,
                color: AppColors.darkGrey,
              ),
            ),
            onPressed: () {
              context.push('/mypage');
            },
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // 상단 텍스트 영역
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '마이크 버튼을 누르고\n대화를 나눠보세요.',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // 캐릭터 이미지 영역 (확장 가능하도록 Expanded 사용)
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/poppet.png', // 기존 이미지 사용
                    width: 366.w,
                  ),
                ),
              ),

              Container(
                width: 393.w,
                height: 160.h,
                child: Stack(
                  children: [
                    // 타원 배경 (겹침 없음)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 393.w,
                        height: 160.h,
                        decoration: ShapeDecoration(
                          color: Color(0xFFfbb279), // 동일한 살구색
                          shape: OvalBorder(),
                        ),
                      ),
                    ),

                    // 하단 직사각형 부분 (겹침 없이 따로 적용)
                    Positioned(
                      left: 0,
                      top: 100, // 적절한 위치 조정
                      child: Container(
                        width: 393.w,
                        height: 100.h, // 겹치는 부분을 제거하도록 조정
                        color: Color(0xFFfbb279), // 동일한 색상
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 마이크 버튼 - 최상단에 위치
          Positioned(
            top: 500.sp,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 157.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => viewModel.toggleRecording(),
                    customBorder: CircleBorder(),
                    child: Center(
                      child: Image.asset(
                        'assets/images/microphone.png',
                        width: 61.w,
                        height: 86.h,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
