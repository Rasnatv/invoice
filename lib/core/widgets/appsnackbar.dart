import 'package:flutter/material.dart';

/// Native-Flutter snackbar utility — no GetX dependency.
///
/// SETUP (one-time, in main.dart):
///   MaterialApp(
///     scaffoldMessengerKey: AppSnackbar.messengerKey,
///     ...
///   )
///
/// Once that's set, call AppSnackbar.success/error/warning(...) from
/// anywhere — including inside a BlocListener — without needing to pass
/// BuildContext at every call site.
class AppSnackbar {
  AppSnackbar._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
  GlobalKey<ScaffoldMessengerState>();

  static void success(String message) => _show(
    message: message,
    icon: Icons.check_circle_rounded,
    backgroundColor: const Color(0xFF094521),
    shadowColor: const Color(0xFF09371B),
  );

  static void error(String message) => _show(
    message: message,
    icon: Icons.error_rounded,
    backgroundColor: Colors.orange.shade700,
    shadowColor: Colors.orange.shade700,
  );

  static void warning(String message) => _show(
    message: message,
    icon: Icons.warning_rounded,
    backgroundColor: const Color(0xFFF57C00),
    shadowColor: const Color(0xFFF57C00),
  );

  static void _show({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color shadowColor,
  }) {
    if (message.isEmpty) return;

    final messengerState = messengerKey.currentState;
    if (messengerState == null) return;

    // Clear any snackbar still showing so they don't stack/overlap.
    messengerState.clearSnackBars();

    messengerState.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        duration: const Duration(seconds: 2),
        elevation: 8,
        // Native SnackBar has no direct shadowColor param on the widget
        // itself; elevation + backgroundColor give an equivalent look.
      ),
    );
  }
}