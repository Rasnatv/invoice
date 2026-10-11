import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/ownerestimateupdationwidget.dart';
import '../../../core/apiclient/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';
import '../../core/utils/delete_helper.dart';
import '../../models/owner_models/ownerestimate_updatemodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/primary_button.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../../Apiprovider/salesman_quotationprovider.dart';

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

  late final TextEditingController _contractorNameCtrl;
  late final TextEditingController _contractorPhoneCtrl;
  late final TextEditingController _contractorEmailCtrl;

  late final TextEditingController _notesCtrl;
  late final TextEditingController _termsCtrl;

  late final TextEditingController _handlingChargeCtrl;
  DateTime? _date;

  final List<EstimateEditItem> _items = [];

  final _itemFormKey = GlobalKey<FormState>();
  EstimateActiveProduct? _selectedProduct;
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

  List<EstimateActiveProduct> _products = [];
  bool _loadingProducts = true;

  bool _backfilledFromCatalog = false;

  final QuotationProvider _quotationProvider = QuotationProvider();
  bool _isAddingItem = false;

  bool get _isBoxUnitProduct {
    if (_editingItemIndex != null) {
      final item = _items[_editingItemIndex!];
      if (item.boxQuantity > 0 || item.pieceQuantity > 0) return true;
    }
    if (_selectedProduct != null) return _selectedProduct!.isBoxUnit;
    if (_editingItemIndex != null) return _items[_editingItemIndex!].isBoxUnit;
    return false;
  }

  double get _computedQuantity => double.tryParse(_itemQtyCtrl.text.trim()) ?? 0;

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

    // Clearing the customer phone also clears name / address / email.
    _phoneCtrl.addListener(_onPhoneChanged);

    // Product suggestions open when the product field is tapped/focused.
    _productSearchFocus.addListener(_onProductFocusChanged);

    _contractorNameCtrl = TextEditingController(text: d.customer.name);
    _contractorPhoneCtrl = TextEditingController(text: d.customer.phone);
    _contractorEmailCtrl = TextEditingController(text: d.customer.email);

    _notesCtrl = TextEditingController(text: d.notes);
    _termsCtrl = TextEditingController(text: d.termsConditions);
    _handlingChargeCtrl = TextEditingController(
        text: d.handlingCharge > 0 ? estimateFormatQty(d.handlingCharge) : '');
    _date = d.date;

    for (final item in d.items) {
      _items.add(EstimateEditItem(
        // ASSUMPTION: EstimateDetailItem exposes the saved row's own id
        // as `.id`. If your model names it differently, change this line.
        id: item.id.toString(),
        productId: item.productId,
        name: item.productName,
        quantity: item.quantity,
        boxQuantity: item.boxQuantity,
        pieceQuantity: item.pieceQuantity,
        rate: item.rate,
        amount: item.amount,
      ));
    }

    _loadProducts();
  }

  void _onPhoneChanged() {
    if (_phoneCtrl.text.trim().isNotEmpty) return;
    if (_nameCtrl.text.isEmpty && _addressCtrl.text.isEmpty && _emailCtrl.text.isEmpty) {
      return;
    }
    _nameCtrl.clear();
    _addressCtrl.clear();
    _emailCtrl.clear();
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
          .map((e) => EstimateActiveProduct.fromJson(e.cast<String, dynamic>()))
          .toList();
      if (mounted) {
        setState(() {
          _products = parsed;
          _loadingProducts = false;
        });
        _backfillFromCatalog();
      }
    } catch (e, st) {
      debugPrint('OwnerEstimateUpdateScreen: failed to load active products: $e\n$st');
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  EstimateActiveProduct? _findProduct(String productId) {
    for (final p in _products) {
      if (p.id == productId) return p;
    }
    return null;
  }

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
    _phoneCtrl.removeListener(_onPhoneChanged);
    _productSearchFocus.removeListener(_onProductFocusChanged);
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _contractorNameCtrl.dispose();
    _contractorPhoneCtrl.dispose();
    _contractorEmailCtrl.dispose();
    _notesCtrl.dispose();
    _termsCtrl.dispose();
    _handlingChargeCtrl.dispose();
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

  // ---------------- Validators ----------------

  String? _validateCustomerName(String? v) => DValidator.validateName('Customer name', v);

  String? _validateCustomerPhone(String? v) => DValidator.validatePhoneNumber(v);

  String? _validateOptionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return DValidator.validateEmail(v);
  }

  String? _validateContractorName(String? v) {
    final name = (v ?? '').trim();
    if (name.isNotEmpty) return null;
    final hasPhone = _contractorPhoneCtrl.text.trim().isNotEmpty;
    final hasEmail = _contractorEmailCtrl.text.trim().isNotEmpty;
    if (hasPhone || hasEmail) {
      return 'Contractor name is required when a phone is provided';
    }
    return null;
  }

  String? _validateContractorPhone(String? v) {
    final phone = (v ?? '').trim();
    final hasName = _contractorNameCtrl.text.trim().isNotEmpty;

    if (phone.isEmpty) {
      if (hasName) return 'Contractor phone is required when a name is provided';
      return null;
    }
    return DValidator.validatePhoneNumber(phone);
  }

  String? _validateHandlingCharge(String? v) =>
      DValidator.validateOptionalNumber('Handling charge', v, max: DValidator.maxPrice);

  // ---------------- Add-item form wiring ----------------

  void _onProductSelected(EstimateActiveProduct? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _productSearchCtrl.text = estimateProductDisplayString(product);
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        _itemMrpCtrl.text = estimateFormatQty(product.mrp);
        _itemRateCtrl.text = product.rate > 0 ? estimateFormatQty(product.rate) : '';
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
  }

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
    _itemFormKey.currentState?.reset();
  }

  Future<void> _saveItemFromForm() async {
    if (_isAddingItem) return;

    if (!(_itemFormKey.currentState?.validate() ?? true)) {
      debugPrint('OwnerEstimateUpdateScreen: item form validation failed '
          '(selectedProduct=${_selectedProduct?.id}, editingIndex=$_editingItemIndex)');
      return;
    }

    final qty = _computedQuantity;
    final rate = double.tryParse(_itemRateCtrl.text.trim()) ?? 0;

    if (qty <= 0) {
      AppSnackbar.error(_isBoxUnitProduct
          ? 'Please enter a valid box/piece quantity'
          : 'Please enter a valid quantity');
      return;
    }
    if (rate <= 0) {
      AppSnackbar.error('Please enter a valid rate');
      return;
    }

    _recomputeBoxQtyIfNeeded();
    final boxQuantity = _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : 0.0;
    final pieceQuantity =
    _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : 0.0;

    final editingIndex = _editingItemIndex;
    final editingSavedItem = editingIndex != null && _items[editingIndex].id.isNotEmpty;

    if (editingSavedItem) {
      debugPrint('OwnerEstimateUpdateScreen: dispatching item update -> '
          'estimateId=${widget.detail.id} itemId=${_items[editingIndex].id} '
          'qty=$qty rate=$rate box=$boxQuantity piece=$pieceQuantity');
      context.read<OwnerEstimateDetailBloc>().add(OwnerEstimateItemUpdateRequested(
        estimateId: widget.detail.id,
        estimateItemId: _items[editingIndex].id,
        quantity: qty,
        rate: rate,
        boxQuantity: boxQuantity,
        pieceQuantity: pieceQuantity,
      ));
      return;
    }

    String productIdStr;
    String name;
    if (_selectedProduct != null) {
      productIdStr = _selectedProduct!.id;
      name = _selectedProduct!.name;
    } else if (editingIndex != null) {
      productIdStr = _items[editingIndex].productId;
      name = _items[editingIndex].name;
    } else {
      AppSnackbar.error('Please select a product');
      return;
    }

    final productId = int.tryParse(productIdStr);
    if (productId == null) {
      AppSnackbar.error('Invalid product selected.');
      debugPrint('OwnerEstimateUpdateScreen: could not parse productId "$productIdStr" as int');
      return;
    }

    setState(() => _isAddingItem = true);

    final incentiveRequest = ProductIncentiveRequest(
      productId: productId,
      quantity: qty,
      rate: rate,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
    );

    debugPrint('OwnerEstimateUpdateScreen: requesting product incentive '
        'productId=$productId qty=$qty rate=$rate box=$boxQuantity piece=$pieceQuantity '
        '(editingIndex=$editingIndex)');

    final result = await _quotationProvider.getProductIncentive(incentiveRequest);

    debugPrint('OwnerEstimateUpdateScreen: incentive result -> '
        'success=${result.success} hasIncentive=${result.incentive != null} '
        'errorMessage=${result.errorMessage}');

    if (!mounted) return;
    setState(() => _isAddingItem = false);

    if (!result.success || result.incentive == null) {
      AppSnackbar.error(
          result.errorMessage ?? 'Could not calculate the amount for this item. Please try again.');
      return;
    }

    final incentive = result.incentive!;
    final formCompany = _itemCompanyCtrl.text.trim();
    final formSize = _itemSizeCtrl.text.trim();
    final formUnit = _itemUnitCtrl.text.trim();
    final formMrp = double.tryParse(_itemMrpCtrl.text.trim());
    final previous = editingIndex != null ? _items[editingIndex] : null;
    final isBoxUnit = _selectedProduct?.isBoxUnit ?? previous?.isBoxUnit ?? false;

    final newItem = EstimateEditItem(
      id: previous?.id ?? '',
      productId: productIdStr,
      name: name,
      company: formCompany.isNotEmpty ? formCompany : (previous?.company ?? ''),
      size: formSize.isNotEmpty ? formSize : (previous?.size ?? ''),
      unit: formUnit.isNotEmpty ? formUnit : (previous?.unit ?? ''),
      quantity: qty,
      rate: rate,
      amount: incentive.amount,
      mrp: formMrp ?? previous?.mrp ?? 0,
      boxQuantity: _isBoxUnitProduct ? boxQuantity : 0,
      pieceQuantity: _isBoxUnitProduct ? pieceQuantity : 0,
      isBoxUnit: isBoxUnit,
      incentiveAmount: incentive.totalIncentive,
      incentiveEligible: incentive.isEligible,
      incentiveReason: incentive.eligibilityReason,
    );

    setState(() {
      if (editingIndex != null) {
        _items[editingIndex] = newItem;
      } else {
        _items.add(newItem);
      }
    });
    debugPrint('OwnerEstimateUpdateScreen: item ${editingIndex != null ? 'updated' : 'added'} locally. '
        'Total items now = ${_items.length}');
    _resetItemForm();
  }

  void _editItem(int index) {
    final item = _items[index];
    final match = _findProduct(item.productId);

    setState(() {
      _editingItemIndex = index;
      _selectedProduct = match;
      _showProductSuggestions = false;
      _productSearchCtrl.text = match != null ? estimateProductDisplayString(match) : item.name;
      _itemCompanyCtrl.text = match?.company ?? item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = estimateFormatQty(match?.mrp ?? item.mrp);
      _itemQtyCtrl.text = estimateFormatQty(item.quantity);
      _itemRateCtrl.text = estimateFormatQty(item.rate);
      _itemBoxQtyCtrl.text = estimateFormatQty(item.boxQuantity);
      _itemPieceQtyCtrl.text = estimateFormatQty(item.pieceQuantity);
    });

    _productSearchFocus.unfocus();

    AppSnackbar.error('Edit the fields above, then tap "Update Item"');
  }

  void _cancelEditItem() => _resetItemForm();

  /// Saved rows (non-empty id) ask for confirmation, then dispatch
  /// POST /estimates/remove-item; the row is dropped once the bloc reports
  /// success (see the listener in build()). Rows added in this session are
  /// removed locally with no confirmation.
  Future<void> _removeItem(int index) async {
    final item = _items[index];

    if (item.id.isNotEmpty) {
      await deleteItem(
        context,
        itemName: 'item',
        onConfirmed: () async {
          if (!mounted) return;
          debugPrint('OwnerEstimateUpdateScreen: dispatching item remove -> '
              'estimateId=${widget.detail.id} itemId=${item.id}');
          context.read<OwnerEstimateDetailBloc>().add(OwnerEstimateItemRemoveRequested(
            estimateId: widget.detail.id,
            estimateItemId: item.id,
          ));
        },
      );
      return;
    }

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

  void _submit(BuildContext context) {
    final formValid = _formKey.currentState?.validate() ?? true;
    if (!formValid) {
      AppSnackbar.error('Please fix the highlighted fields');
      return;
    }

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

    final handlingChargeText = _handlingChargeCtrl.text.trim();

    final request = OwnerUpdateEstimateRequest(
      id: widget.detail.id,
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerAddress: _addressCtrl.text.trim(),
      customerEmail: _emailCtrl.text.trim(),
      contractorName: _contractorNameCtrl.text.trim(),
      contractorPhone: _contractorPhoneCtrl.text.trim(),
      contractorEmail: _contractorEmailCtrl.text.trim(),
      date: _date == null ? null : DateFormat('yyyy-MM-dd').format(_date!),
      handlingCharge: handlingChargeText.isEmpty ? null : double.tryParse(handlingChargeText),
      notes: _notesCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim(),
      items: updateItems,
    );

    debugPrint('OwnerEstimateUpdateScreen: submitting update payload: '
        '${jsonEncode(request.toJson())}');

    context.read<OwnerEstimateDetailBloc>().add(OwnerEstimateUpdateRequested(request));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Update Estimate', style: AppTextStyles.h6())),
        body: SafeArea(
          child: BlocConsumer<OwnerEstimateDetailBloc, OwnerEstimateDetailState>(
            listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus ||
                previous.itemUpdateStatus != current.itemUpdateStatus ||
                previous.itemRemoveStatus != current.itemRemoveStatus,
            listener: (context, state) {
              if (state.actionStatus == OwnerEstimateActionStatus.success) {
                AppSnackbar.success(state.actionMessage ?? 'Estimate updated.');
                Navigator.of(context).pop(true);
              } else if (state.actionStatus == OwnerEstimateActionStatus.failure) {
                debugPrint('OwnerEstimateUpdateScreen: update failed -> ${state.actionMessage}');
                AppSnackbar.error(state.actionMessage ?? 'Failed to update estimate.');
              }

              // Single-item update finished.
              if (state.itemUpdateStatus == OwnerEstimateActionStatus.success &&
                  state.updatedEstimateItemId != null) {
                AppSnackbar.success(state.itemUpdateMessage ?? 'Item updated.');
                final idx = _items.indexWhere((i) => i.id == state.updatedEstimateItemId);
                if (idx != -1) {
                  setState(() {
                    _items[idx] = _items[idx].copyWith(
                      quantity: double.tryParse(_itemQtyCtrl.text) ?? _items[idx].quantity,
                      rate: double.tryParse(_itemRateCtrl.text) ?? _items[idx].rate,
                      boxQuantity:
                      double.tryParse(_itemBoxQtyCtrl.text) ?? _items[idx].boxQuantity,
                      pieceQuantity:
                      double.tryParse(_itemPieceQtyCtrl.text) ?? _items[idx].pieceQuantity,
                    );
                  });
                }
                _resetItemForm();
              } else if (state.itemUpdateStatus == OwnerEstimateActionStatus.failure) {
                debugPrint(
                    'OwnerEstimateUpdateScreen: item update failed -> ${state.itemUpdateMessage}');
                AppSnackbar.error(state.itemUpdateMessage ?? 'Failed to update item.');
              }

              // Single-item remove finished.
              if (state.itemRemoveStatus == OwnerEstimateActionStatus.success &&
                  state.removedEstimateItemId != null) {
                AppSnackbar.success(state.itemRemoveMessage ?? 'Item removed.');
                setState(() {
                  _items.removeWhere((i) => i.id == state.removedEstimateItemId);
                });
              } else if (state.itemRemoveStatus == OwnerEstimateActionStatus.failure) {
                debugPrint(
                    'OwnerEstimateUpdateScreen: item remove failed -> ${state.itemRemoveMessage}');
                AppSnackbar.error(state.itemRemoveMessage ?? 'Failed to remove item.');
              }
            },
            builder: (context, state) {
              final isBusy = state.actionStatus == OwnerEstimateActionStatus.inProgress;
              final isUpdatingItem =
                  state.itemUpdateStatus == OwnerEstimateActionStatus.inProgress;

              return Column(
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
                          EstimateCustomerSection(
                            phone: _phoneCtrl,
                            name: _nameCtrl,
                            address: _addressCtrl,
                            email: _emailCtrl,
                            phoneValidator: _validateCustomerPhone,
                            nameValidator: _validateCustomerName,
                            emailValidator: _validateOptionalEmail,
                          ),
                          SizedBox(height: Responsive.h(20)),

                          Text('Contractor Details', style: AppTextStyles.h3()),
                          SizedBox(height: Responsive.h(12)),
                          EstimateContractorSection(
                            name: _contractorNameCtrl,
                            phone: _contractorPhoneCtrl,
                            email: _contractorEmailCtrl,
                            nameValidator: _validateContractorName,
                            phoneValidator: _validateContractorPhone,
                            emailValidator: _validateOptionalEmail,
                            // Re-validate so the name/phone cross-check updates live.
                            onChanged: (_) => _formKey.currentState?.validate(),
                          ),

                          EstimateOtherDetailsSection(
                            handlingCharge: _handlingChargeCtrl,
                            notes: _notesCtrl,
                            handlingValidator: _validateHandlingCharge,
                          ),
                          SizedBox(height: Responsive.h(20)),

                          Text('Add / Edit Item', style: AppTextStyles.h3()),
                          SizedBox(height: Responsive.h(10)),
                          EstimateItemFormFields(
                            formKey: _itemFormKey,
                            productField: EstimateProductSearch(
                              loading: _loadingProducts,
                              products: _products,
                              searchCtrl: _productSearchCtrl,
                              focusNode: _productSearchFocus,
                              selectedProduct: _selectedProduct,
                              showSuggestions: _showProductSuggestions,
                              onFieldTap: () => setState(() => _showProductSuggestions = true),
                              onTextChanged: (text) {
                                if (_selectedProduct != null &&
                                    text != estimateProductDisplayString(_selectedProduct!)) {
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
                            onRateChanged: (_) => setState(() {}),
                            onQtyChanged: (_) => setState(_recomputeBoxQtyIfNeeded),
                            onPieceChanged: (_) => setState(() {}),
                          ),
                          SizedBox(height: Responsive.h(20)),

                          if (_editingItemIndex != null)
                            EstimateEditingBanner(
                              itemNumber: _editingItemIndex! + 1,
                              onCancel: _cancelEditItem,
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: (_loadingProducts || _isAddingItem || isUpdatingItem)
                                  ? null
                                  : _saveItemFromForm,
                              icon: (_isAddingItem || isUpdatingItem)
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                                  : Icon(
                                _editingItemIndex != null ? Icons.save_outlined : Icons.add,
                                color: Colors.white,
                              ),
                              label: Text(
                                (_isAddingItem || isUpdatingItem)
                                    ? (_editingItemIndex != null ? 'Updating…' : 'Calculating…')
                                    : (_editingItemIndex != null ? 'Update Item' : 'Add Item'),
                              ),
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
                              return EstimateItemTile(
                                serialNo: index + 1,
                                item: entry.value,
                                currency: currency,
                                isEditing: _editingItemIndex == index,
                                onDelete: () => _removeItem(index),
                                onEdit: () => _editItem(index),
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
      ),
    );
  }
}