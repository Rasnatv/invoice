import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/salesmanmodel.dart';
import '../../../../core/utils/responsive.dart';

class OwnerAddSalesmanScreen extends StatefulWidget {
  const OwnerAddSalesmanScreen({super.key, this.salesman});
  final SalesmanModel? salesman;

  @override
  State<OwnerAddSalesmanScreen> createState() => _OwnerAddSalesmanScreenState();
}

class _OwnerAddSalesmanScreenState extends State<OwnerAddSalesmanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.salesman?.name ?? '');
  late final _mobileCtrl = TextEditingController(text: widget.salesman?.mobile ?? '');
  late final _emailCtrl = TextEditingController(text: widget.salesman?.email ?? '');
  late String _designation = widget.salesman?.designation ?? kSalesmanDesignations[1]; // Sales Executive

  bool get _isEditing => widget.salesman != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final salesman = SalesmanModel(
      id: widget.salesman?.id ?? 'SM-${DateTime.now().millisecondsSinceEpoch % 100000}',
      name: _nameCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      joinedDate: widget.salesman?.joinedDate ?? DateTime.now(),
      status: widget.salesman?.status ?? 'Active',
      designation: _designation,
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
              Text('Post', style: AppTextStyles.bodyBold()),
              SizedBox(height: Responsive.h(6)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _designation,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: kSalesmanDesignations
                        .map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d, style: AppTextStyles.bodyBold().copyWith(fontSize: 13)),
                    ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _designation = v);
                    },
                  ),
                ),
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