
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/salemanbloc/estimate/salesman_estimate_bloc.dart';
import '../../../../bloc/salemanbloc/estimate/salesmanestimate_event.dart';
import '../../../../bloc/salemanbloc/estimate/salesmanestimate_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/primary_button.dart';

/// One added item in the estimate. MRP and incentive % are gone as inputs —
/// /products/active doesn't return pricing, so Rate is a manual entry.
/// Incentive is now looked up live from /quotations/product-incentive while
/// the item is being entered, and whatever the API returned at the moment
/// "Add Item" is pressed is snapshotted onto the item below.
class _AddedItem {
  final String id;
  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double quantity;
  final double rate;

  /// Product's reference MRP at the time this item was added — display
  /// only, not used in any calculation and not required to be non-zero.
  final double mrp;

  /// Snapshot of the incentive preview at the moment this item was added
  /// (0 if no incentive data was available, e.g. the product isn't
  /// eligible or the incentive lookup failed).
  final double incentiveAmount;
  final bool incentiveEligible;
  final String? incentiveReason;

  const _AddedItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.company,
    required this.size,
    required this.unit,
    required this.quantity,
    required this.rate,
    this.mrp = 0,
    this.incentiveAmount = 0,
    this.incentiveEligible = false,
    this.incentiveReason,
  });

  double get amount => quantity * rate;
}

