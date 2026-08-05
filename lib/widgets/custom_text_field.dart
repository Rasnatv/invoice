import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Standard rounded input field with a leading icon, used across Login,
/// Add Contractor, Create Estimate forms.
class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final Widget? suffix;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.suffix,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: AppTextStyles.body(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(color: AppColors.textHint),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textHint, size: 20) : null,
        suffixIcon: suffix,
      ),
    );
  }
}

/// Labeled form field wrapper (label above the input), used in
/// Create Estimate / Add Contractor forms.
class LabeledField extends StatelessWidget {
  final String label;
  final Widget field;
  const LabeledField({super.key, required this.label, required this.field});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyBold()),
        const SizedBox(height: 8),
        field,
        const SizedBox(height: 16),
      ],
    );
  }
}