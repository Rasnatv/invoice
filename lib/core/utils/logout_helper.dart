
import 'package:flutter/material.dart';
import '../../ui/auth/login_screen.dart';
import '../network/tokenstorage.dart';
import 'confirmation_dialogue.dart';

Future<void> logout(BuildContext context) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'Logout',
    message: 'Are you sure you want to logout?',
    confirmText: 'Logout',
  );

  if (!confirmed) return;
  if (!context.mounted) return;

  await TokenStorage.clear();
  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
  );
}