enum _Step { details, addItems, preview }

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
  _Step _step = _Step.details;

  // --- Step 1: Party / Contractor / Salesman ---
  final _partyNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _customerEmailCtrl = TextEditingController();
  final _contractorNameCtrl = TextEditingController();
  final _contractorPhoneCtrl = TextEditingController();
  final _contractorEmailCtrl = TextEditingController();

  final _salesmanCtrl = TextEditingController(text: 'Rahul Kumar');
  final _salesmanMobCtrl = TextEditingController();

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
  final _itemRateCtrl = TextEditingController();

  ActiveProductModel? _selectedProduct;

  final List<_AddedItem> _items = [];
  int _itemCounter = 0;
  int? _editingItemIndex;

  // Debounces the live incentive lookup so it doesn't fire on every
  // keystroke while quantity/rate are being typed.
  Timer? _incentiveDebounce;
  static const _incentiveDebounceDuration = Duration(milliseconds: 450);

  @override
  void dispose() {
    _incentiveDebounce?.cancel();
    _partyNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _customerEmailCtrl.dispose();
    _contractorNameCtrl.dispose();
    _contractorPhoneCtrl.dispose();
    _contractorEmailCtrl.dispose();
    _salesmanCtrl.dispose();
    _salesmanMobCtrl.dispose();
    _handlingChargeCtrl.dispose();
    _notesCtrl.dispose();
    _termsCtrl.dispose();
    _itemCompanyCtrl.dispose();
    _itemSizeCtrl.dispose();
    _itemUnitCtrl.dispose();
    _itemMrpCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemRateCtrl.dispose();
    super.dispose();
  }

  // ---------------- Derived totals ----------------

  double get _itemsTotal => _items.fold(0.0, (s, r) => s + r.amount);
  double get _handlingCharge => double.tryParse(_handlingChargeCtrl.text) ?? 0;
  double get _grandTotal => _itemsTotal + _handlingCharge;
  double get _totalQty => _items.fold(0.0, (s, r) => s + r.quantity);
  int get _totalItems => _items.length;

  /// Sum of every added item's snapshotted incentive — salesman-facing
  /// only, shown separately from the customer's grand total.
  double get _incentiveTotal => _items.fold(0.0, (s, r) => s + r.incentiveAmount);

  double get _currentItemAmount {
    final qty = double.tryParse(_itemQtyCtrl.text) ?? 0;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    return qty * rate;
  }

  // ---------------- Validation ----------------

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  bool _validateDetails() {
    if (_partyNameCtrl.text.trim().isEmpty) {
      _showError('Please enter the party name');
      return false;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _showError('Please enter the customer phone number');
      return false;
    }
    return true;
  }

  bool _validateCurrentItemFields() {
    if (_selectedProduct == null) {
      _showError('Please select a product');
      return false;
    }
    if ((double.tryParse(_itemQtyCtrl.text) ?? 0) <= 0) {
      _showError('Please enter a valid quantity');
      return false;
    }
    if ((double.tryParse(_itemRateCtrl.text) ?? 0) <= 0) {
      _showError('Please enter a valid rate');
      return false;
    }
    return true;
  }

  // ---------------- Actions ----------------

  void _goToAddItems() {
    if (!_validateDetails()) return;
    setState(() => _step = _Step.addItems);
  }

  void _selectSiteVisit(SiteVisitDropdownItem visit) {
    _phoneCtrl.text = visit.customerPhone;
    _phoneCtrl.selection = TextSelection.collapsed(offset: _phoneCtrl.text.length);
    _partyNameCtrl.text = visit.customerName;
    _addressCtrl.text = visit.siteAddress;
    context.read<SalesmanEstimateBloc>().add(SiteVisitSelected(visit));
    setState(() {});
  }

  /// Formats a price value without a trailing ".00" for whole numbers,
  /// e.g. 650.0 -> "650", 649.5 -> "649.5".
  String _formatPrice(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  void _onProductSelected(ActiveProductModel? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        // Auto-fill MRP and Rate straight from the product master. Both
        // fields stay editable afterwards — this only pre-fills them, it
        // doesn't lock them, so the salesman can still override the rate
        // (or MRP) by hand for this particular estimate.
        _itemMrpCtrl.text = _formatPrice(product.mrp);
        _itemRateCtrl.text = _formatPrice(product.rate);
      } else {
        _itemCompanyCtrl.clear();
        _itemSizeCtrl.clear();
        _itemUnitCtrl.clear();
        _itemMrpCtrl.clear();
        _itemRateCtrl.clear();
      }
    });
    // Rate is now pre-filled as soon as a product is picked, so the
    // incentive preview should kick off right away too (not just wait for
    // the salesman to touch the rate field).
    _scheduleIncentiveFetch();
  }

  /// Debounces then fires (or clears) the live incentive preview for
  /// whatever product/quantity/rate is currently entered. Called whenever
  /// the selected product, quantity, or rate changes on the Add Items step.
  void _scheduleIncentiveFetch() {
    _incentiveDebounce?.cancel();

    final product = _selectedProduct;
    final qty = double.tryParse(_itemQtyCtrl.text) ?? 0;
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
      ));
    });
  }

  void _resetItemFields() {
    _incentiveDebounce?.cancel();
    _selectedProduct = null;
    _itemCompanyCtrl.clear();
    _itemSizeCtrl.clear();
    _itemUnitCtrl.clear();
    _itemMrpCtrl.clear();
    _itemQtyCtrl.clear();
    _itemRateCtrl.clear();
    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
  }

  void _addItemToList() {
    if (!_validateCurrentItemFields()) return;
    final product = _selectedProduct!;

    // Snapshot whatever incentive preview is currently loaded for this
    // exact product, so a stale/mismatched preview from a previous product
    // never gets attached to the wrong item.
    final incentiveState = context.read<SalesmanEstimateBloc>().state;
    final liveIncentive = incentiveState.incentive;
    final matchesCurrentProduct =
        liveIncentive != null && liveIncentive.productId == product.id;

    setState(() {
      final editingIndex = _editingItemIndex;
      final newItem = _AddedItem(
        id: editingIndex != null ? _items[editingIndex].id : 'item_${_itemCounter++}',
        productId: product.id,
        name: product.name,
        company: _itemCompanyCtrl.text.trim(),
        size: _itemSizeCtrl.text.trim(),
        unit: _itemUnitCtrl.text.trim(),
        quantity: double.tryParse(_itemQtyCtrl.text) ?? 0,
        rate: double.tryParse(_itemRateCtrl.text) ?? 0,
        mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
        incentiveAmount: matchesCurrentProduct ? liveIncentive.totalIncentive : 0,
        incentiveEligible: matchesCurrentProduct ? liveIncentive.isEligible : false,
        incentiveReason: matchesCurrentProduct ? liveIncentive.eligibilityReason : null,
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
    setState(() {
      _editingItemIndex = index;
      _selectedProduct = null; // matching catalog product not tracked by id here
      _itemCompanyCtrl.text = item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = item.mrp == item.mrp.roundToDouble()
          ? item.mrp.toStringAsFixed(0)
          : item.mrp.toString();
      _itemQtyCtrl.text = item.quantity == item.quantity.roundToDouble()
          ? item.quantity.toStringAsFixed(0)
          : item.quantity.toString();
      _itemRateCtrl.text = item.rate == item.rate.roundToDouble()
          ? item.rate.toStringAsFixed(0)
          : item.rate.toString();
    });
    // No product is re-selected on edit (see comment above), so there's
    // nothing to look an incentive up against until the salesman re-picks
    // it from the dropdown — make sure any stale preview is cleared.
    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
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
    setState(() => _step = _Step.preview);
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
      siteVisitId: selectedVisit?.id,
      handlingCharge: _handlingCharge,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
      items: _items
          .map((r) => QuotationItemRequest(
        productId: int.tryParse(r.productId) ?? 0,
        quantity: r.quantity,
        rate: r.rate,
      ))
          .toList(),
    );
  }

  void _saveDraft() {
    if (!_validateDetails()) return;
    final request = _buildRequest(action: 'save_quotation');
    context.read<SalesmanEstimateBloc>().add(QuotationSubmitRequested(request));
  }

  void _submitForApproval() {
    final request = _buildRequest(action: 'submit');
    context.read<SalesmanEstimateBloc>().add(QuotationSubmitRequested(request));
  }

  // ---------------- Back handling between steps ----------------

  bool _onWillPop() {
    if (_step == _Step.preview) {
      setState(() => _step = _Step.addItems);
      return false;
    }
    if (_step == _Step.addItems) {
      setState(() => _step = _Step.details);
      return false;
    }
    return true;
  }

  String get _appBarTitle {
    switch (_step) {
      case _Step.details:
        return 'Create Estimate';
      case _Step.addItems:
        return 'Add Items';
      case _Step.preview:
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.submitMessage ?? 'Saved successfully.')),
          );
          context.read<SalesmanEstimateBloc>().add(const QuotationSubmitResultConsumed());
          Navigator.of(context).pop();
        } else if (state.submitStatus == SubmitStatus.failure) {
          _showError(state.submitError ?? 'Something went wrong. Please try again.');
          context.read<SalesmanEstimateBloc>().add(const QuotationSubmitResultConsumed());
        }
      },
      child: PopScope(
        canPop: _step == _Step.details,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _onWillPop();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_appBarTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_step == _Step.details) {
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
                _StepIndicator(step: _step),
                Expanded(
                  child: switch (_step) {
                    _Step.details => _DetailsStep(
                      date: _date,
                      onDateChanged: (d) => setState(() => _date = d),
                      partyNameCtrl: _partyNameCtrl,
                      addressCtrl: _addressCtrl,
                      phoneCtrl: _phoneCtrl,
                      customerEmailCtrl: _customerEmailCtrl,
                      contractorNameCtrl: _contractorNameCtrl,
                      contractorPhoneCtrl: _contractorPhoneCtrl,
                      contractorEmailCtrl: _contractorEmailCtrl,
                      salesmanCtrl: _salesmanCtrl,
                      salesmanMobCtrl: _salesmanMobCtrl,
                      onSelectSiteVisit: _selectSiteVisit,
                      onNext: _goToAddItems,
                    ),
                    _Step.addItems => _AddItemsStep(
                      selectedProduct: _selectedProduct,
                      onProductSelected: _onProductSelected,
                      itemCompanyCtrl: _itemCompanyCtrl,
                      itemSizeCtrl: _itemSizeCtrl,
                      itemUnitCtrl: _itemUnitCtrl,
                      itemMrpCtrl: _itemMrpCtrl,
                      itemQtyCtrl: _itemQtyCtrl,
                      itemRateCtrl: _itemRateCtrl,
                      currentAmount: _currentItemAmount,
                      onQtyRateChanged: _scheduleIncentiveFetch,
                      items: _items,
                      editingIndex: _editingItemIndex,
                      onAddItem: _addItemToList,
                      onEditItem: _editItem,
                      onCancelEdit: _cancelEditItem,
                      onRemoveItem: _removeItem,
                      onCancel: () => setState(() => _step = _Step.details),
                      onSaveItems: _goToPreview,
                    ),
                    _Step.preview => _PreviewStep(
                      date: _date,
                      partyName: _partyNameCtrl.text,
                      address: _addressCtrl.text,
                      phone: _phoneCtrl.text,
                      contractorName: _contractorNameCtrl.text,
                      contractorPhone: _contractorPhoneCtrl.text,
                      salesmanName: _salesmanCtrl.text,
                      salesmanMobile: _salesmanMobCtrl.text,
                      items: _items,
                      itemsTotal: _itemsTotal,
                      handlingChargeCtrl: _handlingChargeCtrl,
                      notesCtrl: _notesCtrl,
                      termsCtrl: _termsCtrl,
                      grandTotal: _grandTotal,
                      totalQty: _totalQty,
                      totalItems: _totalItems,
                      incentiveTotal: _incentiveTotal,
                      onHandlingChargeChanged: () => setState(() {}),
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
    );
  }
}

// =====================================================================
// STEP INDICATOR
// =====================================================================

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final index = _Step.values.indexOf(step);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(18), vertical: Responsive.h(10)),
      child: Row(
        children: List.generate(_Step.values.length * 2 - 1, (i) {
          if (i.isOdd) {
            final segmentDone = (i ~/ 2) < index;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
                color: segmentDone ? AppColors.primary : AppColors.border,
              ),
            );
          }
          final dotIndex = i ~/ 2;
          final active = dotIndex == index;
          final done = dotIndex < index;
          return CircleAvatar(
            radius: 13,
            backgroundColor: (active || done) ? AppColors.primary : AppColors.border,
            child: done
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
              '${dotIndex + 1}',
              style: TextStyle(
                color: active ? Colors.white : AppColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =====================================================================
// STEP 1 — DETAILS
// =====================================================================

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.date,
    required this.onDateChanged,
    required this.partyNameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.customerEmailCtrl,
    required this.contractorNameCtrl,
    required this.contractorPhoneCtrl,
    required this.contractorEmailCtrl,
    required this.salesmanCtrl,
    required this.salesmanMobCtrl,
    required this.onSelectSiteVisit,
    required this.onNext,
  });

  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController partyNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController customerEmailCtrl;
  final TextEditingController contractorNameCtrl;
  final TextEditingController contractorPhoneCtrl;
  final TextEditingController contractorEmailCtrl;
  final TextEditingController salesmanCtrl;
  final TextEditingController salesmanMobCtrl;
  final ValueChanged<SiteVisitDropdownItem> onSelectSiteVisit;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(Responsive.w(18)),
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(14)),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Estimate', style: AppTextStyles.h3()),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) onDateChanged(picked);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Date', style: AppTextStyles.caption()),
                          Row(
                            children: [
                              Text(DateFormat('dd-MM-yyyy').format(date), style: AppTextStyles.h3()),
                              const SizedBox(width: 4),
                              const Icon(Icons.calendar_today_outlined, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(20)),

              Text('Customer Details', style: AppTextStyles.h3()),
              SizedBox(height: Responsive.h(12)),
              _PhoneSiteVisitField(
                phoneCtrl: phoneCtrl,
                onSelectSiteVisit: onSelectSiteVisit,
              ),
              SizedBox(height: Responsive.h(10)),
              LabeledField(
                label: 'Party Name',
                field: CustomTextField(hint: 'Enter party name', icon: Icons.groups_2_outlined, controller: partyNameCtrl),
              ),
              LabeledField(
                label: 'Address',
                field: CustomTextField(hint: 'Enter site address', icon: Icons.location_on_outlined, controller: addressCtrl),
              ),
              LabeledField(
                label: 'Email (optional)',
                field: CustomTextField(
                  hint: 'Enter customer email',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  controller: customerEmailCtrl,
                ),
              ),
              SizedBox(height: Responsive.h(16)),

              Text('Contractor Details', style: AppTextStyles.h3()),
              SizedBox(height: Responsive.h(12)),
              LabeledField(
                label: 'Contractor Name',
                field: CustomTextField(hint: 'Enter contractor name', icon: Icons.engineering_outlined, controller: contractorNameCtrl),
              ),
              LabeledField(
                label: 'Contact No.',
                field: CustomTextField(
                  hint: 'Enter contractor phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: contractorPhoneCtrl,
                ),
              ),
              LabeledField(
                label: 'Email (optional)',
                field: CustomTextField(
                  hint: 'Enter contractor email',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  controller: contractorEmailCtrl,
                ),
              ),
              SizedBox(height: Responsive.h(16)),

            ],
          ),
        ),
        _BottomActionBar(
          right: PrimaryButton(label: 'Add Items', height: 48, onPressed: onNext),
        ),
      ],
    );
  }
}

