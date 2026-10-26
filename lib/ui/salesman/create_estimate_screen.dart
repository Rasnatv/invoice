
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/salesman/widget/salesman%20estimatecreatewidget.dart';
import '../../Apiprovider/salesman_quotationprovider.dart'; // NEW: direct provider access
import '../../bloc/salemanbloc/estimate/salesman_estimate_bloc.dart';
import '../../bloc/salemanbloc/estimate/salesmanestimate_event.dart';
import '../../bloc/salemanbloc/estimate/salesmanestimate_state.dart';
import '../../bloc/salemanbloc/salemandashboard/salesman_dashboardbloc.dart';
import '../../bloc/salemanbloc/salemandashboard/salesmandashboard_event.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/validator/validationfile.dart';
import '../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../../models/salesmanmodels/salesman_qtnpreviewmodel.dart';
import '../../widgets/appsnackbar.dart';
import 'package:tileshop/ui/salesman/widget/esalesmanestimatetype.dart';

class CreateEstimateScreen extends StatelessWidget {
  const CreateEstimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesmanEstimateBloc()..add(const SalesmanEstimateStarted()),
      child: const _CreateEstimateView(),
    );
  }
}

class _CreateEstimateView extends StatefulWidget {
  const _CreateEstimateView();

  @override
  State<_CreateEstimateView> createState() => _CreateEstimateViewState();
}

class _CreateEstimateViewState extends State<_CreateEstimateView> {
  EstimateStep _step = EstimateStep.details;

  // --- Step 1: Party / Contractor ---
  final _partyNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _customerEmailCtrl = TextEditingController();
  final _contractorNameCtrl = TextEditingController();
  final _contractorPhoneCtrl = TextEditingController();
  final _contractorEmailCtrl = TextEditingController();
  final _contractorAddressCtrl = TextEditingController();

  final _handlingChargeCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();

  DateTime _date = DateTime.now();

  // --- Site visit autofill tracking ---
  String? _siteVisitPhone; // phone of the site visit currently applied
  bool _applyingVisit = false; // guard so filling fields doesn't trigger the clear

  // --- Step 2: Items ---
  final _itemCompanyCtrl = TextEditingController();
  final _itemSizeCtrl = TextEditingController();
  final _itemUnitCtrl = TextEditingController();
  final _itemPackingCtrl = TextEditingController(); // auto-filled packing display
  final _itemMrpCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();

  final _itemBoxQtyCtrl = TextEditingController();
  final _itemPieceQtyCtrl = TextEditingController();

  ActiveProductModel? _selectedProduct;

  final List<AddedItem> _items = [];
  int _itemCounter = 0;
  int? _editingItemIndex;

  // Used ONLY for the "Add Item" call now — a fresh, one-shot request
  // fired straight from QuotationProvider (bypassing the bloc's cached
  // state entirely) so the item that gets added always matches exactly
  // what's on screen at the moment the button is tapped.
  final QuotationProvider _quotationProvider = QuotationProvider();
  bool _isAddingItem = false;

  // Debounces the live incentive lookup shown in the eligibility card
  // (not used for the final Add Item amount anymore).
  Timer? _incentiveDebounce;
  static const _incentiveDebounceDuration = Duration(milliseconds: 450);

