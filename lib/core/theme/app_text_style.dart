import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyle {
  static const String _fontFamily = 'Pretendard';

  // Bold styles (700)
  static TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  // Medium styles (500)
  static TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // Regular styles (400)
  static TextStyle body1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextStyle body2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextStyle body3 = TextStyle(
    fontFamily: 'Pretendard-Regular',
    fontSize: 14.sp,

    height: 1.3,
  );
}
