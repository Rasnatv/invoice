

import 'dart:async';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/createestimate_stepindicator.dart';
import 'package:tileshop/ui/owner/widget/ownerestimatetype.dart';
import '../../Apiprovider/salesman_quotationprovider.dart';
import '../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_bloc.dart';
import '../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_event.dart';
import '../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/validator/validationfile.dart';
import '../../models/owner_models/get_activedrivermodel.dart';
import '../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../models/salesmanmodels/salesman_qtnpreviewmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class OwnerCreateEstimateScreen extends StatelessWidget {
  const OwnerCreateEstimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerEstimateBloc()..add(const OwnerEstimateStarted()),
      child: const _OwnerCreateEstimateView(),
    );
  }
}

class _OwnerCreateEstimateView extends StatefulWidget {
  const _OwnerCreateEstimateView();

  @override
  State<_OwnerCreateEstimateView> createState() => _OwnerCreateEstimateViewState();
}

class _OwnerCreateEstimateViewState extends State<_OwnerCreateEstimateView> {
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
  final _itemPackingCtrl = TextEditingController();
  final _itemMrpCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemBoxQtyCtrl = TextEditingController();
  final _itemPieceQtyCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();

  ActiveProductModel? _selectedProduct;

  final List<AddedItem> _items = [];
  int _itemCounter = 0;
  int? _editingItemIndex;

  /// Fresh, one-shot POST /quotations/product-incentive fired directly
  /// from Add Item — bypasses the bloc's cached `incentive` state
  /// entirely so the item saved always matches exactly what's on screen
  /// at the moment "Add Item" is tapped. No local quantity*rate math is
  /// ever used.
  final QuotationProvider _quotationProvider = QuotationProvider();
  bool _isAddingItem = false;

  /// Debounces re-fetching POST /quotations/preview when the owner edits
  /// the handling charge on the Preview step.
  Timer? _previewDebounce;
  static const _previewDebounceDuration = Duration(milliseconds: 500);

  // --- Owner-only values, collected in the Approve dialog ---
  String? _discountType; // 'percentage' | 'fixed'
  double? _discountValue;
  String? _discountNotes;

  double? _paymentAmount;
  String _paymentMethod = QuotationPaymentMethod.cash;
  String? _paymentReference;
  DateTime? _paymentDate;
  String? _paymentNotes;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
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

  // ---------------- Derived (local, pre-submission) values ----------------

  double get _handlingCharge => double.tryParse(_handlingChargeCtrl.text) ?? 0;

  bool get _isBoxUnitProduct => _selectedProduct?.isBoxUnit ?? false;
  double get _computedQuantity => double.tryParse(_itemQtyCtrl.text) ?? 0;

  void _recomputeBoxQtyIfNeeded() {
    if (!_isBoxUnitProduct) return;
    _itemBoxQtyCtrl.text = _itemQtyCtrl.text;
  }

  // ---------------- Validation ----------------

  void _showError(String msg) {
    AppSnackbar.error(msg);
  }

