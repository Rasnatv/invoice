import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tileshop/core/network/tokenstorage.dart';
import 'package:tileshop/core/utils/responsive.dart';
import '../../bloc/deleteacoount/deleteaccount_bloc.dart';
import '../../bloc/deleteacoount/deleteaccount_event.dart';
import '../../bloc/deleteacoount/deleteaccount_state.dart';
import '../../widgets/appsnackbar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
/// Asks for the password, calls DELETE /delete-account, and on success
/// clears the saved token and sends the user to the login screen.
Future<void> showDeleteAccountDialog(BuildContext context) {
  final rootContext = context;
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider(
      create: (_) => DeleteAccountBloc(),
      child: _DeleteAccountDialog(rootContext: rootContext),
    ),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.rootContext});
  final BuildContext rootContext;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context
        .read<DeleteAccountBloc>()
        .add(DeleteAccountSubmitted(_passwordCtrl.text));
  }

  Future<void> _onSuccess(String? message) async {
    final root = widget.rootContext;
    Navigator.of(context).pop(); // close dialog
    AppSnackbar.success(message ?? 'Your account has been deleted.');
    await TokenStorage.clear();
    if (root.mounted) {
      root.go('/login'); // adjust to your login route
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == DeleteAccountStatus.success) {
          _onSuccess(state.message);
        } else if (state.status == DeleteAccountStatus.failure) {
          AppSnackbar.error(state.message ?? 'Could not delete account.');
        }
      },
      builder: (context, state) {
        final submitting = state.isSubmitting;

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Delete Account', style: AppTextStyles.bodyBold()),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently delete your account. '
                      'Enter your password to confirm.',
                  style: AppTextStyles.subtitle()
                      .copyWith(fontSize: Responsive.sp(11.5)),
                ),
                SizedBox(height: Responsive.h(14)),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  enabled: !submitting,
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: AppTextStyles.body(color: AppColors.textHint),
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        size: 20, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password is required'
                      : null,
                  onFieldSubmitted: (_) => submitting ? null : _submit(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: submitting ? null : _submit,
              child: submitting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text('Delete',
                  style: AppTextStyles.bodyBold(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}