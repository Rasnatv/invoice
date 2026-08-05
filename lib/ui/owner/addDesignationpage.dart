
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../models/owner_models/designationmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/designationbloc.dart';
import '../../bloc/ownerbloc/designationevent.dart';
import '../../bloc/ownerbloc/designationstate.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            AppSnackbar.success(state.message);
            Navigator.pop(context);
          } else if (state is DesignationActionFailure) {
            AppSnackbar.error(state.message);
          }
        },
        child: BlocBuilder<DesignationBloc, DesignationState>(
          builder: (context, state) {
            final isSubmitting = state is DesignationActionLoading;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isEditing
                          ? 'Update the designation name'
                          : 'Create a new salesman designation',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => isSubmitting ? null : _submit(),
                      inputFormatters: DValidator.lettersOnly,
                      decoration: InputDecoration(
                        labelText: 'Designation name',
                        hintText: 'e.g. Regional Sales Manager',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE7E5E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE7E5E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primary, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        // Use DValidator for validation
                        final nameValidator = DValidator.validateName('Designation', value);
                        if (nameValidator != null) return nameValidator;

                        // Additional validation for minimum length
                        if (value != null && value.trim().length < 2) {
                          return 'Designation name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: Responsive.h(48),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
                            : Text(
                          widget.isEditing ? 'Save Changes' : 'Add Designation',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}