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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  // ---------------- logic (unchanged) ----------------
  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.designation?.name ?? '');
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

  // ---------------- UI ----------------
  InputDecoration _fieldDecoration() {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: 'Designation name',
      labelStyle: AppTextStyles.body(color: AppColors.textHint),
      hintText: 'e.g. Regional Sales Manager',
      hintStyle: AppTextStyles.body(color: AppColors.textHint),
      errorStyle: AppTextStyles.caption(color: AppColors.error),
      prefixIcon:
      Icon(Icons.badge_outlined, color: AppColors.textSecondary, size: 20),
      filled: true,
      isDense: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.w(14),
        vertical: Responsive.h(14),
      ),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates) ----------
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
                  padding: EdgeInsets.all(Responsive.w(20)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---- header: icon tile + title/subtitle ----
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.work_outline_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            SizedBox(width: Responsive.w(12)),
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
                                  SizedBox(height: Responsive.h(2)),
                                  Text(
                                    widget.isEditing
                                        ? 'Update the designation name'
                                        : 'Create a new salesman designation',
                                    style: AppTextStyles.caption(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(20)),

                        // ---- form card ----
                        Container(
                          padding: EdgeInsets.all(Responsive.w(16)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
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
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(width: Responsive.w(8)),
                                  Text('Designation Details',
                                      style: AppTextStyles.bodyBold()),
                                ],
                              ),
                              SizedBox(height: Responsive.h(16)),
                              TextFormField(
                                controller: _nameController,
                                autofocus: true,
                                style: AppTextStyles.body(),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                isSubmitting ? null : _submit(),
                                inputFormatters: DValidator.lettersOnly,
                                decoration: _fieldDecoration(),
                                validator: (value) {
                                  final nameValidator =
                                  DValidator.validateName(
                                      'Designation', value);
                                  if (nameValidator != null) {
                                    return nameValidator;
                                  }

                                  if (value != null &&
                                      value.trim().length < 2) {
                                    return 'Designation name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(24)),

                        // ---- submit ----
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
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.isEditing
                                      ? Icons.check_circle_outline
                                      : Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: Responsive.w(8)),
                                Text(
                                  widget.isEditing
                                      ? 'Save Changes'
                                      : 'Add Designation',
                                  style: AppTextStyles.bodyBold(
                                      color: Colors.white),
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
      ),
    );
  }
}