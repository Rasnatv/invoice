import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../models/owner_models/designationmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/designation/designationbloc.dart';
import '../../bloc/ownerbloc/designation/designationevent.dart';
import '../../bloc/ownerbloc/designation/designationstate.dart';


class AddDesignationPage extends StatefulWidget {
  final DesignationModel? designation;

  const AddDesignationPage({super.key, this.designation});

  bool get isEditing => designation != null;

  @override
  State<AddDesignationPage> createState() => _AddDesignationPageState();
}

class _AddDesignationPageState extends State<AddDesignationPage> {
  static const Color _primary = Color(0xFF2F5D50);
  static const Color _accent = Color(0xFFE8A33D);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  // ---------------- UNCHANGED: logic ----------------
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.designation?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final bloc = context.read<DesignationBloc>();

    if (widget.isEditing) {
      bloc.add(UpdateDesignation(id: widget.designation!.id, name: name));
    } else {
      bloc.add(AddDesignation(name));
    }
  }

  // ---------------- RESTYLED: UI ----------------
  InputDecoration _fieldDecoration() {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecoration(
      labelText: 'Designation name',
      hintText: 'e.g. Regional Sales Manager',
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      prefixIcon: const Icon(Icons.badge_outlined, color: _primary, size: 20),
      filled: true,
      fillColor: const Color(0xFFFAFAF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: border(const Color(0xFFE7E5E0)),
      enabledBorder: border(const Color(0xFFE7E5E0)),
      focusedBorder: border(_primary, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWrapper(child:Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditing ? 'Edit Designation' : 'Add Designation',
          style: AppTextStyles.h6(),
        ),
      ),
      body: BlocListener<DesignationBloc, DesignationState>(
        listener: (context, state) {
          if (state is DesignationActionSuccess) {
            if (state.message != null) AppSnackbar.success(state.message!);
            Navigator.pop(context);
          } else if (state is DesignationActionFailure) {
            if (state.message != null) AppSnackbar.error(state.message!);
          }
        },
        child: BlocBuilder<DesignationBloc, DesignationState>(
          builder: (context, state) {
            final isSubmitting = state is DesignationActionLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // NEW: header section
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.work_outline_rounded,
                                color: _primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isEditing
                                      ? 'Update designation'
                                      : 'New designation',
                                  style: AppTextStyles.bodyBold(),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.isEditing
                                      ? 'Update the designation name'
                                      : 'Create a new salesman designation',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // NEW: form card section
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7E5E0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Designation Details',
                                    style: AppTextStyles.bodyBold()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              autofocus: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => isSubmitting ? null : _submit(),
                              inputFormatters: DValidator.lettersOnly,
                              decoration: _fieldDecoration(),
                              validator: (value) {
                                // Use DValidator for validation
                                final nameValidator =
                                DValidator.validateName('Designation', value);
                                if (nameValidator != null) return nameValidator;

                                // Additional validation for minimum length
                                if (value != null && value.trim().length < 2) {
                                  return 'Designation name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: Responsive.h(48),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isSubmitting ? null : _submit,
                          child: isSubmitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isEditing
                                    ? Icons.check_circle_outline
                                    : Icons.add_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isEditing ? 'Save Changes' : 'Add Designation',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ));
  }
}