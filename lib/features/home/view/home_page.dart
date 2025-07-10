import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';

import '../view_model/home_view_model.dart';
import 'package:lottie/lottie.dart';

// 오디오 재생 중인지 관리하는 Providerr
final isPlayingAudioProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final recordState = ref.watch(recordingStateProvider);
    final isPlayingAudio = ref.watch(isPlayingAudioProvider);

    // 텍스트 상태
    String statusText = switch (recordState) {
      RecordingState.uploaded => '뽀삐가 대답하는 중이에요',
      RecordingState.recording => '대화를 그만하고 싶다면\n중지 버튼을 눌러주세요',
      RecordingState.uploading => '뽀삐가 대답을\n생각하는 중이에요',
      RecordingState.initial => '마이크 버튼을 누르고\n대화를 나눠보세요.',
      _ => '대기 중...',
    };
    

    // 이미지 상태
    String imagePath = switch (recordState) {
      RecordingState.recording => 'assets/images/listenPoppet.png',
      RecordingState.uploading => 'assets/images/poppet2.png',
      _ => 'assets/images/basicpopet.png',
    };

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SizedBox(
          width: 120.w,
          height: 30.h,
          child: Image.asset('assets/images/splash/PoppetText.png'),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/mypage.png',
              width: 40.w,
              height: 40.h,
            ),
            onPressed: () => context.push('/mypage'),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // 텍스트 영역
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 34.h, left: 32.w),
                child: Text(statusText, style: AppTextStyle.siwoo_32_regular),
              ),

              SizedBox(height: 30.h),
              (recordState == RecordingState.uploaded )
                ?  Expanded(
                
                child: Container(
                  
                  margin: EdgeInsets.only(bottom: 0.h),
                  child: Image.asset(imagePath, width: 366.w)),
              )
                :  Expanded(
                
                child: Container(
                  
                  margin: EdgeInsets.only(bottom: 75.h),
                  child: Image.asset(imagePath, width: 366.w)),
              ),
               (recordState == RecordingState.uploading)
                ? Container(margin: EdgeInsets.only(bottom: 20.h))
                : const SizedBox(),
             
               (recordState == RecordingState.recording )
                ? Container(margin: EdgeInsets.only(top: 20.h))
                : const SizedBox(),
              (recordState == RecordingState.uploaded )
                ? Container(margin: EdgeInsets.only(top: 40.h))
                : const SizedBox(),
          
          
               


              // 배경 데코
              Container(
                width: 393.w,
                height: 160.h,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 393.w,
                        height: 150.h,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFfbb279),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 80,
                      child: Container(
                        width: 393.w,
                        height: 200.h,
                        color: const Color(0xFFfbb279),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 버튼 위치
          Positioned(
            top: 500.sp,
            left: 0,
            right: 0,
            child: Center(
              child: isPlayingAudio
                  ? _buildPlayingButton()
                  : _buildButton(recordState, viewModel),
            ),
          ),
        ],
      ),
    );
  }

  /// 녹음 상태에 따라 버튼 렌더링
  Widget _buildButton(RecordingState state, HomeViewModel viewModel) {
    switch (state) {
      case RecordingState.initial:
        return _buildMicButton(
          iconPath: 'assets/images/microphone.png',
          iconColor: AppColors.primary,
          onTap: viewModel.toggleRecording,
        );
      case RecordingState.recording:
        return GestureDetector(
          onTap: viewModel.toggleRecording,
          child: Container(
            width: 157.w,
            height: 157.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(Icons.pause, color: Colors.white, size: 70.sp),
          ),
        );
      case RecordingState.uploading:
        return SizedBox(
          width: 157.w,
          height: 157.h,
          child: Lottie.asset(
            'assets/images/flow2.json',
            width: 157.w,
            height: 157.h,
            fit: BoxFit.cover,
          ),
        );
      case RecordingState.uploaded:
        return _buildMicButton(
          iconPath: 'assets/images/microphone.png',
          iconColor: AppColors.grey,
          onTap: null,
        );
      case RecordingState.completed:
      default:
        return _buildMicButton(
          iconData: Icons.more_horiz,
          iconColor: AppColors.primary,
          onTap: viewModel.toggleRecording,
        );
    }
  }

  /// 오디오 재생 중일 때 버튼
  Widget _buildPlayingButton() {
    return _buildMicButton(
      iconPath: 'assets/images/greymic.png',
      iconColor: AppColors.grey,
      onTap: () {},
    );
  }

  /// 공통 버튼 위젯
  Widget _buildMicButton({
    String? iconPath,
    IconData? iconData,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: iconPath != null
                ? Image.asset(iconPath, width: 61.w, height: 86.h, color: iconColor)
                : Icon(iconData, color: iconColor, size: 70.sp),
          ),
        ),
      ),
    );
  }
}