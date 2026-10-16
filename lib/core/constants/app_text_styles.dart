

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../utils/responsive.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Poppins is bundled in assets/fonts and registered in pubspec.yaml.
  static const String fontFamily = 'Poppins';

  /// Scales the font but never lets it grow past 1.1x or shrink below 0.9x.
  static double _fs(double size) {
    final scaled = Responsive.sp(size);
    return scaled.clamp(size * 0.9, size * 1.1).toDouble();
  }

  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
    bool numbers = false,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: _fs(size),
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: numbers ? const [FontFeature.tabularFigures()] : null,
    );
  }

  // ---------------- Headings ----------------

  static TextStyle h1({Color color = AppColors.textPrimary}) =>
      _base(size: 16, weight: FontWeight.w700, color: color);

  static TextStyle h2({Color color = AppColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w700, color: color);

  static TextStyle h3({Color color = AppColors.textPrimary}) =>
      _base(size: 13, weight: FontWeight.w600, color: color);

  static TextStyle h6({Color color = AppColors.white}) =>
      _base(size: 14, weight: FontWeight.w500, color: color);

  // ---------------- Body ----------------

  static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
      _base(size: 13, weight: FontWeight.w400, color: color);

  static TextStyle body({Color color = AppColors.textPrimary}) =>
      _base(size: 12, weight: FontWeight.w400, color: color);

  static TextStyle bodyBold({Color color = AppColors.textPrimary}) =>
      _base(size: 13, weight: FontWeight.w600, color: color);

  /// "View all" style action text
  static TextStyle link({Color color = AppColors.primary}) =>
      _base(size: 12, weight: FontWeight.w600, color: color);

  // ---------------- Captions ----------------

  static TextStyle caption({Color color = AppColors.textHint}) =>
      _base(size: 12, weight: FontWeight.w400, color: color);

  static TextStyle captionnew({Color color = AppColors.textHint}) =>
      _base(size: 10, weight: FontWeight.w400, color: color);

  static TextStyle captionsave({Color color = AppColors.white}) =>
      _base(size: 11, weight: FontWeight.w400, color: color);

  static TextStyle captioref({Color color = AppColors.textPrimary}) =>
      _base(size: 10, weight: FontWeight.w700, color: color);

  /// Quick action tile labels and bottom nav labels
  static TextStyle tabLabel({Color color = AppColors.textPrimary}) =>
      _base(size: 10, weight: FontWeight.w500, color: color, height: 1.15);

  // ---------------- Buttons & amounts ----------------

  static TextStyle button({Color color = AppColors.textOnPrimary}) =>
      _base(size: 14, weight: FontWeight.w600, color: color);

  static TextStyle amount({Color color = AppColors.textPrimary}) =>
      _base(size: 13, weight: FontWeight.w700, color: color, numbers: true);

  static TextStyle balanceamount({Color color = AppColors.textPrimary}) =>
      _base(size: 13, weight: FontWeight.w600, color: color, numbers: true);
}