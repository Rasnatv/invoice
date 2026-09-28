
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/profilemodel.dart';
import '../../core/validator/validationfile.dart';
import '../../widgets/appsnackbar.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// API may return "+91 98765 43210" — keep only the last 10 digits so it
  /// passes the 10-digit formatter and validator.
  String _normalizePhone(String? raw) {
    var phone = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (phone.length > DValidator.defaultPhoneLength) {
      phone = phone.substring(phone.length - DValidator.defaultPhoneLength);
    }
    return phone;
  }

  void _enterEditMode(ProfileModel? profile) {
    _nameController.text = profile?.name ?? '';
    _emailController.text = profile?.email ?? '';
    _mobileController.text = _normalizePhone(profile?.mobile);
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    setState(() => _isEditing = false);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.read<ProfileBloc>().add(
      UpdateProfileRequested(
        ProfileModel(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _mobileController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'My Profile', style: AppTextStyles.h6()),
        leading: _isEditing
            ? IconButton(icon: const Icon(Icons.close), onPressed: _cancelEdit)
            : null,
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
          listener: (context, state) {
            if (state.updateStatus == ProfileActionStatus.success) {
              AppSnackbar.success(state.updateMessage ?? 'Profile updated successfully');
              context.read<ProfileBloc>().add(const ResetProfileActionStatus());
              setState(() => _isEditing = false);
            } else if (state.updateStatus == ProfileActionStatus.failure) {
              AppSnackbar.error(state.updateMessage ?? 'Something went wrong');
              context.read<ProfileBloc>().add(const ResetProfileActionStatus());
            }
          },
          builder: (context, state) {
            final profile = state.profile;
            final isSaving = state.updateStatus == ProfileActionStatus.loading;

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(20)),
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: Responsive.w(46),
                            backgroundColor: AppColors.primarySoft,
                            child: Icon(Icons.person, size: Responsive.w(46), color: AppColors.primary),
                          ),
                        ),
                        SizedBox(height: Responsive.h(24)),
                        if (_isEditing) ...[
                          _EditField(
                            label: 'Full Name',
                            hint: 'Your full name',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            inputFormatters: DValidator.lettersOnly,
                            validator: (v) => DValidator.validateName('Name', v),
                          ),
                          SizedBox(height: Responsive.h(16)),
                          _EditField(
                            label: 'Email',
                            hint: 'you@company.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: DValidator.textWithLimit, // max 100 chars
                            validator: (v) {
                              // Optional: some roles (e.g. drivers) have no email on file
                              if (v == null || v.trim().isEmpty) return null;
                              return DValidator.validateEmail(v);
                            },
                          ),
                          SizedBox(height: Responsive.h(16)),
                          _EditField(
                            label: 'Phone Number',
                            hint: '98765 43210',
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: DValidator.phoneNumber, // digits only, max 10
                            validator: (v) {
                              // Optional: some roles (e.g. owners) have no phone on file
                              if (v == null || v.trim().isEmpty) return null;
                              return DValidator.validatePhoneNumber(v); // exactly 10 digits
                            },
                          ),
                        ] else ...[
                          _ProfileField(label: 'Full Name', value: _display(profile?.name)),
                          _ProfileField(label: 'Phone Number', value: _display(profile?.mobile)),
                          _ProfileField(label: 'Email', value: _display(profile?.email)),
                        ],
                      ],
                    ),
                  ),
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
                        onPressed: isSaving
                            ? null
                            : (_isEditing ? _save : () => _enterEditMode(profile)),
                        child: isSaving
                            ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : Text(
                          _isEditing ? 'Save Changes' : 'Edit Profile',
                          style: AppTextStyles.bodyBold(color: Colors.white),
                        ),
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

  /// Shows '-' for null or empty values in view mode.
  String _display(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(12)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption()),
          SizedBox(height: Responsive.h(4)),
          Text(value, style: AppTextStyles.bodyBold(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _EditField({
    required this.label,
    required this.controller,
    required this.validator,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(12)),
            hintText: hint ?? 'Enter ${label.toLowerCase()}',
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
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