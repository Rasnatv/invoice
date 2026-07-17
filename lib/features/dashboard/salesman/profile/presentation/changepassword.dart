// import 'package:flutter/material.dart';
// import '../../../../../core/constants/app_colors.dart';
// import '../../../../../core/constants/app_text_styles.dart';
// import '../../../../../core/utils/responsive.dart';
//
// class ChangePasswordScreen extends StatefulWidget {
//   const ChangePasswordScreen({super.key});
//
//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }
//
// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   bool _obscureCurrent = true;
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//
//   @override
//   void dispose() {
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       // TODO: call change password API
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password changed successfully')),
//       );
//       Navigator.of(context).pop();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Change Password', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: EdgeInsets.all(Responsive.w(20)),
//             children: [
//               _PasswordField(
//                 label: 'Current Password',
//                 controller: _currentPasswordController,
//                 obscure: _obscureCurrent,
//                 onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
//                 validator: (v) => (v == null || v.isEmpty) ? 'Enter current password' : null,
//               ),
//               SizedBox(height: Responsive.h(14)),
//               _PasswordField(
//                 label: 'New Password',
//                 controller: _newPasswordController,
//                 obscure: _obscureNew,
//                 onToggle: () => setState(() => _obscureNew = !_obscureNew),
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return 'Enter new password';
//                   if (v.length < 6) return 'Must be at least 6 characters';
//                   return null;
//                 },
//               ),
//               SizedBox(height: Responsive.h(14)),
//               _PasswordField(
//                 label: 'Confirm New Password',
//                 controller: _confirmPasswordController,
//                 obscure: _obscureConfirm,
//                 onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return 'Confirm your new password';
//                   if (v != _newPasswordController.text) return 'Passwords do not match';
//                   return null;
//                 },
//               ),
//               SizedBox(height: Responsive.h(28)),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: _submit,
//                   child: Text('Update Password', style: AppTextStyles.bodyBold(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _PasswordField extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final bool obscure;
//   final VoidCallback onToggle;
//   final String? Function(String?) validator;
//
//   const _PasswordField({
//     required this.label,
//     required this.controller,
//     required this.obscure,
//     required this.onToggle,
//     required this.validator,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscure,
//       validator: validator,
//       style: AppTextStyles.body(),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: AppTextStyles.caption(),
//         filled: true,
//         fillColor: AppColors.surface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide(color: AppColors.border),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide(color: AppColors.border),
//         ),
//         suffixIcon: IconButton(
//           icon: Icon(
//             obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//             color: AppColors.textHint,
//           ),
//           onPressed: onToggle,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: call change password API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Change Password', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---- Scrollable content ----
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                  child: Column(
                    children: [
                      SizedBox(height: Responsive.h(24)),
                      Container(
                        width: Responsive.w(64),
                        height: Responsive.w(64),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock_rounded, size: Responsive.w(28), color: AppColors.primary),
                      ),
                      SizedBox(height: Responsive.h(14)),
                      Text(
                        'Use 8 or more characters. Special characters aren\'t allowed.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(),
                      ),
                      SizedBox(height: Responsive.h(28)),
                      _PasswordField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        obscure: _obscureCurrent,
                        onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter current password' : null,
                      ),
                      SizedBox(height: Responsive.h(16)),
                      _PasswordField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        obscure: _obscureNew,
                        onToggle: () => setState(() => _obscureNew = !_obscureNew),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter new password';
                          if (v.length < 8) return 'Must be at least 8 characters';
                          if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\];/\\]').hasMatch(v)) {
                            return 'Special characters are not allowed';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.h(16)),
                      _PasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirm your new password';
                          if (v != _newPasswordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.h(20)),
                    ],
                  ),
                ),
              ),

              // ---- Fixed bottom button ----
              Container(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(20), Responsive.h(16), Responsive.w(20), Responsive.h(20),
                ),
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
                    onPressed: _submit,
                    child: Text('Update Password', style: AppTextStyles.bodyBold(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(12),
              vertical: Responsive.h(12),
            ),
            hintText: 'Enter ${label.toLowerCase()}',
            hintStyle: AppTextStyles.caption(),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textHint,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}