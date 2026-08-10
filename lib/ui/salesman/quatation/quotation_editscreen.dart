import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/primary_button.dart';

import '../../../bloc/salemanbloc/estimate/qtn_listdetail_event.dart';
import '../../../bloc/salemanbloc/estimate/qtn_listdetail_state.dart';
import '../../../bloc/salemanbloc/estimate/quotation_listdetail_bloc.dart';
import '../../../bloc/salemanbloc/estimate/salesman_estimate_bloc.dart';
import '../../../bloc/salemanbloc/estimate/salesmanestimate_event.dart';
import '../../../bloc/salemanbloc/estimate/salesmanestimate_state.dart';

import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../../models/salesmanmodels/quotationupdatemodel.dart';

/// CreateEstimateScreen uses.
class QuotationEditScreen extends StatelessWidget {
  const QuotationEditScreen({super.key, required this.estimate});

  /// The already-loaded detail (from the preview screen) used to prefill
  /// every field, so this screen doesn't need to re-fetch anything for the
  /// quotation itself.
  final QuotationDetailModel estimate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Only products + incentive are needed here (no site-visit picking
      // on an edit screen), so dispatch ActiveProductsRequested directly
      // instead of SalesmanEstimateStarted.
      create: (_) => SalesmanEstimateBloc()..add(const ActiveProductsRequested()),
      child: _QuotationEditView(estimate: estimate),
    );
  }
}

/// One editable line item — covers both items that already existed on the
/// quotation and brand-new ones added here. Only product_id / quantity /
/// rate are ever sent back to /quotations/update; company/size/MRP/
/// incentive are display-only, same as CreateEstimateScreen.
class _EditItem {
  const _EditItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.rate,
    this.company = '',
    this.size = '',
    this.mrp = 0,
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
  final double mrp;
  final double incentiveAmount;
  final bool incentiveEligible;
  final String? incentiveReason;

  double get amount => quantity * rate;
}

class _QuotationEditView extends StatefulWidget {
  const _QuotationEditView({required this.estimate});
  final QuotationDetailModel estimate;

  @override
  State<_QuotationEditView> createState() => _QuotationEditViewState();
}

class _QuotationEditViewState extends State<_QuotationEditView> {
  // ---------------- Customer / contractor / other details ----------------
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
  // termsConditions isn't part of QuotationDetailModel (not returned by
  // /quotations/show), so this starts blank — it's still sent on save if
  // the salesman types something, since it's optional on the update body.
  final TextEditingController _termsConditions = TextEditingController();

  // ---------------- Items ----------------
  late List<_EditItem> _items;
  int _newItemCounter = 0;
  int? _editingItemIndex;

  // ---------------- Add / edit item form ----------------
  ActiveProductModel? _selectedProduct;
  final _itemCompanyCtrl = TextEditingController();
  final _itemSizeCtrl = TextEditingController();
  final _itemUnitCtrl = TextEditingController();
  final _itemMrpCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();

  // Debounces the live incentive lookup so it doesn't fire on every
  // keystroke while quantity/rate are being typed.
  Timer? _incentiveDebounce;
  static const _incentiveDebounceDuration = Duration(milliseconds: 450);

  @override
  void initState() {
    super.initState();
    final e = widget.estimate;

    _customerName = TextEditingController(text: e.customer.name);
    _customerPhone = TextEditingController(text: e.customer.phone);
    _customerEmail = TextEditingController(text: e.customer.email);
    _customerAddress = TextEditingController(text: e.customer.address);

    _contractorName = TextEditingController(text: e.contractor.name);
    _contractorPhone = TextEditingController(text: e.contractor.mobile);
    _contractorEmail = TextEditingController(text: e.contractor.email);
    _contractorAddress = TextEditingController(text: e.contractor.address);

    _handlingCharge = TextEditingController(text: _formatPrice(e.handlingCharge));
    _notes = TextEditingController(text: e.notes);

    _items = e.items
        .asMap()
        .entries
        .map((entry) => _EditItem(
      id: 'existing_${entry.key}',
      productId: entry.value.productId,
      name: entry.value.productName,
      unit: entry.value.productUnit,
      size: entry.value.productSize,
      quantity: entry.value.quantity,
      rate: entry.value.rate,
      incentiveAmount: entry.value.incentiveAmount,
      incentiveEligible: entry.value.incentiveAmount > 0,
    ))
        .toList();
  }

