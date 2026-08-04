import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class ResetSuccessScreen extends StatefulWidget {
  final VoidCallback? onContinue;

  const ResetSuccessScreen({super.key, this.onContinue});

  @override
  State<ResetSuccessScreen> createState() => _ResetSuccessScreenState();
}

class _ResetSuccessScreenState extends State<ResetSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context) {
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(28)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: _SuccessBadge(),
                  ),
                  SizedBox(height: Responsive.h(28)),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        children: [
                          Text(
                            'Password Reset',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1().copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: Responsive.h(10)),
                          Text(
                            'Your password has been changed successfully. '
                                'You can now sign in with your new password.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(36)),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: _BrandButton(
                        label: 'Back to Sign in',
                        onPressed: () => _onContinue(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = Responsive.w(112);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.check_rounded,
          color: AppColors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BrandButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.bodyBold(color: AppColors.white)
                    .copyWith(fontSize: 15.5, letterSpacing: 0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}