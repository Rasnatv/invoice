
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/tokenstorage.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/login_screen.dart';

/// Single onboarding page — shown only once, ever, on first launch.
/// After this, TokenStorage remembers it's been seen and Splash skips
/// straight to LoginScreen (or a dashboard, if a session exists) on
/// every future launch.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _goNext(BuildContext context) async {
    await TokenStorage.setOnboardingSeen();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                child: Column(
                  children: [
                    SizedBox(height: Responsive.h(100)),
                    Image.asset(
                      'assets/images/landingview.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: Responsive.h(28)),
                    Text(
                      'Create Estimate Bills and Dispatch Bills',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1(color: AppColors.primary),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    Text(
                      'Create estimate bills and dispatch bills quickly and efficiently — all in one place.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle(),
                    ),
                    SizedBox(height: Responsive.h(10)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(24),
                Responsive.h(20),
                Responsive.w(24),
                Responsive.h(20),
              ),
              child: PrimaryButton(
                label: 'Get Started',
                trailingIcon: Icons.arrow_forward,
                onPressed: () => _goNext(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}