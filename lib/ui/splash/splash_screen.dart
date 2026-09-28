

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../router/dashboardrouter.dart';
import '../../core/utils/responsive.dart';
import '../../core/network/tokenstorage.dart';

/// Splash / brand loading screen — modern, elegant look for Dreams Ceramic.
/// Soft gradient backdrop, glowing logo mark, refined typography.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.55,
        curve: Curves.easeOut,
      ),
    );

    _scale = Tween<double>(
      begin: 0.82,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.6,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.35,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.35,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();

    _navTimer = Timer(
      const Duration(milliseconds: 2600),
      _navigateNext,
    );
  }

  /// Decides where to go after the splash delay.
  ///
  /// 1. Token + role exist -> directly open that role's dashboard.
  /// 2. No token/role -> Login or Onboarding.
  ///
  /// No API/profile verification is performed here.
  Future<void> _navigateNext() async {
    if (!mounted) return;

    final token = await TokenStorage.readToken();
    final role = roleFromStoredString(
      await TokenStorage.readRole(),
    );

    if (!mounted) return;

    // Saved login session exists.
    if (token != null && token.isNotEmpty && role != null) {
      context.go(routeForRole(role));
      return;
    }

    // No saved login session.
    final seenOnboarding = await TokenStorage.hasSeenOnboarding();

    if (!mounted) return;

    context.go(
      seenOnboarding ? '/login' : '/onboarding',
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.white,
              AppColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -Responsive.w(80),
              right: -Responsive.w(60),
              child: _SoftGlow(
                color: AppColors.primary.withOpacity(0.10),
                size: Responsive.w(260),
              ),
            ),

            Positioned(
              bottom: -Responsive.w(100),
              left: -Responsive.w(70),
              child: _SoftGlow(
                color: AppColors.black.withOpacity(0.06),
                size: Responsive.w(280),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: Responsive.w(128),
                        height: Responsive.w(128),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.18),
                              blurRadius: 40,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(
                              Responsive.w(18),
                            ),
                            child: Image.asset(
                              'assets/images/logo/logo.png',
                              width: Responsive.w(92),
                              height: Responsive.w(92),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: Responsive.h(28),
                  ),

                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          Text(
                            'CERAMO',
                            style: AppTextStyles.h1(
                              color: AppColors.primary,
                            ).copyWith(
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: Responsive.h(8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftGlow({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}