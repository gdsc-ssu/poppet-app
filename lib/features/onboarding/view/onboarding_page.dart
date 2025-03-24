import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
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
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

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

                /// ✅ 변경된 부분 시작: NotificationListener 추가
                Expanded(
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (notification) {
                      final metrics = notification.metrics;

                      final isLastPage = _currentIndex == _items.length - 1;
                      final isAtEdge =
                          metrics.pixels == metrics.maxScrollExtent;

                      if (isLastPage && isAtEdge) {
                        Future.microtask(() {
                          context.go('/login');
                        });
                      }
                      return false;
                    },
                    child: CarouselSlider.builder(
                      carouselController: CarouselSliderController(),
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
                                margin: EdgeInsets.only(left: 26.sp),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: CustomPaint(
                                    painter: SpeechBubblePainter(
                                      isTopBubble: true,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 21.sp),
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
                              Container(
                                margin: EdgeInsets.only(top: 40.h),
                                child: Text(
                                  item.title!,
                                  style: AppTextStyle.siwoo_32_regular,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (item.title == 'POPPET에서\n오늘 하루 있었던 일을')
                              Container(margin: EdgeInsets.only(top: 10.h)),
                            Image.asset(
                              item.image,
                              width: 366.sp,
                              height: 366.sp,
                            ),
                            if (item.title == null)
                              Container(
                                margin: EdgeInsets.only(left: 47.sp),
                                child: CustomPaint(
                                  painter: SpeechBubblePainter(
                                    isTopBubble: false,
                                  ),
                                  child: Container(
                                    width: 300.sp,
                                    height: 98.sp,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.sp,
                                    ),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: AppTextStyle.siwoo_36_regular
                                              .copyWith(color: Colors.black),
                                          children: [
                                            const TextSpan(text: '저는 '),
                                            TextSpan(
                                              text: '뽀삐',
                                              style: AppTextStyle
                                                  .siwoo_36_regular
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFFFF5722,
                                                    ),
                                                  ),
                                            ),
                                            const TextSpan(text: '라고 해요.'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (item.subtitle == '바쁘까, 방해가 될까\n걱정되셨죠?')
                              Container(margin: EdgeInsets.only(top: 10.h)),
                            if (item.subtitle != null)
                              Text(
                                item.subtitle!,
                                style: AppTextStyle.siwoo_32_regular.copyWith(
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
                  ),
                ),
              ],
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

class SpeechBubblePainter extends CustomPainter {
  final bool isTopBubble;

  SpeechBubblePainter({this.isTopBubble = true});

  @override
  void paint(Canvas canvas, Size size) {
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
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 1.2),
        Radius.elliptical(size.width / 2, size.height / 1.5),
      );
      path.addRRect(rect);
      path.moveTo(size.width * 0.65, size.height * 1.1);
      path.lineTo(size.width * 0.9, size.height * 0.2);
      path.lineTo(size.width * 0.75, size.height * 1.35);
      path.close();
    } else {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -size.height * 0.01, size.width, size.height * 0.9),
        Radius.elliptical(size.width / 2, size.height / 2),
      );
      path.addRRect(rect);
      path.moveTo(size.width * 0.17, size.height * 0.7);
      path.lineTo(size.width * 0.4, -size.height * 0.27);
      path.lineTo(size.width * 0.45, size.height * 0.7);
      path.close();
    }

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
