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
                      children: [
                        Image.asset(item.image, width: 240.w, height: 240.w),
                        SizedBox(height: 40.h),
                        item.title != null
                            ? Text(
                              item.title!,
                              style: AppTextStyle.pretendard_24_bold,
                              textAlign: TextAlign.center,
                            )
                            : Container(),
                        SizedBox(height: 16.h),
                        item.subtitle != null
                            ? Text(
                              item.subtitle!,
                              style: AppTextStyle.pretendard_18_regular
                                  .copyWith(
                                    color: AppColors.darkGrey,
                                    height: 1.6,
                                  ),
                              textAlign: TextAlign.center,
                            )
                            : Container(),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 600.h,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                      if (index == _items.length - 1) {
                        Future.delayed(const Duration(seconds: 2), () {
                          context.go('/login');
                        });
                      }
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

  OnboardingItem({required this.image, this.title, this.subtitle});
}
