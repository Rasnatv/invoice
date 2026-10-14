// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'app_colors.dart';
// // import '../utils/responsive.dart';
// //
// // class AppTextStyles {
// //   AppTextStyles._();
// //
// //   /// Scales the font but never lets it grow past 1.1x or shrink below 0.9x.
// //   static double _fs(double size) {
// //     final scaled = Responsive.sp(size);
// //     return scaled.clamp(size * 0.9, size * 1.1).toDouble();
// //   }
// //
// //   static TextStyle _base({
// //     required double size,
// //     FontWeight weight = FontWeight.normal,
// //     Color color = AppColors.textPrimary,
// //     double? height,
// //     double? letterSpacing,
// //   }) {
// //     return GoogleFonts.poppins(
// //       fontSize: _fs(size),
// //       fontWeight: weight,
// //       color: color,
// //       height: height,
// //       letterSpacing: letterSpacing,
// //     );
// //   }
// //
// //   // Headings
// //   static TextStyle h1({Color color = AppColors.textPrimary}) =>
// //       _base(size: 24, weight: FontWeight.w700, color: color);
// //
// //   static TextStyle h2({Color color = AppColors.textPrimary}) =>
// //       _base(size: 14, weight: FontWeight.w400, color: color);
// //
// //   static TextStyle h3({Color color = AppColors.textPrimary}) =>
// //       _base(size: 14, weight: FontWeight.w400, color: color);
// //
// //   static TextStyle h6({Color color = AppColors.white}) =>
// //       _base(size: 14, weight: FontWeight.w500, color: color);
// //
// //   // Body
// //   static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
// //       _base(size: 13, weight: FontWeight.w400, color: color);
// //
// //   static TextStyle body({Color color = AppColors.textPrimary}) =>
// //       _base(size: 13, weight: FontWeight.w400, color: color);
// //
// //   static TextStyle bodyBold({Color color = AppColors.textPrimary}) =>
// //       _base(size: 12, weight: FontWeight.w400, color: color);
// //
// //   // Captions
// //   static TextStyle caption({Color color = AppColors.textHint}) =>
// //       _base(size: 12, weight: FontWeight.w400, color: color);
// //
// //   static TextStyle captionnew({Color color = AppColors.textHint}) =>
// //       _base(size: 10, weight: FontWeight.w400, color: color);
// //
// //   static TextStyle captionsave({Color color = AppColors.white}) =>
// //       _base(size: 11, weight: FontWeight.w400, color: color);
// //
// //   static TextStyle captioref({Color color = AppColors.textPrimary}) =>
// //       _base(size: 10, weight: FontWeight.w700, color: color);
// //
// //   // Buttons & amounts
// //   static TextStyle button({Color color = AppColors.textOnPrimary}) =>
// //       _base(size: 14, weight: FontWeight.w600, color: color);
// //
// //   static TextStyle amount({Color color = AppColors.textPrimary}) =>
// //       _base(size: 18, weight: FontWeight.w700, color: color);
// //
// //   static TextStyle balanceamount({Color color = AppColors.textPrimary}) =>
// //       _base(size: 14, weight: FontWeight.w600, color: color);
// // }
// import 'dart:ui' show FontFeature;
// import 'package:flutter/material.dart';
// import 'app_colors.dart';
//
// /// Single source of truth for typography.
// ///
// /// Font: Inter (local files in assets/fonts, declared in pubspec.yaml)
// /// Scale: 11 label | 12 small | 13 body | 14 title | 16 page | 20 big amount
// class AppTextStyles {
//   AppTextStyles._();
//
//   static const String _fontFamily = 'Inter';
//
//   static TextStyle _base({
//     required double size,
//     FontWeight weight = FontWeight.w400,
//     Color color = AppColors.textPrimary,
//     double? height,
//     double? letterSpacing,
//     bool numbers = false,
//   }) {
//     return TextStyle(
//       fontFamily: _fontFamily,
//       fontSize: size,
//       fontWeight: weight,
//       color: color,
//       height: height,
//       letterSpacing: letterSpacing,
//       // Same-width digits so amounts line up.
//       fontFeatures: numbers ? const [FontFeature.tabularFigures()] : null,
//     );
//   }
//
//   // ---------------------------------------------------------------------------
//   // Headings
//   // ---------------------------------------------------------------------------
//
//   /// Main screen heading - 20 / w600
//   static TextStyle h1({Color color = AppColors.textPrimary}) =>
//       _base(size: 20, weight: FontWeight.w600, color: color);
//
//   /// Page / app bar title - 16 / w600
//   static TextStyle h2({Color color = AppColors.textPrimary}) =>
//       _base(size: 16, weight: FontWeight.w600, color: color);
//
//   /// Section title, names, stat numbers - 14 / w600
//   static TextStyle h3({Color color = AppColors.textPrimary}) =>
//       _base(size: 14, weight: FontWeight.w600, color: color);
//
//   /// Title on coloured backgrounds (app bar, banners) - 16 / w600
//   static TextStyle h6({Color color = AppColors.white}) =>
//       _base(size: 16, weight: FontWeight.w600, color: color);
//
//   // ---------------------------------------------------------------------------
//   // Body
//   // ---------------------------------------------------------------------------
//
//   /// Secondary text under titles - 12 / w400
//   static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
//       _base(size: 12, weight: FontWeight.w400, color: color);
//
//   /// Default content text - 13 / w400
//   static TextStyle body({Color color = AppColors.textPrimary}) =>
//       _base(size: 13, weight: FontWeight.w400, color: color);
//
//   /// Emphasised content text - 13 / w600
//   static TextStyle bodyBold({Color color = AppColors.textPrimary}) =>
//       _base(size: 13, weight: FontWeight.w600, color: color);
//
//   // ---------------------------------------------------------------------------
//   // Captions
//   // ---------------------------------------------------------------------------
//
//   /// Helper text, greeting, dates - 12 / w400
//   static TextStyle caption({Color color = AppColors.textHint}) =>
//       _base(size: 12, weight: FontWeight.w400, color: color);
//
//   /// Small label - 11 / w400
//   static TextStyle captionnew({Color color = AppColors.textHint}) =>
//       _base(size: 11, weight: FontWeight.w400, color: color);
//
//   /// Small label on dark / coloured background - 11 / w500
//   static TextStyle captionsave({Color color = AppColors.white}) =>
//       _base(size: 11, weight: FontWeight.w500, color: color);
//
//   /// Small bold text (IDs, badges, status) - 11 / w600
//   static TextStyle captioref({Color color = AppColors.textPrimary}) =>
//       _base(size: 11, weight: FontWeight.w600, color: color);
//
//   // ---------------------------------------------------------------------------
//   // Buttons & amounts
//   // ---------------------------------------------------------------------------
//
//   /// Button label - 14 / w600
//   static TextStyle button({Color color = AppColors.textOnPrimary}) =>
//       _base(size: 14, weight: FontWeight.w600, color: color);
//
//   /// Big amount (chart total, price highlights) - 20 / w600
//   static TextStyle amount({Color color = AppColors.textPrimary}) =>
//       _base(size: 20, weight: FontWeight.w600, color: color, numbers: true);
//
//   /// Small amount (estimate rows, lists) - 14 / w600
//   static TextStyle balanceamount({Color color = AppColors.textPrimary}) =>
//       _base(size: 14, weight: FontWeight.w600, color: color, numbers: true);
// }
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Single source of truth for typography.
///
/// Font: default system font (Roboto on Android, San Francisco on iOS)
/// Scale: 11 label | 12 small | 13 body | 14 title | 16 page | 20 big amount
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
    bool numbers = false,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      // Same-width digits so amounts line up.
      fontFeatures: numbers ? const [FontFeature.tabularFigures()] : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Headings
  // ---------------------------------------------------------------------------

  /// Main screen heading - 20 / w600
  static TextStyle h1({Color color = AppColors.textPrimary}) =>
      _base(size:20, weight: FontWeight.w600, color: color);

  /// Page / app bar title - 16 / w600
  static TextStyle h2({Color color = AppColors.textPrimary}) =>
      _base(size: 16, weight: FontWeight.w600, color: color);

  /// Section title, names, stat numbers - 14 / w600
  static TextStyle h3({Color color = AppColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w600, color: color);

  /// Title on coloured backgrounds (app bar, banners) - 16 / w600
  static TextStyle h6({Color color = AppColors.white}) =>
      _base(size: 16, weight: FontWeight.w600, color: color);

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  /// Secondary text under titles - 12 / w400
  static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
      _base(size: 12, weight: FontWeight.w400, color: color);

  /// Default content text - 13 / w400
  static TextStyle body({Color color = AppColors.textPrimary}) =>
      _base(size: 13, weight: FontWeight.w400, color: color);

  /// Emphasised content text - 13 / w600
  static TextStyle bodyBold({Color color = AppColors.textPrimary}) =>
      _base(size: 13, weight: FontWeight.w600, color: color);

  // ---------------------------------------------------------------------------
  // Captions
  // ---------------------------------------------------------------------------

  /// Helper text, greeting, dates - 12 / w400
  static TextStyle caption({Color color = AppColors.textHint}) =>
      _base(size: 12, weight: FontWeight.w400, color: color);

  /// Small label - 11 / w400
  static TextStyle captionnew({Color color = AppColors.textHint}) =>
      _base(size: 11, weight: FontWeight.w400, color: color);

  /// Small label on dark / coloured background - 11 / w500
  static TextStyle captionsave({Color color = AppColors.white}) =>
      _base(size: 11, weight: FontWeight.w500, color: color);

  /// Small bold text (IDs, badges, status) - 11 / w600
  static TextStyle captioref({Color color = AppColors.textPrimary}) =>
      _base(size: 11, weight: FontWeight.w600, color: color);

  // ---------------------------------------------------------------------------
  // Buttons & amounts
  // ---------------------------------------------------------------------------

  /// Button label - 14 / w600
  static TextStyle button({Color color = AppColors.textOnPrimary}) =>
      _base(size: 14, weight: FontWeight.w600, color: color);

  /// Big amount (chart total, price highlights) - 20 / w600
  static TextStyle amount({Color color = AppColors.textPrimary}) =>
      _base(size: 20, weight: FontWeight.w600, color: color, numbers: true);

  /// Small amount (estimate rows, lists) - 14 / w600
  static TextStyle balanceamount({Color color = AppColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w600, color: color, numbers: true);
}