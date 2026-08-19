
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/product_enums.dart';
import '../../bloc/ownerbloc/product/product_bloc.dart';
import '../../bloc/ownerbloc/product/product_event.dart';
import '../../bloc/ownerbloc/product/product_state.dart';
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
  late final TextEditingController _piecesPerBoxCtrl;
  late final TextEditingController _packingCtrl;

  String? _selectedCompanyId;
  String? _selectedUnitId;
  ProductIncentiveType _incentiveType = ProductIncentiveType.percentage;
  ProductBonusType _bonusType = ProductBonusType.single;

  // True once we've synced _selectedCompanyId/_selectedUnitId against the
  // loaded dropdown lists at least once. Prevents re-running the sync (and
  // fighting user edits) on every rebuild.
  bool _dropdownSelectionSynced = false;

  // True when the currently-selected unit's API record has
  // show_pieces_per_box = "1". Controls whether the packing / pieces-per-box
  // fields show up and get sent to the API.
  bool _isBoxUnit = false;

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
    _piecesPerBoxCtrl = TextEditingController(text: p?.piecesPerBox ?? '');
    _packingCtrl = TextEditingController(text: p?.packing ?? '');

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
    _piecesPerBoxCtrl.dispose();
    _packingCtrl.dispose();
    super.dispose();
  }

  /// Returns true when the selected unit's API record has
  /// show_pieces_per_box = "1". Driven entirely by the units/active
  /// response now — no more matching on unit name/abbreviation, so this
  /// keeps working automatically if more "box-type" units get added on
  /// the backend later.
  bool _computeIsBoxUnit(ProductState state) {
    if (_selectedUnitId == null) return false;
    final matches = state.units.where((u) => u.id == _selectedUnitId);
    if (matches.isEmpty) return false;
    return matches.first.showPiecesPerBox;
  }

  void _onUnitChanged(String? unitId, ProductState state) {
    setState(() {
      _selectedUnitId = unitId;
      _isBoxUnit = _computeIsBoxUnit(state);
      if (!_isBoxUnit) {
        _piecesPerBoxCtrl.clear();
        _packingCtrl.clear();
      }
    });
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
      _isBoxUnit = _computeIsBoxUnit(state);
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
        piecesPerBox: _isBoxUnit ? _piecesPerBoxCtrl.text.trim() : null,
        packing: _isBoxUnit ? _packingCtrl.text.trim() : null,
        isBoxUnit: _isBoxUnit,
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
        piecesPerBox: _isBoxUnit ? _piecesPerBoxCtrl.text.trim() : null,
        packing: _isBoxUnit ? _packingCtrl.text.trim() : null,
        isBoxUnit: _isBoxUnit,
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
                                    : (v) => _onUnitChanged(v, state),
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),

                  // Packing / pieces-per-box — only shown when the selected
                  // unit's show_pieces_per_box flag is true.
                  if (_isBoxUnit) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Packing'),
                              TextFormField(
                                controller: _packingCtrl,
                                decoration: const InputDecoration(hintText: 'e.g. 8pcs/box'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: Responsive.w(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Pieces per Box'),
                              TextFormField(
                                controller: _piecesPerBoxCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(hintText: 'e.g. 8'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(14)),
                  ],

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

                  _FieldLabel('Incentive Type'),
                  DropdownButtonFormField<ProductIncentiveType>(
                    isExpanded: true,
                    initialValue: _incentiveType,
                    decoration: const InputDecoration(hintText: 'Select incentive type'),
                    items: ProductIncentiveType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _incentiveType = v);
                    },
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

                  _FieldLabel('Bonus Type'),
                  DropdownButtonFormField<ProductBonusType>(
                    isExpanded: true,
                    initialValue: _bonusType,
                    decoration: const InputDecoration(hintText: 'Select bonus type'),
                    items: ProductBonusType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _bonusType = v);
                    },
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