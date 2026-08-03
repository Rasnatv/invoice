import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../data/model/salesman_getmodel.dart';

class OwnerAddSalesmanScreen extends StatefulWidget {
  const OwnerAddSalesmanScreen({super.key, this.salesman});
  final HSalesmanModel? salesman;

  @override
  State<OwnerAddSalesmanScreen> createState() => _OwnerAddSalesmanScreenState();
}

class _OwnerAddSalesmanScreenState extends State<OwnerAddSalesmanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.salesman?.name ?? '');
  late final _mobileCtrl = TextEditingController(text: widget.salesman?.mobile ?? '');
  late final _emailCtrl = TextEditingController(text: widget.salesman?.email ?? '');
  late final _salaryCtrl =
  TextEditingController(text: widget.salesman?.salary != null ? widget.salesman!.salary.toString() : '');
  DateTime? _joiningDate = null;

  bool get _isEditing => widget.salesman != null;

  @override
  void initState() {
    super.initState();
    _joiningDate = widget.salesman?.joiningDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _joiningDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final salesman = HSalesmanModel(
      id: widget.salesman?.id ?? DateTime.now().millisecondsSinceEpoch % 100000,
      name: _nameCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      salary: double.tryParse(_salaryCtrl.text.trim()) ?? 0,
      joiningDate: _joiningDate,
    );
    Navigator.of(context).pop(salesman);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Salesman' : 'Add Salesman', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(Responsive.w(16)),
            children: [
              Text('Full Name', style: AppTextStyles.bodyBold()),
              SizedBox(height: Responsive.h(6)),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Ramesh Kumar'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              SizedBox(height: Responsive.h(16)),
              Text('Mobile Number', style: AppTextStyles.bodyBold()),
              SizedBox(height: Responsive.h(6)),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'e.g. 9876543210'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                  if (v.trim().length < 10) return 'Enter a valid mobile number';
                  return null;
                },
              ),
              SizedBox(height: Responsive.h(16)),
              Text('Email', style: AppTextStyles.bodyBold()),
              SizedBox(height: Responsive.h(6)),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'e.g. ramesh@example.com'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                  return ok ? null : 'Enter a valid email';
                },
              ),
              SizedBox(height: Responsive.h(16)),
              Text('Salary', style: AppTextStyles.bodyBold()),
              SizedBox(height: Responsive.h(6)),
              TextFormField(
                controller: _salaryCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'e.g. 15000'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Salary is required';
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid amount';
                  return null;
                },
              ),
              SizedBox(height: Responsive.h(16)),
              Text('Joining Date', style: AppTextStyles.bodyBold()),
              SizedBox(height: Responsive.h(6)),
              InkWell(
                onTap: _pickJoiningDate,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(14)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _joiningDate == null
                        ? 'Select date'
                        : '${_joiningDate!.day}/${_joiningDate!.month}/${_joiningDate!.year}',
                    style: AppTextStyles.bodyBold().copyWith(fontSize: 13),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(28)),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Save Changes' : 'Add Salesman', style: AppTextStyles.bodyBold(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}