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
      body: Column(
        children: [
          // 상단 텍스트 영역
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Text(
              '마이크 버튼을 누르고\n대화를 나눠보세요.',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
                height: 1.4,
              ),
            ),
          ),

          // 캐릭터 이미지 영역 (확장 가능하도록 Expanded 사용)
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/poppet.png', // 기존 이미지 사용
                width: 240.w,
              ),
            ),
          ),

          // 마이크 버튼 영역
          Container(
            width: double.infinity,
            height: 180.h,
            decoration: BoxDecoration(
              color: Color(0xFFF8D3B0), // 연한 살구색
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.r),
                topRight: Radius.circular(40.r),
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: () => viewModel.toggleRecording(),
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary, width: 2.w),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/microphone.png',
                      width: 50.w,
                      height: 50.h,
                      color: AppColors.primary,
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
