
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/createestimate_stepindicator.dart';
import 'package:tileshop/ui/owner/widget/ownerestimatetype.dart';
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
import '../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../models/salesmanmodels/salesman_qtnpreviewmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

// NOTE: `AddedItem` and the step enum (now `EstimateStep`) used to be
// declared here. They now live in owner_estimate_types.dart so that this
// file and createestimate_stepindicator.dart (which also needs them) can
// share the exact same type instead of two library-private lookalikes.

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

  // --- Step 2: Items ---
  final _itemCompanyCtrl = TextEditingController();
  final _itemSizeCtrl = TextEditingController();
  final _itemUnitCtrl = TextEditingController();
  final _itemMrpCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemBoxQtyCtrl = TextEditingController();
  final _itemPieceQtyCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();

  ActiveProductModel? _selectedProduct;

  final List<AddedItem> _items = [];
  int _itemCounter = 0;
  int? _editingItemIndex;

  /// Debounces re-fetching POST /quotations/preview when the owner edits
  /// the handling charge on the Preview step, so we don't hit the API on
  /// every keystroke.
  Timer? _previewDebounce;
  static const _previewDebounceDuration = Duration(milliseconds: 500);

  // --- Step 3: owner-only — Discount / Payment / Salesman assignment ---

  /// Extra discount the owner grants on top of the grand total, entered
  /// through the "Give Additional Discount" dialog. Null until added.
  /// NOTE: /quotations/preview has no discount fields, so this is applied
  /// locally on top of the server-calculated grand total, and is only
  /// ever sent to the backend on submit (action = 'approve').
  String? _discountType; // 'percentage' | 'fixed'
  double? _discountValue;
  String? _discountNotes;

  /// Amount already received from the party, entered through the
  /// "Add Payment" dialog. Null until recorded. Same caveat as discount.
  double? _paymentAmount;
  String _paymentMethod = QuotationPaymentMethod.cash;
  String? _paymentReference;
  DateTime? _paymentDate;
  String? _paymentNotes;

  @override
  void dispose() {
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
    _itemMrpCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemBoxQtyCtrl.dispose();
    _itemPieceQtyCtrl.dispose();
    _itemRateCtrl.dispose();
    super.dispose();
  }

  // ---------------- Derived (local, pre-submission) values ----------------
  // Only used on the Add Items step now — the Preview step reads totals
  // straight from the server (state.preview) instead of computing them.

  double get _handlingCharge => double.tryParse(_handlingChargeCtrl.text) ?? 0;

  bool get _isBoxUnitProduct => _selectedProduct?.isBoxUnit ?? false;
  double get _computedQuantity => double.tryParse(_itemQtyCtrl.text) ?? 0;

  void _recomputeBoxQtyIfNeeded() {
    if (!_isBoxUnitProduct) return;
    _itemBoxQtyCtrl.text = _itemQtyCtrl.text;
  }

  double get _currentItemAmount {
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    return _computedQuantity * rate;
  }

  // ---------------- Validation ----------------

  void _showError(String msg) {
    AppSnackbar.error(msg);
  }

  /// Validates the Details step (Step 1) using DValidator instead of the
  /// previous hand-rolled empty-checks.
  bool _validateDetails() {
    final nameError = DValidator.validateName('Party name', _partyNameCtrl.text);
    if (nameError != null) {
      _showError(nameError);
      return false;
    }

    final phoneError = DValidator.validatePhoneNumber(_phoneCtrl.text);
    if (phoneError != null) {
      _showError(phoneError);
      return false;
    }

    // Email is optional on this form, so only validate format when the
    // owner actually typed something — DValidator.validateEmail treats
    // an empty value as an error, which isn't correct here.
    if (_customerEmailCtrl.text.trim().isNotEmpty) {
      final emailError = DValidator.validateEmail(_customerEmailCtrl.text);
      if (emailError != null) {
        _showError(emailError);
        return false;
      }
    }

    return true;
  }

  /// Validates the current item fields (Step 2) using DValidator instead
  /// of the previous hand-rolled checks.
  bool _validateCurrentItemFields() {
    if (_selectedProduct == null) {
      _showError('Please select a product');
      return false;
    }

    // DValidator.validateOptionalNumber allows empty values (they're
    // "optional" numeric fields elsewhere in the app), so we still
    // enforce the ">0" business rule ourselves afterward.
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

    final rateError = DValidator.validateOptionalNumber('Rate', _itemRateCtrl.text);
    final rateValue = double.tryParse(_itemRateCtrl.text) ?? 0;
    if (rateError != null || rateValue <= 0) {
      _showError('Please enter a valid rate');
      return false;
    }

    return true;
  }

  // ---------------- Actions: navigation ----------------

  void _goToAddItems() {
    if (!_validateDetails()) return;
    setState(() => _step = EstimateStep.addItems);
  }

  void _selectSiteVisit(SiteVisitDropdownItem visit) {
    _phoneCtrl.text = visit.customerPhone;
    _phoneCtrl.selection = TextSelection.collapsed(offset: _phoneCtrl.text.length);
    _partyNameCtrl.text = visit.customerName;
    _addressCtrl.text = visit.siteAddress;
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
    _itemMrpCtrl.clear();
    _itemQtyCtrl.clear();
    _itemBoxQtyCtrl.clear();
    _itemPieceQtyCtrl.clear();
    _itemRateCtrl.clear();
  }

  void _addItemToList() {
    if (!_validateCurrentItemFields()) return;
    final product = _selectedProduct!;

    setState(() {
      final editingIndex = _editingItemIndex;
      final newItem = AddedItem(
        id: editingIndex != null ? _items[editingIndex].id : 'item_${_itemCounter++}',
        productId: product.id,
        name: product.name,
        company: _itemCompanyCtrl.text.trim(),
        size: _itemSizeCtrl.text.trim(),
        unit: _itemUnitCtrl.text.trim(),
        quantity: _computedQuantity,
        boxQuantity: _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : 0,
        pieceQuantity: _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : 0,
        rate: double.tryParse(_itemRateCtrl.text) ?? 0,
        mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
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

  void _goToPreview() {
    if (_items.isEmpty) {
      _showError('Please add at least one item');
      return;
    }
    setState(() => _step = EstimateStep.preview);
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
      // contractorAddress:
      // _contractorAddressCtrl.text.trim().isEmpty ? null : _contractorAddressCtrl.text.trim(),
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

  /// Calls POST /quotations/preview immediately with the current form
  /// state. Used when entering the Preview step.
  void _fetchPreview() {
    context.read<OwnerEstimateBloc>().add(OwnerQuotationPreviewRequested(_buildPreviewRequest()));
  }

  /// Debounced re-fetch — used when the owner edits handling charge on
  /// the Preview step so we don't hit the API on every keystroke.
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
      // contractorAddress:
      // _contractorAddressCtrl.text.trim().isEmpty ? null : _contractorAddressCtrl.text.trim(),
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
      // Discount / payment / salesman assignment are only meaningful (and
      // only sent) when the owner is approving the estimate directly.
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

  void _saveDraft() {
    if (!_validateDetails()) return;
    final request = _buildRequest(action: 'save_quotation');
    context.read<OwnerEstimateBloc>().add(OwnerQuotationSubmitRequested(request));
  }

  Future<void> _showApproveDialog() async {
    final bloc = context.read<OwnerEstimateBloc>();
    SalesmanActiveModel? dialogSelection = bloc.state.selectedSalesman;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
              bloc: bloc,
              builder: (context, state) {
                return AlertDialog(
                  title: const Text('Approve Estimate'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You can approve this estimate directly, or optionally '
                            'assign it to a salesman first.',
                      ),
                      SizedBox(height: Responsive.h(16)),
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
                                style: AppTextStyles.caption(color: AppColors.error),
                              ),
                            ),
                            TextButton(
                              onPressed: () => bloc.add(const ActiveSalesmenRequested()),
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<SalesmanActiveModel?>(
                          value: dialogSelection,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Salesman (optional)',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<SalesmanActiveModel?>(
                              value: null,
                              child: Text('No salesman — approve directly'),
                            ),
                            ...state.salesmen.map((s) => DropdownMenuItem<SalesmanActiveModel?>(
                              value: s,
                              child: Text(s.displayLabel, overflow: TextOverflow.ellipsis),
                            )),
                          ],
                          onChanged: (s) => setDialogState(() => dialogSelection = s),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(
                        dialogSelection != null ? 'Approve & Assign' : 'Approve',
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (confirmed == true) {
      if (dialogSelection != null) {
        bloc.add(SalesmanSelected(dialogSelection!));
      }
      final request = _buildRequest(
        action: 'approve',
        salesmanId: dialogSelection != null ? int.tryParse(dialogSelection!.id) : null,
      );
      bloc.add(OwnerQuotationSubmitRequested(request));
    }
  }
  // ---------------- Discount / Payment dialogs (Preview step) ----------------

  Future<void> _showAddDiscountDialog() async {
    String type = _discountType ?? QuotationDiscountType.percentage;
    final valueCtrl = TextEditingController(
      text: _discountValue != null ? _formatPrice(_discountValue!) : '',
    );
    final notesCtrl = TextEditingController(text: _discountNotes ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Additional Discount'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(
                        labelText: 'Discount Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('None')),
                        DropdownMenuItem(
                          value: QuotationDiscountType.percentage,
                          child: Text('Percentage'),
                        ),
                        DropdownMenuItem(
                          value: QuotationDiscountType.fixed,
                          child: Text('Fixed '),
                        ),
                      ],
                      onChanged: (v) => setDialogState(() => type = v ?? type),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: valueCtrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: type == QuotationDiscountType.percentage
                            ? 'Discount %'
                            : 'Discount Amount',
                        prefixText: type == QuotationDiscountType.percentage ? null : '₹ ',
                        suffixText: type == QuotationDiscountType.percentage ? '%' : null,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Value is required';
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed < 0) return 'Enter a valid value';
                        if (type == QuotationDiscountType.percentage && parsed > 100) {
                          return 'Percentage can\'t exceed 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _discountType = type;
        _discountValue = double.tryParse(valueCtrl.text.trim());
        _discountNotes = notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim();
      });
    }
  }

  void _clearDiscount() {
    setState(() {
      _discountType = null;
      _discountValue = null;
      _discountNotes = null;
    });
  }

  Future<void> _showAddPaymentDialog() async {
    final amountCtrl = TextEditingController(
      text: _paymentAmount != null ? _formatPrice(_paymentAmount!) : '',
    );
    final referenceCtrl = TextEditingController(text: _paymentReference ?? '');
    final notesCtrl = TextEditingController(text: _paymentNotes ?? '');
    String method = _paymentMethod;
    DateTime date = _paymentDate ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Payment Received'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: amountCtrl,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Amount Received',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Amount is required';
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: method,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: QuotationPaymentMethod.cash, child: Text('Cash')),
                          DropdownMenuItem(value: QuotationPaymentMethod.cheque, child: Text('Cheque')),
                          DropdownMenuItem(value: QuotationPaymentMethod.online, child: Text('Online')),
                          DropdownMenuItem(value: QuotationPaymentMethod.credit, child: Text('Credit')),
                          DropdownMenuItem(
                              value: QuotationPaymentMethod.bankTransfer, child: Text('Bank Transfer')),
                        ],
                        onChanged: (v) => setDialogState(() => method = v ?? method),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: referenceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Reference (optional)',
                          hintText: 'Cheque no. / Transaction ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setDialogState(() => date = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Payment Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          child: Text(DateFormat('dd-MM-yyyy').format(date)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          hintText: 'e.g. Advance payment',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _paymentAmount = double.tryParse(amountCtrl.text.trim());
        _paymentMethod = method;
        _paymentReference = referenceCtrl.text.trim().isEmpty ? null : referenceCtrl.text.trim();
        _paymentDate = date;
        _paymentNotes = notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim();
      });
    }
  }

  void _clearPayment() {
    setState(() {
      _paymentAmount = null;
      _paymentMethod = QuotationPaymentMethod.cash;
      _paymentReference = null;
      _paymentDate = null;
      _paymentNotes = null;
    });
  }

  // ---------------- Back handling between steps ----------------

  bool _onWillPop() {
    if (_step == EstimateStep.preview) {
      setState(() => _step = EstimateStep.addItems);
      return false;
    }
    if (_step == EstimateStep.addItems) {
      setState(() => _step = EstimateStep.details);
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
            context.go('/owner-dashboard');
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
          child: NetworkAwareWrapper(child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(_appBarTitle),
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
                        itemMrpCtrl: _itemMrpCtrl,
                        itemQtyCtrl: _itemQtyCtrl,
                        itemBoxQtyCtrl: _itemBoxQtyCtrl,
                        itemPieceQtyCtrl: _itemPieceQtyCtrl,
                        itemRateCtrl: _itemRateCtrl,
                        currentAmount: _currentItemAmount,
                        onQuantityChanged: _onQuantityChanged,
                        items: _items,
                        editingIndex: _editingItemIndex,
                        onAddItem: _addItemToList,
                        onEditItem: _editItem,
                        onCancelEdit: _cancelEditItem,
                        onRemoveItem: _removeItem,
                        onCancel: () => setState(() => _step = EstimateStep.details),
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
                        discountType: _discountType,
                        discountValue: _discountValue,
                        paymentAmount: _paymentAmount,
                        onHandlingChargeChanged: () {
                          setState(() {});
                          _schedulePreviewFetch();
                        },
                        onAddDiscount: _showAddDiscountDialog,
                        onEditDiscount: _showAddDiscountDialog,
                        onClearDiscount: _clearDiscount,
                        onAddPayment: _showAddPaymentDialog,
                        onEditPayment: _showAddPaymentDialog,
                        onClearPayment: _clearPayment,
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