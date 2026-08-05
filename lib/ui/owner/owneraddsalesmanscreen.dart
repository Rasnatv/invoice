
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/designation_provider.dart';
import '../../models/owner_models/designationmodel.dart';
import '../../models/owner_models/salesmanmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/salesman_bloc.dart';
import '../../bloc/ownerbloc/salesman_event.dart';
import '../../bloc/ownerbloc/salesman_state.dart';


class OwnerAddSalesmanScreen extends StatefulWidget {
  const OwnerAddSalesmanScreen({super.key, this.salesman});

  final HSalesmanModel? salesman;

  bool get isEdit => salesman != null;

  @override
  State<OwnerAddSalesmanScreen> createState() =>
      _OwnerAddSalesmanScreenState();
}

class _OwnerAddSalesmanScreenState extends State<OwnerAddSalesmanScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _salaryCtrl;
  final _passwordCtrl = TextEditingController();

  DateTime? _joiningDate;
  bool _isActive = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  // Use DesignationProvider directly
  final _designationProvider = DesignationProvider();
  List<DesignationModel> _designations = [];
  DesignationModel? _selectedDesignation;
  bool _loadingDesignations = true;
  String? _designationError;

  @override
  void initState() {
    super.initState();
    final s = widget.salesman;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _mobileCtrl = TextEditingController(text: s?.mobile ?? '');
    _salaryCtrl = TextEditingController(
      text: s != null ? s.salary.toStringAsFixed(0) : '',
    );
    _joiningDate = s?.joiningDate;
    _loadDesignations();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _salaryCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDesignations() async {
    setState(() {
      _loadingDesignations = true;
      _designationError = null;
    });

    try {
      final result = await _designationProvider.getDesignations();

      if (!mounted) return;

      if (result.success) {
        // Preselect existing designation if in edit mode
        DesignationModel? preselected;
        final existingName = widget.salesman?.designationName;
        if (existingName != null && existingName.isNotEmpty) {
          for (final d in result.designations) {
            if (d.name.toLowerCase() == existingName.toLowerCase()) {
              preselected = d;
              break;
            }
          }
        }

        setState(() {
          _designations = result.designations;
          _selectedDesignation = preselected;
          _loadingDesignations = false;
        });
      } else {
        setState(() {
          _designationError = result.errorMessage ?? 'Failed to load designations';
          _loadingDesignations = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _designationError = e.toString().replaceAll('Exception: ', '');
        _loadingDesignations = false;
      });
    }
  }

  Future<void> _pickJoiningDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  String? _validateSalary(String? value) {
    final error = DValidator.validateRequired(value, message: 'Salary is required');
    if (error != null) return error;
    final parsed = num.tryParse(value!.trim());
    if (parsed == null) return 'Enter a valid salary';
    if (parsed <= 0) return 'Salary must be greater than 0';
    return null;
  }

  String? _validatePasswordOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DValidator.validatePassword(value);
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_joiningDate == null) {
      AppSnackbar.warning('Please select a joining date');
      return;
    }
    if (_selectedDesignation == null) {
      AppSnackbar.warning('Please select a designation');
      return;
    }
    if (!isValid) return;

    final bloc = context.read<SalesmanBloc>();
    final joiningDateStr = DateFormat('yyyy-MM-dd').format(_joiningDate!);
    final salary = num.tryParse(_salaryCtrl.text.trim()) ?? 0;

    // Use the designation ID from the selected model (it's a String)
    final designationId = _selectedDesignation!.id;

    if (widget.isEdit) {
      bloc.add(UpdateSalesman(
        id: widget.salesman!.id,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        designationId: designationId,
        mobile: _mobileCtrl.text.trim(),
        salary: salary,
        joiningDate: joiningDateStr,
        password: _passwordCtrl.text.trim().isEmpty
            ? null
            : _passwordCtrl.text.trim(),
        isActive: _isActive,
      ));
    } else {
      bloc.add(AddSalesman(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        designationId: designationId,
        mobile: _mobileCtrl.text.trim(),
        salary: salary,
        joiningDate: joiningDateStr,
        password: _passwordCtrl.text.trim().isEmpty
            ? null
            : _passwordCtrl.text.trim(),
        isActive: _isActive,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Salesman' : 'Add Salesman',
          style: AppTextStyles.h6(),
        ),
      ),
      body: BlocListener<SalesmanBloc, SalesmanState>(
        listener: (context, state) {
          if (state is SalesmanActionLoading) {
            setState(() => _isSubmitting = true);
          } else if (state is SalesmanActionSuccess) {
            setState(() => _isSubmitting = false);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else if (state is SalesmanActionFailure) {
            setState(() => _isSubmitting = false);
            AppSnackbar.error(state.message);
          }
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(Responsive.w(16)),
              children: [
                // Name Field
                Text('Name', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(6)),
                TextFormField(
                  controller: _nameCtrl,
                  inputFormatters: DValidator.lettersOnly,
                  validator: (v) => DValidator.validateName('Name', v),
                  decoration: const InputDecoration(hintText: 'Enter full name'),
                ),
                SizedBox(height: Responsive.h(16)),

                // Email Field
                Text('Email', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(6)),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: DValidator.textWithLimit,
                  validator: DValidator.validateEmail,
                  decoration: const InputDecoration(hintText: 'name@example.com'),
                ),
                SizedBox(height: Responsive.h(16)),

                // Mobile Field
                Text('Mobile', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(6)),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: DValidator.phoneNumber,
                  validator: (v) => DValidator.validatePhoneNumber(v),
                  decoration: const InputDecoration(hintText: '10-digit mobile number'),
                ),
                SizedBox(height: Responsive.h(16)),

                // Designation Field
                Text('Designation', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(6)),
                _buildDesignationField(),
                SizedBox(height: Responsive.h(16)),

                // Salary Field
                Text('Salary', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(6)),
                TextFormField(
                  controller: _salaryCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: DValidator.digitsOnly,
                  validator: _validateSalary,
                  decoration: const InputDecoration(hintText: 'Monthly salary'),
                ),
                SizedBox(height: Responsive.h(16)),

                // Joining Date Field
                Text('Joining Date', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(6)),
                InkWell(
                  onTap: _pickJoiningDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.textSecondary),
                        SizedBox(width: Responsive.w(8)),
                        Text(
                          _joiningDate != null
                              ? DateFormat('dd-MM-yyyy').format(_joiningDate!)
                              : 'Select joining date',
                          style: _joiningDate != null
                              ? AppTextStyles.caption()
                              : AppTextStyles.caption()
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(16)),

                // Password field (optional - only for new salesmen)

                  SizedBox(height: Responsive.h(16)),

                // Active toggle (only for edit mode)
                if (widget.isEdit) ...[
                  Row(
                    children: [
                      Switch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.bodyBold(),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),
                ],

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size.fromHeight(Responsive.h(48)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    widget.isEdit ? 'Update Salesman' : 'Add Salesman',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesignationField() {
    if (_loadingDesignations) {
      return const LinearProgressIndicator(minHeight: 2);
    }

    if (_designationError != null) {
      return Container(
        padding: EdgeInsets.all(Responsive.w(12)),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(_designationError!, style: AppTextStyles.caption()),
            ),
            TextButton(
              onPressed: _loadDesignations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_designations.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Responsive.w(12)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text('No designations found', style: AppTextStyles.caption()),
            ),
            TextButton(
              onPressed: _loadDesignations,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<DesignationModel>(
      value: _selectedDesignation,
      isExpanded: true,
      decoration: const InputDecoration(
        hintText: 'Select designation',
        border: OutlineInputBorder(),
      ),
      items: _designations
          .map((d) => DropdownMenuItem(
        value: d,
        child: Text(d.name),
      ))
          .toList(),
      onChanged: (v) => setState(() => _selectedDesignation = v),
      validator: (v) => v == null ? 'Please select a designation' : null,
    );
  }
}