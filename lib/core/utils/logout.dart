import 'package:flutter/material.dart';
import '../../ui/auth/login_screen.dart';
import '../network/tokenstorage.dart';

Future<void> logout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  await TokenStorage.clear();
  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
  );
}