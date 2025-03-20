import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/utils/audio_utils.dart';
import '../view_model/home_view_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// 오디오 재생 중인지 관리하는 Provider
final isPlayingAudioProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final recordingState = ref.watch(homeViewModelProvider);
    final recordState = viewModel.recordingState;
    final isRecording = viewModel.isRecording;
    final isCompleted = viewModel.isCompleted;
    final isUploading = viewModel.isUploading;
    final isUploaded = viewModel.isUploaded;
    final isPlayingAudio = ref.watch(isPlayingAudioProvider);

    // 상태에 따른 텍스트 설정
    String statusText = '';
    if (isPlayingAudio) {
      statusText = '뽀삐가 대답을\n생각하는 중이에요';
    } else if (recordState == RecordingState.initial) {
      statusText = '마이크 버튼을 누르고\n대화를 나눠보세요.';
    } else if (recordState == RecordingState.recording) {
      statusText = '대화를 그만하고 싶다면\n중지 버튼을 눌러주세요';
    } else if (recordState == RecordingState.uploading) {
      statusText = '녹음 파일을 서버로\n전송하는 중이에요';
    } else {
      statusText = '뽀삐가 대답을\n생각하는 중이에요';
    }

    // 상태에 따른 이미지 설정
    String imagePath = '';
    if (isPlayingAudio) {
      imagePath = 'assets/images/basicpopet.png'; // 오디오 재생 중 이미지
    } else if (recordState == RecordingState.initial) {
      imagePath = 'assets/images/basicpopet.png';
    } else if (recordState == RecordingState.recording) {
      imagePath = 'assets/images/listenPoppet.png';
    } else if (recordState == RecordingState.uploading) {
      imagePath = 'assets/images/poppet2.png';
    } else {
      imagePath = 'assets/images/poppet2.png';
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SizedBox(
          width: 120.w, // 적절한 크기 설정
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
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 34.h, left: 32.w),
                child: Text(statusText, style: AppTextStyle.siwoo_32_regular),
              ),
              isCompleted || isRecording || isUploading || isUploaded
                  ? SizedBox()
                  : Container(margin: EdgeInsets.only(top: 30.h)),
              isRecording
                  ? Container(margin: EdgeInsets.only(top: 15.h))
                  : SizedBox(),
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 캐릭터 이미지
                    Image.asset(imagePath, width: 366.w),
                  ],
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

          // 녹음 버튼 - 최상단에 위치
          Positioned(
            top: 500.sp,
            left: 0,
            right: 0,
            child: Center(
              child:
                  isPlayingAudio
                      ? _buildPlayingButton(viewModel)
                      : _buildButton(recordState, viewModel),
            ),
          ),
        ],
      ),
    );
  }

  // 상태에 따른 버튼 위젯 생성
  Widget _buildButton(RecordingState state, HomeViewModel viewModel) {
    switch (state) {
      case RecordingState.initial:
        // 초기 상태 - 마이크 버튼 (기존 코드 사용)
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
        );

      case RecordingState.recording:
        // 녹음 중 - 일시정지 버튼
        return GestureDetector(
          onTap: () => viewModel.toggleRecording(),
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
        // 업로드 중 - 로딩 인디케이터
        return Container(
          width: 157.w,
          height: 157.h,
          padding: EdgeInsets.only(top: 10.h),
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
          child: Center(
            child: LoadingAnimationWidget.waveDots(
              color: AppColors.primary,
              size: 100.sp,
            ),
          ),
        );

      case RecordingState.uploaded:
        // 업로드 완료 - 회색 마이크 버튼
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
                  'assets/images/greymic.png',
                  width: 61.w,
                  height: 86.h,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        );

      case RecordingState.completed:
      default:
        // 녹음 완료 - 점 세 개 버튼
        return Container(
          width: 157.w,
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
              child: Icon(
                Icons.more_horiz,
                color: AppColors.primary,
                size: 70.sp,
              ),
            ),
          ),
        );
    }
  }

  // 오디오 재생 중일 때 표시되는 버튼
  Widget _buildPlayingButton(HomeViewModel viewModel) {
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => viewModel.isCompleted,
          customBorder: CircleBorder(),
          child: Center(
            child: Image.asset(
              'assets/images/greymic.png',
              width: 61.w,
              height: 86.h,
              color: AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
