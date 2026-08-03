import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  // ---------------- Brand ----------------
  static const Color primary =
  //Color(0xFFB87333);
  Color(0xFF770816);
  static const Color primaryDark =
  //Color(0xFFB87333);
   Color(0xFF770816);

  static const Color primaryLight = Color(0xFFFF4B54); // highlights / hover
  static const Color primarySoft = Color(0xFFDE8E9); // red tint backgrounds
  static const Color primarySoftss = Color(0xFF9AC0DD); // red tint backgrounds
  static const Color primarySoftsshigh = Color(0xFF4580A6); // red tint backgrounds
  static const Color black = Color(0xFF1A1A1A); // near-black brand color
  static const Color charcoal = Color(0xFF2B2B2B);

  // ---------------- Neutrals ----------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F6FA); // scaffold bg
  static const Color surface = Color(0xFFFFFFFF); // card bg
  static const Color surfaceAlt = Color(0xFFF8F9FB);
  static const Color divider = Color(0xFFEDEEF2);
  static const Color border = Color(0xFFE3E5EA);
  static const Color shadow = Color(0x1A000000);

  // ---------------- Text ----------------
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B6E76);
  static const Color textHint = Color(0xFFA0A3AC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------- Status ----------------
  static const Color success = Color(0xFF2ECC71); // Approved / Delivered
  static const Color successBg = Color(0xFFE8F9EF);
  static const Color warning = Color(0xFFFF9F1C); // Pending
  static const Color warningBg = Color(0xFFFFF3E1);
  static const Color error = Color(0xFFE3121E); // Rejected
  static const Color errorBg = Color(0xFFFDE8E9);
  static const Color info = Color(0xFF2E8CFF); // In Transit
  static const Color infoBg = Color(0xFFE7F1FF);
  static const Color infoBge = Color(0xFFA6DAAF);

  // ---------------- Socials ----------------
  static const Color google = Color(0xFFEA4335);
  static const Color facebook = Color(0xFF1877F2);

  // ---------------- Gradients ----------------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkFadeGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Maps a status string (as seen across estimates / dispatch bills)
  /// to its foreground color.
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'delivered':
        return success;
      case 'pending':
        return warning;
      case 'rejected':
        return error;
      case 'in transit':
        return info;
      default:
        return textSecondary;
    }
  }

  /// Maps a status string to its background tint.
  static Color statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'delivered':
        return successBg;
      case 'pending':
        return warningBg;
      case 'rejected':
        return errorBg;
      case 'in transit':
        return infoBg;
      default:
        return surfaceAlt;
    }
  }
}
