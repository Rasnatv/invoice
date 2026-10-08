
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../bloc/ownerbloc/ownerquatationedit/owner_qtneditbloc.dart';
import '../../bloc/ownerbloc/ownerquatationedit/owner_qtneditestate.dart';
import '../../bloc/ownerbloc/ownerquatationedit/owner_qtneditevent.dart';
import '../../bloc/quotationitemremove/quotationitemremove_bloc.dart';
import '../../bloc/quotationitemremove/quotationitemremove_event.dart';
import '../../bloc/quotationitemremove/quotationitemremove_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/delete_helper.dart';
import '../../core/utils/responsive.dart';
import '../../core/validator/validationfile.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
// TODO: change this path to wherever your deleteItem() helper file liveser.dart';
import '../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../models/salesmanmodels/quotationupdatemodel.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
// Same fresh, one-shot provider CreateEstimateScreen / QuotationEditScreen
// use for POST /quotations/product-incentive — fired the moment Add/Update
// Item is tapped, bypassing any cached/debounced bloc state, so what gets
// added/updated always matches exactly what the server computed.
import '../../Apiprovider/salesman_quotationprovider.dart';

class OwnerQuotationEditScreen extends StatelessWidget {
  const OwnerQuotationEditScreen({super.key, required this.estimate});

  /// Already-loaded detail (from the owner details screen) used to
  /// prefill every field — no re-fetch needed for the quotation itself.
  final QuotationDetailModel estimate;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OwnerQuotationEditBloc()
            ..add(const OwnerEditActiveProductsRequested()),
        ),
        BlocProvider(create: (_) => QuotationItemRemoveBloc()),
      ],
      child: _OwnerQuotationEditView(estimate: estimate),
    );
  }
}


class _OwnerEditItem {
  const _OwnerEditItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.company = '',
    this.size = '',
    this.mrp = 0,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    this.incentiveAmount = 0,
    this.incentiveEligible = false,
    this.incentiveReason,
  });

  final String id;
  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double quantity;
  final double rate;
  final double amount;
  final double mrp;
  final double boxQuantity;
  final double pieceQuantity;
  final double incentiveAmount;
  final bool incentiveEligible;
  final String? incentiveReason;

  _OwnerEditItem copyWith({String? company, double? mrp}) {
    return _OwnerEditItem(
      id: id,
      productId: productId,
      name: name,
      unit: unit,
      quantity: quantity,
      rate: rate,
      amount: amount,
      company: company ?? this.company,
      size: size,
      mrp: mrp ?? this.mrp,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
      incentiveAmount: incentiveAmount,
      incentiveEligible: incentiveEligible,
      incentiveReason: incentiveReason,
    );
  }
}

class _OwnerQuotationEditView extends StatefulWidget {
  const _OwnerQuotationEditView({required this.estimate});
  final QuotationDetailModel estimate;

  @override
  State<_OwnerQuotationEditView> createState() => _OwnerQuotationEditViewState();
}

class _OwnerQuotationEditViewState extends State<_OwnerQuotationEditView> {
  // Form key for the customer/other-details section.
  final _formKey = GlobalKey<FormState>();

  // Separate Form for just the contractor name/phone pair, so they can be
  // re-validated against each other on every keystroke without re-running
  // (and flashing errors on) the customer fields in the main Form above.
  final _contractorFormKey = GlobalKey<FormState>();

  // ---- Customer / contractor / other details (all editable for owner) ----
  late final TextEditingController _customerName;
  late final TextEditingController _customerPhone;
  late final TextEditingController _customerEmail;
  late final TextEditingController _customerAddress;
  late final TextEditingController _contractorName;
  late final TextEditingController _contractorPhone;
  late final TextEditingController _contractorEmail;
  late final TextEditingController _contractorAddress;
  late final TextEditingController _handlingCharge;
  late final TextEditingController _notes;
  final TextEditingController _termsConditions = TextEditingController();

  // ---- Items ----
  late List<_OwnerEditItem> _items;
  int _newItemCounter = 0;
  int? _editingItemIndex;

  // ---- Add / edit item form ----
  final _itemFormKey = GlobalKey<FormState>();
  ActiveProductModel? _selectedProduct;
  final _productSearchCtrl = TextEditingController();
  final _productSearchFocus = FocusNode();
  bool _showProductSuggestions = false;
  final _itemCompanyCtrl = TextEditingController();
  final _itemSizeCtrl = TextEditingController();
  final _itemUnitCtrl = TextEditingController();
  final _itemMrpCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();
  final _itemBoxQtyCtrl = TextEditingController();
  final _itemPieceQtyCtrl = TextEditingController();

  Timer? _incentiveDebounce;
  static const _incentiveDebounceDuration = Duration(milliseconds: 450);

  bool _backfilledFromCatalog = false;

  final QuotationProvider _quotationProvider = QuotationProvider();
  bool _isAddingItem = false;

  _OwnerEditItem? _pendingItemUpdate;

  bool get _isBoxUnitProduct {
    if (_editingItemIndex != null) {
      final item = _items[_editingItemIndex!];
      if (item.boxQuantity > 0 || item.pieceQuantity > 0) return true;
    }
    if (_selectedProduct != null) return _selectedProduct!.isBoxUnit;
    return false;
  }

