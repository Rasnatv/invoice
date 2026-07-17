import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/product_incentive_model.dart';
import '../../../../core/utils/responsive.dart';

/// Add / edit a product's incentive setup.
/// No tiers, no annual targets — just the product info and a flat
/// incentive % applied to whatever sales it achieves.
class OwnerAddIncentiveProductScreen extends StatefulWidget {
  const OwnerAddIncentiveProductScreen({super.key, this.product});

  /// If null -> "Add" mode. If provided -> "Edit" mode, prefilled.
  final ProductIncentiveModel? product;

  @override
  State<OwnerAddIncentiveProductScreen> createState() => _OwnerAddIncentiveProductScreenState();
}

class _OwnerAddIncentiveProductScreenState extends State<OwnerAddIncentiveProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _mrpCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _incentiveCtrl;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _companyCtrl = TextEditingController(text: p?.company ?? '');
    _mrpCtrl = TextEditingController(text: p != null ? p.mrp.toString() : '');
    _rateCtrl = TextEditingController(text: p != null ? p.rate.toString() : '');
    _incentiveCtrl = TextEditingController(text: p != null ? p.incentivePercent.toString() : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _mrpCtrl.dispose();
    _rateCtrl.dispose();
    _incentiveCtrl.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final model = ProductIncentiveModel(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      mrp: double.parse(_mrpCtrl.text.trim()),
      rate: double.parse(_rateCtrl.text.trim()),
      incentivePercent: double.parse(_incentiveCtrl.text.trim()),
    );

    Navigator.of(context).pop(model);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(16), Responsive.w(16), Responsive.h(24)),
            children: [
              Text('Product Details', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
              SizedBox(height: Responsive.h(12)),
              _FieldLabel('Product Name'),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Vitrified Tile 600x600'),
                validator: _requiredValidator,
              ),
              SizedBox(height: Responsive.h(14)),
              _FieldLabel('Company'),
              TextFormField(
                controller: _companyCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Kajaria'),
                validator: _requiredValidator,
              ),
              SizedBox(height: Responsive.h(14)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('MRP (₹)'),
                        TextFormField(
                          controller: _mrpCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(hintText: 'e.g. 65'),
                          validator: _numberValidator,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Selling Rate (₹)'),
                        TextFormField(
                          controller: _rateCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(hintText: 'e.g. 55'),
                          validator: _numberValidator,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(20)),
              Text('Incentive', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
              SizedBox(height: Responsive.h(4)),
              Text(
                'Applied directly to whatever sales value this product achieves — no targets involved.',
                style: AppTextStyles.caption(),
              ),
              SizedBox(height: Responsive.h(12)),
              _FieldLabel('Incentive (%)'),
              TextFormField(
                controller: _incentiveCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'e.g. 5'),
                validator: _numberValidator,
              ),
              SizedBox(height: Responsive.h(28)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                  ),
                  onPressed: _save,
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Add Product',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(6)),
      child: Text(text, style: AppTextStyles.caption()),
    );
  }
}