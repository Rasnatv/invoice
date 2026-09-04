import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../core/validator/validationfile.dart';
import '../../models/profilemodel.dart';
import '../../widgets/appsnackbar.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialEmail;

  const EditProfileScreen({
    super.key,
    this.initialName = '',
    this.initialPhone = '',
    this.initialEmail = '',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.read<ProfileBloc>().add(
      UpdateProfileRequested(
        ProfileModel(
          name: _nameController.text.trim(),
          mobile: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
      listener: (context, state) {
        if (state.updateStatus == ProfileActionStatus.success) {
          AppSnackbar.success(state.updateMessage ?? 'Profile updated successfully');
          context.read<ProfileBloc>().add(const ResetProfileActionStatus());
          Navigator.of(context).pop();
        } else if (state.updateStatus == ProfileActionStatus.failure) {
          AppSnackbar.error(state.updateMessage ?? 'Failed to update profile');
          context.read<ProfileBloc>().add(const ResetProfileActionStatus());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Edit Profile', style: AppTextStyles.h6()),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: BlocBuilder<ProfileBloc, ProfileState>(
              buildWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
              builder: (context, state) {
                final isSaving = state.updateStatus == ProfileActionStatus.loading;

                return ListView(
                  padding: EdgeInsets.all(Responsive.w(20)),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: Responsive.w(46),
                            backgroundColor: AppColors.primarySoft,
                            child: Icon(Icons.person,
                                size: Responsive.w(46), color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(28)),

                    const _FieldLabel('FULL NAME'),
                    SizedBox(height: Responsive.h(8)),
                    _BrandField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      hint: 'Your full name',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      validator: (v) => DValidator.validateName('Name', v),
                    ),
                    SizedBox(height: Responsive.h(20)),

                    const _FieldLabel('PHONE NUMBER'),
                    SizedBox(height: Responsive.h(8)),
                    _BrandField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      hint: '+91 98765 43210',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        // Some roles (e.g. owners in this API) legitimately
                        // have no phone on file — only validate format if
                        // something was actually entered. DValidator's
                        // phone validator expects an exact-length local
                        // number, so we keep this screen's own looser
                        // regex to allow the "+91 ..." format shown above.
                        if (value.isEmpty) return null;
                        final phoneRegex = RegExp(r'^\+?[0-9\s]{7,15}$');
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Invalid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.h(20)),

                    const _FieldLabel('EMAIL ADDRESS'),
                    SizedBox(height: Responsive.h(8)),
                    _BrandField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hint: 'you@company.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        // Some roles (e.g. drivers in this API) legitimately
                        // have no email on file, so DValidator.validateEmail
                        // (which requires a value) doesn't fit here directly.
                        if (value.isEmpty) return null;
                        return DValidator.validateEmail(value);
                      },
                    ),
                    SizedBox(height: Responsive.h(32)),

                    _BrandButton(
                      label: isSaving ? 'Saving…' : 'Save Changes',
                      isLoading: isSaving,
                      onPressed: _onSave,
                    ),
                    SizedBox(height: Responsive.h(20)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Small uppercase field label.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption(color: AppColors.textHint).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        fontSize: 11,
      ),
    );
  }
}

class _BrandField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _BrandField({
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.controller,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  State<_BrandField> createState() => _BrandFieldState();
}

class _BrandFieldState extends State<_BrandField> {
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

  @override
  Widget build(BuildContext context) {
    // FormField manages only the validation state — the border wraps just
    // the input box, and the error message renders as a separate line
    // underneath it (outside the border), not inside it.
    return FormField<String>(
      initialValue: widget.controller?.text ?? '',
      validator: widget.validator,
      builder: (field) {
        final hasError = field.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError
                      ? AppColors.error
                      : (_focused ? AppColors.primary : AppColors.border),
                  width: (_focused || hasError) ? 1.6 : 1.2,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                onChanged: (v) {
                  field.didChange(v);
                  widget.onChanged?.call(v);
                },
                style: AppTextStyles.body(color: AppColors.textPrimary),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.body(color: AppColors.textHint),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 2),
                    child: Icon(
                      widget.icon,
                      color: hasError
                          ? AppColors.error
                          : (_focused ? AppColors.primary : AppColors.textHint),
                      size: 19,
                    ),
                  ),
                  prefixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 20),
                  suffixIcon: widget.suffix,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                ),
              ),
            ),
            if (hasError) ...[
              SizedBox(height: Responsive.h(6)),
              Text(
                field.errorText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(color: AppColors.error),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Primary CTA — brand-red fill, matches the rest of the app's buttons.
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