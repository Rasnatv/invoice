
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/forgotpswd/forgotpassword_bloc.dart';
import '../../bloc/forgotpswd/forgotpassword_event.dart';
import '../../bloc/forgotpswd/forgotpassword_state.dart';
import 'newpasswordsetscreen.dart';


const int _kOtpLength = 6;
const int _kResendSeconds = 30;

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers =
  List.generate(_kOtpLength, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes =
  List.generate(_kOtpLength, (_) => FocusNode());

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Timer? _resendTimer;
  int _secondsRemaining = _kResendSeconds;
  String? _localErrorText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _startResendTimer();
  }

  void _startResendTimer() {
    _secondsRemaining = _kResendSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (_localErrorText != null) setState(() => _localErrorText = null);

    if (value.isNotEmpty && index < _kOtpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == _kOtpLength) {
      FocusScope.of(context).unfocus();
    }
    setState(() {});
  }

  void _onVerify() {
    if (_code.length != _kOtpLength) {
      setState(() => _localErrorText = 'Enter the complete 6-digit code');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _localErrorText = null);
    context.read<ForgotPasswordBloc>().add(VerifyForgotPasswordOtp(_code));
  }

  void _onResend() {
    if (_secondsRemaining != 0) return;

    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _localErrorText = null);
    _focusNodes.first.requestFocus();
    _startResendTimer();
    context.read<ForgotPasswordBloc>().add(const ResendForgotPasswordOtp());
  }

  void _goToNewPasswordScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, anim, __) => BlocProvider.value(
          value: context.read<ForgotPasswordBloc>(),
          child: const SetNewPasswordScreen(),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return widget.email;
    final name = parts[0];
    final visible = name.length <= 2 ? name : name.substring(0, 2);
    return '$visible${'•' * (name.length - visible.length).clamp(1, 6)}@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state.verifyOtpStatus == RequestStatus.success) {
          _goToNewPasswordScreen();
        }
        if (state.resendOtpStatus == RequestStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('A new code has been sent'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(Responsive.w(16)),
            ),
          );
        }
        if (state.resendOtpStatus == RequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text(state.resendOtpError ?? 'Could not resend the code'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(Responsive.w(16)),
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  height: Responsive.h(220),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _HeaderContent(
                        icon: Icons.mark_email_read_outlined,
                        title: 'Verify Code',
                        subtitle: 'Code sent to $_maskedEmail',
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(22)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: Responsive.h(28)),
                    FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: BlocBuilder<ForgotPasswordBloc,
                              ForgotPasswordState>(
                            buildWhen: (previous, current) =>
                            previous.verifyOtpStatus !=
                                current.verifyOtpStatus,
                            builder: (context, state) {
                              final isVerifying = state.verifyOtpStatus ==
                                  RequestStatus.loading;
                              final serverError =
                              state.verifyOtpStatus == RequestStatus.failure
                                  ? state.verifyOtpError
                                  : null;
                              return _FormCard(
                                controllers: _controllers,
                                focusNodes: _focusNodes,
                                errorText: _localErrorText ?? serverError,
                                isVerifying: isVerifying,
                                secondsRemaining: _secondsRemaining,
                                onDigitChanged: _onDigitChanged,
                                onVerify: _onVerify,
                                onResend: _onResend,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Curved bottom edge for the header band — mirrors LoginScreen.
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HeaderContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _HeaderContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
        ),
        SizedBox(height: Responsive.h(8)),
        Container(
          width: Responsive.w(60),
          height: Responsive.w(60),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Responsive.w(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        SizedBox(height: Responsive.h(14)),
        Text(
          title,
          style: AppTextStyles.h1(color: AppColors.white).copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: Responsive.h(4)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(
            color: AppColors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String? errorText;
  final bool isVerifying;
  final int secondsRemaining;
  final void Function(int index, String value) onDigitChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _FormCard({
    required this.controllers,
    required this.focusNodes,
    required this.errorText,
    required this.isVerifying,
    required this.secondsRemaining,
    required this.onDigitChanged,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(24),
        Responsive.h(28),
        Responsive.w(24),
        Responsive.h(24),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Responsive.w(22)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter verification code', style: AppTextStyles.h2()),
          SizedBox(height: Responsive.h(4)),
          Text(
            'Enter the 6-digit code we sent to your email.',
            style: AppTextStyles.subtitle(),
          ),
          SizedBox(height: Responsive.h(26)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _kOtpLength,
                  (i) => _OtpDigitBox(
                controller: controllers[i],
                focusNode: focusNodes[i],
                hasError: errorText != null,
                onChanged: (v) => onDigitChanged(i, v),
              ),
            ),
          ),

          if (errorText != null) ...[
            SizedBox(height: Responsive.h(10)),
            Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 16),
                SizedBox(width: Responsive.w(6)),
                Text(errorText!,
                    style: AppTextStyles.caption(color: AppColors.error)),
              ],
            ),
          ],

          SizedBox(height: Responsive.h(20)),

          Center(
            child: secondsRemaining > 0
                ? Text(
              'Resend code in 0:${secondsRemaining.toString().padLeft(2, '0')}',
              style: AppTextStyles.caption(color: AppColors.textHint),
            )
                : TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, Responsive.h(28)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onResend,
              child: Text(
                "Didn't get the code? Resend",
                style: AppTextStyles.bodyBold(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(20)),

          _BrandButton(
            label: isVerifying ? 'Verifying…' : 'Verify Code',
            isLoading: isVerifying,
            onPressed: onVerify,
          ),
        ],
      ),
    );
  }
}

/// A single OTP digit box — square, centered, brand-highlighted on focus.
class _OtpDigitBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
  });

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = widget.focusNode.hasFocus);

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  Color get _borderColor {
    if (widget.hasError) return AppColors.error;
    if (_focused) return AppColors.primary;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive.w(46);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      width: size,
      height: size + 6,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor,
          width: _focused || widget.hasError ? 1.6 : 1.2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTextStyles.h1(color: AppColors.textPrimary)
              .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
          cursorColor: AppColors.primary,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ),
    );
  }
}

/// Primary CTA — matches LoginScreen's button.
class _BrandButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BrandButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

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
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
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