  Timer? _previewDebounce;
  static const _previewDebounceDuration = Duration(milliseconds: 450);

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
    _incentiveDebounce?.cancel();
    _previewDebounce?.cancel();
    _partyNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _customerEmailCtrl.dispose();
    _contractorNameCtrl.dispose();
    _contractorPhoneCtrl.dispose();
    _contractorEmailCtrl.dispose();
    _contractorAddressCtrl.dispose();
    _handlingChargeCtrl.dispose();
    _notesCtrl.dispose();
    _termsCtrl.dispose();
    _itemCompanyCtrl.dispose();
    _itemSizeCtrl.dispose();
    _itemUnitCtrl.dispose();
    _itemPackingCtrl.dispose();
    _itemMrpCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemBoxQtyCtrl.dispose();
    _itemPieceQtyCtrl.dispose();
    _itemRateCtrl.dispose();
    super.dispose();
  }

  double get _handlingCharge => double.tryParse(_handlingChargeCtrl.text) ?? 0;

  bool get _isBoxUnitProduct => _selectedProduct?.isBoxUnit ?? false;

  double get _computedQuantity => double.tryParse(_itemQtyCtrl.text) ?? 0;

  void _recomputeBoxQtyIfNeeded() {
    if (!_isBoxUnitProduct) return;
    _itemBoxQtyCtrl.text = _itemQtyCtrl.text;
  }

  void _showError(String msg) {
    AppSnackbar.error(msg);
  }

  bool _validateDetails() {
    final partyNameError = DValidator.validateName('Party name', _partyNameCtrl.text);
    if (partyNameError != null) {
      _showError(partyNameError);
      return false;
    }

    final phoneError = DValidator.validatePhoneNumber(_phoneCtrl.text);
    if (phoneError != null) {
      _showError(phoneError);
      return false;
    }

    if (_customerEmailCtrl.text.trim().isNotEmpty) {
      final emailError = DValidator.validateEmail(_customerEmailCtrl.text);
      if (emailError != null) {
        _showError(emailError);
        return false;
      }
    }

    // --- Contractor name/phone mutual requirement ---
    final contractorName = _contractorNameCtrl.text.trim();
    final contractorPhone = _contractorPhoneCtrl.text.trim();

    if (contractorName.isNotEmpty && contractorPhone.isEmpty) {
      _showError('Contractor phone number is required when contractor name is entered');
      return false;
    }

    if (contractorPhone.isNotEmpty && contractorName.isEmpty) {
      _showError('Contractor name is required when contractor phone number is entered');
      return false;
    }

    if (contractorName.isNotEmpty) {
      final contractorNameError = DValidator.validateAlphaOnly('Contractor name', contractorName);
      if (contractorNameError != null) {
        _showError(contractorNameError);
        return false;
      }
    }

    if (contractorPhone.isNotEmpty) {
      final contractorPhoneError = DValidator.validatePhoneNumber(contractorPhone);
      if (contractorPhoneError != null) {
        _showError(contractorPhoneError);
        return false;
      }
    }

    if (_contractorEmailCtrl.text.trim().isNotEmpty) {
      final contractorEmailError = DValidator.validateEmail(_contractorEmailCtrl.text);
      if (contractorEmailError != null) {
        _showError(contractorEmailError);
        return false;
      }
    }

    return true;
  }

  /// Validates the item currently on the form:
  ///  - Quantity / Piece qty: max 99999 (5 digits)
  ///  - Rate: max 99999999 (8 digits)
  bool _validateCurrentItemFields() {
    if (_selectedProduct == null) {
      _showError('Please select a product');
      return false;
    }

    // Quantity (max 99999)
    final qtyError = DValidator.validateOptionalNumber(
      _isBoxUnitProduct ? 'Box quantity' : 'Quantity',
      _itemQtyCtrl.text,
      max: DValidator.maxQuantity,
    );
    if (qtyError != null) {
      _showError(qtyError);
      return false;
    }
    if (_computedQuantity <= 0) {
      _showError(_isBoxUnitProduct
          ? 'Please enter a valid box quantity or piece quantity'
          : 'Please enter a valid quantity');
      return false;
    }

    // Piece quantity (box-unit products only, max 99999)
    if (_isBoxUnitProduct) {
      final pieceError = DValidator.validateOptionalNumber(
        'Piece quantity',
        _itemPieceQtyCtrl.text,
        max: DValidator.maxQuantity,
      );
      if (pieceError != null) {
        _showError(pieceError);
        return false;
      }
    }

    // Rate (max 99999999)
    final rateError = DValidator.validateOptionalNumber(
      'Rate',
      _itemRateCtrl.text,
      max: DValidator.maxPrice,
    );
    if (rateError != null) {
      _showError(rateError);
      return false;
    }
    final rateValue = double.tryParse(_itemRateCtrl.text) ?? 0;
    if (rateValue <= 0) {
      _showError('Please enter a valid rate');
      return false;
    }

    return true;
  }

  /// Handling charge (max 99999999).
  bool _validateHandlingCharge() {
    final error = DValidator.validateOptionalNumber(
      'Handling charge',
      _handlingChargeCtrl.text,
      max: DValidator.maxPrice,
    );
    if (error != null) {
      _showError(error);
      return false;
    }
    return true;
  }

  // ---------------- Actions ----------------

  void _goToAddItems() {
    if (!_validateDetails()) return;
    setState(() => _step = EstimateStep.addItems);
  }

  /// Fires on every phone edit. If a site visit was auto-filled and the
  /// phone number no longer matches it, clear the auto-filled name and
  /// address and drop the selected visit from the bloc so a stale
  /// site_visit_id isn't submitted.
  void _onPhoneChanged() {
    if (_applyingVisit || _siteVisitPhone == null) return;

    if (_phoneCtrl.text.trim() != _siteVisitPhone) {
      _siteVisitPhone = null;
      _partyNameCtrl.clear();
      _addressCtrl.clear();
      // NOTE: if your salesman event is named differently, change it here.
      context.read<SalesmanEstimateBloc>().add(const SiteVisitSelectionCleared());
      setState(() {});
    }
  }

  void _selectSiteVisit(SiteVisitDropdownItem visit) {
    _applyingVisit = true;
    _phoneCtrl.text = visit.customerPhone;
    _phoneCtrl.selection = TextSelection.collapsed(offset: _phoneCtrl.text.length);
    _partyNameCtrl.text = visit.customerName;
    _addressCtrl.text = visit.siteAddress;
    _applyingVisit = false;

    _siteVisitPhone = visit.customerPhone;
    context.read<SalesmanEstimateBloc>().add(SiteVisitSelected(visit));
    setState(() {});
  }

  String _formatPrice(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  void _onProductSelected(ActiveProductModel? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        _itemPackingCtrl.text = product.packing;
        _itemMrpCtrl.text = _formatPrice(product.mrp);
        _itemRateCtrl.text = _formatPrice(product.rate);
        _itemQtyCtrl.clear();
        _itemBoxQtyCtrl.clear();
        _itemPieceQtyCtrl.clear();
      } else {
        _itemCompanyCtrl.clear();
        _itemSizeCtrl.clear();
        _itemUnitCtrl.clear();
        _itemPackingCtrl.clear();
        _itemMrpCtrl.clear();
        _itemRateCtrl.clear();
        _itemQtyCtrl.clear();
        _itemBoxQtyCtrl.clear();
        _itemPieceQtyCtrl.clear();
      }
    });
    _scheduleIncentiveFetch();
  }

  /// Debounces the live eligibility-card lookup only (informational).
  /// The Add Item amount no longer relies on this at all.
  void _scheduleIncentiveFetch() {
    _incentiveDebounce?.cancel();

    final product = _selectedProduct;
    final qty = _computedQuantity;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    final productId = product != null ? int.tryParse(product.id) : null;

    if (product == null || productId == null || qty <= 0 || rate <= 0) {
      context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
      return;
    }

    _incentiveDebounce = Timer(_incentiveDebounceDuration, () {
      if (!mounted) return;
      context.read<SalesmanEstimateBloc>().add(ProductIncentiveRequested(
        productId: productId,
        quantity: qty,
        rate: rate,
        boxQuantity: _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : null,
        pieceQuantity: _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : null,
      ));
    });
  }

  void _onQuantityChanged() {
    setState(_recomputeBoxQtyIfNeeded);
    _scheduleIncentiveFetch();
  }

  void _resetItemFields() {
    _incentiveDebounce?.cancel();
    _selectedProduct = null;
    _itemCompanyCtrl.clear();
    _itemSizeCtrl.clear();
    _itemUnitCtrl.clear();
    _itemPackingCtrl.clear();
    _itemMrpCtrl.clear();
    _itemQtyCtrl.clear();
    _itemBoxQtyCtrl.clear();
    _itemPieceQtyCtrl.clear();
    _itemRateCtrl.clear();
    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
  }

  /// Fires a FRESH, one-shot POST /quotations/product-incentive with
  /// exactly what's on the form right now (product_id, quantity, rate,
  /// box_quantity, piece_quantity), waits for the real response, and
  /// adds the item using ONLY that response's amount/incentive fields.
  /// No cached bloc state, no local qty*rate math, ever.
  ///
  /// UPDATED:
  ///  - blocks adding the same product twice (ignores the item being edited)
  ///  - try/catch so "Calculating…" can never get stuck if the call throws
  Future<void> _addItemToList() async {
    if (_isAddingItem) return;
    if (!_validateCurrentItemFields()) return;

    final product = _selectedProduct!;
    final productId = int.tryParse(product.id);
    if (productId == null) {
      _showError('Invalid product selected.');
      return;
    }

    // Block duplicates (ignore the item currently being edited)
    final alreadyAdded = _items.asMap().entries.any(
          (e) => e.key != _editingItemIndex && e.value.productId == product.id,
    );
    if (alreadyAdded) {
      _showError('This product is already added. Edit the existing item instead.');
      return;
    }

    _recomputeBoxQtyIfNeeded();

    final quantity = _computedQuantity;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    final boxQuantity = _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : null;
    final pieceQuantity = _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : null;

    setState(() => _isAddingItem = true);

    ProductIncentiveResult result;
    try {
      result = await _quotationProvider.getProductIncentive(ProductIncentiveRequest(
        productId: productId,
        quantity: quantity,
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
    setState(() => _isAddingItem = false);

    if (!result.success || result.incentive == null) {
      _showError(result.errorMessage ?? 'Could not calculate the amount for this item. Please try again.');
      return;
    }

    final incentive = result.incentive!;

    setState(() {
      final editingIndex = _editingItemIndex;
      final newItem = AddedItem(
        id: editingIndex != null ? _items[editingIndex].id : 'item_${_itemCounter++}',
        productId: product.id,
        name: product.name,
        company: _itemCompanyCtrl.text.trim(),
        size: _itemSizeCtrl.text.trim(),
        unit: _itemUnitCtrl.text.trim(),
        packing: _itemPackingCtrl.text.trim(),
        quantity: quantity,
        boxQuantity: _isBoxUnitProduct ? (boxQuantity ?? 0) : 0,
        pieceQuantity: _isBoxUnitProduct ? (pieceQuantity ?? 0) : 0,
        rate: rate,
        mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
        amount: incentive.amount,
        incentiveAmount: incentive.totalIncentive,
        incentiveEligible: incentive.isEligible,
        incentiveReason: incentive.eligibilityReason,
      );
      if (editingIndex != null) {
        _items[editingIndex] = newItem;
        _editingItemIndex = null;
      } else {
        _items.add(newItem);
      }
      _resetItemFields();
    });
  }

  void _editItem(int index) {
    final item = _items[index];

    final products = context.read<SalesmanEstimateBloc>().state.products;
    ActiveProductModel? matchedProduct;
    for (final p in products) {
      if (p.id == item.productId) {
        matchedProduct = p;
        break;
      }
    }

    setState(() {
      _editingItemIndex = index;
      _selectedProduct = matchedProduct;
      _itemCompanyCtrl.text = item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemPackingCtrl.text = item.packing;
      _itemMrpCtrl.text = item.mrp == item.mrp.roundToDouble()
          ? item.mrp.toStringAsFixed(0)
          : item.mrp.toString();
      _itemQtyCtrl.text = item.quantity == item.quantity.roundToDouble()
          ? item.quantity.toStringAsFixed(0)
          : item.quantity.toString();
      _itemBoxQtyCtrl.text = item.boxQuantity == item.boxQuantity.roundToDouble()
          ? item.boxQuantity.toStringAsFixed(0)
          : item.boxQuantity.toString();
      _itemPieceQtyCtrl.text = item.pieceQuantity == item.pieceQuantity.roundToDouble()
          ? item.pieceQuantity.toStringAsFixed(0)
          : item.pieceQuantity.toString();
      _itemRateCtrl.text = item.rate == item.rate.roundToDouble()
          ? item.rate.toStringAsFixed(0)
          : item.rate.toString();
    });

    if (matchedProduct != null) {
      _scheduleIncentiveFetch();
    } else {
      context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
    }
  }

  void _cancelEditItem() {
    setState(() {
      _editingItemIndex = null;
      _resetItemFields();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_editingItemIndex != null) {
        if (_editingItemIndex == index) {
          _editingItemIndex = null;
          _resetItemFields();
        } else if (_editingItemIndex! > index) {
          _editingItemIndex = _editingItemIndex! - 1;
        }
      }
    });
  }

  /// Save Items -> Preview.
  /// If an edit was never applied ("Update Item" not tapped) or a product
  /// was picked but never added, ask the user what to do instead of
  /// silently dropping it. Pending values are always cleared before moving
  /// on, so they don't reappear when the user comes back from Preview.
  Future<void> _goToPreview() async {
    final isEditing = _editingItemIndex != null;
    final hasPendingNew = !isEditing && _selectedProduct != null;

    if (isEditing || hasPendingNew) {
      final choice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(isEditing ? 'Item not updated' : 'Item not added'),
          content: Text(
            isEditing
                ? 'You changed item #${_editingItemIndex! + 1} but did not tap '
                '"Update Item". The price/amount shown on the next screen will '
                'still be the OLD one.'
                : 'You selected a product but did not tap "Add Item". '
                'It will not be included in the estimate.',
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

      if (!mounted || choice == null) return;

      if (choice == 'apply') {
        await _addItemToList(); // recalculates amount from the server
        if (!mounted) return;
        // Validation / API failed -> stay on this step so the user can fix it
        if (_editingItemIndex != null || _selectedProduct != null) return;
      }
    }

    if (_items.isEmpty) {
      _showError('Please add at least one item');
      return;
    }

    setState(() {
      _editingItemIndex = null;
      _resetItemFields();
      _step = EstimateStep.preview;
    });
    // NEW: clear stale preview so the old numbers never flash on screen
    context.read<SalesmanEstimateBloc>().add(const QuotationPreviewCleared());
    _requestPreview();
  }

  QuotationCreateRequest _buildRequest({required String action}) {
    final selectedVisit = context.read<SalesmanEstimateBloc>().state.selectedSiteVisit;
    return QuotationCreateRequest(
      action: action,
      date: DateFormat('yyyy-MM-dd').format(_date),
      customerName: _partyNameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerEmail: _customerEmailCtrl.text.trim().isEmpty ? null : _customerEmailCtrl.text.trim(),
      customerAddress: _addressCtrl.text.trim().isEmpty ? 'Not specified' : _addressCtrl.text.trim(),
      contractorName: _contractorNameCtrl.text.trim().isEmpty ? null : _contractorNameCtrl.text.trim(),
      contractorPhone:
      _contractorPhoneCtrl.text.trim().isEmpty ? null : _contractorPhoneCtrl.text.trim(),
      contractorEmail:
      _contractorEmailCtrl.text.trim().isEmpty ? null : _contractorEmailCtrl.text.trim(),
      contractorAddress:
      _contractorAddressCtrl.text.trim().isEmpty ? null : _contractorAddressCtrl.text.trim(),
      siteVisitId: selectedVisit?.id,
      handlingCharge: _handlingCharge,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
      items: _items
          .map((r) => QuotationItemRequest(
        productId: r.productId,
        quantity: r.quantity,
        boxQuantity: r.boxQuantity,
        pieceQuantity: r.pieceQuantity,
        rate: r.rate,
      ))
          .toList(),
    );
  }

  QuotationPreviewRequest _buildPreviewRequest() {
    return QuotationPreviewRequest(
      date: DateFormat('yyyy-MM-dd').format(_date),
      customerName: _partyNameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerEmail: _customerEmailCtrl.text.trim().isEmpty ? null : _customerEmailCtrl.text.trim(),
      customerAddress: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      contractorName: _contractorNameCtrl.text.trim().isEmpty ? null : _contractorNameCtrl.text.trim(),
      contractorPhone:
      _contractorPhoneCtrl.text.trim().isEmpty ? null : _contractorPhoneCtrl.text.trim(),
      contractorEmail:
      _contractorEmailCtrl.text.trim().isEmpty ? null : _contractorEmailCtrl.text.trim(),
      contractorAddress:
      _contractorAddressCtrl.text.trim().isEmpty ? null : _contractorAddressCtrl.text.trim(),
      handlingCharge: _handlingCharge,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
      items: _items
          .map((r) => QuotationItemRequest(
        productId: r.productId,
        quantity: r.quantity,
        boxQuantity: r.boxQuantity,
        pieceQuantity: r.pieceQuantity,
        rate: r.rate,
      ))
          .toList(),
    );
  }

  void _requestPreview() {
    context.read<SalesmanEstimateBloc>().add(QuotationPreviewRequested(_buildPreviewRequest()));
  }

  void _onHandlingChargeChanged() {
    setState(() {});
    _previewDebounce?.cancel();
    _previewDebounce = Timer(_previewDebounceDuration, _requestPreview);
  }

  void _saveDraft() {
    if (!_validateDetails()) return;
    if (!_validateHandlingCharge()) return;
    final request = _buildRequest(action: 'save_quotation');
    context.read<SalesmanEstimateBloc>().add(QuotationSubmitRequested(request));
  }

  void _submitForApproval() {
    if (!_validateHandlingCharge()) return;
    final request = _buildRequest(action: 'submit');
    context.read<SalesmanEstimateBloc>().add(QuotationSubmitRequested(request));
  }

  bool _onWillPop() {
    if (_step == EstimateStep.preview) {
      setState(() => _step = EstimateStep.addItems);
      return false;
    }
    if (_step == EstimateStep.addItems) {
      // Drop any unsaved edit / half-filled item form when leaving this step
      setState(() {
        _editingItemIndex = null;
        _resetItemFields();
        _step = EstimateStep.details;
      });
      return false;
    }
    return true;
  }

  String get _appBarTitle {
    switch (_step) {
      case EstimateStep.details:
        return 'Create Estimate';
      case EstimateStep.addItems:
        return 'Add Items';
      case EstimateStep.preview:
        return 'Estimate Preview';
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<SalesmanEstimateBloc, SalesmanEstimateState>(
      listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          AppSnackbar.success(state.submitMessage ?? 'Saved successfully.');
          context.read<SalesmanEstimateBloc>().add(const QuotationSubmitResultConsumed());
          context.pop(true);
        } else if (state.submitStatus == SubmitStatus.failure) {
          _showError(state.submitError ?? 'Something went wrong. Please try again.');
          context.read<SalesmanEstimateBloc>().add(const QuotationSubmitResultConsumed());
        }
      },
      child: PopScope(
        canPop: _step == EstimateStep.details,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _onWillPop();
        },
        child: NetworkAwareWrapper(
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(_appBarTitle, style: AppTextStyles.h6()),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_step == EstimateStep.details) {
                    Navigator.of(context).pop();
                  } else {
                    _onWillPop();
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  StepIndicator(step: _step),
                  Expanded(
                    child: switch (_step) {
                      EstimateStep.details => DetailsStep(
                        date: _date,
                        onDateChanged: (d) => setState(() => _date = d),
                        partyNameCtrl: _partyNameCtrl,
                        addressCtrl: _addressCtrl,
                        phoneCtrl: _phoneCtrl,
                        customerEmailCtrl: _customerEmailCtrl,
                        contractorNameCtrl: _contractorNameCtrl,
                        contractorPhoneCtrl: _contractorPhoneCtrl,
                        contractorEmailCtrl: _contractorEmailCtrl,
                        contractorAddressCtrl: _contractorAddressCtrl,
                        onSelectSiteVisit: _selectSiteVisit,
                        onNext: _goToAddItems,
                      ),
                      EstimateStep.addItems => AddItemsSteps(
                        selectedProduct: _selectedProduct,
                        onProductSelected: _onProductSelected,
                        itemCompanyCtrl: _itemCompanyCtrl,
                        itemSizeCtrl: _itemSizeCtrl,
                        itemUnitCtrl: _itemUnitCtrl,
                        itemPackingCtrl: _itemPackingCtrl,
                        itemMrpCtrl: _itemMrpCtrl,
                        itemQtyCtrl: _itemQtyCtrl,
                        itemBoxQtyCtrl: _itemBoxQtyCtrl,
                        itemPieceQtyCtrl: _itemPieceQtyCtrl,
                        itemRateCtrl: _itemRateCtrl,
                        isAdding: _isAddingItem,
                        onQuantityChanged: _onQuantityChanged,
                        onQtyRateChanged: _scheduleIncentiveFetch,
                        items: _items,
                        editingIndex: _editingItemIndex,
                        onAddItem: _addItemToList,
                        onEditItem: _editItem,
                        onCancelEdit: _cancelEditItem,
                        onRemoveItem: _removeItem,
                        onCancel: () => setState(() {
                          _editingItemIndex = null;
                          _resetItemFields();
                          _step = EstimateStep.details;
                        }),
                        onSaveItems: _goToPreview,
                      ),
                      EstimateStep.preview => PreviewStep(
                        date: _date,
                        partyName: _partyNameCtrl.text,
                        address: _addressCtrl.text,
                        phone: _phoneCtrl.text,
                        customerEmail: _customerEmailCtrl.text,
                        contractorName: _contractorNameCtrl.text,
                        contractorPhone: _contractorPhoneCtrl.text,
                        contractorEmail: _contractorEmailCtrl.text,
                        handlingChargeCtrl: _handlingChargeCtrl,
                        notesCtrl: _notesCtrl,
                        onHandlingChargeChanged: _onHandlingChargeChanged,
                        onRetryPreview: _requestPreview,
                        onSaveDraft: _saveDraft,
                        onSubmit: _submitForApproval,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}