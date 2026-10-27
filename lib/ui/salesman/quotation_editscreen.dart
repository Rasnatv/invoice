import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/salesman/widget/quotation%20editscreen_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../widgets/primary_button.dart';
import '../../bloc/quotationitemremove/quotationitemremove_bloc.dart';
import '../../bloc/quotationitemremove/quotationitemremove_event.dart';
import '../../bloc/quotationitemremove/quotationitemremove_state.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';
import '../../bloc/salemanbloc/estimate/salesman_estimate_bloc.dart';
import '../../bloc/salemanbloc/estimate/salesmanestimate_event.dart';
import '../../bloc/salemanbloc/estimate/salesmanestimate_state.dart';
import '../../core/utils/delete_helper.dart'; // NOTE: adjust path if your deleteItem() helper lives elsewhere
import '../../core/validator/validationfile.dart';
import '../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../models/salesmanmodels/quotationupdatemodel.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../../widgets/appsnackbar.dart';
import '../../Apiprovider/salesman_quotationprovider.dart';

/// Salesman quotation edit screen — same structure CreateEstimateScreen uses.
class QuotationEditScreen extends StatelessWidget {
  const QuotationEditScreen({super.key, required this.estimate});

  final QuotationDetailModel estimate;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SalesmanEstimateBloc()..add(const ActiveProductsRequested()),
        ),
        BlocProvider(create: (_) => QuotationItemRemoveBloc()),
      ],
      child: _QuotationEditView(estimate: estimate),
    );
  }
}

class _QuotationEditView extends StatefulWidget {
  const _QuotationEditView({required this.estimate});
  final QuotationDetailModel estimate;

  @override
  State<_QuotationEditView> createState() => _QuotationEditViewState();
}

class _QuotationEditViewState extends State<_QuotationEditView> {
  final _formKey = GlobalKey<FormState>();

  // ---- Customer / contractor / other details ----
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

  // ---- Items ----
  late List<EditItem> _items;
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

  // Box Quantity auto-follows Quantity; Piece Quantity is entered separately.
  final _itemBoxQtyCtrl = TextEditingController();
  final _itemPieceQtyCtrl = TextEditingController();

  Timer? _incentiveDebounce;
  static const _incentiveDebounceDuration = Duration(milliseconds: 450);

  bool _backfilledFromCatalog = false;

  // One-shot call for Add/Update Item, bypassing the bloc's cached state
  // (same approach as CreateEstimateScreen's _addItemToList).
  final QuotationProvider _quotationProvider = QuotationProvider();
  bool _isAddingItem = false;

  // Item built from /quotations/product-incentive while PUT
  // /quotations/update-item is in flight (existing items only).
  // Applied on success, discarded on failure.
  EditItem? _pendingItemUpdate;

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

  /// Product IDs already in the quotation, EXCLUDING the item that is
  /// currently being edited (so it still shows in the dropdown while editing).
  /// Used to hide already-added products from the "Select Product" list.
  Set<String> get _addedProductIds => <String>{
    for (var i = 0; i < _items.length; i++)
      if (i != _editingItemIndex) _items[i].productId,
  };

  @override
  void initState() {
    super.initState();
    final e = widget.estimate;

    debugPrint('EDIT SCREEN OPENED: contractor=${e.contractor.name}');

    _customerName = TextEditingController(text: e.customer.name);
    _customerPhone = TextEditingController(text: e.customer.phone);
    _customerEmail = TextEditingController(text: e.customer.email);
    _customerAddress = TextEditingController(text: e.customer.address);

    // Clearing the customer phone also clears name / address / email.
    _customerPhone.addListener(_onCustomerPhoneChanged);

    // Product suggestions open when the product field is tapped/focused.
    _productSearchFocus.addListener(_onProductFocusChanged);

    _contractorName = TextEditingController(text: e.contractor.name);
    _contractorPhone = TextEditingController(text: e.contractor.mobile);
    _contractorEmail = TextEditingController(text: e.contractor.email);
    _contractorAddress = TextEditingController(text: e.contractor.address);

    _handlingCharge = TextEditingController(text: _formatPrice(e.handlingCharge));
    _notes = TextEditingController(text: e.notes);

    // Real backend ids are needed for remove-item / update-item calls.
    // Items added on this screen get an id prefixed 'new_'.
    _items = e.items
        .map((it) => EditItem(
      id: it.id,
      productId: it.productId,
      name: it.productName,
      unit: it.productUnit,
      size: it.productSize,
      quantity: it.quantity,
      rate: it.rate,
      amount: it.amount,
      boxQuantity: it.boxQuantity,
      pieceQuantity: it.pieceQuantity,
      incentiveAmount: it.incentiveAmount,
      incentiveEligible: it.incentiveAmount > 0,
    ))
        .toList();
  }

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

