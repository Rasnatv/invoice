import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../core/validator/validationfile.dart';
import '../../widgets/appsnackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Note: DValidator.validatePassword() requires a special character, but
  // this screen's rule (see _PasswordTipsCard below) is the opposite —
  // special characters are disallowed. So we use DValidator.validateRequired
  // for the empty checks and keep this screen's own length/character rule.
  String? _validateNewPassword(String? v) {
    final required = DValidator.validateRequired(v, message: 'Enter new password');
    if (required != null) return required;
    if (v!.length < 8) return 'Must be at least 8 characters';
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\];/\\]').hasMatch(v)) {
      return 'Special characters are not allowed';
    }
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    final required = DValidator.validateRequired(v, message: 'Confirm your new password');
    if (required != null) return required;
    if (v != _newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePasswordRequested(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          newPasswordConfirmation: _confirmPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Change Password', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) => prev.passwordStatus != curr.passwordStatus,
          listener: (context, state) {
            if (state.passwordStatus == ProfileActionStatus.success) {
              AppSnackbar.success(state.passwordMessage ?? 'Password changed successfully');
              context.read<ProfileBloc>().add(const ResetProfileActionStatus());
              Navigator.of(context).pop();
            } else if (state.passwordStatus == ProfileActionStatus.failure) {
              AppSnackbar.error(state.passwordMessage ?? 'Something went wrong');
              context.read<ProfileBloc>().add(const ResetProfileActionStatus());
            }
          },
          builder: (context, state) {
            final isLoading = state.passwordStatus == ProfileActionStatus.loading;
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                      child: Column(
                        children: [
                          SizedBox(height: Responsive.h(24)),
                          Container(
                            width: Responsive.w(64),
                            height: Responsive.w(64),
                            decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                            child: Icon(Icons.lock_rounded, size: Responsive.w(28), color: AppColors.primary),
                          ),
                          SizedBox(height: Responsive.h(28)),
                          _PasswordField(
                            label: 'Current Password',
                            controller: _currentPasswordController,
                            obscure: _obscureCurrent,
                            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                            validator: (v) => DValidator.validateRequired(v, message: 'Enter current password'),
                          ),
                          SizedBox(height: Responsive.h(16)),
                          _PasswordField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            obscure: _obscureNew,
                            onToggle: () => setState(() => _obscureNew = !_obscureNew),
                            validator: _validateNewPassword,
                          ),
                          SizedBox(height: Responsive.h(16)),
                          _PasswordField(
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            obscure: _obscureConfirm,
                            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            validator: _validateConfirmPassword,
                          ),
                          SizedBox(height: Responsive.h(20)),
                          const _PasswordTipsCard(),
                          SizedBox(height: Responsive.h(20)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(Responsive.w(20), Responsive.h(16), Responsive.w(20), Responsive.h(20)),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : Text('Update Password', style: AppTextStyles.bodyBold(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PasswordTipsCard extends StatelessWidget {
  const _PasswordTipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: Responsive.w(16), color: AppColors.primary),
              SizedBox(width: Responsive.w(6)),
              Text('Password Tips', style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          const _TipRow(text: 'Use 8 or more characters'),
          SizedBox(height: Responsive.h(4)),
          const _TipRow(text: 'Special characters aren\'t allowed'),
          SizedBox(height: Responsive.h(4)),
          const _TipRow(text: 'Avoid reusing your current password'),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: Responsive.h(2)),
          child: Icon(Icons.circle, size: Responsive.w(4), color: AppColors.textHint),
        ),
        SizedBox(width: Responsive.w(8)),
        Expanded(child: Text(text, style: AppTextStyles.caption())),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        SizedBox(height: Responsive.h(6)),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(12)),
            hintText: 'Enter ${label.toLowerCase()}',
            hintStyle: AppTextStyles.caption(),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}