  bool _validateDetails() {
    final nameError = DValidator.validateName('Customer name', _partyNameCtrl.text);
    if (nameError != null) {
      _showError(nameError);
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

    if (contractorPhone.isNotEmpty) {
      final contractorPhoneError = DValidator.validatePhoneNumber(contractorPhone);
      if (contractorPhoneError != null) {
        _showError(contractorPhoneError);
        return false;
      }
    }

    if (contractorName.isNotEmpty) {
      final contractorNameError = DValidator.validateName('Contractor name', contractorName);
      if (contractorNameError != null) {
        _showError(contractorNameError);
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

  bool _validateCurrentItemFields() {
    if (_selectedProduct == null) {
      _showError('Please select a product');
      return false;
    }

    final qtyError = DValidator.validateOptionalNumber(
      _isBoxUnitProduct ? 'Box/piece quantity' : 'Quantity',
      _itemQtyCtrl.text,
    );
    if (qtyError != null || _computedQuantity <= 0) {
      _showError(_isBoxUnitProduct
          ? 'Please enter a valid box quantity or piece quantity'
          : 'Please enter a valid quantity');
      return false;
    }
    if (_computedQuantity > DValidator.maxQuantity) {
      _showError('Quantity can have at most ${DValidator.maxQuantityDigits} digits');
      return false;
    }

    final rateError = DValidator.validateOptionalNumber('Rate', _itemRateCtrl.text);
    final rateValue = double.tryParse(_itemRateCtrl.text) ?? 0;
    if (rateError != null || rateValue <= 0) {
      _showError('Please enter a valid rate');
      return false;
    }
    if (rateValue > DValidator.maxPrice) {
      _showError('Rate can have at most ${DValidator.maxPriceDigits} digits');
      return false;
    }

    // Piece qty (box-unit products only)
    if (_isBoxUnitProduct) {
      final piece = double.tryParse(_itemPieceQtyCtrl.text) ?? 0;
      if (piece > DValidator.maxQuantity) {
        _showError('Piece quantity can have at most ${DValidator.maxQuantityDigits} digits');
        return false;
      }
    }

    return true;
  }

  // ---------------- Actions: navigation ----------------

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
      context.read<OwnerEstimateBloc>().add(const OwnerSiteVisitSelectionCleared());
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
    context.read<OwnerEstimateBloc>().add(OwnerSiteVisitSelected(visit));
    setState(() {});
  }

  String _formatPrice(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  // ---------------- Actions: items ----------------

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
        _recomputeBoxQtyIfNeeded();
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
  }

  void _onQuantityChanged() {
    setState(_recomputeBoxQtyIfNeeded);
  }

  void _resetItemFields() {
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
  }

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
      // Show a message instead of failing silently
      if (mounted) {
        _showError('Could not calculate the amount for this item. Please try again.');
      }
      return;
    } finally {
      if (mounted) setState(() => _isAddingItem = false);
    }

    if (!mounted) return;

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
    final products = context.read<OwnerEstimateBloc>().state.products;
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
  /// Any pending (un-updated) edit or half-filled item form is discarded,
  /// so the old item keeps its old amount and the stale values don't
  /// reappear when the user comes back from Preview.
  Future<void> _goToPreview() async {
    final isEditing = _editingItemIndex != null;
    final hasPendingNew = !isEditing && _selectedProduct != null;

    // An edit (or a half-filled new item) was never applied -> tell the user
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
    _fetchPreview();
  }

  // ---------------- Actions: server preview (POST /quotations/preview) ----------------

  QuotationPreviewRequest _buildPreviewRequest() {
    return QuotationPreviewRequest(
      date: DateFormat('yyyy-MM-dd').format(_date),
      customerName: _partyNameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerEmail: _customerEmailCtrl.text.trim().isEmpty ? null : _customerEmailCtrl.text.trim(),
      customerAddress: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      contractorName:
      _contractorNameCtrl.text.trim().isEmpty ? null : _contractorNameCtrl.text.trim(),
      contractorPhone:
      _contractorPhoneCtrl.text.trim().isEmpty ? null : _contractorPhoneCtrl.text.trim(),
      contractorEmail:
      _contractorEmailCtrl.text.trim().isEmpty ? null : _contractorEmailCtrl.text.trim(),
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

  void _fetchPreview() {
    context.read<OwnerEstimateBloc>().add(OwnerQuotationPreviewRequested(_buildPreviewRequest()));
  }

  void _schedulePreviewFetch() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(_previewDebounceDuration, () {
      if (!mounted) return;
      _fetchPreview();
    });
  }

  // ---------------- Actions: build & submit request ----------------

  QuotationCreateRequest _buildRequest({
    required String action,
    int? salesmanId,
  }) {
    final selectedVisit = context.read<OwnerEstimateBloc>().state.selectedSiteVisit;
    final isApprove = action == 'approve';
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
      salesmanId: isApprove ? salesmanId : null,
      discountType: isApprove ? _discountType : null,
      discountValue: isApprove ? _discountValue : null,
      discountNotes: isApprove ? _discountNotes : null,
      paymentAmount: isApprove ? _paymentAmount : null,
      paymentMethod: isApprove ? (_paymentAmount != null ? _paymentMethod : null) : null,
      paymentReference: isApprove ? _paymentReference : null,
      paymentDate: isApprove && _paymentDate != null
          ? DateFormat('yyyy-MM-dd').format(_paymentDate!)
          : null,
      paymentNotes: isApprove ? _paymentNotes : null,
    );
  }

  /// Save as Quotation — NO discount / payment is sent.
  void _saveDraft() {
    if (!_validateDetails()) return;
    final request = _buildRequest(action: 'save_quotation');
    context.read<OwnerEstimateBloc>().add(OwnerQuotationSubmitRequested(request));
  }

  // ---------------- Approve dialog: Salesman + Discount + Payment (all optional) ----------------
  // Styled to match the Approve Estimate dialog used in the estimate detail screen.

  Future<void> _showApproveDialog() async {
    final bloc = context.read<OwnerEstimateBloc>();
    SalesmanActiveModel? dialogSelection = bloc.state.selectedSalesman;

    // Discount (optional)
    String? discType = _discountType; // null = no discount
    final discValueCtrl = TextEditingController(
      text: _discountValue != null ? _formatPrice(_discountValue!) : '',
    );
    final discNotesCtrl = TextEditingController(text: _discountNotes ?? '');

    // Payment (optional)
    final payAmountCtrl = TextEditingController(
      text: _paymentAmount != null ? _formatPrice(_paymentAmount!) : '',
    );
    final payRefCtrl = TextEditingController(text: _paymentReference ?? '');
    final payNotesCtrl = TextEditingController(text: _paymentNotes ?? '');
    String payMethod = _paymentMethod;
    DateTime payDate = _paymentDate ?? DateTime.now();

    final formKey = GlobalKey<FormState>();
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    // ---- dialog text styles (same look as the detail-screen approve dialog) ----
    final labelStyle = AppTextStyles.caption(color: AppColors.textSecondary)
        .copyWith(fontSize: Responsive.sp(12));
    final inputStyle = AppTextStyles.body().copyWith(fontSize: Responsive.sp(13));
    final errorStyle = AppTextStyles.caption(color: AppColors.error)
        .copyWith(fontSize: Responsive.sp(11));
    final headingStyle =
    AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13.5));

    Widget previewRow(String label, String value, {bool bold = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: Responsive.sp(12.5),
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                      color: color ?? AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
              bloc: bloc,
              builder: (context, state) {
                // ---- Payable amount (display only, from server grand total) ----
                final grandTotal = state.preview?.totals.grandTotal ?? 0;
                final discValue = double.tryParse(discValueCtrl.text.trim()) ?? 0;
                double discAmount = 0;
                if (discType != null && discValue > 0) {
                  discAmount = discType == QuotationDiscountType.percentage
                      ? grandTotal * discValue / 100
                      : discValue;
                  if (discAmount > grandTotal) discAmount = grandTotal;
                }
                final payable = grandTotal - discAmount;
                final received = double.tryParse(payAmountCtrl.text.trim()) ?? 0;
                final balance =
                (payable - received).clamp(0, double.infinity).toDouble();

                return Theme(
                  data: Theme.of(dialogContext).copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: labelStyle,
                      floatingLabelStyle: labelStyle,
                      hintStyle: labelStyle,
                      prefixStyle: inputStyle,
                      suffixStyle: inputStyle,
                      errorStyle: errorStyle,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(14),
                        vertical: Responsive.h(14),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textTheme: Theme.of(dialogContext).textTheme.copyWith(
                      titleMedium: inputStyle, // typed text + dropdown value
                      bodyLarge: inputStyle,
                    ),
                  ),
                  child: AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Approve Estimate', style: headingStyle),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---------- Salesman (optional) ----------
                              Text('Assign Salesman (optional)', style: headingStyle),
                              const SizedBox(height: 6),
                              if (state.salesmenStatus == LoadStatus.loading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              else if (state.salesmenStatus == LoadStatus.failure)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.salesmenError ?? 'Failed to load salesmen.',
                                        style: errorStyle,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          bloc.add(const ActiveSalesmenRequested()),
                                      child: Text('Retry',
                                          style: AppTextStyles.bodyBold(
                                              color: AppColors.primary)),
                                    ),
                                  ],
                                )
                              else
                                DropdownButtonFormField<SalesmanActiveModel?>(
                                  value: dialogSelection,
                                  isExpanded: true,
                                  style: inputStyle,
                                  decoration:
                                  const InputDecoration(labelText: 'Salesman'),
                                  items: [
                                    DropdownMenuItem<SalesmanActiveModel?>(
                                      value: null,
                                      child: Text('No salesman — approve directly',
                                          style: inputStyle),
                                    ),
                                    ...state.salesmen.map(
                                          (s) => DropdownMenuItem<SalesmanActiveModel?>(
                                        value: s,
                                        child: Text(s.displayLabel,
                                            style: inputStyle,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ],
                                  onChanged: (s) =>
                                      setDialogState(() => dialogSelection = s),
                                ),

                              // ---------- Discount (optional) ----------
                              const SizedBox(height: 16),
                              Text('Discount', style: headingStyle),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String?>(
                                value: discType,
                                style: inputStyle,
                                items: [
                                  DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('No discount', style: inputStyle)),
                                  DropdownMenuItem<String?>(
                                      value: QuotationDiscountType.percentage,
                                      child: Text('Percentage', style: inputStyle)),
                                  DropdownMenuItem<String?>(
                                      value: QuotationDiscountType.fixed,
                                      child: Text('Fixed', style: inputStyle)),
                                ],
                                onChanged: (v) => setDialogState(() => discType = v),
                              ),
                              if (discType != null) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: discValueCtrl,
                                  style: inputStyle,
                                  onChanged: (_) => setDialogState(() {}),
                                  keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: DValidator.decimalWithLimit(
                                    maxIntDigits:
                                    discType == QuotationDiscountType.percentage
                                        ? 3
                                        : DValidator.maxPriceDigits,
                                  ),
                                  decoration: InputDecoration(
                                    labelText:
                                    discType == QuotationDiscountType.percentage
                                        ? 'Discount %'
                                        : 'Discount Amount',
                                    prefixText:
                                    discType == QuotationDiscountType.percentage
                                        ? null
                                        : '₹ ',
                                    suffixText:
                                    discType == QuotationDiscountType.percentage
                                        ? '%'
                                        : null,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a value or choose "No discount"';
                                    }
                                    final parsed = double.tryParse(value.trim());
                                    if (parsed == null || parsed < 0) {
                                      return 'Enter a valid value';
                                    }
                                    if (discType == QuotationDiscountType.percentage &&
                                        parsed > 99) {
                                      return 'Cannot exceed 99%';
                                    }
                                    if (discType != QuotationDiscountType.percentage &&
                                        parsed > DValidator.maxPrice) {
                                      return 'Amount can have at most ${DValidator.maxPriceDigits} digits';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],

                              // ---- PAYABLE AMOUNT: shown right before Amount Received ----
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    previewRow('Grand Total', money.format(grandTotal)),
                                    if (discType != null && discAmount > 0)
                                      previewRow(
                                        discType == QuotationDiscountType.percentage
                                            ? 'Discount (${discValueCtrl.text.trim().isEmpty ? '0' : discValueCtrl.text.trim()}%)'
                                            : 'Discount',
                                        '- ${money.format(discAmount)}',
                                        color: AppColors.error,
                                      ),
                                    const Divider(height: 14, color: AppColors.border),
                                    previewRow(
                                      'Payable Amount',
                                      money.format(payable),
                                      bold: true,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),

                              // ---------- Initial Payment (optional) ----------
                              const SizedBox(height: 16),
                              Text('Initial Payment (optional)', style: headingStyle),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: payAmountCtrl,
                                style: inputStyle,
                                keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: DValidator.priceNumber,
                                onChanged: (_) => setDialogState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Amount Received',
                                  prefixText: '₹ ',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null; // optional
                                  }
                                  final parsed = double.tryParse(value.trim());
                                  if (parsed == null || parsed < 0) {
                                    return 'Enter a valid amount';
                                  }
                                  if (parsed > DValidator.maxPrice) {
                                    return 'Amount can have at most ${DValidator.maxPriceDigits} digits';
                                  }
                                  if (grandTotal > 0 && parsed > payable + 0.005) {
                                    return 'Cannot exceed payable amount (${money.format(payable)})';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              // Live balance after the amount received.
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Balance Due', style: AppTextStyles.bodyBold()),
                                    Text(
                                      money.format(balance),
                                      style: AppTextStyles.bodyBold(
                                        color: balance > 0
                                            ? AppColors.error
                                            : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: payMethod,
                                style: inputStyle,
                                decoration:
                                const InputDecoration(labelText: 'Payment Method'),
                                items: [
                                  DropdownMenuItem(
                                      value: QuotationPaymentMethod.cash,
                                      child: Text('Cash', style: inputStyle)),
                                  DropdownMenuItem(
                                      value: QuotationPaymentMethod.cheque,
                                      child: Text('Cheque', style: inputStyle)),
                                  DropdownMenuItem(
                                      value: QuotationPaymentMethod.online,
                                      child: Text('Online', style: inputStyle)),
                                  DropdownMenuItem(
                                      value: QuotationPaymentMethod.credit,
                                      child: Text('Credit', style: inputStyle)),
                                  DropdownMenuItem(
                                      value: QuotationPaymentMethod.bankTransfer,
                                      child: Text('Bank Transfer', style: inputStyle)),
                                ],
                                onChanged: (v) =>
                                    setDialogState(() => payMethod = v ?? payMethod),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: payRefCtrl,
                                style: inputStyle,
                                decoration: const InputDecoration(
                                  labelText: 'Payment Reference (optional)',
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: dialogContext,
                                    initialDate: payDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setDialogState(() => payDate = picked);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Date',
                                  ),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy').format(payDate),
                                    style: inputStyle,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: payNotesCtrl,
                                style: inputStyle,
                                decoration: const InputDecoration(
                                  labelText: 'Payment Notes (optional)',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text('Cancel',
                            style:
                            AppTextStyles.bodyBold(color: AppColors.textSecondary)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(dialogContext).pop(true);
                          }
                        },
                        child: Text(
                          dialogSelection != null ? 'Approve & Assign' : 'Approve',
                          style: AppTextStyles.bodyBold(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (confirmed == true) {
      // Discount: only if a type is chosen AND a value entered
      final discVal = double.tryParse(discValueCtrl.text.trim());
      if (discType != null && discVal != null) {
        _discountType = discType;
        _discountValue = discVal;
        _discountNotes =
        discNotesCtrl.text.trim().isEmpty ? null : discNotesCtrl.text.trim();
      } else {
        _discountType = null;
        _discountValue = null;
        _discountNotes = null;
      }

      // Payment: only if an amount is entered
      final payAmt = double.tryParse(payAmountCtrl.text.trim());
      if (payAmt != null) {
        _paymentAmount = payAmt;
        _paymentMethod = payMethod;
        _paymentReference =
        payRefCtrl.text.trim().isEmpty ? null : payRefCtrl.text.trim();
        _paymentDate = payDate;
        _paymentNotes =
        payNotesCtrl.text.trim().isEmpty ? null : payNotesCtrl.text.trim();
      } else {
        _paymentAmount = null;
        _paymentMethod = QuotationPaymentMethod.cash;
        _paymentReference = null;
        _paymentDate = null;
        _paymentNotes = null;
      }

      if (dialogSelection != null) {
        bloc.add(SalesmanSelected(dialogSelection!));
      }

      final request = _buildRequest(
        action: 'approve',
        salesmanId: dialogSelection != null ? int.tryParse(dialogSelection!.id) : null,
      );
      debugPrint('APPROVE BODY: ${jsonEncode(request.toJson())}'); // temporary, for testing
      bloc.add(OwnerQuotationSubmitRequested(request));
    }
    // Note: dialog controllers are intentionally not disposed here —
    // the dialog is still animating out and would throw "used after dispose".
  }

  // ---------------- Back handling between steps ----------------

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

    return BlocListener<OwnerEstimateBloc, OwnerEstimateState>(
        listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
        listener: (context, state) {
          if (state.submitStatus == SubmitStatus.success) {
            AppSnackbar.success(state.submitMessage ?? 'Saved successfully.');
            context.read<OwnerEstimateBloc>().add(const OwnerQuotationSubmitResultConsumed());

            // If this screen was pushed from the dashboard (or any other
            // screen), pop back with `true` so that screen can reload.
            // Otherwise (deep link / no previous page) fall back to go().
            if (context.canPop()) {
              context.pop(true);
            } else {
              context.go('/owner');
            }
          } else if (state.submitStatus == SubmitStatus.failure) {
            _showError(state.submitError ?? 'Something went wrong. Please try again.');
            context.read<OwnerEstimateBloc>().add(const OwnerQuotationSubmitResultConsumed());
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
                        EstimateStep.addItems => AddItemsStep(
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
                      // Discount / Payment params removed — they now live in the Approve dialog.
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
                          onHandlingChargeChanged: () {
                            setState(() {});
                            _schedulePreviewFetch();
                          },
                          onSaveDraft: _saveDraft,
                          onApprove: _showApproveDialog,
                          onRetryPreview: _fetchPreview,
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}