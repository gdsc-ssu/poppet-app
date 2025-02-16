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
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.grey[200],
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              viewModel.isRecording
                  ? '음성을 녹음하고 있어요.\n정지 버튼을 누르면 저장돼요.'
                  : '마이크 버튼을 누르고\n대화를 나눠보세요.',
              style: AppTextStyle.pretendard_16_regular.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 24.h),

            Center(
              child: Image.asset(
                'assets/images/hamoPoppet.png',
                width: 200.w,
                height: 200.h,
              ),
            ),
            SizedBox(height: 40.h),
            Center(
              child: Column(
                children: [
                  Text(
                    viewModel.isRecording ? viewModel.elapsedTime : '녹음 대기 중',
                    style: AppTextStyle.pretendard_16_regular.copyWith(
                      color:
                          viewModel.isRecording
                              ? AppColors.accent
                              : AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          viewModel.isRecording
                              ? AppColors.accent
                              : AppColors.primary,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => viewModel.toggleRecording(),
                        customBorder: const CircleBorder(),
                        child: Icon(
                          viewModel.isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
