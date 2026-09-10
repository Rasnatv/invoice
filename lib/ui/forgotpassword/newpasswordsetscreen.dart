import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/forgotpswd/forgotpassword_bloc.dart';
import '../../bloc/forgotpswd/forgotpassword_event.dart';
import '../../bloc/forgotpswd/forgotpassword_state.dart';

/// Screen 3 of the flow — collects the new password and calls
/// POST /reset-password (email + otp carried forward in the bloc's state
/// from the earlier two screens). On success, replaces itself with
/// ResetSuccessScreen below.
class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<ForgotPasswordBloc>().add(
      SubmitNewPassword(
        password: _passwordController.text,
        passwordConfirmation: _confirmController.text,
      ),
    );
  }

  void _goToSuccessScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, anim, __) => const ResetSuccessScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (previous, current) =>
      previous.resetPasswordStatus != current.resetPasswordStatus,
      listener: (context, state) {
        if (state.resetPasswordStatus == RequestStatus.success) {
          _goToSuccessScreen();
        } else if (state.resetPasswordStatus == RequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  state.resetPasswordError ?? 'Could not reset password'),
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(22)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Container(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Set a new password',
                                style: AppTextStyles.h2()),
                            SizedBox(height: Responsive.h(4)),
                            Text(
                              'Your new password must be different from '
                                  'previously used passwords.',
                              style: AppTextStyles.subtitle(),
                            ),
                            SizedBox(height: Responsive.h(26)),
                            _PasswordField(
                              label: 'NEW PASSWORD',
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              hint: 'Enter new password',
                              obscureText: _obscurePassword,
                              onToggleObscure: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.length < 8) {
                                  return 'At least 8 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.h(18)),
                            _PasswordField(
                              label: 'CONFIRM PASSWORD',
                              controller: _confirmController,
                              focusNode: _confirmFocus,
                              hint: 'Re-enter new password',
                              obscureText: _obscureConfirm,
                              onToggleObscure: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                              validator: (v) {
                                if (v != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.h(24)),
                            BlocBuilder<ForgotPasswordBloc,
                                ForgotPasswordState>(
                              buildWhen: (previous, current) =>
                              previous.resetPasswordStatus !=
                                  current.resetPasswordStatus,
                              builder: (context, state) {
                                final isSubmitting =
                                    state.resetPasswordStatus ==
                                        RequestStatus.loading;
                                return _BrandButton(
                                  label: isSubmitting
                                      ? 'Saving…'
                                      : 'Reset Password',
                                  isLoading: isSubmitting,
                                  onPressed: _onSubmit,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.obscureText,
    required this.onToggleObscure,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(color: AppColors.textHint).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            fontSize: 11,
          ),
        ),
        SizedBox(height: Responsive.h(8)),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          validator: validator,
          style: AppTextStyles.body(color: AppColors.textPrimary),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: AppTextStyles.body(color: AppColors.textHint),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 4, right: 2),
              child: Icon(Icons.lock_outline_rounded, size: 19),
            ),
            prefixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 20),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19,
                color: AppColors.textHint,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1.6),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

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

// class _BrandButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;
//
//   const _BrandButton({required this.label, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           gradient: AppColors.primaryGradient,
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withOpacity(0.35),
//               blurRadius: 18,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(14),
//             onTap: onPressed,
//             child: Center(
//               child: Text(
//                 label,
//                 style: AppTextStyles.bodyBold(color: AppColors.white)
//                     .copyWith(fontSize: 15.5, letterSpacing: 0.2),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class _BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _BrandButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
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