  double get _computedQuantity => double.tryParse(_itemQtyCtrl.text) ?? 0;

  void _recomputeBoxQtyIfNeeded() {
    if (!_isBoxUnitProduct) return;
    _itemBoxQtyCtrl.text = _itemQtyCtrl.text;
  }

  bool get _isOwner {
    final label = widget.estimate.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return widget.estimate.createdBy.role.trim().toLowerCase() == 'owner';
  }

  bool _isUnsavedItem(_OwnerEditItem item) => item.id.startsWith('new_');

  @override
  void initState() {
    super.initState();
    final e = widget.estimate;

    _customerName = TextEditingController(text: e.customer.name);
    _customerPhone = TextEditingController(text: e.customer.phone);
    _customerEmail = TextEditingController(text: e.customer.email);
    _customerAddress = TextEditingController(text: e.customer.address);

    // When the customer phone number is cleared completely, the other
    // customer fields (name / address / email) are cleared too — same
    // behaviour as the Create Estimate screen.
    _customerPhone.addListener(_onCustomerPhoneChanged);

    // Product suggestions open when the product field is tapped/focused.
    _productSearchFocus.addListener(_onProductFocusChanged);

    _contractorName = TextEditingController(text: e.contractor.name);
    _contractorPhone = TextEditingController(text: e.contractor.mobile);
    _contractorEmail = TextEditingController(text: e.contractor.email);
    _contractorAddress = TextEditingController(text: e.contractor.address);
    _contractorName.addListener(_revalidateContractorFields);
    _contractorPhone.addListener(_revalidateContractorFields);

    _handlingCharge = TextEditingController(text: _formatPrice(e.handlingCharge));
    _notes = TextEditingController(text: e.notes);

    _items = e.items
        .asMap()
        .entries
        .map((entry) => _OwnerEditItem(
      id: entry.value.id,
      productId: entry.value.productId,
      name: entry.value.productName,
      unit: entry.value.productUnit,
      size: entry.value.productSize,
      quantity: entry.value.quantity,
      rate: entry.value.rate,
      amount: entry.value.amount,
      boxQuantity: entry.value.boxQuantity,
      pieceQuantity: entry.value.pieceQuantity,
      incentiveAmount: entry.value.incentiveAmount,
      incentiveEligible: entry.value.incentiveAmount > 0,
    ))
        .toList();
  }

  /// Clears name / address / email once the phone number is emptied.
  void _onCustomerPhoneChanged() {
    if (_customerPhone.text.trim().isNotEmpty) return;
    if (_customerName.text.isEmpty &&
        _customerAddress.text.isEmpty &&
        _customerEmail.text.isEmpty) {
      return;
    }
    _customerName.clear();
    _customerAddress.clear();
    _customerEmail.clear();
  }

