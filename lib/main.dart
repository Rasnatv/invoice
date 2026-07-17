import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/responsive.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  runApp(const DreamsCeramicApp());
}

class DreamsCeramicApp extends StatelessWidget {
  const DreamsCeramicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreams Ceramic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Initializes the Responsive helper once per rebuild so every
      // descendant screen can immediately call Responsive.w/h/sp.
      builder: (context, child) {
        Responsive.init(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
