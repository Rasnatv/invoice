
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';

import '../../../core/apiclient/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';

import '../../models/owner_models/ownerestimate_updatemodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/primary_button.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';

/// Shared numeric formatter — mirrors the `_formatPrice` helper used on
/// the Owner Quotation Edit screen: whole numbers render without a
/// trailing ".0".
String _formatQty(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

bool _parseBool(dynamic v) {
  if (v is bool) return v;
  final s = v?.toString().toLowerCase() ?? '';
  return s == '1' || s == 'true';
}

/// Active-catalog product, parsed loosely since the shape of
/// GET /products/active isn't modeled elsewhere yet. Extended with
/// company/unit/mrp (on top of the old id/name/size/rate/isBoxUnit) so
/// the Add/Edit Item form below can auto-fill the same fields as
/// OwnerQuotationEditScreen's `ActiveProductModel`.
class _ActiveProduct {
  final String id;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double rate;
  final double mrp;
  final bool isBoxUnit;

  const _ActiveProduct({
    required this.id,
    required this.name,
    this.company = '',
    this.size = '',
    this.unit = '',
    required this.rate,
    this.mrp = 0,
    this.isBoxUnit = false,
  });

  factory _ActiveProduct.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return _ActiveProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['product_name'] ?? '').toString(),
      company: (json['company'] ?? json['company_name'] ?? '').toString(),
      size: (json['size'] ?? json['product_size'] ?? '').toString(),
      unit: (json['unit'] ?? json['product_unit'] ?? '').toString(),
      rate: parseNum(json['rate'] ?? json['default_rate'] ?? json['selling_rate']),
      mrp: parseNum(json['mrp']),
      // Accept a couple of likely key spellings from the API rather than
      // assuming one, same defensiveness as the rest of this loose model.
      isBoxUnit: _parseBool(
        json['is_box_unit'] ?? json['isBoxUnit'] ?? json['box_unit'],
      ),
    );
  }
}

/// One saved line item in the estimate being edited.
///
/// This replaces the old per-row `_EditableItem` (a bundle of
/// TextEditingControllers rendered inline for every row) with a plain
/// value object built from a single shared Add/Edit Item form — the same
/// architecture OwnerQuotationEditScreen uses for its `_OwnerEditItem`.
/// That form-based flow is what actually lets you pick a product,
/// fill in quantity/rate, and explicitly commit the row with an
/// Add Item / Update Item button, instead of relying on a dropdown
/// embedded in a scrolling list of rows.
class _EstimateEditItem {
  const _EstimateEditItem({
    required this.productId,
    required this.name,
    this.company = '',
    this.size = '',
    this.unit = '',
    required this.quantity,
    required this.rate,
    this.mrp = 0,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    this.isBoxUnit = false,
  });

  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double quantity;
  final double rate;
  final double mrp;
  final double boxQuantity;
  final double pieceQuantity;
  final bool isBoxUnit;

  double get amount => quantity * rate;

  _EstimateEditItem copyWith({
    String? company,
    String? size,
    String? unit,
    double? mrp,
    bool? isBoxUnit,
  }) {
    return _EstimateEditItem(
      productId: productId,
      name: name,
      company: company ?? this.company,
      size: size ?? this.size,
      unit: unit ?? this.unit,
      quantity: quantity,
      rate: rate,
      mrp: mrp ?? this.mrp,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
      isBoxUnit: isBoxUnit ?? this.isBoxUnit,
    );
  }
}

/// Screen for editing an estimate's customer details, notes, terms, date
/// and item list via POST /estimates/update. Expects to be pushed with a
/// `BlocProvider.value` sharing the same [OwnerEstimateDetailBloc] as the
/// detail screen that opened it, so a successful update also refreshes
/// that screen's state.
class OwnerEstimateUpdateScreen extends StatefulWidget {
  const OwnerEstimateUpdateScreen({super.key, required this.detail});
  final EstimateDetailModel detail;

  @override
  State<OwnerEstimateUpdateScreen> createState() => _OwnerEstimateUpdateScreenState();
}

