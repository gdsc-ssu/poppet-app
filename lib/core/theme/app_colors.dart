import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const primary = Color(0xFFE86B00);
  static const secondary = Color(0xFFFFA500);

  // Neutral colors
  static const white = Color(0xFFFFF9F2);
  static const lightGrey = Color(0xFFF0F0F0);
  static const grey = Color(0xFFB6B6B6);
  static const darkGrey = Color(0xFF333333);

  // Accent colors
  static const accent = Color(0xFFEB261F);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
