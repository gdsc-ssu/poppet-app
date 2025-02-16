import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_style.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomPopup({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 313.sp,
        constraints: BoxConstraints(maxHeight: 660.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    right: 8.w,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.darkGrey,
                    ),
                  ),
                  // Title
                  Center(
                    child: Text(
                      title,
                      style: AppTextStyle.pretendard_24_bold.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}
