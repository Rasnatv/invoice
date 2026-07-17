import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../utils/responsive.dart';

/// Centralized text styles built on Google Fonts (Poppins), sized via
/// [Responsive.sp] so typography scales gracefully across devices.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: Responsive.sp(size),
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle h1({Color color = AppColors.textPrimary}) =>
      _base(size: 28, weight: FontWeight.w700, color: color);

  static TextStyle h2({Color color = AppColors.textPrimary}) =>
      _base(size: 22, weight: FontWeight.w700, color: color);
  static TextStyle h6({Color color = AppColors.white}) =>
      _base(size: 18, weight: FontWeight.w500, color: color);

  static TextStyle h3({Color color = AppColors.textPrimary}) =>
      _base(size: 18, weight: FontWeight.w600, color: color);

  static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
      _base(size: 14, weight: FontWeight.w400, color: color);

  static TextStyle body({Color color = AppColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w400, color: color);

  static TextStyle bodyBold({Color color = AppColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w600, color: color);

  static TextStyle caption({Color color = AppColors.textHint}) =>
      _base(size: 12, weight: FontWeight.w400, color: color);
  static TextStyle captionnew({Color color = AppColors.textHint}) =>
      _base(size: 10, weight: FontWeight.w400, color: color);
  static TextStyle captionsave({Color color = AppColors.white}) =>
      _base(size: 12, weight: FontWeight.w400, color: color);

  static TextStyle button({Color color = AppColors.textOnPrimary}) =>
      _base(size: 15, weight: FontWeight.w600, color: color);

  static TextStyle amount({Color color = AppColors.textPrimary}) =>
      _base(size: 20, weight: FontWeight.w700, color: color);
}