class _OwnerEstimateUpdateScreenState extends State<OwnerEstimateUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _termsCtrl;
  DateTime? _date;

  // ---- Saved items ----
  final List<_EstimateEditItem> _items = [];

  // ---- Add / edit item form (mirrors OwnerQuotationEditScreen) ----
  _ActiveProduct? _selectedProduct;
  int? _editingItemIndex;
  final _productSearchCtrl = TextEditingController();
  final _productSearchFocus = FocusNode();
  bool _showProductSuggestions = false;
  final _itemCompanyCtrl = TextEditingController();
  final _itemSizeCtrl = TextEditingController();
  final _itemUnitCtrl = TextEditingController();
  final _itemMrpCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemBoxQtyCtrl = TextEditingController();
  final _itemPieceQtyCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();

  List<_ActiveProduct> _products = [];
  bool _loadingProducts = true;

  /// Guards the catalog backfill so it only ever runs once, the same way
  /// OwnerQuotationEditScreen._backfilledFromCatalog guards its
  /// company/MRP backfill.
  bool _backfilledFromCatalog = false;

  /// Whether the item currently being added/edited is a box-unit
  /// product — drives whether Box/Piece Quantity show at all, and
  /// whether Box Quantity auto-syncs from Quantity. Falls back to the
  /// item being edited (if any) when no fresh product was picked in
  /// this form session.
  bool get _isBoxUnitProduct {
    if (_selectedProduct != null) return _selectedProduct!.isBoxUnit;
    if (_editingItemIndex != null) return _items[_editingItemIndex!].isBoxUnit;
    return false;
  }

  double get _computedQuantity => double.tryParse(_itemQtyCtrl.text.trim()) ?? 0;

  double get _currentItemAmount {
    final rate = double.tryParse(_itemRateCtrl.text.trim()) ?? 0;
    return _computedQuantity * rate;
  }

  /// Live-sync only: keeps the visible Box Quantity field in sync with
  /// Quantity for box-unit products, the same way
  /// OwnerQuotationEditScreen._recomputeBoxQtyIfNeeded does. Must only
  /// be called from the Quantity field's onChanged — never used to seed
  /// Box Quantity when an existing item is loaded into the form for
  /// editing (see _editItem, which reads the item's own saved value).
  void _recomputeBoxQtyIfNeeded() {
    if (!_isBoxUnitProduct) return;
    _itemBoxQtyCtrl.text = _itemQtyCtrl.text;
  }

  @override
  void initState() {
    super.initState();
    final d = widget.detail;
    _nameCtrl = TextEditingController(text: d.customerName);
    _phoneCtrl = TextEditingController(text: d.customerPhone);
    _addressCtrl = TextEditingController(text: d.customerAddress);
    _emailCtrl = TextEditingController(text: d.customerEmail);
    _notesCtrl = TextEditingController(text: d.notes);
    _termsCtrl = TextEditingController(text: d.termsConditions);
    _date = d.date;

    for (final item in d.items) {
      _items.add(_EstimateEditItem(
        productId: item.productId,
        name: item.productName,
        // Seed from the estimate's own saved values
        // (EstimateDetailItem.quantity/.boxQuantity/.pieceQuantity/.rate)
        // — these must come from the item's own stored fields, not be
        // guessed.
        quantity: item.quantity,
        boxQuantity: item.boxQuantity,
        pieceQuantity: item.pieceQuantity,
        rate: item.rate,
        // company/size/unit/isBoxUnit are unknown until the active
        // products catalog loads and we can match this row's productId
        // against it — see _backfillFromCatalog, called once
        // _loadProducts() resolves.
      ));
    }

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await ApiClient().activeProducts();
      final body = response.data;
      List<dynamic> rawList = const [];
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['list'] is List) {
          rawList = data['list'] as List;
        }
      } else if (body is List) {
        rawList = body;
      }
      final parsed = rawList
          .whereType<Map>()
          .map((e) => _ActiveProduct.fromJson(e.cast<String, dynamic>()))
          .toList();
      if (mounted) {
        setState(() {
          _products = parsed;
          _loadingProducts = false;
        });
        _backfillFromCatalog();
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  _ActiveProduct? _findProduct(String productId) {
    for (final p in _products) {
      if (p.id == productId) return p;
    }
    return null;
  }

  /// Fills in company/size/unit/isBoxUnit for pre-existing rows once the
  /// active-products catalog is available (GET /products/active isn't
  /// known at the time the initial rows are built from `d.items`).
  /// Mirrors OwnerQuotationEditScreen._backfillCompanyAndMrp.
  void _backfillFromCatalog() {
    if (_backfilledFromCatalog || _products.isEmpty) return;
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      final row = _items[i];
      if (row.productId.isEmpty) continue;
      final match = _findProduct(row.productId);
      if (match == null) continue;
      _items[i] = row.copyWith(
        company: match.company,
        size: row.size.isEmpty ? match.size : row.size,
        unit: row.unit.isEmpty ? match.unit : row.unit,
        mrp: match.mrp,
        isBoxUnit: match.isBoxUnit,
      );
      changed = true;
    }
    _backfilledFromCatalog = true;
    if (changed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    _termsCtrl.dispose();
    _productSearchCtrl.dispose();
    _productSearchFocus.dispose();
    _itemCompanyCtrl.dispose();
    _itemSizeCtrl.dispose();
    _itemUnitCtrl.dispose();
    _itemMrpCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemBoxQtyCtrl.dispose();
    _itemPieceQtyCtrl.dispose();
    _itemRateCtrl.dispose();
    super.dispose();
  }

  // ---- Add-item form wiring (mirrors OwnerQuotationEditScreen) ----
  static String _productDisplayString(_ActiveProduct p) =>
      p.company.isEmpty ? p.name : '${p.name} — ${p.company}';

  void _onProductSelected(_ActiveProduct? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _productSearchCtrl.text = _productDisplayString(product);
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        _itemMrpCtrl.text = _formatQty(product.mrp);
        _itemRateCtrl.text = product.rate > 0 ? _formatQty(product.rate) : '';
        _itemQtyCtrl.clear();
        _itemBoxQtyCtrl.clear();
        _itemPieceQtyCtrl.clear();
      } else {
        _itemCompanyCtrl.clear();
        _itemSizeCtrl.clear();
        _itemUnitCtrl.clear();
        _itemMrpCtrl.clear();
        _itemRateCtrl.clear();
        _itemQtyCtrl.clear();
        _itemBoxQtyCtrl.clear();
        _itemPieceQtyCtrl.clear();
      }
    });
  }

  /// Clears the product search box itself — used by the field's clear
  /// button and whenever the whole item form resets. Plain deselection
  /// (user edits the typed text without picking a fresh option) goes
  /// through `_onProductSelected(null)` instead and leaves the typed
  /// text alone so they can keep searching.
  void _clearProductSelection() {
    _productSearchCtrl.clear();
    _onProductSelected(null);
  }

  void _resetItemForm() {
    setState(() {
      _selectedProduct = null;
      _editingItemIndex = null;
      _showProductSuggestions = false;
      _productSearchCtrl.clear();
      _itemCompanyCtrl.clear();
      _itemSizeCtrl.clear();
      _itemUnitCtrl.clear();
      _itemMrpCtrl.clear();
      _itemQtyCtrl.clear();
      _itemBoxQtyCtrl.clear();
      _itemPieceQtyCtrl.clear();
      _itemRateCtrl.clear();
    });
  }

  void _saveItemFromForm() {
    final qty = _computedQuantity;
    final rate = double.tryParse(_itemRateCtrl.text.trim()) ?? 0;

    String productId;
    String name;
    bool isBoxUnit;
    if (_selectedProduct != null) {
      productId = _selectedProduct!.id;
      name = _selectedProduct!.name;
      isBoxUnit = _selectedProduct!.isBoxUnit;
    } else if (_editingItemIndex != null) {
      final existing = _items[_editingItemIndex!];
      productId = existing.productId;
      name = existing.name;
      isBoxUnit = existing.isBoxUnit;
    } else {
      AppSnackbar.error('Please select a product');
      return;
    }
    if (qty <= 0) {
      AppSnackbar.error(isBoxUnit
          ? 'Please enter a valid box/piece quantity'
          : 'Please enter a valid quantity');
      return;
    }
    if (rate < 0) {
      AppSnackbar.error('Please enter a valid rate');
      return;
    }

    final editingIndex = _editingItemIndex;
    final formCompany = _itemCompanyCtrl.text.trim();
    final formSize = _itemSizeCtrl.text.trim();
    final formUnit = _itemUnitCtrl.text.trim();
    final formMrp = double.tryParse(_itemMrpCtrl.text.trim());
    final previous = editingIndex != null ? _items[editingIndex] : null;

    final newItem = _EstimateEditItem(
      productId: productId,
      name: name,
      company: formCompany.isNotEmpty ? formCompany : (previous?.company ?? ''),
      size: formSize.isNotEmpty ? formSize : (previous?.size ?? ''),
      unit: formUnit.isNotEmpty ? formUnit : (previous?.unit ?? ''),
      quantity: qty,
      rate: rate,
      mrp: formMrp ?? previous?.mrp ?? 0,
      // Box Quantity mirrors Quantity (kept in sync in the UI); Piece
      // Quantity is entered independently by the user. Non-box-unit
      // items send both as 0 — same rule as
      // OwnerQuotationEditScreen._saveItemFromForm.
      boxQuantity: isBoxUnit ? qty : 0,
      pieceQuantity: isBoxUnit ? (double.tryParse(_itemPieceQtyCtrl.text.trim()) ?? 0) : 0,
      isBoxUnit: isBoxUnit,
    );

    setState(() {
      if (editingIndex != null) {
        _items[editingIndex] = newItem;
      } else {
        _items.add(newItem);
      }
    });
    _resetItemForm();
  }

  void _editItem(int index) {
    final item = _items[index];
    final match = _findProduct(item.productId);

    setState(() {
      _editingItemIndex = index;
      _selectedProduct = match;
      _showProductSuggestions = false;
      _productSearchCtrl.text = match != null ? _productDisplayString(match) : item.name;
      _itemCompanyCtrl.text = match?.company ?? item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = _formatQty(match?.mrp ?? item.mrp);
      _itemQtyCtrl.text = _formatQty(item.quantity);
      _itemRateCtrl.text = _formatQty(item.rate);
      // Show the item's own saved box/piece quantity here — do NOT
      // derive Box Quantity from the Quantity field (that's only for
      // live-sync while the user is actively typing, see the Quantity
      // field's onChanged below). Quantity and Box Quantity are
      // separate stored values and must each be populated from their
      // own field on the item.
      _itemBoxQtyCtrl.text = _formatQty(item.boxQuantity);
      _itemPieceQtyCtrl.text = _formatQty(item.pieceQuantity);
    });
  }

  void _cancelEditItem() => _resetItemForm();

  /// Removal here is purely local — unlike the quotation screen, the
  /// estimate update endpoint takes the full item list in one
  /// POST /estimates/update call, so there's no separate remove-item API
  /// to call first.
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_editingItemIndex != null) {
        if (_editingItemIndex == index) {
          _editingItemIndex = null;
          _resetItemForm();
        } else if (_editingItemIndex! > index) {
          _editingItemIndex = _editingItemIndex! - 1;
        }
      }
    });
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      AppSnackbar.error('Add at least one item.');
      return;
    }

    final updateItems = _items
        .map((row) => EstimateUpdateItem(
      productId: row.productId,
      quantity: row.quantity,
      boxQuantity: row.boxQuantity,
      pieceQuantity: row.pieceQuantity,
      rate: row.rate,
    ))
        .toList();

    final request = OwnerUpdateEstimateRequest(
      id: widget.detail.id,
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerAddress: _addressCtrl.text.trim(),
      customerEmail: _emailCtrl.text.trim(),
      date: _date == null ? null : DateFormat('yyyy-MM-dd').format(_date!),
      notes: _notesCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim(),
      items: updateItems,
    );

    context.read<OwnerEstimateDetailBloc>().add(OwnerEstimateUpdateRequested(request));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Update Estimate', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocConsumer<OwnerEstimateDetailBloc, OwnerEstimateDetailState>(
          listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
          listener: (context, state) {
            if (state.actionStatus == OwnerEstimateActionStatus.success) {
              AppSnackbar.success(state.actionMessage ?? 'Estimate updated.');
              Navigator.of(context).pop(true);
            } else if (state.actionStatus == OwnerEstimateActionStatus.failure) {
              AppSnackbar.error(state.actionMessage ?? 'Failed to update estimate.');
            }
          },
          builder: (context, state) {
            final isBusy = state.actionStatus == OwnerEstimateActionStatus.inProgress;

            return Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(18)),
                      children: [
                        Text('Customer Details', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(10)),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Customer Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _addressCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => _date = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Estimate Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_date == null
                                ? 'Select date'
                                : DateFormat('yyyy-MM-dd').format(_date!)),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _notesCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _termsCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Terms & Conditions',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(20)),

                        Text('Add / Edit Item', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(10)),
                        _buildProductSearch(),
                        SizedBox(height: Responsive.h(10)),
                        LabeledField(
                          label: 'Company (auto)',
                          field: IgnorePointer(
                            child: TextFormField(
                              controller: _itemCompanyCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Select a product first',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: LabeledField(
                                label: 'Size (auto)',
                                field: TextFormField(
                                  controller: _itemSizeCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. 600x1200',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: Responsive.w(10)),
                            Expanded(
                              child: LabeledField(
                                label: 'Unit (auto)',
                                field: TextFormField(
                                  controller: _itemUnitCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. sqft',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        LabeledField(
                          label: 'MRP (auto)',
                          field: TextFormField(
                            controller: _itemMrpCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: const InputDecoration(
                              hintText: '0',
                              prefixText: '₹ ',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        LabeledField(
                          label: _isBoxUnitProduct ? 'Quantity (Box)' : 'Quantity',
                          field: TextFormField(
                            controller: _itemQtyCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Enter quantity',
                              border: OutlineInputBorder(),
                            ),
                            // Live-sync only: this is the one place Box
                            // Quantity should be derived from Quantity —
                            // while the user is actively editing it.
                            onChanged: (_) {
                              setState(_recomputeBoxQtyIfNeeded);
                            },
                          ),
                        ),
                        if (_isBoxUnitProduct)
                          Row(
                            children: [
                              Expanded(
                                child: LabeledField(
                                  label: 'Box Quantity (auto)',
                                  field: IgnorePointer(
                                    child: TextFormField(
                                      controller: _itemBoxQtyCtrl,
                                      keyboardType:
                                      const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        hintText: '0',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Responsive.w(10)),
                              Expanded(
                                child: LabeledField(
                                  label: 'Piece Quantity',
                                  field: TextFormField(
                                    controller: _itemPieceQtyCtrl,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,2}')),
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Enter piece qty',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        LabeledField(
                          label: 'Rate',
                          field: TextFormField(
                            controller: _itemRateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Enter rate per unit',
                              prefixText: '₹ ',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Container(
                          padding: EdgeInsets.all(Responsive.w(12)),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Amount', style: AppTextStyles.bodyBold()),
                              Text(currency.format(_currentItemAmount),
                                  style: AppTextStyles.bodyBold(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        if (_editingItemIndex != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(12), vertical: Responsive.h(8)),
                            margin: EdgeInsets.only(bottom: Responsive.h(10)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined,
                                    size: 16, color: AppColors.primary),
                                SizedBox(width: Responsive.w(6)),
                                Expanded(
                                  child: Text(
                                    'Editing item #${_editingItemIndex! + 1}',
                                    style: AppTextStyles.caption(),
                                  ),
                                ),
                                InkWell(
                                  onTap: _cancelEditItem,
                                  child: Text('Cancel',
                                      style: AppTextStyles.bodyBold(color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loadingProducts ? null : _saveItemFromForm,
                            icon: Icon(
                              _editingItemIndex != null ? Icons.save_outlined : Icons.add,
                              color: Colors.white,
                            ),
                            label: Text(_editingItemIndex != null ? 'Update Item' : 'Add Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(20)),

                        Text('Items (${_items.length})', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(10)),
                        if (_loadingProducts)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_items.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
                            child: Center(
                              child: Text('No items added yet',
                                  style: AppTextStyles.body(color: AppColors.textHint)),
                            ),
                          )
                        else
                          ..._items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return _EstimateItemTile(
                              serialNo: index + 1,
                              item: item,
                              currency: currency,
                              isEditing: _editingItemIndex == index,
                              onEdit: () => _editItem(index),
                              onDelete: () => _removeItem(index),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
                  child: PrimaryButton(
                    label: isBusy ? 'Saving...' : 'Save Changes',
                    height: 48,
                    onPressed: isBusy ? null : () => _submit(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ));
  }

  Widget _buildProductSearch() {
    if (_loadingProducts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final query = _productSearchCtrl.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _products
        : _products.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.company.toLowerCase().contains(query) ||
          p.size.toLowerCase().contains(query);
    }).toList();

    return LabeledField(
      label: 'Select Product',
      field: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _productSearchCtrl,
            focusNode: _productSearchFocus,
            decoration: InputDecoration(
              hintText: 'Type a product name…',
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              suffixIcon: _productSearchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear',
                onPressed: _clearProductSelection,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (text) {
              if (_selectedProduct != null &&
                  text != _productDisplayString(_selectedProduct!)) {
                _onProductSelected(null);
              }
              setState(() {
                _showProductSuggestions = text.trim().isNotEmpty;
              });
            },
          ),
          if (_showProductSuggestions) ...[
            SizedBox(height: Responsive.h(6)),
            Container(
              constraints: BoxConstraints(maxHeight: Responsive.h(220)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: filtered.isEmpty
                  ? Padding(
                padding: EdgeInsets.all(Responsive.w(14)),
                child: Text('No matching products', style: AppTextStyles.caption()),
              )
                  : ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.inventory_2_outlined, size: 18),
                    title: Text(p.name, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${p.company}${p.size.isNotEmpty ? ' • ${p.size}' : ''}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _onProductSelected(p);
                      setState(() => _showProductSuggestions = false);
                      _productSearchFocus.unfocus();
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EstimateItemTile extends StatelessWidget {
  const _EstimateItemTile({
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.isEditing = false,
  });

  final int serialNo;
  final _EstimateEditItem item;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      padding: EdgeInsets.all(Responsive.w(12)),
      decoration: BoxDecoration(
        color: isEditing ? AppColors.primary.withOpacity(0.06) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isEditing ? AppColors.primary : AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.surfaceAlt,
            child: Text('$serialNo', style: AppTextStyles.caption()),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(2)),
                if (item.size.isNotEmpty || item.company.isNotEmpty)
                  Text(
                    '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}',
                    style: AppTextStyles.caption(),
                  ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Qty: ${_formatQty(item.quantity)}${item.unit.isNotEmpty ? ' ${item.unit}' : ''}'
                      '${item.mrp > 0 ? '   MRP: ${_formatQty(item.mrp)}' : ''}'
                      '   Rate: ${_formatQty(item.rate)}',
                  style: AppTextStyles.caption(),
                ),
                if (item.isBoxUnit) ...[
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    'Box: ${_formatQty(item.boxQuantity)}   Piece: ${_formatQty(item.pieceQuantity)}',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(item.amount),
                  style: AppTextStyles.bodyBold(color: AppColors.primary)),
              SizedBox(height: Responsive.h(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  ),
                  SizedBox(width: Responsive.w(14)),
                  InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small label-over-field wrapper, matching the convention used on
/// OwnerQuotationEditScreen's `LabeledField`. If your project already
/// exports a shared `LabeledField` widget, remove this local copy and
/// import that one instead to avoid a duplicate definition.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.field});
  final String label;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption()),
          SizedBox(height: Responsive.h(4)),
          field,
        ],
      ),
    );
  }
}