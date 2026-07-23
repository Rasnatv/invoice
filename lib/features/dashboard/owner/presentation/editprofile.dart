import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialEmail;

  const EditProfileScreen({
    super.key,
    this.initialName = 'Rahul Kumar',
    this.initialPhone = '+91 98765 43210',
    this.initialEmail = 'rahul.sales@dreams.com',
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

  bool _isSaving = false;

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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    // TODO: replace with actual "update profile" API / bloc call.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 14),
                      ),
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
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  return null;
                },
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
                  final phoneRegex = RegExp(r'^\+?[0-9\s]{7,15}$');
                  if (value.isEmpty || !phoneRegex.hasMatch(value)) {
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
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (value.isEmpty || !emailRegex.hasMatch(value)) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.h(32)),

              _BrandButton(
                label: _isSaving ? 'Saving…' : 'Save Changes',
                isLoading: _isSaving,
                onPressed: _onSave,
              ),
              SizedBox(height: Responsive.h(20)),
            ],
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