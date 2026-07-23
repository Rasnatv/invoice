import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/product_incentive_model.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/owner_cubit.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key, this.product});
  final ProductIncentiveModel? product;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  late final _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
  late final _companyCtrl = TextEditingController(text: widget.product?.company ?? '');
  late final _mrpCtrl = TextEditingController(text: widget.product?.mrp.toStringAsFixed(0) ?? '');
  late final _rateCtrl = TextEditingController(text: widget.product?.rate.toStringAsFixed(0) ?? '');
  late final _incentiveCtrl = TextEditingController(text: widget.product?.incentivePercent.toStringAsFixed(1) ?? '');


  bool get _isEditing => widget.product != null;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _companyCtrl,
      _mrpCtrl,
      _rateCtrl,
      _incentiveCtrl,

    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter product name'), backgroundColor: AppColors.error));
      return;
    }
    final product = ProductIncentiveModel(
      id: widget.product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      mrp: double.tryParse(_mrpCtrl.text) ?? 0,
      rate: double.tryParse(_rateCtrl.text) ?? 0,
      incentivePercent: double.tryParse(_incentiveCtrl.text) ?? 0,
    );
    if (_isEditing) {
      context.read<OwnerCubit>().updateProduct(product);
    } else {
      context.read<OwnerCubit>().addProduct(product);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Product'),
                    content: const Text('This will remove the product from the incentive list.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  context.read<OwnerCubit>().deleteProduct(widget.product!.id);
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.w(18)),
        children: [
          LabeledField(
            label: 'Product Name',
            field: CustomTextField(hint: 'e.g. Vitrified Tile 600x600', icon: Icons.inventory_2_outlined, controller: _nameCtrl),
          ),
          LabeledField(
            label: 'Company',
            field: CustomTextField(hint: 'Enter company', icon: Icons.factory_outlined, controller: _companyCtrl),
          ),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'MRP',
                  field: CustomTextField(hint: '0', icon: Icons.currency_rupee, keyboardType: TextInputType.number, controller: _mrpCtrl),
                ),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: LabeledField(
                  label: 'Rate',
                  field: CustomTextField(hint: '0', icon: Icons.currency_rupee, keyboardType: TextInputType.number, controller: _rateCtrl),
                ),
              ),
            ],
          ),
          LabeledField(
            label: 'Base Incentive %',
            field: CustomTextField(hint: 'e.g. 5', icon: Icons.percent, keyboardType: TextInputType.number, controller: _incentiveCtrl),
          ),
          SizedBox(height: Responsive.h(10)),
          Text('Annual Target Bonus Slabs', style: AppTextStyles.h3()),
          SizedBox(height: Responsive.h(4)),
          Text(
            'Extra incentive % on top of the base %, unlocked once a salesman crosses each annual sales '
            'target for this product (e.g. ₹1,00,000 → +1%, ₹2,00,000 → +2%).',
            style: AppTextStyles.caption(),
          ),
          SizedBox(height: Responsive.h(10)),

          SizedBox(height: Responsive.h(20)),
          PrimaryButton(label: _isEditing ? 'Update Product' : 'Save Product', height: 48, onPressed: _save),
          SizedBox(height: Responsive.h(20)),
        ],
      ),
    );
  }
}