  @override
  void dispose() {
    _incentiveDebounce?.cancel();
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
    _itemCompanyCtrl.dispose();
    _itemSizeCtrl.dispose();
    _itemUnitCtrl.dispose();
    _itemMrpCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemRateCtrl.dispose();
    super.dispose();
  }

  // ---------------- Derived totals ----------------

  double get _itemsTotal => _items.fold(0.0, (s, i) => s + i.amount);
  double get _handling => double.tryParse(_handlingCharge.text.trim()) ?? 0;
  double get _grandTotal => _itemsTotal + _handling;
  double get _incentiveTotal => _items.fold(0.0, (s, i) => s + i.incentiveAmount);

  double get _currentItemAmount {
    final qty = double.tryParse(_itemQtyCtrl.text) ?? 0;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    return qty * rate;
  }

  static String _formatPrice(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  // ---------------- Add-item form wiring (mirrors CreateEstimateScreen) ----------------

  void _onProductSelected(ActiveProductModel? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        // Auto-fill MRP and Rate straight from the product master. Both
        // stay editable afterwards, same as the create-estimate flow.
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
    _scheduleIncentiveFetch();
  }

  /// Debounces then fires (or clears) the live incentive preview for
  /// whatever product/quantity/rate is currently entered in the form.
  void _scheduleIncentiveFetch() {
    _incentiveDebounce?.cancel();

    final product = _selectedProduct;
    final qty = double.tryParse(_itemQtyCtrl.text) ?? 0;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    // Fall back to the existing item's product id when editing an item
    // whose matching catalog entry wasn't found in the dropdown.
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
      _itemCompanyCtrl.clear();
      _itemSizeCtrl.clear();
      _itemUnitCtrl.clear();
      _itemMrpCtrl.clear();
      _itemQtyCtrl.clear();
      _itemRateCtrl.clear();
    });
    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
  }

  void _saveItemFromForm() {
    final qty = double.tryParse(_itemQtyCtrl.text) ?? 0;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;

    String productId;
    String name;
    if (_selectedProduct != null) {
      productId = _selectedProduct!.id;
      name = _selectedProduct!.name;
    } else if (_editingItemIndex != null) {
      // Editing an existing item whose product wasn't (re)selected from
      // the dropdown — keep its original product, just update qty/rate/etc.
      productId = _items[_editingItemIndex!].productId;
      name = _items[_editingItemIndex!].name;
    } else {
      _showError('Please select a product');
      return;
    }
    if (qty <= 0) {
      _showError('Please enter a valid quantity');
      return;
    }
    if (rate <= 0) {
      _showError('Please enter a valid rate');
      return;
    }

    // Snapshot whatever incentive preview is currently loaded, so a
    // stale/mismatched preview from a previous product never gets
    // attached to the wrong item.
    final incentiveState = context.read<SalesmanEstimateBloc>().state;
    final liveIncentive = incentiveState.incentive;
    final matchesCurrentProduct =
        liveIncentive != null && liveIncentive.productId == productId;

    final editingIndex = _editingItemIndex;
    final newItem = _EditItem(
      id: editingIndex != null ? _items[editingIndex].id : 'new_${_newItemCounter++}',
      productId: productId,
      name: name,
      company: _itemCompanyCtrl.text.trim(),
      size: _itemSizeCtrl.text.trim(),
      unit: _itemUnitCtrl.text.trim(),
      quantity: qty,
      rate: rate,
      mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
      incentiveAmount: matchesCurrentProduct ? liveIncentive.totalIncentive : 0,
      incentiveEligible: matchesCurrentProduct ? liveIncentive.isEligible : false,
      incentiveReason: matchesCurrentProduct ? liveIncentive.eligibilityReason : null,
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
    // Try to preselect the matching product from the loaded catalog so
    // its other fields (company/size/unit) can be re-derived; if it isn't
    // found (e.g. no longer active), the form still lets qty/rate/etc. be
    // edited against the item's original product.
    final products = context.read<SalesmanEstimateBloc>().state.products;
    ActiveProductModel? match;
    for (final p in products) {
      if (p.id == item.productId) {
        match = p;
        break;
      }
    }

    setState(() {
      _editingItemIndex = index;
      _selectedProduct = match;
      _itemCompanyCtrl.text = item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = _formatPrice(item.mrp);
      _itemQtyCtrl.text = _formatPrice(item.quantity);
      _itemRateCtrl.text = _formatPrice(item.rate);
    });

    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
    if (match != null) _scheduleIncentiveFetch();
  }

  void _cancelEditItem() => _resetItemForm();

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

  // ---------------- Submit ----------------

  bool _validate() {
    if (_customerName.text.trim().isEmpty) {
      _showError('Please enter the party name');
      return false;
    }
    if (_customerPhone.text.trim().isEmpty) {
      _showError('Please enter the customer phone number');
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
      ))
          .toList(),
    );

    context.read<SalesmanQuotationBloc>().add(QuotationUpdateSubmitted(request));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Edit Quotation', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
          // NOTE: submitStatus is shared with "submit for approval" on the
          // preview screen underneath us (same bloc instance, same field).
          // The preview screen's own BlocListener is still mounted while
          // this screen is pushed on top, so it will also react to this
          // same success/failure. Harmless, just a minor UX duplicate.
          listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
          listener: (context, state) {
            if (state.submitStatus == QuotationActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitMessage ?? 'Quotation updated.')),
              );
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
              Navigator.of(context).pop();
            } else if (state.submitStatus == QuotationActionStatus.failure) {
              _showError(state.submitError ?? 'Failed to update quotation.');
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            }
          },
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(Responsive.w(18)),
                  children: [
                    Text('Customer Details', style: AppTextStyles.h3()),
                    SizedBox(height: Responsive.h(12)),
                    LabeledField(
                      label: 'Party Name',
                      field: CustomTextField(
                        hint: 'Enter party name',
                        icon: Icons.groups_2_outlined,
                        controller: _customerName,
                      ),
                    ),
                    LabeledField(
                      label: 'Contact No.',
                      field: CustomTextField(
                        hint: 'Enter phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _customerPhone,
                      ),
                    ),
                    LabeledField(
                      label: 'Address',
                      field: CustomTextField(
                        hint: 'Enter site address',
                        icon: Icons.location_on_outlined,
                        controller: _customerAddress,
                      ),
                    ),
                    LabeledField(
                      label: 'Email (optional)',
                      field: CustomTextField(
                        hint: 'Enter customer email',
                        icon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        controller: _customerEmail,
                      ),
                    ),
                    SizedBox(height: Responsive.h(16)),

                    Text('Contractor Details', style: AppTextStyles.h3()),
                    SizedBox(height: Responsive.h(12)),
                    LabeledField(
                      label: 'Contractor Name',
                      field: CustomTextField(
                        hint: 'Enter contractor name',
                        icon: Icons.engineering_outlined,
                        controller: _contractorName,
                      ),
                    ),
                    LabeledField(
                      label: 'Contact No.',
                      field: CustomTextField(
                        hint: 'Enter contractor phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _contractorPhone,
                      ),
                    ),
                    LabeledField(
                      label: 'Address',
                      field: CustomTextField(
                        hint: 'Enter contractor address',
                        icon: Icons.location_on_outlined,
                        controller: _contractorAddress,
                      ),
                    ),
                    LabeledField(
                      label: 'Email (optional)',
                      field: CustomTextField(
                        hint: 'Enter contractor email',
                        icon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        controller: _contractorEmail,
                      ),
                    ),
                    SizedBox(height: Responsive.h(20)),

                    Text('Add / Edit Item', style: AppTextStyles.h3()),
                    SizedBox(height: Responsive.h(10)),
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
                            field: CustomTextField(
                              hint: 'e.g. 600x1200',
                              icon: Icons.straighten_outlined,
                              controller: _itemSizeCtrl,
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
                              controller: _itemUnitCtrl,
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
                        controller: _itemMrpCtrl,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    LabeledField(
                      label: 'Quantity',
                      field: CustomTextField(
                        hint: 'Enter quantity',
                        icon: Icons.numbers_outlined,
                        keyboardType: TextInputType.number,
                        controller: _itemQtyCtrl,
                        onChanged: (_) {
                          setState(() {});
                          _scheduleIncentiveFetch();
                        },
                      ),
                    ),
                    LabeledField(
                      label: 'Rate',
                      field: CustomTextField(
                        hint: 'Enter rate per unit',
                        icon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        controller: _itemRateCtrl,
                        onChanged: (_) {
                          setState(() {});
                          _scheduleIncentiveFetch();
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
                          Text(currency.format(_currentItemAmount),
                              style: AppTextStyles.bodyBold(color: AppColors.primary)),
                        ],
                      ),
                    ),

                    if (_selectedProduct != null || _editingItemIndex != null) ...[
                      SizedBox(height: Responsive.h(8)),
                      const _IncentivePreviewCard(),
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
                        onPressed: _saveItemFromForm,
                        icon: Icon(
                          _editingItemIndex != null ? Icons.save_outlined : Icons.add,
                          color: Colors.white,
                        ),
                        label: Text(_editingItemIndex != null ? 'Update Item' : 'Add Item'),
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
                      ..._items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return _EditItemTile(
                          serialNo: i + 1,
                          item: item,
                          currency: currency,
                          isEditing: _editingItemIndex == i,
                          onEdit: () => _editItem(i),
                          onDelete: () => _removeItem(i),
                        );
                      }),
                    SizedBox(height: Responsive.h(20)),

                    Text('Other Details', style: AppTextStyles.h3()),
                    SizedBox(height: Responsive.h(12)),
                    LabeledField(
                      label: 'Handling Charge',
                      field: CustomTextField(
                        hint: 'Enter handling charge',
                        icon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        controller: _handlingCharge,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    LabeledField(
                      label: 'Notes (optional)',
                      field: CustomTextField(
                        hint: 'e.g. Customer enquiry for new project',
                        icon: Icons.notes_outlined,
                        controller: _notes,
                      ),
                    ),
                    LabeledField(
                      label: 'Terms & Conditions (optional)',
                      field: CustomTextField(
                        hint: 'e.g. Standard terms apply',
                        icon: Icons.gavel_outlined,
                        controller: _termsConditions,
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

                    if (_incentiveTotal > 0)
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
              BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
                buildWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
                builder: (context, state) {
                  final saving = state.submitStatus == QuotationActionStatus.inProgress;
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
    );
  }

  Widget _buildProductDropdown() {
    return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
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

        // Make sure the currently selected product (set e.g. via _editItem
        // before this list finished loading) is a value the dropdown
        // actually recognises, otherwise Flutter throws.
        final products = state.products;
        final selected =
        _selectedProduct != null && products.any((p) => p.id == _selectedProduct!.id)
            ? _selectedProduct
            : null;

        return LabeledField(
          label: 'Select Product',
          field: DropdownButtonFormField<ActiveProductModel>(
            value: selected,
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
            items: products
                .map((p) => DropdownMenuItem(
              value: p,
              child: Text('${p.name} — ${p.company}', overflow: TextOverflow.ellipsis),
            ))
                .toList(),
            onChanged: _onProductSelected,
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

/// Shows the live /quotations/product-incentive result for whatever is
/// currently in the product/quantity/rate fields on the add-item form.
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

class _EditItemTile extends StatelessWidget {
  const _EditItemTile({
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.isEditing = false,
  });

  final int serialNo;
  final _EditItem item;
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
                  // InkWell(onTap: onDelete, child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}