  /// Opens the suggestion list on focus; closes it shortly after focus is
  /// lost so a tap on a suggestion can register first.
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

  @override
  void dispose() {
    _incentiveDebounce?.cancel();
    _customerPhone.removeListener(_onCustomerPhoneChanged);
    _productSearchFocus.removeListener(_onProductFocusChanged);
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
    final u = i.unit
        .toLowerCase()
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll('²', '2');
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

  bool _isUnsavedItem(EditItem item) => item.id.startsWith('new_');

  void _showError(String msg) => AppSnackbar.error(msg);

  ActiveProductModel? _findCatalogMatch(List<ActiveProductModel> products, String productId) {
    for (final p in products) {
      if (p.id == productId) return p;
    }
    return null;
  }

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

  // ---------------- Validators ----------------

  String? _validatePartyName(String? v) => DValidator.validateName('Party name', v);

  String? _validateCustomerPhone(String? v) => DValidator.validatePhoneNumber(v);

  String? _validateCustomerAddress(String? v) =>
      DValidator.validateRequired(v, message: 'Site address is required');

  String? _validateOptionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return DValidator.validateEmail(v);
  }

  String? _validateOptionalName(String fieldName, String? v) {
    final name = (v ?? '').trim();
    final phone = _contractorPhone.text.trim();

    if (name.isEmpty && phone.isNotEmpty) {
      return '$fieldName is required when contractor phone number is entered';
    }
    if (name.isEmpty) return null;
    return DValidator.validateAlphaOnly(fieldName, name);
  }

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
      DValidator.validateOptionalNumber('Handling charge', v, max: DValidator.maxPrice);

  // ---------------- Add-item form wiring ----------------