// =====================================================================
// PHONE FIELD WITH LIVE SITE-VISIT SUGGESTIONS (from the bloc)
// =====================================================================

class _PhoneSiteVisitField extends StatelessWidget {
  const _PhoneSiteVisitField({
    required this.phoneCtrl,
    required this.onSelectSiteVisit,
  });

  final TextEditingController phoneCtrl;
  final ValueChanged<SiteVisitDropdownItem> onSelectSiteVisit;

  static const int _minDigitsToSearch = 2;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: phoneCtrl,
      builder: (context, value, _) {
        final query = value.text.trim();

        return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
          buildWhen: (prev, curr) =>
          prev.siteVisits != curr.siteVisits || prev.siteVisitsStatus != curr.siteVisitsStatus,
          builder: (context, state) {
            List<SiteVisitDropdownItem> matches = [];
            if (query.length >= _minDigitsToSearch) {
              matches = state.siteVisits.where((v) => v.customerPhone.contains(query)).toList();
            }
            final showSuggestions = matches.isNotEmpty;
            final loading = state.siteVisitsStatus == LoadStatus.loading;
            final failed = state.siteVisitsStatus == LoadStatus.failure;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledField(
                  label: 'Contact No.',
                  field: CustomTextField(
                    hint: 'Enter phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: phoneCtrl,
                  ),
                ),
                if (query.length >= _minDigitsToSearch && loading) ...[
                  SizedBox(height: Responsive.h(6)),
                  Text('Searching pending site visits…', style: AppTextStyles.caption()),
                ] else if (query.length >= _minDigitsToSearch && failed) ...[
                  SizedBox(height: Responsive.h(6)),
                  InkWell(
                    onTap: () => context.read<SalesmanEstimateBloc>().add(const PendingSiteVisitsRequested()),
                    child: Text(
                      'Couldn\'t load site visits — tap to retry',
                      style: AppTextStyles.caption(color: AppColors.error),
                    ),
                  ),
                ] else if (showSuggestions) ...[
                  SizedBox(height: Responsive.h(6)),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: Responsive.h(220)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: matches.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final v = matches[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.surfaceAlt,
                            child: Text(
                              v.customerName.isNotEmpty ? v.customerName[0].toUpperCase() : '?',
                              style: AppTextStyles.caption(),
                            ),
                          ),
                          title: Text(v.customerName, style: AppTextStyles.bodyBold()),
                          subtitle: Text(
                            '${v.customerPhone} · ${v.siteAddress}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(),
                          ),
                          trailing: const Icon(Icons.north_west, size: 16, color: AppColors.primary),
                          onTap: () => onSelectSiteVisit(v),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    'Tap a match to fill party name and address',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

// =====================================================================
// STEP 2 — ADD ITEMS
// =====================================================================

class _AddItemsStep extends StatelessWidget {
  const _AddItemsStep({
    required this.selectedProduct,
    required this.onProductSelected,
    required this.itemCompanyCtrl,
    required this.itemSizeCtrl,
    required this.itemUnitCtrl,
    required this.itemMrpCtrl,
    required this.itemQtyCtrl,
    required this.itemRateCtrl,
    required this.currentAmount,
    required this.onQtyRateChanged,
    required this.items,
    required this.editingIndex,
    required this.onAddItem,
    required this.onEditItem,
    required this.onCancelEdit,
    required this.onRemoveItem,
    required this.onCancel,
    required this.onSaveItems,
  });

  final ActiveProductModel? selectedProduct;
  final ValueChanged<ActiveProductModel?> onProductSelected;
  final TextEditingController itemCompanyCtrl;
  final TextEditingController itemSizeCtrl;
  final TextEditingController itemUnitCtrl;
  final TextEditingController itemMrpCtrl;
  final TextEditingController itemQtyCtrl;
  final TextEditingController itemRateCtrl;
  final double currentAmount;

  /// Fired whenever quantity or rate changes, so the parent can debounce a
  /// fresh live-incentive lookup.
  final VoidCallback onQtyRateChanged;

  final List<_AddedItem> items;
  final int? editingIndex;
  final VoidCallback onAddItem;
  final void Function(int) onEditItem;
  final VoidCallback onCancelEdit;
  final void Function(int) onRemoveItem;
  final VoidCallback onCancel;
  final VoidCallback onSaveItems;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
                    buildWhen: (prev, curr) =>
                    prev.products != curr.products || prev.productsStatus != curr.productsStatus,
                    builder: (context, state) {
                      if (state.productsStatus == LoadStatus.loading && state.products.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (state.productsStatus == LoadStatus.failure && state.products.isEmpty) {
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
                                onPressed: () =>
                                    context.read<SalesmanEstimateBloc>().add(const ActiveProductsRequested()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      return LabeledField(
                        label: 'Select Product',
                        field: DropdownButtonFormField<ActiveProductModel>(
                          value: selectedProduct,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          decoration: InputDecoration(
                            hintText: 'Choose a product',
                            prefixIcon: const Icon(Icons.inventory_2_outlined),
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
                          items: state.products
                              .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              '${p.name} — ${p.company}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                              .toList(),
                          onChanged: (p) {
                            onProductSelected(p);
                            setLocalState(() {});
                          },
                        ),
                      );
                    },
                  ),

                  SizedBox(height: Responsive.h(10)),
                  LabeledField(
                    label: 'Company (auto)',
                    field: IgnorePointer(
                      child: CustomTextField(
                        hint: 'Select a product first',
                        icon: Icons.factory_outlined,
                        controller: itemCompanyCtrl,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Size (auto)',
                          field: CustomTextField(
                            hint: 'e.g. 600x1200',
                            icon: Icons.straighten_outlined,
                            controller: itemSizeCtrl,
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        child: LabeledField(
                          label: 'Unit (auto)',
                          field: CustomTextField(
                            hint: 'e.g. sqft',
                            icon: Icons.square_foot_outlined,
                            controller: itemUnitCtrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                  LabeledField(
                    label: 'MRP (auto)',
                    field: CustomTextField(
                      hint: '0',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      controller: itemMrpCtrl,
                      // MRP is pre-filled from the product master when a
                      // product is selected, but stays editable in case it
                      // needs a manual override for this estimate.
                      onChanged: (_) => setLocalState(() {}),
                    ),
                  ),
                  LabeledField(
                    label: 'Quantity',
                    field: CustomTextField(
                      hint: 'Enter quantity',
                      icon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                      controller: itemQtyCtrl,
                      onChanged: (_) {
                        setLocalState(() {});
                        onQtyRateChanged();
                      },
                    ),
                  ),
                  LabeledField(
                    label: 'Rate',
                    field: CustomTextField(
                      hint: 'Enter rate per unit',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      controller: itemRateCtrl,
                      // Auto-filled from the product's default rate on
                      // selection, but fully editable — the salesman can
                      // type over it to quote a different rate.
                      onChanged: (_) {
                        setLocalState(() {});
                        onQtyRateChanged();
                      },
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
                        Text(currency.format(currentAmount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
                      ],
                    ),
                  ),

                  // Live incentive preview for the item currently being
                  // entered — only shown once a product is selected.
                  if (selectedProduct != null) ...[
                    SizedBox(height: Responsive.h(8)),
                    const _IncentivePreviewCard(),
                  ],

                  SizedBox(height: Responsive.h(14)),

                  if (editingIndex != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(8)),
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
                              'Editing item #${editingIndex! + 1}',
                              style: AppTextStyles.caption(),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              onCancelEdit();
                              setLocalState(() {});
                            },
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.bodyBold(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onAddItem();
                        setLocalState(() {});
                      },
                      icon: Icon(
                        editingIndex != null ? Icons.save_outlined : Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(editingIndex != null ? 'Update Item' : 'Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(20)),

                  Text('Items Added (${items.length})', style: AppTextStyles.h3()),
                  SizedBox(height: Responsive.h(10)),

                  if (items.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
                      child: Center(
                        child: Text(
                          'No items added yet',
                          style: AppTextStyles.body(color: AppColors.textHint),
                        ),
                      ),
                    )
                  else
                    ...items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return _AddedItemTile(
                        serialNo: i + 1,
                        item: item,
                        currency: currency,
                        isEditing: editingIndex == i,
                        onEdit: () {
                          onEditItem(i);
                          setLocalState(() {});
                        },
                        onDelete: () {
                          onRemoveItem(i);
                          setLocalState(() {});
                        },
                      );
                    }),
                ],
              ),
            ),
            _BottomActionBar(
              left: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel'),
              ),
              right: PrimaryButton(label: 'Save Items', height: 48, onPressed: onSaveItems),
            ),
          ],
        );
      },
    );
  }
}

/// Shows the live /quotations/product-incentive result for whatever is
/// currently in the product/quantity/rate fields on the Add Items step.
/// Reads incentiveStatus/incentive straight off the bloc, since the fetch
/// itself is dispatched (debounced) by the parent screen.
class _IncentivePreviewCard extends StatelessWidget {
  const _IncentivePreviewCard();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
      buildWhen: (prev, curr) =>
      prev.incentiveStatus != curr.incentiveStatus ||
          prev.incentive != curr.incentive ||
          prev.incentiveError != curr.incentiveError,
      builder: (context, state) {
        if (state.incentiveStatus == LoadStatus.initial) {
          return const SizedBox.shrink();
        }

        if (state.incentiveStatus == LoadStatus.loading) {
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

        if (state.incentiveStatus == LoadStatus.failure) {
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
                      Text('Incentive on this item', style: AppTextStyles.bodyBold(color: AppColors.success)),
                    ],
                  ),
                  Text(
                    currency.format(incentive.totalIncentive),
                    style: AppTextStyles.bodyBold(color: AppColors.success),
                  ),
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

class _AddedItemTile extends StatelessWidget {
  const _AddedItemTile({
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.isEditing = false,
  });
  final int serialNo;
  final _AddedItem item;
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
                if (item.incentiveEligible && item.incentiveAmount > 0) ...[
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
              Text(currency.format(item.amount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
              SizedBox(height: Responsive.h(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(onTap: onEdit, child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary)),
                  SizedBox(width: Responsive.w(14)),
                  InkWell(onTap: onDelete, child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// STEP 3 — PREVIEW
// =====================================================================

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({
    required this.date,
    required this.partyName,
    required this.address,
    required this.phone,
    required this.contractorName,
    required this.contractorPhone,
    required this.salesmanName,
    required this.salesmanMobile,
    required this.items,
    required this.itemsTotal,
    required this.handlingChargeCtrl,
    required this.notesCtrl,
    required this.termsCtrl,
    required this.grandTotal,
    required this.totalQty,
    required this.totalItems,
    required this.incentiveTotal,
    required this.onHandlingChargeChanged,
    required this.onSaveDraft,
    required this.onSubmit,
  });

  final DateTime date;
  final String partyName;
  final String address;
  final String phone;
  final String contractorName;
  final String contractorPhone;
  final String salesmanName;
  final String salesmanMobile;
  final List<_AddedItem> items;
  final double itemsTotal;
  final TextEditingController handlingChargeCtrl;
  final TextEditingController notesCtrl;
  final TextEditingController termsCtrl;
  final double grandTotal;
  final double totalQty;
  final int totalItems;

  /// Sum of every item's snapshotted incentive — salesman-facing only,
  /// shown separately from the customer's grand total below.
  final double incentiveTotal;
  final VoidCallback onHandlingChargeChanged;
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(Responsive.w(18)),
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(14)),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Estimate', style: AppTextStyles.h3()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Date', style: AppTextStyles.caption()),
                        Text(DateFormat('dd-MM-yyyy').format(date), style: AppTextStyles.h3()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(16)),

              _PreviewSection(
                title: 'Customer Details',
                rows: [
                  _PreviewRow('Party Name', partyName.isEmpty ? '-' : partyName),
                  _PreviewRow('Address', address.isEmpty ? '-' : address),
                  _PreviewRow('Contact No.', phone.isEmpty ? '-' : phone),
                ],
              ),
              SizedBox(height: Responsive.h(14)),

              _PreviewSection(
                title: 'Contractor',
                rows: [
                  _PreviewRow('Name', contractorName.isEmpty ? '-' : contractorName),
                  _PreviewRow('Contact No.', contractorPhone.isEmpty ? '-' : contractorPhone),
                ],
              ),
              SizedBox(height: Responsive.h(14)),

              _PreviewSection(
                title: 'Salesman',
                rows: [
                  _PreviewRow('Name', salesmanName.isEmpty ? '-' : salesmanName),
                  _PreviewRow('Mob.', salesmanMobile.isEmpty ? '-' : salesmanMobile),
                ],
              ),
              SizedBox(height: Responsive.h(20)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items', style: AppTextStyles.h3()),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Total Items: $totalItems', style: AppTextStyles.bodyBold(color: AppColors.primary)),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(10)),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
                    headingTextStyle: AppTextStyles.bodyBold(),
                    dataTextStyle: AppTextStyles.body(),
                    columnSpacing: 18,
                    columns: const [
                      DataColumn(label: Text('Sl.No')),
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Company')),
                      DataColumn(label: Text('Size')),
                      DataColumn(label: Text('Qty'), numeric: true),
                      DataColumn(label: Text('Unit')),
                      DataColumn(label: Text('Rate'), numeric: true),
                      DataColumn(label: Text('Amount'), numeric: true),
                      DataColumn(label: Text('Incentive'), numeric: true),
                    ],
                    rows: items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(item.name)),
                        DataCell(Text(item.company.isEmpty ? '-' : item.company)),
                        DataCell(Text(item.size.isEmpty ? '-' : item.size)),
                        DataCell(Text(number.format(item.quantity))),
                        DataCell(Text(item.unit)),
                        DataCell(Text(number.format(item.rate))),
                        DataCell(Text(currency.format(item.amount), style: AppTextStyles.bodyBold())),
                        DataCell(Text(
                          item.incentiveAmount > 0 ? currency.format(item.incentiveAmount) : '-',
                          style: AppTextStyles.bodyBold(color: AppColors.success),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(16)),

              LabeledField(
                label: 'Handling Charge',
                field: CustomTextField(
                  hint: 'Enter handling charge',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  controller: handlingChargeCtrl,
                  onChanged: (_) => onHandlingChargeChanged(),
                ),
              ),
              SizedBox(height: Responsive.h(10)),
              LabeledField(
                label: 'Notes (optional)',
                field: CustomTextField(
                  hint: 'e.g. Customer enquiry for new project',
                  icon: Icons.notes_outlined,
                  controller: notesCtrl,
                ),
              ),
              SizedBox(height: Responsive.h(10)),
              LabeledField(
                label: 'Terms & Conditions (optional)',
                field: CustomTextField(
                  hint: 'e.g. Standard terms apply',
                  icon: Icons.gavel_outlined,
                  controller: termsCtrl,
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
                    _totalRow('Total Items', '$totalItems'),
                    SizedBox(height: Responsive.h(6)),
                    _totalRow('Total Qty', number.format(totalQty)),
                    SizedBox(height: Responsive.h(6)),
                    _totalRow('Items Total', currency.format(itemsTotal)),
                    SizedBox(height: Responsive.h(6)),
                    _totalRow('Handling Charge', currency.format(double.tryParse(handlingChargeCtrl.text) ?? 0)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: AppTextStyles.h3()),
                        Text(currency.format(grandTotal), style: AppTextStyles.h2(color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(12)),

              // Separate, visually distinct box for incentive so it's clear
              // this is salesman-facing info, not part of the customer's
              // bill total above.
              if (incentiveTotal > 0)
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
                          Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
                        ],
                      ),
                      Text(
                        currency.format(incentiveTotal),
                        style: AppTextStyles.h3(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: Responsive.h(12)),
            ],
          ),
        ),
        BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
          buildWhen: (prev, curr) =>
          prev.submitStatus != curr.submitStatus || prev.submitAction != curr.submitAction,
          builder: (context, state) {
            final submitting = state.submitStatus == SubmitStatus.submitting;
            final savingDraft = submitting && state.submitAction == 'save_quotation';
            final submittingForApproval = submitting && state.submitAction == 'submit';

            return _BottomActionBar(
              left: OutlinedButton.icon(
                onPressed: submitting ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: savingDraft
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.request_quote_outlined, size: 18),
                label: Text(savingDraft ? 'Saving…' : 'Save as Quotation'),
              ),
              right: PrimaryButton(
                label: submittingForApproval ? 'Submitting…' : 'Submit for Approval',
                height: 48,
                onPressed: submitting ? null : onSubmit,
              ),
            );
          },
        ),
      ],
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

class _PreviewRow {
  final String label;
  final String value;
  _PreviewRow(this.label, this.value);
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.rows});
  final String title;
  final List<_PreviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
          SizedBox(height: Responsive.h(8)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(4)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 100, child: Text(r.label, style: AppTextStyles.caption())),
                Expanded(child: Text(r.value, style: AppTextStyles.body())),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    super.key,
    this.left,
    required this.right,
  });

  final Widget? left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(18),
        Responsive.h(10),
        Responsive.w(18),
        Responsive.h(14),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (left != null) ...[
            Expanded(child: left!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(child: right),
        ],
      ),
    );
  }
}
