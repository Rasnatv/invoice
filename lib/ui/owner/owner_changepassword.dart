import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class OwnerChangePasswordScreen extends StatefulWidget {
  const OwnerChangePasswordScreen({super.key});

  @override
  State<OwnerChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<OwnerChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Password rule states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updatePasswordRules);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_updatePasswordRules);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordRules() {
    final value = _newPasswordController.text;
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]/\\+=~`]').hasMatch(value);
    });
  }

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  String get _strengthLabel {
    if (_newPasswordController.text.isEmpty) return '';
    switch (_strengthScore) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
      case 3:
        return 'Medium';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return '';
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
      case 3:
        return Colors.orange;
      case 4:
        return AppColors.primary;
      case 5:
        return Colors.green;
      default:
        return AppColors.textHint;
    }
  }

  bool get _allRulesPassed =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_allRulesPassed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password does not meet all requirements'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Call your change password API here
      // Example:
      // await AuthRepository().changePassword(
      //   currentPassword: _currentPasswordController.text,
      //   newPassword: _newPasswordController.text,
      // );
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Change Password', style: AppTextStyles.h6())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(20)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Update your password', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(4)),
                Text(
                  'Please enter your current password and choose a new one.',
                  style: AppTextStyles.caption(),
                ),
                SizedBox(height: Responsive.h(28)),

                _PasswordField(
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.h(16)),

                _PasswordField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value == _currentPasswordController.text) {
                      return 'New password must be different from current password';
                    }
                    if (!_allRulesPassed) {
                      return 'Password does not meet all requirements';
                    }
                    return null;
                  },
                ),

                // Strength meter
                if (_newPasswordController.text.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(10)),
                  _StrengthMeter(score: _strengthScore, color: _strengthColor, label: _strengthLabel),
                ],

                SizedBox(height: Responsive.h(12)),

                // Requirements checklist
                _RequirementsChecklist(
                  hasMinLength: _hasMinLength,
                  hasUppercase: _hasUppercase,
                  hasLowercase: _hasLowercase,
                  hasNumber: _hasNumber,
                  hasSpecialChar: _hasSpecialChar,
                ),

                SizedBox(height: Responsive.h(16)),

                _PasswordField(
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.h(32)),

                SizedBox(
                  width: double.infinity,
                  height: Responsive.h(50),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleChangePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: Responsive.w(20),
                      width: Responsive.w(20),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'Update Password',
                      style: AppTextStyles.bodyBold(color: Colors.white),
                    ),
                  ),
                ),
              ],
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
  final bool obscureText;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body()),
        SizedBox(height: Responsive.h(6)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyles.body(),
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(14),
              vertical: Responsive.h(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.textHint,
                size: Responsive.w(20),
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  final int score; // 0 - 5
  final Color color;
  final String label;

  const _StrengthMeter({required this.score, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final filled = index < score;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 4 ? 0 : Responsive.w(4)),
                height: Responsive.h(6),
                decoration: BoxDecoration(
                  color: filled ? color : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: Responsive.h(6)),
        Text(
          'Strength: $label',
          style: AppTextStyles.caption(color: color),
        ),
      ],
    );
  }
}

class _RequirementsChecklist extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  const _RequirementsChecklist({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password must contain:', style: AppTextStyles.bodyBold()),
          SizedBox(height: Responsive.h(8)),
          _RuleRow(label: 'At least 8 characters', passed: hasMinLength),
          _RuleRow(label: 'One uppercase letter (A-Z)', passed: hasUppercase),
          _RuleRow(label: 'One lowercase letter (a-z)', passed: hasLowercase),
          _RuleRow(label: 'One number (0-9)', passed: hasNumber),
          _RuleRow(label: 'One special character (!@#\$%^&*)', passed: hasSpecialChar),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool passed;

  const _RuleRow({required this.label, required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed ? Colors.green : AppColors.textHint;
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(6)),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: Responsive.w(16),
            color: color,
          ),
          SizedBox(width: Responsive.w(8)),
          Text(
            label,
            style: AppTextStyles.caption(color: color),
          ),
        ],
      ),
    );
  }
}