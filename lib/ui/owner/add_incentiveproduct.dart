
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/product_enums.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../models/owner_models/addproductmodel.dart';
import '../../models/owner_models/getproductmodel.dart';
import '../../models/owner_models/updateproductmodel.dart';

/// Public entry point — wraps the form in its own BlocProvider so callers
/// don't need to know ProductBloc exists.
class AddIncentiveProductScreen extends StatelessWidget {
  const AddIncentiveProductScreen({super.key, this.product});

  /// If null -> "Add" mode. If provided -> "Edit" mode, prefilled.
  /// NOTE: the list API doesn't return incentive_type / bonus_type /
  /// min_quantity, so those three fields fall back to their defaults in
  /// edit mode. company_id and unit_id ARE returned and are prefilled.
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc()..add(const LoadProductDropdowns()),
      child: _AddIncentiveProductForm(product: product),
    );
  }
}

class _AddIncentiveProductForm extends StatefulWidget {
  const _AddIncentiveProductForm({this.product});

  final ProductModel? product;

  @override
  State<_AddIncentiveProductForm> createState() => _AddIncentiveProductFormState();
}

class _AddIncentiveProductFormState extends State<_AddIncentiveProductForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _mrpCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _incentivePercentCtrl;
  late final TextEditingController _incentiveFixedCtrl;
  late final TextEditingController _minQuantityCtrl;

  String? _selectedCompanyId;
  String? _selectedUnitId;
  ProductIncentiveType _incentiveType = ProductIncentiveType.percentage;
  ProductBonusType _bonusType = ProductBonusType.single;

  // True once we've synced _selectedCompanyId/_selectedUnitId against the
  // loaded dropdown lists at least once. Prevents re-running the sync (and
  // fighting user edits) on every rebuild.
  bool _dropdownSelectionSynced = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _sizeCtrl = TextEditingController(text: p?.size ?? '');
    _mrpCtrl = TextEditingController(text: p != null ? p.mrp.toString() : '');
    _rateCtrl = TextEditingController(text: p != null ? p.rate.toString() : '');
    _incentivePercentCtrl =
        TextEditingController(text: p != null ? p.incentivePercentage.toString() : '');
    _incentiveFixedCtrl =
        TextEditingController(text: p != null ? p.incentiveAmount.toString() : '');
    _minQuantityCtrl = TextEditingController(text: '0');

    // Prefill dropdown selections from the product being edited.
    _selectedCompanyId = p?.companyId;
    _selectedUnitId = p?.unitId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sizeCtrl.dispose();
    _mrpCtrl.dispose();
    _rateCtrl.dispose();
    _incentivePercentCtrl.dispose();
    _incentiveFixedCtrl.dispose();
    _minQuantityCtrl.dispose();
    super.dispose();
  }

  /// Once companies/units have actually loaded, make sure the ids we
  /// prefilled from widget.product really exist in those lists. If a
  /// product references a company/unit that's since been deactivated (so
  /// it's missing from the "active" dropdown list), fall back to null
  /// instead of leaving DropdownButtonFormField pointed at a value with no
  /// matching item (which Flutter renders as blank with no error).
  void _syncDropdownSelectionsIfNeeded(ProductState state) {
    if (_dropdownSelectionSynced) return;
    if (state.dropdownStatus != DropdownStatus.loaded) return;

    final companyExists =
    state.companies.any((c) => c.id == _selectedCompanyId);
    final unitExists = state.units.any((u) => u.id == _selectedUnitId);

    setState(() {
      if (!companyExists) _selectedCompanyId = null;
      if (!unitExists) _selectedUnitId = null;
      _dropdownSelectionSynced = true;
    });
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

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompanyId == null || _selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a company and a unit.')),
      );
      return;
    }

    final bloc = context.read<ProductBloc>();

    if (_isEditing) {
      bloc.add(UpdateProduct(ProductUpdateRequestModel(
        id: widget.product!.id,
        name: _nameCtrl.text.trim(),
        companyId: _selectedCompanyId!,
        size: _sizeCtrl.text.trim(),
        unitId: _selectedUnitId!,
        mrp: double.parse(_mrpCtrl.text.trim()),
        rate: double.parse(_rateCtrl.text.trim()),
        incentiveType: _incentiveType,
        incentivePercentage: _incentiveType == ProductIncentiveType.percentage
            ? double.parse(_incentivePercentCtrl.text.trim())
            : null,
        incentiveAmount: _incentiveType == ProductIncentiveType.fixed
            ? double.parse(_incentiveFixedCtrl.text.trim())
            : null,
        bonusType: _bonusType,
        minQuantity: _bonusType == ProductBonusType.bulk
            ? _minQuantityCtrl.text.trim()
            : '0',
      )));
    } else {
      bloc.add(CreateProduct(ProductAddRequestModel(
        name: _nameCtrl.text.trim(),
        companyId: _selectedCompanyId!,
        size: _sizeCtrl.text.trim(),
        unitId: _selectedUnitId!,
        mrp: double.parse(_mrpCtrl.text.trim()),
        rate: double.parse(_rateCtrl.text.trim()),
        incentiveType: _incentiveType,
        incentivePercentage: _incentiveType == ProductIncentiveType.percentage
            ? double.parse(_incentivePercentCtrl.text.trim())
            : null,
        incentiveAmount: _incentiveType == ProductIncentiveType.fixed
            ? double.parse(_incentiveFixedCtrl.text.trim())
            : null,
        bonusType: _bonusType,
        minQuantity: _bonusType == ProductBonusType.bulk
            ? (int.tryParse(_minQuantityCtrl.text.trim()) ?? 0)
            : 0,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: BlocConsumer<ProductBloc, ProductState>(
          listenWhen: (previous, current) =>
          previous.status != current.status ||
              previous.errorMessage != current.errorMessage ||
              previous.dropdownStatus != current.dropdownStatus,
          listener: (context, state) {
            if (state.status == ProductStatus.actionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage ?? 'Saved successfully.')),
              );
              Navigator.of(context).pop(true);
            } else if (state.status == ProductStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }

            // Re-check the prefilled company/unit ids as soon as the
            // dropdown lists finish loading.
            if (state.dropdownStatus == DropdownStatus.loaded) {
              _syncDropdownSelectionsIfNeeded(state);
            }
          },
          builder: (context, state) {
            final isSaving = state.status == ProductStatus.actionInProgress;
            final dropdownsLoading = state.dropdownStatus == DropdownStatus.loading;
            final dropdownsFailed = state.dropdownStatus == DropdownStatus.error;

            // Also try syncing on build (covers the case where dropdowns
            // were already loaded before listener ever fired, e.g. hot
            // reload during development).
            if (state.dropdownStatus == DropdownStatus.loaded && !_dropdownSelectionSynced) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _syncDropdownSelectionsIfNeeded(state);
              });
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                    Responsive.w(16), Responsive.h(16), Responsive.w(16), Responsive.h(24)),
                children: [
                  Text('Product Details',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
                  SizedBox(height: Responsive.h(12)),

                  _FieldLabel('Product Name'),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. Marvel Statuario'),
                    validator: _requiredValidator,
                  ),
                  SizedBox(height: Responsive.h(14)),

                  _FieldLabel('Company'),
                  if (dropdownsFailed)
                    _DropdownRetry(
                      message: state.errorMessage ?? 'Failed to load companies.',
                      onRetry: () =>
                          context.read<ProductBloc>().add(const LoadProductDropdowns()),
                    )
                  else
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedCompanyId,
                      decoration: InputDecoration(
                        hintText: dropdownsLoading ? 'Loading...' : 'Select company',
                      ),
                      items: state.companies
                          .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.label, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: dropdownsLoading
                          ? null
                          : (v) => setState(() => _selectedCompanyId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  SizedBox(height: Responsive.h(14)),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Size'),
                            TextFormField(
                              controller: _sizeCtrl,
                              decoration: const InputDecoration(hintText: 'e.g. 600x1200'),
                              validator: _requiredValidator,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Responsive.w(12)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Unit'),
                            if (dropdownsFailed)
                              const SizedBox.shrink()
                            else
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _selectedUnitId,
                                decoration: InputDecoration(
                                  hintText: dropdownsLoading ? 'Loading...' : 'Select',
                                ),
                                items: state.units
                                    .map((u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Text(u.label, overflow: TextOverflow.ellipsis),
                                ))
                                    .toList(),
                                onChanged: dropdownsLoading
                                    ? null
                                    : (v) => setState(() => _selectedUnitId = v),
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                          ],
                        ),
                      ),
                    ],
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
                              decoration: const InputDecoration(hintText: 'e.g. 650'),
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
                              decoration: const InputDecoration(hintText: 'e.g. 50'),
                              validator: _numberValidator,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(20)),

                  Text('Incentive',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
                  SizedBox(height: Responsive.h(10)),
                  _SegmentedToggle<ProductIncentiveType>(
                    value: _incentiveType,
                    options: ProductIncentiveType.values,
                    labelBuilder: (t) => t.label,
                    onChanged: (v) => setState(() => _incentiveType = v),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  if (_incentiveType == ProductIncentiveType.percentage) ...[
                    _FieldLabel('Incentive (%)'),
                    TextFormField(
                      controller: _incentivePercentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'e.g. 5'),
                      validator: _numberValidator,
                    ),
                  ] else ...[
                    _FieldLabel('Incentive Amount (₹)'),
                    TextFormField(
                      controller: _incentiveFixedCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'e.g. 20'),
                      validator: _numberValidator,
                    ),
                  ],
                  SizedBox(height: Responsive.h(20)),

                  Text('Bonus',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
                  SizedBox(height: Responsive.h(10)),
                  _SegmentedToggle<ProductBonusType>(
                    value: _bonusType,
                    options: ProductBonusType.values,
                    labelBuilder: (t) => t.label,
                    onChanged: (v) => setState(() => _bonusType = v),
                  ),
                  if (_bonusType == ProductBonusType.bulk) ...[
                    SizedBox(height: Responsive.h(12)),
                    _FieldLabel('Minimum Quantity'),
                    TextFormField(
                      controller: _minQuantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 5'),
                      validator: _numberValidator,
                    ),
                  ],
                  SizedBox(height: Responsive.h(28)),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                      ),
                      onPressed: isSaving ? null : () => _save(context),
                      child: isSaving
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Text(
                        _isEditing ? 'Save Changes' : 'Add Product',
                        style:
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ));
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

class _DropdownRetry extends StatelessWidget {
  const _DropdownRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(message, style: AppTextStyles.caption().copyWith(color: AppColors.error)),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

/// Simple two-way segmented control used for incentive_type / bonus_type.
class _SegmentedToggle<T> extends StatelessWidget {
  const _SegmentedToggle({
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final selected = option == value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: option == options.last ? 0 : Responsive.w(10)),
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  labelBuilder(option),
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
