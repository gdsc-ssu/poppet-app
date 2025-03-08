import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(image: 'assets/images/basicpopet.png'),
    OnboardingItem(
      image: 'assets/images/poppet2.png',
      title: '매일 가족들에게\n전화걸자니',
      subtitle: '바쁘까, 방해가 될까\n걱정되셨죠?',
    ),
    OnboardingItem(
      image: 'assets/images/basicpopet.png',
      title: 'POPPET에서\n오늘 하루 있었던 일을',
      subtitle: '편하게 얘기해주세요~\n저랑 같이 대화해요~!!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 40.h),
                // Page Indicator
                AnimatedSmoothIndicator(
                  activeIndex: _currentIndex,
                  count: _items.length,
                  effect: SlideEffect(
                    dotHeight: 12.sp,
                    dotWidth: 12.sp,
                    spacing: 16.sp,
                    activeDotColor: AppColors.primary,
                    dotColor: Colors.grey.shade300,
                  ),
                ),
                SizedBox(height: 40.h),
                // Carousel
                CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: _items.length,
                  itemBuilder: (context, index, realIndex) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment:
                          item.title == null && item.subtitle == null
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                      children: [
                        if (item.title == null)
                          Container(
                            margin: EdgeInsets.only(left: 21.sp),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(isTopBubble: true),
                                child: Container(
                                  width: 220.sp,
                                  height: 108.sp,
                                  child: Center(
                                    child: Text(
                                      '할모니~\n안녕하세요!',
                                      style: AppTextStyle.siwoo_32_regular
                                          .copyWith(color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (item.title != null)
                          Text(
                            item.title!,
                            style: AppTextStyle.pretendard_32_bold,
                            textAlign: TextAlign.center,
                          ),
                        Image.asset(item.image, width: 366.sp, height: 366.sp),

                        if (item.title == null)
                          Container(
                            margin: EdgeInsets.only(left: 47.sp),
                            child: CustomPaint(
                              painter: SpeechBubblePainter(isTopBubble: false),
                              child: Container(
                                width: 300.sp,
                                height: 108.sp,
                                padding: EdgeInsets.only(
                                  left: 30.sp,
                                  right: 30.sp,
                                  top: 20.sp,
                                ),
                                child: Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: AppTextStyle.siwoo_36_regular
                                          .copyWith(color: Colors.black),
                                      children: [
                                        TextSpan(text: '저는 '),
                                        TextSpan(
                                          text: '뽀삐',
                                          style: AppTextStyle.siwoo_36_regular
                                              .copyWith(
                                                color: const Color(0xFFFF5722),
                                              ),
                                        ),
                                        TextSpan(text: '라고 해요.'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (item.subtitle != null)
                          Text(
                            item.subtitle!,
                            style: AppTextStyle.pretendard_32_bold.copyWith(
                              color: AppColors.darkGrey,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 650.sp,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ],
            ),
            // Skip button
            Positioned(
              top: 0,
              right: 0,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  '건너뛰기',
                  style: AppTextStyle.pretendard_16_regular.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String? title;
  final String? subtitle;
  final String? topBubbleText;
  final String? bottomBubbleText;

  OnboardingItem({
    required this.image,
    this.title,
    this.subtitle,
    this.topBubbleText,
    this.bottomBubbleText,
  });
}

// 🎨 Custom Speech Bubble Painter
class SpeechBubblePainter extends CustomPainter {
  final bool isTopBubble;

  SpeechBubblePainter({this.isTopBubble = true});

  @override
  void paint(Canvas canvas, Size size) {
    // Shadow paint
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final path = Path();

    if (isTopBubble) {
      // Top bubble - oval shape
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.9),
        Radius.elliptical(size.width / 2, size.height / 2),
      );
      path.addRRect(rect);

      // Add triangular tail to bottom-right
      path.moveTo(size.width * 0.7, size.height * 0.8);
      path.lineTo(size.width * 0.8, 0);
      path.lineTo(size.width * 0.85, size.height * 1.05);
      path.close();
    } else {
      // Bottom bubble - oval shape
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.9),
        Radius.elliptical(size.width / 2, size.height / 2),
      );
      path.addRRect(rect);

      // Add triangular tail to top-right
      path.moveTo(size.width * 0.2, size.height * 0.65);
      path.lineTo(size.width * 0.4, 0.8);
      path.lineTo(size.width * 0.5, size.height * 1.0);
      path.close();
    }

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);
    // Then draw the bubble
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
