import 'package:flutter/material.dart';

/// Generic reusable confirmation dialog.
/// Returns true if confirmed, false/null if cancelled or dismissed.
Future<bool> showConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      String cancelText = 'Cancel',
      String confirmText = 'Confirm',
      Color confirmColor = Colors.red,
    }) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  return result ?? false;
}