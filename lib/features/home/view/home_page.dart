import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../view_model/home_view_model.dart';

// 말풍선 CustomPainter 추가
class SpeechBubblePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  SpeechBubblePainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final Paint shadowPaint =
        Paint()
          ..color = shadowColor
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

    var path = Path();
    path.moveTo(15, 15);
    path.lineTo(30, 15);
    path.lineTo(30, 5);
    path.quadraticBezierTo(30, 2, 32, 2);
    path.lineTo(48, 15);
    path.lineTo(size.width - 15, 15);
    path.quadraticBezierTo(size.width, 15, size.width, 30);
    path.lineTo(size.width, size.height - 15);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 15,
      size.height,
    );
    path.lineTo(15, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 15);
    path.lineTo(0, 30);
    path.quadraticBezierTo(0, 15, 15, 15);

    // 그림자 그리기
    canvas.drawPath(path, shadowPaint);
    // 말풍선 그리기
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final recordingState = ref.watch(homeViewModelProvider);
    final recordState = viewModel.recordingState;
    final isRecording = viewModel.isRecording;
    final isCompleted = viewModel.isCompleted;

    // 상태에 따른 텍스트 설정
    String statusText = '';
    if (recordState == RecordingState.initial) {
      statusText = '마이크 버튼을 누르고\n대화를 나눠보세요.';
    } else if (recordState == RecordingState.recording) {
      statusText = '대화를 그만하고 싶다면\n중지 버튼을 눌러주세요';
    } else {
      statusText = '뽀삐가 대답을\n생각하는 중이에요';
    }

    // 상태에 따른 이미지 설정
    String imagePath = '';
    if (recordState == RecordingState.initial) {
      imagePath = 'assets/images/basicpopet.png';
    } else if (recordState == RecordingState.recording) {
      imagePath = 'assets/images/listenPoppet.png';
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 캐릭터 이미지
                    Image.asset(imagePath, width: 366.w),

                    // 말풍선
                    Positioned(
                      top: 80.h,
                      child: CustomPaint(
                        painter: SpeechBubblePainter(
                          color: Colors.white,
                          shadowColor: Colors.black.withOpacity(0.05),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.w,
                            vertical: 16.h,
                          ),
                          width: 280.w,
                          height: 70.h,
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '저는 ',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '뽀삐',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF8A3D),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '라고 해요.',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isRecording ? SizedBox(height: 30.h) : SizedBox(),
              isCompleted ? SizedBox(height: 30.h) : SizedBox(),
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
            child: Center(child: _buildButton(recordState, viewModel)),
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

      case RecordingState.completed:
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
}