  void _onProductSelected(ActiveProductModel? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _productSearchCtrl.text = qeProductDisplayString(product);
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        _itemMrpCtrl.text = _formatPrice(product.mrp);
        _itemRateCtrl.text = _formatPrice(product.rate);
      } else {
        _itemCompanyCtrl.clear();
        _itemSizeCtrl.clear();
        _itemUnitCtrl.clear();
        _itemMrpCtrl.clear();
        _itemRateCtrl.clear();
      }
      _itemQtyCtrl.clear();
      _itemBoxQtyCtrl.clear();
      _itemPieceQtyCtrl.clear();
    });
    _scheduleIncentiveFetch();
  }

  /// Clears the product search box itself (clear button).
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
      context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
      return;
    }

    _incentiveDebounce = Timer(_incentiveDebounceDuration, () {
      if (!mounted) return;
      context.read<SalesmanEstimateBloc>().add(ProductIncentiveRequested(
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
    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
    _itemFormKey.currentState?.reset();
  }

  /// - blocks adding the same product twice (ignores the item being edited)
  /// - try/catch so "Calculating…" can never get stuck if the call throws
  Future<void> _saveItemFromForm() async {
    if (_isAddingItem) return;

    if (!(_itemFormKey.currentState?.validate() ?? true)) return;

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
          ? 'Please enter a valid box quantity or piece quantity'
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

    // Block duplicates (ignore the item currently being edited)
    final alreadyAdded = _items.asMap().entries.any(
          (e) => e.key != _editingItemIndex && e.value.productId == productIdStr,
    );
    if (alreadyAdded) {
      _showError('This product is already added. Edit the existing item instead.');
      return;
    }

    _recomputeBoxQtyIfNeeded();
    final boxQuantity = _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : null;
    final pieceQuantity = _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : null;

    setState(() => _isAddingItem = true);

    // try/catch so the loading flag is always reset
    ProductIncentiveResult result;
    try {
      result = await _quotationProvider.getProductIncentive(ProductIncentiveRequest(
        productId: productId,
        quantity: qty,
        rate: rate,
        boxQuantity: boxQuantity,
        pieceQuantity: pieceQuantity,
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAddingItem = false);
      _showError('Could not calculate the amount for this item. Please try again.');
      return;
    }

    if (!mounted) return;

    if (!result.success || result.incentive == null) {
      setState(() => _isAddingItem = false);
      _showError(result.errorMessage ??
          'Could not calculate the amount for this item. Please try again.');
      return;
    }

    final incentive = result.incentive!;
    final editingIndex = _editingItemIndex;

    final formCompany = _itemCompanyCtrl.text.trim();
    final formMrp = double.tryParse(_itemMrpCtrl.text);
    final previousCompany = editingIndex != null ? _items[editingIndex].company : '';
    final previousMrp = editingIndex != null ? _items[editingIndex].mrp : 0.0;

    final newItem = EditItem(
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
      incentiveAmount: incentive.totalIncentive,
      incentiveEligible: incentive.isEligible,
      incentiveReason: incentive.eligibilityReason,
    );

    final existingItem = editingIndex != null ? _items[editingIndex] : null;

    if (existingItem != null && !_isUnsavedItem(existingItem)) {
      // Already-saved item — persist immediately via PUT /quotations/update-item.
      // _isAddingItem stays true until the itemUpdateStatus listener reports back.
      _pendingItemUpdate = newItem;
      context.read<SalesmanEstimateBloc>().add(QuotationItemUpdateSubmitted(
        quotationId: widget.estimate.id,
        quotationItemId: existingItem.id,
        quantity: qty,
        rate: rate,
        boxQuantity: boxQuantity,
        pieceQuantity: pieceQuantity,
      ));
      return;
    }

    // Brand-new / unsaved item — keep purely local.
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
    final products = context.read<SalesmanEstimateBloc>().state.products;
    final match = _findCatalogMatch(products, item.productId);

    setState(() {
      _editingItemIndex = index;
      _selectedProduct = match;
      _showProductSuggestions = false;
      _productSearchCtrl.text = match != null ? qeProductDisplayString(match) : item.name;
      _itemCompanyCtrl.text = match?.company ?? item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = _formatPrice(match?.mrp ?? item.mrp);
      _itemQtyCtrl.text = _formatPrice(item.quantity);
      _itemRateCtrl.text = _formatPrice(item.rate);
      _itemBoxQtyCtrl.text = _formatPrice(item.boxQuantity);
      _itemPieceQtyCtrl.text = _formatPrice(item.pieceQuantity);
    });

    _productSearchFocus.unfocus();

    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
    if (match != null) _scheduleIncentiveFetch();
  }

  void _cancelEditItem() => _resetItemForm();

  /// Unsaved items are removed locally. Saved items ask for confirmation,
  /// then call the remove-item API; the item is dropped on success.
  Future<void> _removeItem(int index) async {
    final item = _items[index];

    if (_isUnsavedItem(item)) {
      _removeLocalItemAt(index);
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

  void _removeLocalItemAt(int index) {
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

  void _dropItemById(String itemId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    _removeLocalItemAt(index);
  }

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

  // ---------------- Submit ----------------

  /// NEW: runs before Save Changes.
  /// If the salesman picked a product (or started editing an item) but never
  /// tapped "Add Item" / "Update Item", ask what to do instead of silently
  /// dropping it. Returns true when it is OK to continue saving.
  Future<bool> _resolvePendingItem() async {
    final editingIndex = _editingItemIndex;
    final isEditing = editingIndex != null;
    final hasPendingNew = !isEditing && _selectedProduct != null;

    if (!isEditing && !hasPendingNew) return true;

    final editingSaved = isEditing && !_isUnsavedItem(_items[editingIndex]);

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Item not updated' : 'Item not added'),
        content: Text(
          isEditing
              ? 'You changed item #${editingIndex + 1} but did not tap '
              '"Update Item". Your changes will not be saved and the old '
              'quantity/rate/amount will be kept.'
              : 'You selected a product but did not tap "Add Item". '
              'It will not be included in the quotation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: Text(isEditing ? 'Keep old item' : 'Skip it'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop('apply'),
            child: Text(isEditing ? 'Update now' : 'Add now'),
          ),
        ],
      ),
    );

    if (!mounted || choice == null) return false;

    if (choice == 'discard') {
      // Drop the half-filled form so stale values don't linger.
      _resetItemForm();
      return true;
    }

    // choice == 'apply'
    await _saveItemFromForm(); // recalculates / updates the item
    if (!mounted) return false;

    // Saved rows are updated on the server through the bloc (async), so the
    // salesman should tap Save Changes again once that finishes.
    if (editingSaved) return false;

    // Validation / API failed -> stay on screen so the user can fix it.
    if (_editingItemIndex != null || _selectedProduct != null) return false;

    return true;
  }

  bool _validate() {
    final formValid = _formKey.currentState?.validate() ?? true;
    if (!formValid) {
      _showError('Please fix the highlighted fields');
      return false;
    }
    if (_items.isEmpty) {
      _showError('Add at least one item');
      return false;
    }
    return true;
  }

  String? _nullIfEmpty(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _submit() async {
    // Read the bloc before any await so we don't use a stale context later.
    final bloc = context.read<SalesmanQuotationBloc>();

    // NEW: handle a forgotten Add Item / Update Item first.
    final canContinue = await _resolvePendingItem();
    if (!mounted || !canContinue) return;

    if (!_validate()) return;

    final request = QuotationUpdateRequest(
      id: widget.estimate.id,
      customerName: _customerName.text.trim(),
      customerPhone: _customerPhone.text.trim(),
      customerEmail: _nullIfEmpty(_customerEmail),
      customerAddress: _nullIfEmpty(_customerAddress),
      contractorName: _nullIfEmpty(_contractorName),
      contractorPhone: _nullIfEmpty(_contractorPhone),
      contractorEmail: _nullIfEmpty(_contractorEmail),
      contractorAddress: _nullIfEmpty(_contractorAddress),
      handlingCharge: _handling,
      notes: _nullIfEmpty(_notes),
      items: _items
          .map((i) => QuotationUpdateItemRequest(
        productId: i.productId,
        quantity: i.quantity,
        rate: i.rate,
        boxQuantity: i.boxQuantity > 0 ? i.boxQuantity : null,
        pieceQuantity: i.pieceQuantity > 0 ? i.pieceQuantity : null,
      ))
          .toList(),
    );

    debugPrint('UPDATE BODY: ${jsonEncode(request.toJson())}');

    bloc.add(QuotationUpdateSubmitted(request));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Edit Quotation', style: AppTextStyles.h6())),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
                listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
                listener: (context, state) {
                  if (state.submitStatus == QuotationActionStatus.success) {
                    AppSnackbar.success(state.submitMessage ?? 'Quotation updated.');
                    context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
                    Navigator.of(context).pop();
                  } else if (state.submitStatus == QuotationActionStatus.failure) {
                    _showError(state.submitError ?? 'Failed to update quotation.');
                    context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
                  }
                },
              ),
              BlocListener<SalesmanEstimateBloc, SalesmanEstimateState>(
                listenWhen: (prev, curr) => prev.itemUpdateStatus != curr.itemUpdateStatus,
                listener: (context, state) {
                  if (state.itemUpdateStatus == ItemUpdateStatus.success) {
                    _applyPendingItemUpdate();
                    AppSnackbar.success(state.itemUpdateMessage ?? 'Item updated successfully');
                    context.read<SalesmanEstimateBloc>().add(const QuotationItemUpdateResultConsumed());
                  } else if (state.itemUpdateStatus == ItemUpdateStatus.failure) {
                    _pendingItemUpdate = null;
                    setState(() => _isAddingItem = false);
                    _showError(state.itemUpdateError ?? 'Failed to update item.');
                    context.read<SalesmanEstimateBloc>().add(const QuotationItemUpdateResultConsumed());
                  }
                },
              ),
              BlocListener<SalesmanEstimateBloc, SalesmanEstimateState>(
                listenWhen: (prev, curr) =>
                !_backfilledFromCatalog &&
                    prev.productsStatus != curr.productsStatus &&
                    curr.productsStatus == LoadStatus.success,
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
                      padding: EdgeInsets.fromLTRB(
                          Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                      children: [
                        // ---- Customer ----
                        QeSectionCard(
                          title: 'Customer Details',
                          icon: Icons.groups_2_outlined,
                          child: QeCustomerSection(
                            phone: _customerPhone,
                            name: _customerName,
                            address: _customerAddress,
                            email: _customerEmail,
                            phoneValidator: _validateCustomerPhone,
                            nameValidator: _validatePartyName,
                            addressValidator: _validateCustomerAddress,
                            emailValidator: _validateOptionalEmail,
                          ),
                        ),
                        SizedBox(height: Responsive.h(14)),

                        // ---- Contractor ----
                        QeSectionCard(
                          title: 'Contractor Details',
                          icon: Icons.engineering_outlined,
                          child: QeContractorSection(
                            name: _contractorName,
                            phone: _contractorPhone,
                            email: _contractorEmail,
                            nameValidator: (v) => _validateOptionalName('Contractor name', v),
                            phoneValidator: _validateOptionalPhone,
                            emailValidator: _validateOptionalEmail,
                            // Re-validate so name/phone cross-check updates live.
                            onNamePhoneChanged: (_) => _formKey.currentState?.validate(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(14)),

                        // ---- Add / Edit item ----
                        QeSectionCard(
                          title: _editingItemIndex != null ? 'Edit Item' : 'Add Item',
                          icon: _editingItemIndex != null
                              ? Icons.edit_outlined
                              : Icons.add_box_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              QeItemFormFields(
                                formKey: _itemFormKey,
                                productField: QeProductDropdown(
                                  searchCtrl: _productSearchCtrl,
                                  focusNode: _productSearchFocus,
                                  selectedProduct: _selectedProduct,
                                  editingProductId: _editingItemIndex != null
                                      ? _items[_editingItemIndex!].productId
                                      : null,
                                  // Products already added are hidden from the list
                                  addedProductIds: _addedProductIds,
                                  showSuggestions: _showProductSuggestions,
                                  onFieldTap: () =>
                                      setState(() => _showProductSuggestions = true),
                                  onTextChanged: (text) {
                                    if (_selectedProduct != null &&
                                        text != qeProductDisplayString(_selectedProduct!)) {
                                      _onProductSelected(null);
                                    }
                                    setState(() => _showProductSuggestions = true);
                                  },
                                  onClear: _clearProductSelection,
                                  onSelected: (p) {
                                    _onProductSelected(p);
                                    setState(() => _showProductSuggestions = false);
                                    _productSearchFocus.unfocus();
                                  },
                                ),
                                companyCtrl: _itemCompanyCtrl,
                                sizeCtrl: _itemSizeCtrl,
                                unitCtrl: _itemUnitCtrl,
                                mrpCtrl: _itemMrpCtrl,
                                rateCtrl: _itemRateCtrl,
                                qtyCtrl: _itemQtyCtrl,
                                boxQtyCtrl: _itemBoxQtyCtrl,
                                pieceQtyCtrl: _itemPieceQtyCtrl,
                                isBoxUnit: _isBoxUnitProduct,
                                onMrpChanged: (_) => setState(() {}),
                                onRateChanged: (_) {
                                  setState(() {});
                                  _scheduleIncentiveFetch();
                                },
                                onQtyChanged: (_) {
                                  setState(_recomputeBoxQtyIfNeeded);
                                  _scheduleIncentiveFetch();
                                },
                                onPieceChanged: (_) => setState(() {}),
                              ),

                              if (_selectedProduct != null || _editingItemIndex != null)
                                IncentivePreviewCard(qtyCtrl: _itemQtyCtrl)
                              else
                                SizedBox(height: Responsive.h(2)),

                              if (_editingItemIndex != null)
                                QeEditingBanner(
                                  itemNumber: _editingItemIndex! + 1,
                                  onCancel: _cancelEditItem,
                                ),

                              SizedBox(
                                width: double.infinity,
                                height: Responsive.h(48),
                                child: ElevatedButton.icon(
                                  onPressed: _isAddingItem ? null : _saveItemFromForm,
                                  icon: _isAddingItem
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                      : Icon(
                                    _editingItemIndex != null
                                        ? Icons.save_outlined
                                        : Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _isAddingItem
                                        ? (_editingItemIndex != null
                                        ? 'Updating…'
                                        : 'Calculating…')
                                        : (_editingItemIndex != null
                                        ? 'Update Item'
                                        : 'Add Item'),
                                    style: AppTextStyles.bodyBold(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                              SizedBox(height: Responsive.h(8)),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(18)),

                        // ---- Items list ----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const QeSectionHeader('Items'),
                            QePill(
                              label:
                              '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(10)),
                        if (_items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Responsive.w(18)),
                            decoration: qeCardDecoration(),
                            child: Text('No items added yet',
                                style: AppTextStyles.caption(color: AppColors.textSecondary)),
                          )
                        else
                          BlocBuilder<QuotationItemRemoveBloc, QuotationItemRemoveState>(
                            buildWhen: (prev, curr) =>
                            prev.status != curr.status ||
                                prev.removedItemId != curr.removedItemId,
                            builder: (context, removeState) {
                              final removingId =
                              removeState.status == QuotationItemRemoveStatus.inProgress
                                  ? removeState.removedItemId
                                  : null;
                              return Column(
                                children: _items.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final item = entry.value;
                                  return EditItemTile(
                                    serialNo: i + 1,
                                    item: item,
                                    currency: currency,
                                    isEditing: _editingItemIndex == i,
                                    isRemoving: item.id == removingId,
                                    onEdit: () => _editItem(i),
                                    onDelete: () => _removeItem(i),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        SizedBox(height: Responsive.h(8)),

                        // ---- Other details ----
                        QeSectionCard(
                          title: 'Other Details',
                          icon: Icons.tune_rounded,
                          child: QeOtherDetailsSection(
                            handlingCharge: _handlingCharge,
                            notes: _notes,
                            handlingValidator: _validateHandlingCharge,
                            onHandlingChanged: (_) => setState(() {}),
                          ),
                        ),
                        SizedBox(height: Responsive.h(14)),

                        // ---- Summary ----
                        QeTotalsCard(
                          totalSqft: _totalSqft,
                          mrpTotal: _mrpTotal,
                          itemsTotal: _itemsTotal,
                          handling: _handling,
                          grandTotal: _grandTotal,
                          currency: currency,
                          number: number,
                        ),

                        if (_incentiveTotal > 0) ...[
                          SizedBox(height: Responsive.h(14)),
                          QeIncentiveTotalCard(total: _incentiveTotal, currency: currency),
                        ],
                      ],
                    ),
                  ),
                ),
                BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
                  buildWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
                  builder: (context, state) {
                    final saving = state.submitStatus == QuotationActionStatus.inProgress;
                    return Container(
                      padding: EdgeInsets.fromLTRB(
                          Responsive.w(20), Responsive.h(10), Responsive.w(20), Responsive.h(14)),
                      decoration: const BoxDecoration(
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
      ),
    );
  }
}