  void _onProductFocusChanged() {
    if (_productSearchFocus.hasFocus) {
      setState(() => _showProductSuggestions = true);
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted || _productSearchFocus.hasFocus) return;
        setState(() => _showProductSuggestions = false);
      });
    }
  }


  void _revalidateContractorFields() {
    _contractorFormKey.currentState?.validate();
  }

  @override
  void dispose() {
    _incentiveDebounce?.cancel();
    _customerPhone.removeListener(_onCustomerPhoneChanged);
    _productSearchFocus.removeListener(_onProductFocusChanged);
    _contractorName.removeListener(_revalidateContractorFields);
    _contractorPhone.removeListener(_revalidateContractorFields);
    _customerName.dispose();
    _customerPhone.dispose();
    _customerEmail.dispose();
    _customerAddress.dispose();
    _contractorName.dispose();
    _contractorPhone.dispose();
    _contractorEmail.dispose();
    _contractorAddress.dispose();
    _handlingCharge.dispose();
    _notes.dispose();
    _termsConditions.dispose();
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

  // ---- Derived totals ----
  double get _itemsTotal => _items.fold(0.0, (s, i) => s + i.amount);
  double get _handling => double.tryParse(_handlingCharge.text.trim()) ?? 0;
  double get _grandTotal => _itemsTotal + _handling;
  double get _incentiveTotal => _items.fold(0.0, (s, i) => s + i.incentiveAmount);
  double get _mrpTotal => _items.fold(0.0, (s, i) => s + (i.mrp * i.quantity));

  double get _totalSqft => _items.fold(0.0, (s, i) {
    final u = i.unit.toLowerCase().replaceAll('.', '').replaceAll(' ', '').replaceAll('²', '2');
    final isSqft = u == 'sqft' ||
        u == 'sqfeet' ||
        u == 'squarefeet' ||
        u == 'squareft' ||
        u == 'sft' ||
        u == 'ft2' ||
        u.contains('sqft') ||
        u.contains('squareft') ||
        u.contains('squarefeet');
    return s + (isSqft ? i.quantity : 0);
  });

  static String _formatPrice(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  void _showError(String msg) {
    AppSnackbar.error(msg);
  }

  ActiveProductModel? _findCatalogMatch(List<ActiveProductModel> products, String productId) {
    for (final p in products) {
      if (p.id == productId) return p;
    }
    return null;
  }

  /// Fills in company/mrp for existing items once the active-products
  /// catalog is available (/quotations/show doesn't return either field).
  void _backfillCompanyAndMrp(List<ActiveProductModel> products) {
    if (products.isEmpty) return;
    var changed = false;
    final updated = _items.map((item) {
      if (item.company.isNotEmpty) return item;
      final match = _findCatalogMatch(products, item.productId);
      if (match == null) return item;
      changed = true;
      return item.copyWith(company: match.company, mrp: match.mrp);
    }).toList();

    if (changed) {
      setState(() {
        _items = updated;
        _backfilledFromCatalog = true;
      });
    } else {
      _backfilledFromCatalog = true;
    }
  }

  // ---------------- Field-level validators (DValidator) ----------------

  String? _validatePartyName(String? v) => DValidator.validateName('Customer name', v);

  String? _validateCustomerPhone(String? v) => DValidator.validatePhoneNumber(v);

  String? _validateCustomerAddress(String? v) =>
      DValidator.validateRequired(v, message: 'Site address is required');

  /// Email is optional on this screen — only validate format if something
  /// was typed.
  String? _validateOptionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return DValidator.validateEmail(v);
  }

  /// Contractor name is optional — but becomes required once contractor
  /// phone is filled in, since a phone without a name to attach it to
  /// isn't useful on the quotation.
  String? _validateOptionalName(String fieldName, String? v) {
    final name = (v ?? '').trim();
    final phone = _contractorPhone.text.trim();

    if (name.isEmpty && phone.isNotEmpty) {
      return '$fieldName is required when contractor phone number is entered';
    }
    if (name.isEmpty) return null;
    return DValidator.validateAlphaOnly(fieldName, name);
  }

  /// Contractor phone is optional — but becomes required once contractor
  /// name is filled in, mirroring _validateOptionalName above.
  String? _validateOptionalPhone(String? v) {
    final phone = (v ?? '').trim();
    final name = _contractorName.text.trim();

    if (phone.isEmpty && name.isNotEmpty) {
      return 'Contractor phone number is required when contractor name is entered';
    }
    if (phone.isEmpty) return null;
    return DValidator.validatePhoneNumber(phone);
  }

  String? _validateHandlingCharge(String? v) =>
      DValidator.validateOptionalNumber('Handling charge', v);

  // ---- Add-item form wiring ----
  static String _productDisplayString(ActiveProductModel p) => '${p.name} — ${p.company}';

  void _onProductSelected(ActiveProductModel? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _productSearchCtrl.text = _productDisplayString(product);
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        _itemMrpCtrl.text = _formatPrice(product.mrp);
        _itemRateCtrl.text = _formatPrice(product.rate);
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
    _scheduleIncentiveFetch();
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

  void _scheduleIncentiveFetch() {
    _incentiveDebounce?.cancel();

    final product = _selectedProduct;
    final qty = _computedQuantity;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    final fallbackProductId =
    _editingItemIndex != null ? _items[_editingItemIndex!].productId : null;
    final productId = product != null
        ? int.tryParse(product.id)
        : (fallbackProductId != null ? int.tryParse(fallbackProductId) : null);

    if (productId == null || qty <= 0 || rate <= 0) {
      context.read<OwnerQuotationEditBloc>().add(const OwnerEditProductIncentiveCleared());
      return;
    }

    _incentiveDebounce = Timer(_incentiveDebounceDuration, () {
      if (!mounted) return;
      context.read<OwnerQuotationEditBloc>().add(OwnerEditProductIncentiveRequested(
        productId: productId,
        quantity: qty,
        rate: rate,
      ));
    });
  }

  void _resetItemForm() {
    _incentiveDebounce?.cancel();
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
    context.read<OwnerQuotationEditBloc>().add(const OwnerEditProductIncentiveCleared());
    // Clear any stale validation messages left on the item form.
    _itemFormKey.currentState?.reset();
  }

  Future<void> _saveItemFromForm() async {
    if (_isAddingItem) return;

    if (!(_itemFormKey.currentState?.validate() ?? true)) {
      return;
    }

    final qty = _computedQuantity;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;

    String productIdStr;
    String name;
    if (_selectedProduct != null) {
      productIdStr = _selectedProduct!.id;
      name = _selectedProduct!.name;
    } else if (_editingItemIndex != null) {
      productIdStr = _items[_editingItemIndex!].productId;
      name = _items[_editingItemIndex!].name;
    } else {
      _showError('Please select a product');
      return;
    }
    if (qty <= 0) {
      _showError(_isBoxUnitProduct
          ? 'Please enter a valid box/piece quantity'
          : 'Please enter a valid quantity');
      return;
    }
    if (rate <= 0) {
      _showError('Please enter a valid rate');
      return;
    }

    final productId = int.tryParse(productIdStr);
    if (productId == null) {
      _showError('Invalid product selected.');
      return;
    }

    // Box Quantity mirrors Quantity (same convention as Create Estimate);
    // Piece Quantity is entered independently by the user in its own
    // field. Non-box-unit items send null for both.
    _recomputeBoxQtyIfNeeded();
    final boxQuantity = _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : null;
    final pieceQuantity = _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : null;

    setState(() => _isAddingItem = true);

    final result = await _quotationProvider.getProductIncentive(ProductIncentiveRequest(
      productId: productId,
      quantity: qty,
      rate: rate,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
    ));

    if (!mounted) return;

    if (!result.success || result.incentive == null) {
      setState(() => _isAddingItem = false);
      _showError(result.errorMessage ?? 'Could not calculate the amount for this item. Please try again.');
      return;
    }

    final incentive = result.incentive!;
    final editingIndex = _editingItemIndex;

    final formCompany = _itemCompanyCtrl.text.trim();
    final formMrp = double.tryParse(_itemMrpCtrl.text);
    final previousCompany = editingIndex != null ? _items[editingIndex].company : '';
    final previousMrp = editingIndex != null ? _items[editingIndex].mrp : 0.0;

    final newItem = _OwnerEditItem(
      id: editingIndex != null ? _items[editingIndex].id : 'new_${_newItemCounter++}',
      productId: productIdStr,
      name: name,
      company: formCompany.isNotEmpty ? formCompany : previousCompany,
      size: _itemSizeCtrl.text.trim(),
      unit: _itemUnitCtrl.text.trim(),
      quantity: qty,
      rate: rate,
      amount: incentive.amount,
      mrp: formMrp ?? previousMrp,
      boxQuantity: _isBoxUnitProduct ? (boxQuantity ?? 0) : 0,
      pieceQuantity: _isBoxUnitProduct ? (pieceQuantity ?? 0) : 0,
      // Incentive is salesman-facing; still stored here so per-item /
      // total incentive views stay correct if this quotation is later
      // reassigned, but the UI hides it whenever _isOwner is true.
      incentiveAmount: incentive.totalIncentive,
      incentiveEligible: incentive.isEligible,
      incentiveReason: incentive.eligibilityReason,
    );

    final existingItem = editingIndex != null ? _items[editingIndex] : null;

    if (existingItem != null && !_isUnsavedItem(existingItem)) {
      // Existing, already-saved item — persist the change immediately via
      // PUT /quotations/update-item. _isAddingItem stays true (button keeps
      // its spinner) until the itemUpdateStatus BlocListener below reports
      // success or failure.
      _pendingItemUpdate = newItem;
      context.read<OwnerQuotationEditBloc>().add(OwnerQuotationItemUpdateSubmitted(
        quotationId: widget.estimate.id,
        quotationItemId: existingItem.id,
        quantity: qty,
        rate: rate,
        boxQuantity: boxQuantity,
        pieceQuantity: pieceQuantity,
      ));
      return;
    }

    // Brand-new item (or one added earlier on this screen and not yet
    // saved) — nothing to persist yet, keep it purely local.
    setState(() {
      _isAddingItem = false;
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
    final products = context.read<OwnerQuotationEditBloc>().state.products;
    final match = _findCatalogMatch(products, item.productId);

    setState(() {
      _editingItemIndex = index;
      _selectedProduct = match;
      _showProductSuggestions = false;
      _productSearchCtrl.text =
      match != null ? _productDisplayString(match) : item.name;
      _itemCompanyCtrl.text = match?.company ?? item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = _formatPrice(match?.mrp ?? item.mrp);
      _itemQtyCtrl.text = _formatPrice(item.quantity);
      _itemRateCtrl.text = _formatPrice(item.rate);
      // Show the item's own saved box quantity here — do NOT derive it
      // from the Quantity field (that's only for live-sync while the
      // user is actively typing, see the Quantity field's onChanged).
      _itemBoxQtyCtrl.text = _formatPrice(item.boxQuantity);
      _itemPieceQtyCtrl.text = _formatPrice(item.pieceQuantity);
    });

    // Make sure the suggestion list isn't left open from a previous tap.
    _productSearchFocus.unfocus();

    context.read<OwnerQuotationEditBloc>().add(const OwnerEditProductIncentiveCleared());
    if (match != null) _scheduleIncentiveFetch();
  }

  void _cancelEditItem() => _resetItemForm();


  Future<void> _removeItem(int index) async {
    final item = _items[index];

    if (_isUnsavedItem(item)) {
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
      return;
    }

    await deleteItem(
      context,
      itemName: 'item',
      onConfirmed: () async {
        if (!mounted) return;
        context.read<QuotationItemRemoveBloc>().add(QuotationItemRemoveRequested(
          quotationId: widget.estimate.id,
          quotationItemId: item.id,
        ));
      },
    );
  }

  /// Called once the remove-item API call for [itemId] has succeeded —
  /// actually drops the item from the local list and fixes up the
  /// editing index.
  void _dropItemById(String itemId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

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

  /// Called once the PUT /quotations/update-item call for the item
  /// currently being edited has succeeded — applies the item built from
  /// the /quotations/product-incentive response (see _saveItemFromForm)
  /// to [_items] and resets the add/edit-item form.
  void _applyPendingItemUpdate() {
    final pending = _pendingItemUpdate;
    final editingIndex = _editingItemIndex;
    _pendingItemUpdate = null;
    if (pending == null || editingIndex == null) {
      setState(() => _isAddingItem = false);
      return;
    }
    setState(() {
      _isAddingItem = false;
      _items[editingIndex] = pending;
    });
    _resetItemForm();
  }

  // ---- Submit ----
  bool _validate() {
    // Runs every validator attached to the customer/other-details Form
    // (customer name, phone, address, optional email, handling charge).
    final formValid = _formKey.currentState?.validate() ?? true;
    // Contractor name/phone live in their own Form so they can be
    // cross-validated live — checked separately here.
    final contractorValid = _contractorFormKey.currentState?.validate() ?? true;

    if (!formValid || !contractorValid) {
      _showError('Please fix the highlighted fields');
      return false;
    }
    if (_items.isEmpty) {
      _showError('Add at least one item');
      return false;
    }
    return true;
  }

  void _submit() {
    if (!_validate()) return;

    final request = QuotationUpdateRequest(
      id: widget.estimate.id,
      customerName: _customerName.text.trim(),
      customerPhone: _customerPhone.text.trim(),
      customerEmail: _customerEmail.text.trim().isEmpty ? null : _customerEmail.text.trim(),
      customerAddress:
      _customerAddress.text.trim().isEmpty ? null : _customerAddress.text.trim(),
      contractorName:
      _contractorName.text.trim().isEmpty ? null : _contractorName.text.trim(),
      contractorPhone:
      _contractorPhone.text.trim().isEmpty ? null : _contractorPhone.text.trim(),
      contractorEmail:
      _contractorEmail.text.trim().isEmpty ? null : _contractorEmail.text.trim(),
      contractorAddress:
      _contractorAddress.text.trim().isEmpty ? null : _contractorAddress.text.trim(),
      handlingCharge: _handling,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      termsConditions:
      _termsConditions.text.trim().isEmpty ? null : _termsConditions.text.trim(),
      items: _items
          .map((i) => QuotationUpdateItemRequest(
        productId: i.productId,
        quantity: i.quantity,
        rate: i.rate,
        // Only sent when actually a box-unit item with a positive
        // value — QuotationUpdateItemRequest.toJson() omits nulls, so
        // regular (non-box) items are unaffected.
        boxQuantity: i.boxQuantity > 0 ? i.boxQuantity : null,
        pieceQuantity: i.pieceQuantity > 0 ? i.pieceQuantity : null,
      ))
          .toList(),
    );

    context.read<OwnerQuotationEditBloc>().add(OwnerQuotationUpdateSubmitted(request));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Edit Quotation', style: AppTextStyles.h6())),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<OwnerQuotationEditBloc, OwnerQuotationEditState>(
              listenWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
              listener: (context, state) {
                if (state.updateStatus == OwnerQuotationUpdateStatus.success) {
                  AppSnackbar.success(state.updateMessage ?? 'Quotation updated.');
                  context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationUpdateResultConsumed());
                  Navigator.of(context).pop(true);
                } else if (state.updateStatus == OwnerQuotationUpdateStatus.failure) {
                  _showError(state.updateError ?? 'Failed to update quotation.');
                  context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationUpdateResultConsumed());
                }
              },
            ),

            BlocListener<OwnerQuotationEditBloc, OwnerQuotationEditState>(
              listenWhen: (prev, curr) => prev.itemUpdateStatus != curr.itemUpdateStatus,
              listener: (context, state) {
                if (state.itemUpdateStatus == OwnerItemUpdateStatus.success) {
                  _applyPendingItemUpdate();
                  AppSnackbar.success(state.itemUpdateMessage ?? 'Item updated successfully');
                  context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationItemUpdateResultConsumed());
                } else if (state.itemUpdateStatus == OwnerItemUpdateStatus.failure) {
                  _pendingItemUpdate = null;
                  setState(() => _isAddingItem = false);
                  _showError(state.itemUpdateError ?? 'Failed to update item.');
                  context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationItemUpdateResultConsumed());
                }
              },
            ),
            BlocListener<OwnerQuotationEditBloc, OwnerQuotationEditState>(
              listenWhen: (prev, curr) =>
              !_backfilledFromCatalog &&
                  prev.productsStatus != curr.productsStatus &&
                  curr.productsStatus == OwnerEditLoadStatus.success,
              listener: (context, state) => _backfillCompanyAndMrp(state.products),
            ),
            BlocListener<QuotationItemRemoveBloc, QuotationItemRemoveState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: (context, state) {
                if (state.status == QuotationItemRemoveStatus.success) {
                  final removedId = state.removedItemId;
                  if (removedId != null) _dropItemById(removedId);
                  AppSnackbar.success(state.message ?? 'Item removed successfully');
                  context.read<QuotationItemRemoveBloc>().add(const QuotationItemRemoveResultConsumed());
                } else if (state.status == QuotationItemRemoveStatus.failure) {
                  _showError(state.errorMessage ?? 'Failed to remove item');
                  context.read<QuotationItemRemoveBloc>().add(const QuotationItemRemoveResultConsumed());
                }
              },
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.w(18)),
                    children: [
                      Text('Customer Details', style: AppTextStyles.h3()),
                      SizedBox(height: Responsive.h(12)),
                      LabeledField(
                        label: 'Contact No.',
                        field: CustomTextField(
                          hint: 'Enter phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          controller: _customerPhone,
                          inputFormatters: DValidator.phoneNumber,
                          validator: _validateCustomerPhone,
                        ),
                      ),
                      LabeledField(
                        label: 'Customer Name',
                        field: CustomTextField(
                          hint: 'Enter customer name',
                          icon: Icons.groups_2_outlined,
                          controller: _customerName,
                          validator: _validatePartyName,
                        ),
                      ),

                      LabeledField(
                        label: 'Address',
                        field: CustomTextField(
                          hint: 'Enter site address',
                          icon: Icons.location_on_outlined,
                          controller: _customerAddress,
                          validator: _validateCustomerAddress,
                        ),
                      ),
                      LabeledField(
                        label: 'Email',
                        field: CustomTextField(
                          hint: 'Enter customer email',
                          icon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                          controller: _customerEmail,
                          validator: _validateOptionalEmail,
                        ),
                      ),
                      SizedBox(height: Responsive.h(16)),

                      Text('Contractor Details', style: AppTextStyles.h3()),
                      SizedBox(height: Responsive.h(12)),
                      Form(
                        key: _contractorFormKey,
                        child: Column(
                          children: [
                            LabeledField(
                              label: 'Contractor Name',
                              field: CustomTextField(
                                hint: 'Enter contractor name',
                                icon: Icons.engineering_outlined,
                                controller: _contractorName,
                                inputFormatters: DValidator.lettersOnly,
                                validator: (v) => _validateOptionalName('Contractor name', v),
                              ),
                            ),
                            LabeledField(
                              label: 'Contact No.',
                              field: CustomTextField(
                                hint: 'Enter contractor phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                controller: _contractorPhone,
                                inputFormatters: DValidator.phoneNumber,
                                validator: _validateOptionalPhone,
                              ),
                            ),
                          ],
                        ),
                      ),
                      LabeledField(
                        label: 'Email (optional)',
                        field: CustomTextField(
                          hint: 'Enter contractor email',
                          icon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                          controller: _contractorEmail,
                          validator: _validateOptionalEmail,
                        ),
                      ),
                      SizedBox(height: Responsive.h(20)),

                      Text('Add / Edit Item', style: AppTextStyles.h3()),
                      SizedBox(height: Responsive.h(10)),
                      Form(
                        key: _itemFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            _buildProductDropdown(),
                            SizedBox(height: Responsive.h(10)),
                            LabeledField(
                              label: 'Company (auto)',
                              field: IgnorePointer(
                                child: CustomTextField(
                                  hint: 'Select a product first',
                                  icon: Icons.factory_outlined,
                                  controller: _itemCompanyCtrl,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: LabeledField(
                                    label: 'Size (auto)',
                                    field: IgnorePointer(
                                      child: CustomTextField(
                                        hint: 'Select a product first',
                                        icon: Icons.straighten_outlined,
                                        controller: _itemSizeCtrl,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(10)),
                                Expanded(
                                  child: LabeledField(
                                    label: 'Unit (auto)',
                                    field: IgnorePointer(
                                      child: CustomTextField(
                                        hint: 'Select a product first',
                                        icon: Icons.square_foot_outlined,
                                        controller: _itemUnitCtrl,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // MRP and Rate share one row.
                            Row(
                              children: [
                                Expanded(
                                  child: LabeledField(
                                    label: 'MRP (auto)',
                                    field: IgnorePointer(
                                      child: CustomTextField(
                                        hint: 'MRP',
                                        icon: Icons.currency_rupee,
                                        keyboardType: TextInputType.number,
                                        controller: _itemMrpCtrl,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(10)),
                                Expanded(
                                  child: LabeledField(
                                    label: 'Rate',
                                    field: CustomTextField(
                                      hint: 'Rate',
                                      icon: Icons.currency_rupee,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      controller: _itemRateCtrl,
                                      inputFormatters: DValidator.priceNumber,
                                      validator: (v) {
                                        final n = double.tryParse((v ?? '').trim());
                                        if (n == null || n <= 0) return 'Enter a valid rate';
                                        if (n > DValidator.maxPrice) {
                                          return 'Rate can have at most ${DValidator.maxPriceDigits} digits';
                                        }
                                        return null;
                                      },
                                      onChanged: (_) {
                                        setState(() {});
                                        _scheduleIncentiveFetch();
                                      },
                                    ),)
                                ),
                              ],
                            ),
                            LabeledField(
                              label: 'Quantity',
                              field:
                              CustomTextField(
                                hint: 'Enter quantity',
                                icon: Icons.numbers_outlined,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                controller: _itemQtyCtrl,
                                inputFormatters: DValidator.quantityNumber,
                                validator: (v) {
                                  final n = double.tryParse((v ?? '').trim());
                                  if (n == null || n <= 0) {
                                    return _isBoxUnitProduct
                                        ? 'Enter a valid box/piece quantity'
                                        : 'Enter a valid quantity';
                                  }
                                  if (n > DValidator.maxQuantity) {
                                    return 'Quantity can have at most ${DValidator.maxQuantityDigits} digits';
                                  }
                                  return null;
                                },
                                onChanged: (_) {
                                  setState(_recomputeBoxQtyIfNeeded);
                                  _scheduleIncentiveFetch();
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
                                        child: CustomTextField(
                                          hint: '0',
                                          icon: Icons.inventory_2_outlined,
                                          keyboardType: TextInputType.number,
                                          controller: _itemBoxQtyCtrl,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Responsive.w(10)),
                                  Expanded(
                                    child: LabeledField(
                                      label: 'Piece Quantity',
                                      field:
                                      CustomTextField(
                                        hint: 'Enter piece qty',
                                        icon: Icons.widgets_outlined,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        controller: _itemPieceQtyCtrl,
                                        inputFormatters: DValidator.quantityNumber,
                                        validator: (v) {
                                          final n = double.tryParse((v ?? '').trim());
                                          if (n != null && n > DValidator.maxQuantity) {
                                            return 'Piece quantity can have at most ${DValidator.maxQuantityDigits} digits';
                                          }
                                          return null;
                                        },
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(6)),

                      // Incentive preview hidden for owner-created quotations.
                      if (!_isOwner && (_selectedProduct != null || _editingItemIndex != null)) ...[
                        SizedBox(height: Responsive.h(8)),
                        const _OwnerIncentivePreviewCard(),
                      ],

                      SizedBox(height: Responsive.h(14)),

                      if (_editingItemIndex != null) ...[
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
                              const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
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
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isAddingItem ? null : _saveItemFromForm,
                          icon: _isAddingItem
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : Icon(
                            _editingItemIndex != null ? Icons.save_outlined : Icons.add,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isAddingItem
                                ? (_editingItemIndex != null ? 'Updating…' : 'Calculating…')
                                : (_editingItemIndex != null ? 'Update Item' : 'Add Item'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(20)),

                      Text('Items (${_items.length})', style: AppTextStyles.h3()),
                      SizedBox(height: Responsive.h(10)),
                      if (_items.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
                          child: Center(
                            child: Text('No items added yet',
                                style: AppTextStyles.body(color: AppColors.textHint)),
                          ),
                        )
                      else
                        BlocBuilder<QuotationItemRemoveBloc, QuotationItemRemoveState>(
                          buildWhen: (prev, curr) =>
                          prev.status != curr.status || prev.removedItemId != curr.removedItemId,
                          builder: (context, removeState) {
                            final removingId = removeState.status == QuotationItemRemoveStatus.inProgress
                                ? removeState.removedItemId
                                : null;
                            return Column(
                              children: _items.asMap().entries.map((entry) {
                                final i = entry.key;
                                final item = entry.value;
                                return _OwnerEditItemTile(
                                  serialNo: i + 1,
                                  item: item,
                                  currency: currency,
                                  isEditing: _editingItemIndex == i,
                                  isRemoving: item.id == removingId,
                                  // Per-item incentive line hidden for owner-created
                                  // quotations, same rule as the preview/total above.
                                  showIncentive: !_isOwner,
                                  onEdit: () => _editItem(i),
                                  onDelete: () => _removeItem(i),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      SizedBox(height: Responsive.h(20)),

                      Text('Other Details', style: AppTextStyles.h3()),
                      SizedBox(height: Responsive.h(12)),
                      LabeledField(
                        label: 'Handling Charge',
                        field: CustomTextField(
                          hint: 'Enter handling charge',
                          icon: Icons.currency_rupee,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: _handlingCharge,
                          inputFormatters: DValidator.priceNumber,
                          validator: _validateHandlingCharge,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      LabeledField(
                        label: 'Notes (optional)',
                        field: CustomTextField(
                          hint: 'e.g. Customer enquiry for new project',
                          icon: Icons.notes_outlined,
                          controller: _notes,
                          inputFormatters: DValidator.textWithLimit,
                        ),
                      ),
                      SizedBox(height: Responsive.h(10)),

                      Container(
                        padding: EdgeInsets.all(Responsive.w(14)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Total Sq.Ft', number.format(_totalSqft)),
                            if (_mrpTotal > 0) ...[
                              SizedBox(height: Responsive.h(6)),
                              _totalRow('Total MRP', currency.format(_mrpTotal)),
                            ],
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Items Total', currency.format(_itemsTotal)),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Handling Charge', currency.format(_handling)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Grand Total', style: AppTextStyles.h3()),
                                Text(currency.format(_grandTotal),
                                    style: AppTextStyles.h2(color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(12)),

                      // Incentive total hidden for owner-created quotations.
                      if (!_isOwner && _incentiveTotal > 0)
                        Container(
                          padding: EdgeInsets.all(Responsive.w(14)),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.success.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.percent, size: 18, color: AppColors.success),
                                  SizedBox(width: Responsive.w(8)),
                                  Text('Incentive Total',
                                      style: AppTextStyles.bodyBold(color: AppColors.success)),
                                ],
                              ),
                              Text(currency.format(_incentiveTotal),
                                  style: AppTextStyles.h3(color: AppColors.success)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<OwnerQuotationEditBloc, OwnerQuotationEditState>(
                buildWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
                builder: (context, state) {
                  final saving = state.updateStatus == OwnerQuotationUpdateStatus.submitting;
                  return Container(
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: PrimaryButton(
                      label: saving ? 'Saving…' : 'Save Changes',
                      height: 48,
                      onPressed: saving ? null : _submit,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildProductDropdown() {
    return BlocBuilder<OwnerQuotationEditBloc, OwnerQuotationEditState>(
      buildWhen: (prev, curr) =>
      prev.products != curr.products || prev.productsStatus != curr.productsStatus,
      builder: (context, state) {
        if (state.productsStatus == OwnerEditLoadStatus.loading && state.products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.productsStatus == OwnerEditLoadStatus.failure && state.products.isEmpty) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.productsError ?? 'Failed to load products.',
                    style: AppTextStyles.caption(color: AppColors.error),
                  ),
                ),
                TextButton(
                  onPressed: () => context
                      .read<OwnerQuotationEditBloc>()
                      .add(const OwnerEditActiveProductsRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final products = state.products;

        // When a product is already chosen the box shows its full
        // "name — company" text; treat that as "no search" so tapping the
        // field lists every product instead of "No matching products".
        final typed = _productSearchCtrl.text.trim();
        final showingChosenText = _selectedProduct != null &&
            typed == _productDisplayString(_selectedProduct!);
        final query = showingChosenText ? '' : typed.toLowerCase();

        final filtered = query.isEmpty
            ? products
            : products.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.company.toLowerCase().contains(query) ||
              p.size.toLowerCase().contains(query);
        }).toList();

        return LabeledField(
          label: 'Select Product',
          field: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _productSearchCtrl,
                focusNode: _productSearchFocus,
                decoration: InputDecoration(
                  hintText: 'Search product by name',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _productSearchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear, size: 18),
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
                validator: (v) => DValidator.validateDropdown('product', _selectedProduct?.id),
                // Tapping the field (even if it already has focus) opens
                // the product list.
                onTap: () => setState(() => _showProductSuggestions = true),
                onChanged: (text) {
                  if (_selectedProduct != null &&
                      text != _productDisplayString(_selectedProduct!)) {
                    _onProductSelected(null);
                  }
                  setState(() => _showProductSuggestions = true);
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
      },
    );
  }

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: AppTextStyles.body()),
      ],
    );
  }
}


class _OwnerIncentivePreviewCard extends StatelessWidget {
  const _OwnerIncentivePreviewCard();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return BlocBuilder<OwnerQuotationEditBloc, OwnerQuotationEditState>(
      buildWhen: (prev, curr) =>
      prev.incentiveStatus != curr.incentiveStatus ||
          prev.incentive != curr.incentive ||
          prev.incentiveError != curr.incentiveError,
      builder: (context, state) {
        if (state.incentiveStatus == OwnerEditLoadStatus.initial) {
          return const SizedBox.shrink();
        }

        if (state.incentiveStatus == OwnerEditLoadStatus.loading) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: Responsive.w(10)),
                Text('Checking incentive…', style: AppTextStyles.caption()),
              ],
            ),
          );
        }

        if (state.incentiveStatus == OwnerEditLoadStatus.failure) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              state.incentiveError ?? 'Couldn\'t fetch incentive for this item.',
              style: AppTextStyles.caption(color: AppColors.error),
            ),
          );
        }

        final incentive = state.incentive;
        if (incentive == null) return const SizedBox.shrink();

        if (!incentive.isEligible) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    incentive.eligibilityReason.isNotEmpty
                        ? incentive.eligibilityReason
                        : 'Not eligible for incentive on this quantity/rate.',
                    style: AppTextStyles.caption(),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(Responsive.w(12)),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.percent, size: 16, color: AppColors.success),
                      SizedBox(width: Responsive.w(6)),
                      Text('Incentive on this item',
                          style: AppTextStyles.bodyBold(color: AppColors.success)),
                    ],
                  ),
                  Text(currency.format(incentive.totalIncentive),
                      style: AppTextStyles.bodyBold(color: AppColors.success)),
                ],
              ),
              if (incentive.eligibilityReason.isNotEmpty) ...[
                SizedBox(height: Responsive.h(4)),
                Text(incentive.eligibilityReason, style: AppTextStyles.caption()),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OwnerEditItemTile extends StatelessWidget {
  const _OwnerEditItemTile({
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.isEditing = false,
    this.isRemoving = false,
    this.showIncentive = true,
  });

  final int serialNo;
  final _OwnerEditItem item;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEditing;
  final bool isRemoving;
  final bool showIncentive;

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
                  'Qty: ${item.quantity.toStringAsFixed(0)} ${item.unit}'
                      '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
                      '   Rate: ${item.rate.toStringAsFixed(0)}',
                  style: AppTextStyles.caption(),
                ),
                // Per-item incentive line hidden for owner-created
                // quotations via showIncentive.
                if (showIncentive && item.incentiveEligible && item.incentiveAmount > 0) ...[
                  SizedBox(height: Responsive.h(2)),
                  Row(
                    children: [
                      Icon(Icons.percent, size: 12, color: AppColors.success),
                      SizedBox(width: Responsive.w(3)),
                      Text(
                        'Incentive: ${currency.format(item.incentiveAmount)}',
                        style: AppTextStyles.caption(color: AppColors.success),
                      ),
                    ],
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
                    onTap: isRemoving ? null : onEdit,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: isRemoving ? AppColors.textHint : AppColors.primary,
                    ),
                  ),
                  SizedBox(width: Responsive.w(14)),
                  if (isRemoving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
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
