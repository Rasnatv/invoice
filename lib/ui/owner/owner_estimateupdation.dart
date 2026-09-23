//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
//
// import '../../../core/apiclient/api_client.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../../core/validator/validationfile.dart';
// import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
// import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
// import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';
//
// import '../../models/owner_models/ownerestimate_updatemodel.dart';
// import '../../widgets/appsnackbar.dart';
// import '../../widgets/custom_text_field.dart';
// import '../../widgets/primary_button.dart';
// import '../../../models/salesmanmodels/estimatedetail.model.dart';
// import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
// // Same fresh, one-shot provider the Owner Create Estimate screen and
// // OwnerQuotationEditScreen use for POST /quotations/product-incentive —
// // fired the moment Add/Update Item is tapped, bypassing any
// // cached/debounced bloc state, so the item that gets added/updated always
// // matches exactly what the server computed (not a local quantity*rate
// // approximation).
// import '../../Apiprovider/salesman_quotationprovider.dart';
//
// /// Shared numeric formatter — mirrors the `_formatPrice` helper used on
// /// the Owner Quotation Edit screen: whole numbers render without a
// /// trailing ".0".
// String _formatQty(double value) =>
//     value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
//
// bool _parseBool(dynamic v) {
//   if (v is bool) return v;
//   final s = v?.toString().toLowerCase() ?? '';
//   return s == '1' || s == 'true';
// }
//
// /// Active-catalog product, parsed loosely since the shape of
// /// GET /products/active isn't modeled elsewhere yet. Extended with
// /// company/unit/mrp (on top of the old id/name/size/rate/isBoxUnit) so
// /// the Add/Edit Item form below can auto-fill the same fields as
// /// OwnerQuotationEditScreen's `ActiveProductModel`.
// class _ActiveProduct {
//   final String id;
//   final String name;
//   final String company;
//   final String size;
//   final String unit;
//   final double rate;
//   final double mrp;
//   final bool isBoxUnit;
//
//   const _ActiveProduct({
//     required this.id,
//     required this.name,
//     this.company = '',
//     this.size = '',
//     this.unit = '',
//     required this.rate,
//     this.mrp = 0,
//     this.isBoxUnit = false,
//   });
//
//   factory _ActiveProduct.fromJson(Map<String, dynamic> json) {
//     double parseNum(dynamic v) {
//       if (v == null) return 0;
//       if (v is num) return v.toDouble();
//       return double.tryParse(v.toString()) ?? 0;
//     }
//
//     return _ActiveProduct(
//       id: (json['id'] ?? '').toString(),
//       name: (json['name'] ?? json['product_name'] ?? '').toString(),
//       company: (json['company'] ?? json['company_name'] ?? '').toString(),
//       size: (json['size'] ?? json['product_size'] ?? '').toString(),
//       unit: (json['unit'] ?? json['product_unit'] ?? '').toString(),
//       rate: parseNum(json['rate'] ?? json['default_rate'] ?? json['selling_rate']),
//       mrp: parseNum(json['mrp']),
//       isBoxUnit: _parseBool(
//         json['is_box_unit'] ?? json['isBoxUnit'] ?? json['box_unit'],
//       ),
//     );
//   }
// }
//
// /// One saved line item in the estimate being edited.
// ///
// /// Mirrors the salesman flow's `AddedItem` (see owner_estimate_types.dart)
// /// and QuotationEditScreen's `_EditItem`: `amount` is always the server's
// /// own figure — from POST /quotations/product-incentive at the moment an
// /// item is added/updated here, or straight from the estimate's own saved
// /// EstimateDetailItem.amount for rows that were already on the estimate —
// /// never recomputed locally as quantity * rate, since the server may
// /// derive it from square feet or a box/piece breakdown instead of a flat
// /// multiplication.
// class _EstimateEditItem {
//   const _EstimateEditItem({
//     required this.productId,
//     required this.name,
//     required this.amount,
//     this.company = '',
//     this.size = '',
//     this.unit = '',
//     required this.quantity,
//     required this.rate,
//     this.mrp = 0,
//     this.boxQuantity = 0,
//     this.pieceQuantity = 0,
//     this.isBoxUnit = false,
//     this.incentiveAmount = 0,
//     this.incentiveEligible = false,
//     this.incentiveReason,
//   });
//
//   final String productId;
//   final String name;
//   final String company;
//   final String size;
//   final String unit;
//   final double quantity;
//   final double rate;
//   final double amount;
//   final double mrp;
//   final double boxQuantity;
//   final double pieceQuantity;
//   final bool isBoxUnit;
//   final double incentiveAmount;
//   final bool incentiveEligible;
//   final String? incentiveReason;
//
//   _EstimateEditItem copyWith({
//     String? company,
//     String? size,
//     String? unit,
//     double? mrp,
//     bool? isBoxUnit,
//   }) {
//     return _EstimateEditItem(
//       productId: productId,
//       name: name,
//       amount: amount,
//       company: company ?? this.company,
//       size: size ?? this.size,
//       unit: unit ?? this.unit,
//       quantity: quantity,
//       rate: rate,
//       mrp: mrp ?? this.mrp,
//       boxQuantity: boxQuantity,
//       pieceQuantity: pieceQuantity,
//       isBoxUnit: isBoxUnit ?? this.isBoxUnit,
//       incentiveAmount: incentiveAmount,
//       incentiveEligible: incentiveEligible,
//       incentiveReason: incentiveReason,
//     );
//   }
// }
//
// /// Screen for editing an estimate's customer details, notes, terms, date
// /// and item list via POST /estimates/update. Expects to be pushed with a
// /// `BlocProvider.value` sharing the same [OwnerEstimateDetailBloc] as the
// /// detail screen that opened it, so a successful update also refreshes
// /// that screen's state.
// class OwnerEstimateUpdateScreen extends StatefulWidget {
//   const OwnerEstimateUpdateScreen({super.key, required this.detail});
//   final EstimateDetailModel detail;
//
//   @override
//   State<OwnerEstimateUpdateScreen> createState() => _OwnerEstimateUpdateScreenState();
// }
//
// class _OwnerEstimateUpdateScreenState extends State<OwnerEstimateUpdateScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   // late final TextEditingController _nameCtrl;
//   // late final TextEditingController _phoneCtrl;
//   // late final TextEditingController _addressCtrl;
//   // late final TextEditingController _emailCtrl;
//   // late final TextEditingController _notesCtrl;
//   // late final TextEditingController _termsCtrl;
//   // DateTime? _date;
//   late final TextEditingController _nameCtrl;
//   late final TextEditingController _phoneCtrl;
//   late final TextEditingController _addressCtrl;
//   late final TextEditingController _emailCtrl;
//   late final TextEditingController _contractorNameCtrl;
//   late final TextEditingController _contractorPhoneCtrl;
//   late final TextEditingController _contractorEmailCtrl;
//   late final TextEditingController _contractorAddressCtrl;
//   late final TextEditingController _notesCtrl;
//   late final TextEditingController _termsCtrl;
//   DateTime? _date;
//   // ---- Saved items ----
//   final List<_EstimateEditItem> _items = [];
//
//   // ---- Add / edit item form (mirrors OwnerQuotationEditScreen) ----
//   final _itemFormKey = GlobalKey<FormState>();
//   _ActiveProduct? _selectedProduct;
//   int? _editingItemIndex;
//   final _productSearchCtrl = TextEditingController();
//   final _productSearchFocus = FocusNode();
//   bool _showProductSuggestions = false;
//   final _itemCompanyCtrl = TextEditingController();
//   final _itemSizeCtrl = TextEditingController();
//   final _itemUnitCtrl = TextEditingController();
//   final _itemMrpCtrl = TextEditingController();
//   final _itemQtyCtrl = TextEditingController();
//   final _itemBoxQtyCtrl = TextEditingController();
//   final _itemPieceQtyCtrl = TextEditingController();
//   final _itemRateCtrl = TextEditingController();
//
//   List<_ActiveProduct> _products = [];
//   bool _loadingProducts = true;
//
//   bool _backfilledFromCatalog = false;
//
//   final QuotationProvider _quotationProvider = QuotationProvider();
//   bool _isAddingItem = false;
//
//   bool get _isBoxUnitProduct {
//     if (_editingItemIndex != null) {
//       final item = _items[_editingItemIndex!];
//       if (item.boxQuantity > 0 || item.pieceQuantity > 0) return true;
//     }
//     if (_selectedProduct != null) return _selectedProduct!.isBoxUnit;
//     if (_editingItemIndex != null) return _items[_editingItemIndex!].isBoxUnit;
//     return false;
//   }
//
//   double get _computedQuantity => double.tryParse(_itemQtyCtrl.text.trim()) ?? 0;
//
//   void _recomputeBoxQtyIfNeeded() {
//     if (!_isBoxUnitProduct) return;
//     _itemBoxQtyCtrl.text = _itemQtyCtrl.text;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     final d = widget.detail;
//     _nameCtrl = TextEditingController(text: d.customerName);
//     _phoneCtrl = TextEditingController(text: d.customerPhone);
//     _addressCtrl = TextEditingController(text: d.customerAddress);
//     _emailCtrl = TextEditingController(text: d.customerEmail);
//     _notesCtrl = TextEditingController(text: d.notes);
//     _termsCtrl = TextEditingController(text: d.termsConditions);
//     _date = d.date;
//
//     for (final item in d.items) {
//       _items.add(_EstimateEditItem(
//         productId: item.productId,
//         name: item.productName,
//         quantity: item.quantity,
//         boxQuantity: item.boxQuantity,
//         pieceQuantity: item.pieceQuantity,
//         rate: item.rate,
//         amount: item.amount,
//       ));
//     }
//
//     _loadProducts();
//   }
//
//   Future<void> _loadProducts() async {
//     try {
//       final response = await ApiClient().activeProducts();
//       final body = response.data;
//       List<dynamic> rawList = const [];
//       if (body is Map<String, dynamic>) {
//         final data = body['data'];
//         if (data is List) {
//           rawList = data;
//         } else if (data is Map && data['list'] is List) {
//           rawList = data['list'] as List;
//         }
//       } else if (body is List) {
//         rawList = body;
//       }
//       final parsed = rawList
//           .whereType<Map>()
//           .map((e) => _ActiveProduct.fromJson(e.cast<String, dynamic>()))
//           .toList();
//       if (mounted) {
//         setState(() {
//           _products = parsed;
//           _loadingProducts = false;
//         });
//         _backfillFromCatalog();
//       }
//     } catch (_) {
//       if (mounted) setState(() => _loadingProducts = false);
//     }
//   }
//
//   _ActiveProduct? _findProduct(String productId) {
//     for (final p in _products) {
//       if (p.id == productId) return p;
//     }
//     return null;
//   }
//
//   void _backfillFromCatalog() {
//     if (_backfilledFromCatalog || _products.isEmpty) return;
//     var changed = false;
//     for (var i = 0; i < _items.length; i++) {
//       final row = _items[i];
//       if (row.productId.isEmpty) continue;
//       final match = _findProduct(row.productId);
//       if (match == null) continue;
//       _items[i] = row.copyWith(
//         company: match.company,
//         size: row.size.isEmpty ? match.size : row.size,
//         unit: row.unit.isEmpty ? match.unit : row.unit,
//         mrp: match.mrp,
//         isBoxUnit: match.isBoxUnit,
//       );
//       changed = true;
//     }
//     _backfilledFromCatalog = true;
//     if (changed && mounted) setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _phoneCtrl.dispose();
//     _addressCtrl.dispose();
//     _emailCtrl.dispose();
//     _notesCtrl.dispose();
//     _termsCtrl.dispose();
//     _productSearchCtrl.dispose();
//     _productSearchFocus.dispose();
//     _itemCompanyCtrl.dispose();
//     _itemSizeCtrl.dispose();
//     _itemUnitCtrl.dispose();
//     _itemMrpCtrl.dispose();
//     _itemQtyCtrl.dispose();
//     _itemBoxQtyCtrl.dispose();
//     _itemPieceQtyCtrl.dispose();
//     _itemRateCtrl.dispose();
//     super.dispose();
//   }
//
//   String? _validateCustomerName(String? v) => DValidator.validateName('Customer name', v);
//
//   String? _validateCustomerPhone(String? v) => DValidator.validatePhoneNumber(v);
//
//   String? _validateOptionalEmail(String? v) {
//     if (v == null || v.trim().isEmpty) return null;
//     return DValidator.validateEmail(v);
//   }
//
//   static String _productDisplayString(_ActiveProduct p) =>
//       p.company.isEmpty ? p.name : '${p.name} — ${p.company}';
//
//   void _onProductSelected(_ActiveProduct? product) {
//     setState(() {
//       _selectedProduct = product;
//       if (product != null) {
//         _productSearchCtrl.text = _productDisplayString(product);
//         _itemCompanyCtrl.text = product.company;
//         _itemSizeCtrl.text = product.size;
//         _itemUnitCtrl.text = product.unit;
//         _itemMrpCtrl.text = _formatQty(product.mrp);
//         _itemRateCtrl.text = product.rate > 0 ? _formatQty(product.rate) : '';
//         _itemQtyCtrl.clear();
//         _itemBoxQtyCtrl.clear();
//         _itemPieceQtyCtrl.clear();
//       } else {
//         _itemCompanyCtrl.clear();
//         _itemSizeCtrl.clear();
//         _itemUnitCtrl.clear();
//         _itemMrpCtrl.clear();
//         _itemRateCtrl.clear();
//         _itemQtyCtrl.clear();
//         _itemBoxQtyCtrl.clear();
//         _itemPieceQtyCtrl.clear();
//       }
//     });
//   }
//
//   void _clearProductSelection() {
//     _productSearchCtrl.clear();
//     _onProductSelected(null);
//   }
//
//   void _resetItemForm() {
//     setState(() {
//       _selectedProduct = null;
//       _editingItemIndex = null;
//       _showProductSuggestions = false;
//       _productSearchCtrl.clear();
//       _itemCompanyCtrl.clear();
//       _itemSizeCtrl.clear();
//       _itemUnitCtrl.clear();
//       _itemMrpCtrl.clear();
//       _itemQtyCtrl.clear();
//       _itemBoxQtyCtrl.clear();
//       _itemPieceQtyCtrl.clear();
//       _itemRateCtrl.clear();
//     });
//     _itemFormKey.currentState?.reset();
//   }
//
//   Future<void> _saveItemFromForm() async {
//     if (_isAddingItem) return;
//
//     if (!(_itemFormKey.currentState?.validate() ?? true)) {
//       return;
//     }
//
//     final qty = _computedQuantity;
//     final rate = double.tryParse(_itemRateCtrl.text.trim()) ?? 0;
//
//     String productIdStr;
//     String name;
//     if (_selectedProduct != null) {
//       productIdStr = _selectedProduct!.id;
//       name = _selectedProduct!.name;
//     } else if (_editingItemIndex != null) {
//       productIdStr = _items[_editingItemIndex!].productId;
//       name = _items[_editingItemIndex!].name;
//     } else {
//       AppSnackbar.error('Please select a product');
//       return;
//     }
//     if (qty <= 0) {
//       AppSnackbar.error(_isBoxUnitProduct
//           ? 'Please enter a valid box/piece quantity'
//           : 'Please enter a valid quantity');
//       return;
//     }
//     if (rate <= 0) {
//       AppSnackbar.error('Please enter a valid rate');
//       return;
//     }
//
//     final productId = int.tryParse(productIdStr);
//     if (productId == null) {
//       AppSnackbar.error('Invalid product selected.');
//       return;
//     }
//
//     _recomputeBoxQtyIfNeeded();
//     final boxQuantity = _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : null;
//     final pieceQuantity = _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : null;
//
//     setState(() => _isAddingItem = true);
//
//     final result = await _quotationProvider.getProductIncentive(ProductIncentiveRequest(
//       productId: productId,
//       quantity: qty,
//       rate: rate,
//       boxQuantity: boxQuantity,
//       pieceQuantity: pieceQuantity,
//     ));
//
//     if (!mounted) return;
//     setState(() => _isAddingItem = false);
//
//     if (!result.success || result.incentive == null) {
//       AppSnackbar.error(
//           result.errorMessage ?? 'Could not calculate the amount for this item. Please try again.');
//       return;
//     }
//
//     final incentive = result.incentive!;
//     final editingIndex = _editingItemIndex;
//     final formCompany = _itemCompanyCtrl.text.trim();
//     final formSize = _itemSizeCtrl.text.trim();
//     final formUnit = _itemUnitCtrl.text.trim();
//     final formMrp = double.tryParse(_itemMrpCtrl.text.trim());
//     final previous = editingIndex != null ? _items[editingIndex] : null;
//     final isBoxUnit = _selectedProduct?.isBoxUnit ?? previous?.isBoxUnit ?? false;
//
//     final newItem = _EstimateEditItem(
//       productId: productIdStr,
//       name: name,
//       company: formCompany.isNotEmpty ? formCompany : (previous?.company ?? ''),
//       size: formSize.isNotEmpty ? formSize : (previous?.size ?? ''),
//       unit: formUnit.isNotEmpty ? formUnit : (previous?.unit ?? ''),
//       quantity: qty,
//       rate: rate,
//       amount: incentive.amount,
//       mrp: formMrp ?? previous?.mrp ?? 0,
//       boxQuantity: _isBoxUnitProduct ? (boxQuantity ?? 0) : 0,
//       pieceQuantity: _isBoxUnitProduct ? (pieceQuantity ?? 0) : 0,
//       isBoxUnit: isBoxUnit,
//       incentiveAmount: incentive.totalIncentive,
//       incentiveEligible: incentive.isEligible,
//       incentiveReason: incentive.eligibilityReason,
//     );
//
//     setState(() {
//       if (editingIndex != null) {
//         _items[editingIndex] = newItem;
//       } else {
//         _items.add(newItem);
//       }
//     });
//     _resetItemForm();
//   }
//
//   void _editItem(int index) {
//     final item = _items[index];
//     final match = _findProduct(item.productId);
//
//     setState(() {
//       _editingItemIndex = index;
//       _selectedProduct = match;
//       _showProductSuggestions = false;
//       _productSearchCtrl.text = match != null ? _productDisplayString(match) : item.name;
//       _itemCompanyCtrl.text = match?.company ?? item.company;
//       _itemSizeCtrl.text = item.size;
//       _itemUnitCtrl.text = item.unit;
//       _itemMrpCtrl.text = _formatQty(match?.mrp ?? item.mrp);
//       _itemQtyCtrl.text = _formatQty(item.quantity);
//       _itemRateCtrl.text = _formatQty(item.rate);
//       _itemBoxQtyCtrl.text = _formatQty(item.boxQuantity);
//       _itemPieceQtyCtrl.text = _formatQty(item.pieceQuantity);
//     });
//   }
//
//   void _cancelEditItem() => _resetItemForm();
//
//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//       if (_editingItemIndex != null) {
//         if (_editingItemIndex == index) {
//           _editingItemIndex = null;
//           _resetItemForm();
//         } else if (_editingItemIndex! > index) {
//           _editingItemIndex = _editingItemIndex! - 1;
//         }
//       }
//     });
//   }
//
//   void _submit(BuildContext context) {
//     final formValid = _formKey.currentState?.validate() ?? true;
//     if (!formValid) {
//       AppSnackbar.error('Please fix the highlighted fields');
//       return;
//     }
//
//     if (_items.isEmpty) {
//       AppSnackbar.error('Add at least one item.');
//       return;
//     }
//
//     final updateItems = _items
//         .map((row) => EstimateUpdateItem(
//       productId: row.productId,
//       quantity: row.quantity,
//       boxQuantity: row.boxQuantity,
//       pieceQuantity: row.pieceQuantity,
//       rate: row.rate,
//     ))
//         .toList();
//
//     final request = OwnerUpdateEstimateRequest(
//       id: widget.detail.id,
//       customerName: _nameCtrl.text.trim(),
//       customerPhone: _phoneCtrl.text.trim(),
//       customerAddress: _addressCtrl.text.trim(),
//       customerEmail: _emailCtrl.text.trim(),
//       date: _date == null ? null : DateFormat('yyyy-MM-dd').format(_date!),
//       notes: _notesCtrl.text.trim(),
//       termsConditions: _termsCtrl.text.trim(),
//       items: updateItems,
//     );
//
//     context.read<OwnerEstimateDetailBloc>().add(OwnerEstimateUpdateRequested(request));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//
//     return NetworkAwareWrapper(child: Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Update Estimate', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: BlocConsumer<OwnerEstimateDetailBloc, OwnerEstimateDetailState>(
//           listenWhen: (previous, current) =>
//           previous.actionStatus != current.actionStatus,
//           listener: (context, state) {
//             if (state.actionStatus == OwnerEstimateActionStatus.success) {
//               AppSnackbar.success(state.actionMessage ?? 'Estimate updated.');
//               Navigator.of(context).pop(true);
//             } else if (state.actionStatus == OwnerEstimateActionStatus.failure) {
//               AppSnackbar.error(state.actionMessage ?? 'Failed to update estimate.');
//             }
//           },
//           builder: (context, state) {
//             final isBusy = state.actionStatus == OwnerEstimateActionStatus.inProgress;
//
//             return Column(
//               children: [
//                 Expanded(
//                   child: Form(
//                     key: _formKey,
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     child: ListView(
//                       padding: EdgeInsets.all(Responsive.w(18)),
//                       children: [
//                         Text('Customer Details', style: AppTextStyles.h3()),
//                         SizedBox(height: Responsive.h(12)),
//                         LabeledField(
//                           label: 'Customer Name',
//                           field: CustomTextField(
//                             hint: 'Enter customer name',
//                             icon: Icons.groups_2_outlined,
//                             controller: _nameCtrl,
//                             validator: _validateCustomerName,
//                           ),
//                         ),
//                         LabeledField(
//                           label: 'Contact No.',
//                           field: CustomTextField(
//                             hint: 'Enter phone number',
//                             icon: Icons.phone_outlined,
//                             keyboardType: TextInputType.phone,
//                             controller: _phoneCtrl,
//                             inputFormatters: DValidator.phoneNumber,
//                             validator: _validateCustomerPhone,
//                           ),
//                         ),
//                         LabeledField(
//                           label: 'Address',
//                           field: CustomTextField(
//                             hint: 'Enter site address',
//                             icon: Icons.location_on_outlined,
//                             controller: _addressCtrl,
//                           ),
//                         ),
//                         LabeledField(
//                           label: 'Email',
//                           field: CustomTextField(
//                             hint: 'Enter customer email',
//                             icon: Icons.alternate_email,
//                             keyboardType: TextInputType.emailAddress,
//                             controller: _emailCtrl,
//                             validator: _validateOptionalEmail,
//                           ),
//                         ),
//                         LabeledField(
//                           label: 'Estimate Date',
//                           field: InkWell(
//                             onTap: () async {
//                               final picked = await showDatePicker(
//                                 context: context,
//                                 initialDate: _date ?? DateTime.now(),
//                                 firstDate: DateTime(2020),
//                                 lastDate: DateTime(2100),
//                               );
//                               if (picked != null) setState(() => _date = picked);
//                             },
//                             child: InputDecorator(
//                               decoration: InputDecoration(
//                                 prefixIcon: const Icon(Icons.calendar_today_outlined),
//                                 filled: true,
//                                 fillColor: AppColors.surface,
//                                 contentPadding:
//                                 const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.border),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.border),
//                                 ),
//                               ),
//                               child: Text(_date == null
//                                   ? 'Select date'
//                                   : DateFormat('yyyy-MM-dd').format(_date!)),
//                             ),
//                           ),
//                         ),
//                         LabeledField(
//                           label: 'Notes (optional)',
//                           field: CustomTextField(
//                             hint: 'e.g. Customer enquiry for new project',
//                             icon: Icons.notes_outlined,
//                             controller: _notesCtrl,
//                             inputFormatters: DValidator.textWithLimit,
//                           ),
//                         ),
//                         LabeledField(
//                           label: 'Terms & Conditions (optional)',
//                           field: CustomTextField(
//                             hint: 'e.g. 50% advance, balance on delivery',
//                             icon: Icons.description_outlined,
//                             controller: _termsCtrl,
//                             inputFormatters: DValidator.textWithLimit,
//                           ),
//                         ),
//                         SizedBox(height: Responsive.h(20)),
//
//                         Text('Add / Edit Item', style: AppTextStyles.h3()),
//                         SizedBox(height: Responsive.h(10)),
//                         Form(
//                           key: _itemFormKey,
//                           autovalidateMode: AutovalidateMode.onUserInteraction,
//                           child: Column(
//                             children: [
//                               _buildProductSearch(),
//                               SizedBox(height: Responsive.h(10)),
//                               LabeledField(
//                                 label: 'Company (auto)',
//                                 field: IgnorePointer(
//                                   child: CustomTextField(
//                                     hint: 'Select a product first',
//                                     icon: Icons.factory_outlined,
//                                     controller: _itemCompanyCtrl,
//                                   ),
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: LabeledField(
//                                       label: 'Size (auto)',
//                                       field: CustomTextField(
//                                         hint: 'e.g. 600x1200',
//                                         icon: Icons.straighten_outlined,
//                                         controller: _itemSizeCtrl,
//                                         inputFormatters: DValidator.textWithLimit,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: Responsive.w(10)),
//                                   Expanded(
//                                     child: LabeledField(
//                                       label: 'Unit (auto)',
//                                       field: CustomTextField(
//                                         hint: 'e.g. sqft',
//                                         icon: Icons.square_foot_outlined,
//                                         controller: _itemUnitCtrl,
//                                         inputFormatters: DValidator.textWithLimit,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               LabeledField(
//                                 label: 'MRP (auto)',
//                                 field: CustomTextField(
//                                   hint: '0',
//                                   icon: Icons.currency_rupee,
//                                   keyboardType: TextInputType.number,
//                                   controller: _itemMrpCtrl,
//                                   inputFormatters: DValidator.decimalNumber,
//                                   validator: (v) => DValidator.validateOptionalNumber('MRP', v),
//                                   onChanged: (_) => setState(() {}),
//                                 ),
//                               ),
//                               LabeledField(
//                                 label: _isBoxUnitProduct ? 'Quantity (Box)' : 'Quantity',
//                                 field: CustomTextField(
//                                   hint: 'Enter quantity',
//                                   icon: Icons.numbers_outlined,
//                                   keyboardType: TextInputType.number,
//                                   controller: _itemQtyCtrl,
//                                   inputFormatters: DValidator.decimalNumber,
//                                   validator: (v) {
//                                     final n = double.tryParse((v ?? '').trim());
//                                     if (n == null || n <= 0) {
//                                       return _isBoxUnitProduct
//                                           ? 'Enter a valid box/piece quantity'
//                                           : 'Enter a valid quantity';
//                                     }
//                                     return null;
//                                   },
//                                   onChanged: (_) {
//                                     setState(_recomputeBoxQtyIfNeeded);
//                                   },
//                                 ),
//                               ),
//                               if (_isBoxUnitProduct)
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: LabeledField(
//                                         label: 'Box Quantity (auto)',
//                                         field: IgnorePointer(
//                                           child: CustomTextField(
//                                             hint: '0',
//                                             icon: Icons.inventory_2_outlined,
//                                             keyboardType: TextInputType.number,
//                                             controller: _itemBoxQtyCtrl,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: Responsive.w(10)),
//                                     Expanded(
//                                       child: LabeledField(
//                                         label: 'Piece Quantity',
//                                         field: CustomTextField(
//                                           hint: 'Enter piece qty',
//                                           icon: Icons.widgets_outlined,
//                                           keyboardType: TextInputType.number,
//                                           controller: _itemPieceQtyCtrl,
//                                           inputFormatters: DValidator.decimalNumber,
//                                           onChanged: (_) => setState(() {}),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               LabeledField(
//                                 label: 'Rate',
//                                 field: CustomTextField(
//                                   hint: 'Enter rate per unit',
//                                   icon: Icons.currency_rupee,
//                                   keyboardType: TextInputType.number,
//                                   controller: _itemRateCtrl,
//                                   inputFormatters: DValidator.decimalNumber,
//                                   validator: (v) {
//                                     final n = double.tryParse((v ?? '').trim());
//                                     if (n == null || n <= 0) return 'Enter a valid rate';
//                                     return null;
//                                   },
//                                   onChanged: (_) => setState(() {}),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: Responsive.h(6)),
//                         SizedBox(height: Responsive.h(14)),
//                         if (_editingItemIndex != null)
//                           Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: Responsive.w(12), vertical: Responsive.h(8)),
//                             margin: EdgeInsets.only(bottom: Responsive.h(10)),
//                             decoration: BoxDecoration(
//                               color: AppColors.primary.withOpacity(0.08),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.edit_outlined,
//                                     size: 16, color: AppColors.primary),
//                                 SizedBox(width: Responsive.w(6)),
//                                 Expanded(
//                                   child: Text(
//                                     'Editing item #${_editingItemIndex! + 1}',
//                                     style: AppTextStyles.caption(),
//                                   ),
//                                 ),
//                                 InkWell(
//                                   onTap: _cancelEditItem,
//                                   child: Text('Cancel',
//                                       style: AppTextStyles.bodyBold(color: AppColors.error)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: (_loadingProducts || _isAddingItem) ? null : _saveItemFromForm,
//                             icon: _isAddingItem
//                                 ? const SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                             )
//                                 : Icon(
//                               _editingItemIndex != null ? Icons.save_outlined : Icons.add,
//                               color: Colors.white,
//                             ),
//                             label: Text(
//                               _isAddingItem
//                                   ? 'Calculating…'
//                                   : (_editingItemIndex != null ? 'Update Item' : 'Add Item'),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14)),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: Responsive.h(20)),
//
//                         Text('Items (${_items.length})', style: AppTextStyles.h3()),
//                         SizedBox(height: Responsive.h(10)),
//                         if (_loadingProducts)
//                           const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             child: Center(child: CircularProgressIndicator()),
//                           )
//                         else if (_items.isEmpty)
//                           Padding(
//                             padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
//                             child: Center(
//                               child: Text('No items added yet',
//                                   style: AppTextStyles.body(color: AppColors.textHint)),
//                             ),
//                           )
//                         else
//                           ..._items.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final item = entry.value;
//                             return _EstimateItemTile(
//                               serialNo: index + 1,
//                               item: item,
//                               currency: currency,
//                               isEditing: _editingItemIndex == index,
//                               onDelete: () => _removeItem(index),
//                             );
//                           }),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(
//                       Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
//                   child: PrimaryButton(
//                     label: isBusy ? 'Saving...' : 'Save Changes',
//                     height: 48,
//                     onPressed: isBusy ? null : () => _submit(context),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildProductSearch() {
//     if (_loadingProducts) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 12),
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     final query = _productSearchCtrl.text.trim().toLowerCase();
//     final filtered = query.isEmpty
//         ? _products
//         : _products.where((p) {
//       return p.name.toLowerCase().contains(query) ||
//           p.company.toLowerCase().contains(query) ||
//           p.size.toLowerCase().contains(query);
//     }).toList();
//
//     return LabeledField(
//       label: 'Select Product',
//       field: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextFormField(
//             controller: _productSearchCtrl,
//             focusNode: _productSearchFocus,
//             decoration: InputDecoration(
//               hintText: 'Type a product name…',
//               prefixIcon: const Icon(Icons.inventory_2_outlined),
//               suffixIcon: _productSearchCtrl.text.isEmpty
//                   ? null
//                   : IconButton(
//                 icon: const Icon(Icons.clear),
//                 tooltip: 'Clear',
//                 onPressed: _clearProductSelection,
//               ),
//               filled: true,
//               fillColor: AppColors.surface,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: AppColors.border),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: AppColors.border),
//               ),
//             ),
//             validator: (v) => DValidator.validateDropdown('product', _selectedProduct?.id),
//             onChanged: (text) {
//               if (_selectedProduct != null &&
//                   text != _productDisplayString(_selectedProduct!)) {
//                 _onProductSelected(null);
//               }
//               setState(() {
//                 _showProductSuggestions = text.trim().isNotEmpty;
//               });
//             },
//           ),
//           if (_showProductSuggestions) ...[
//             SizedBox(height: Responsive.h(6)),
//             Container(
//               constraints: BoxConstraints(maxHeight: Responsive.h(220)),
//               decoration: BoxDecoration(
//                 color: AppColors.surface,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: filtered.isEmpty
//                   ? Padding(
//                 padding: EdgeInsets.all(Responsive.w(14)),
//                 child: Text('No matching products', style: AppTextStyles.caption()),
//               )
//                   : ListView.separated(
//                 padding: EdgeInsets.zero,
//                 shrinkWrap: true,
//                 itemCount: filtered.length,
//                 separatorBuilder: (_, __) => const Divider(height: 1),
//                 itemBuilder: (context, index) {
//                   final p = filtered[index];
//                   return ListTile(
//                     dense: true,
//                     leading: const Icon(Icons.inventory_2_outlined, size: 18),
//                     title: Text(p.name, overflow: TextOverflow.ellipsis),
//                     subtitle: Text(
//                       '${p.company}${p.size.isNotEmpty ? ' • ${p.size}' : ''}',
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     onTap: () {
//                       _onProductSelected(p);
//                       setState(() => _showProductSuggestions = false);
//                       _productSearchFocus.unfocus();
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _EstimateItemTile extends StatelessWidget {
//   const _EstimateItemTile({
//     required this.serialNo,
//     required this.item,
//     required this.currency,
//     required this.onDelete,
//     this.isEditing = false,
//   });
//
//   final int serialNo;
//   final _EstimateEditItem item;
//   final NumberFormat currency;
//   final VoidCallback onDelete;
//   final bool isEditing;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: Responsive.h(10)),
//       padding: EdgeInsets.all(Responsive.w(12)),
//       decoration: BoxDecoration(
//         color: isEditing ? AppColors.primary.withOpacity(0.06) : AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: isEditing ? AppColors.primary : AppColors.border),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 12,
//             backgroundColor: AppColors.surfaceAlt,
//             child: Text('$serialNo', style: AppTextStyles.caption()),
//           ),
//           SizedBox(width: Responsive.w(10)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.name, style: AppTextStyles.bodyBold()),
//                 SizedBox(height: Responsive.h(2)),
//                 if (item.size.isNotEmpty || item.company.isNotEmpty)
//                   Text(
//                     '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}',
//                     style: AppTextStyles.caption(),
//                   ),
//                 SizedBox(height: Responsive.h(2)),
//                 Text(
//                   'Qty: ${_formatQty(item.quantity)}${item.unit.isNotEmpty ? ' ${item.unit}' : ''}'
//                       '${item.mrp > 0 ? '   MRP: ${_formatQty(item.mrp)}' : ''}'
//                       '   Rate: ${_formatQty(item.rate)}',
//                   style: AppTextStyles.caption(),
//                 ),
//                 if (item.isBoxUnit) ...[
//                   SizedBox(height: Responsive.h(2)),
//                   Text(
//                     'Box: ${_formatQty(item.boxQuantity)}   Piece: ${_formatQty(item.pieceQuantity)}',
//                     style: AppTextStyles.caption(),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(currency.format(item.amount),
//                   style: AppTextStyles.bodyBold(color: AppColors.primary)),
//               SizedBox(height: Responsive.h(8)),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   InkWell(
//                     onTap: onDelete,
//                     child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// Small label-over-field wrapper, matching the convention used on
// /// OwnerQuotationEditScreen's `LabeledField`. If your project already
// /// exports a shared `LabeledField` widget, remove this local copy and
// /// import that one instead to avoid a duplicate definition.
// class LabeledField extends StatelessWidget {
//   const LabeledField({super.key, required this.label, required this.field});
//   final String label;
//   final Widget field;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: Responsive.h(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: AppTextStyles.caption()),
//           SizedBox(height: Responsive.h(4)),
//           field,
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';

import '../../../core/apiclient/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';

import '../../models/owner_models/ownerestimate_updatemodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
// Same fresh, one-shot provider the Owner Create Estimate screen and
// OwnerQuotationEditScreen use for POST /quotations/product-incentive —
// fired the moment Add/Update Item is tapped, bypassing any
// cached/debounced bloc state, so the item that gets added/updated always
// matches exactly what the server computed (not a local quantity*rate
// approximation).
import '../../Apiprovider/salesman_quotationprovider.dart';

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
      isBoxUnit: _parseBool(
        json['is_box_unit'] ?? json['isBoxUnit'] ?? json['box_unit'],
      ),
    );
  }
}

/// One saved line item in the estimate being edited.
///
/// Mirrors the salesman flow's `AddedItem` (see owner_estimate_types.dart)
/// and QuotationEditScreen's `_EditItem`: `amount` is always the server's
/// own figure — from POST /quotations/product-incentive at the moment an
/// item is added/updated here, or straight from the estimate's own saved
/// EstimateDetailItem.amount for rows that were already on the estimate —
/// never recomputed locally as quantity * rate, since the server may
/// derive it from square feet or a box/piece breakdown instead of a flat
/// multiplication.
class _EstimateEditItem {
  const _EstimateEditItem({
    required this.productId,
    required this.name,
    required this.amount,
    this.company = '',
    this.size = '',
    this.unit = '',
    required this.quantity,
    required this.rate,
    this.mrp = 0,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    this.isBoxUnit = false,
    this.incentiveAmount = 0,
    this.incentiveEligible = false,
    this.incentiveReason,
  });

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
  final bool isBoxUnit;
  final double incentiveAmount;
  final bool incentiveEligible;
  final String? incentiveReason;

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
      amount: amount,
      company: company ?? this.company,
      size: size ?? this.size,
      unit: unit ?? this.unit,
      quantity: quantity,
      rate: rate,
      mrp: mrp ?? this.mrp,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
      isBoxUnit: isBoxUnit ?? this.isBoxUnit,
      incentiveAmount: incentiveAmount,
      incentiveEligible: incentiveEligible,
      incentiveReason: incentiveReason,
    );
  }
}

/// Screen for editing an estimate's customer details, contractor details,
/// notes, terms, date and item list via POST /estimates/update. Expects
/// to be pushed with a `BlocProvider.value` sharing the same
/// [OwnerEstimateDetailBloc] as the detail screen that opened it, so a
/// successful update also refreshes that screen's state.
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

  // ---- Contractor fields (mirrors QuotationDetailModel.contractor /
  // EstimateDetailModel.customer used on the read-only detail screens) ----
  late final TextEditingController _contractorNameCtrl;
  late final TextEditingController _contractorPhoneCtrl;
  late final TextEditingController _contractorEmailCtrl;

  late final TextEditingController _notesCtrl;
  late final TextEditingController _termsCtrl;
  DateTime? _date;

  // ---- Saved items ----
  final List<_EstimateEditItem> _items = [];

  // ---- Add / edit item form (mirrors OwnerQuotationEditScreen) ----
  final _itemFormKey = GlobalKey<FormState>();
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

    _contractorNameCtrl = TextEditingController(text: d.customer.name);
    _contractorPhoneCtrl = TextEditingController(text: d.customer.phone);
    _contractorEmailCtrl = TextEditingController(text: d.customer.email);

    _notesCtrl = TextEditingController(text: d.notes);
    _termsCtrl = TextEditingController(text: d.termsConditions);
    _date = d.date;

    for (final item in d.items) {
      _items.add(_EstimateEditItem(
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
    } catch (e, st) {
      debugPrint('OwnerEstimateUpdateScreen: failed to load active products: $e\n$st');
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  _ActiveProduct? _findProduct(String productId) {
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
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _contractorNameCtrl.dispose();
    _contractorPhoneCtrl.dispose();
    _contractorEmailCtrl.dispose();
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

  String? _validateCustomerName(String? v) => DValidator.validateName('Customer name', v);

  String? _validateCustomerPhone(String? v) => DValidator.validatePhoneNumber(v);

  String? _validateOptionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return DValidator.validateEmail(v);
  }

  String? _validateOptionalPhone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return DValidator.validatePhoneNumber(v);
  }

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

    String productIdStr;
    String name;
    if (_selectedProduct != null) {
      productIdStr = _selectedProduct!.id;
      name = _selectedProduct!.name;
    } else if (_editingItemIndex != null) {
      productIdStr = _items[_editingItemIndex!].productId;
      name = _items[_editingItemIndex!].name;
    } else {
      AppSnackbar.error('Please select a product');
      return;
    }
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

    final productId = int.tryParse(productIdStr);
    if (productId == null) {
      AppSnackbar.error('Invalid product selected.');
      debugPrint('OwnerEstimateUpdateScreen: could not parse productId "$productIdStr" as int');
      return;
    }

    _recomputeBoxQtyIfNeeded();
    final boxQuantity = _isBoxUnitProduct ? (double.tryParse(_itemBoxQtyCtrl.text) ?? 0) : null;
    final pieceQuantity = _isBoxUnitProduct ? (double.tryParse(_itemPieceQtyCtrl.text) ?? 0) : null;

    setState(() => _isAddingItem = true);

    final incentiveRequest = ProductIncentiveRequest(
      productId: productId,
      quantity: qty,
      rate: rate,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
    );

    // Diagnostics: this call is what actually determines whether an item
    // gets added at all — if adding new items silently "does nothing",
    // check this log first. Either result.success is false (backend
    // rejected the product/quantity/rate combo — see errorMessage below)
    // or result.incentive is null despite success being true.
    debugPrint('OwnerEstimateUpdateScreen: requesting product incentive '
        'productId=$productId qty=$qty rate=$rate box=$boxQuantity piece=$pieceQuantity '
        '(editingIndex=$_editingItemIndex)');

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
    final editingIndex = _editingItemIndex;
    final formCompany = _itemCompanyCtrl.text.trim();
    final formSize = _itemSizeCtrl.text.trim();
    final formUnit = _itemUnitCtrl.text.trim();
    final formMrp = double.tryParse(_itemMrpCtrl.text.trim());
    final previous = editingIndex != null ? _items[editingIndex] : null;
    final isBoxUnit = _selectedProduct?.isBoxUnit ?? previous?.isBoxUnit ?? false;

    final newItem = _EstimateEditItem(
      productId: productIdStr,
      name: name,
      company: formCompany.isNotEmpty ? formCompany : (previous?.company ?? ''),
      size: formSize.isNotEmpty ? formSize : (previous?.size ?? ''),
      unit: formUnit.isNotEmpty ? formUnit : (previous?.unit ?? ''),
      quantity: qty,
      rate: rate,
      amount: incentive.amount,
      mrp: formMrp ?? previous?.mrp ?? 0,
      boxQuantity: _isBoxUnitProduct ? (boxQuantity ?? 0) : 0,
      pieceQuantity: _isBoxUnitProduct ? (pieceQuantity ?? 0) : 0,
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
    debugPrint('OwnerEstimateUpdateScreen: item ${editingIndex != null ? 'updated' : 'added'}. '
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
      _productSearchCtrl.text = match != null ? _productDisplayString(match) : item.name;
      _itemCompanyCtrl.text = match?.company ?? item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = _formatQty(match?.mrp ?? item.mrp);
      _itemQtyCtrl.text = _formatQty(item.quantity);
      _itemRateCtrl.text = _formatQty(item.rate);
      _itemBoxQtyCtrl.text = _formatQty(item.boxQuantity);
      _itemPieceQtyCtrl.text = _formatQty(item.pieceQuantity);
    });
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

    // Items constructed here always carry real (non-null) box/piece
    // quantities from the in-memory row, so clearBoxQuantity /
    // clearPieceQuantity stay false — this screen doesn't currently
    // expose UI to explicitly null those out. If you need that, add a
    // "clear" toggle per item and set the corresponding flag below.
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
      contractorName: _contractorNameCtrl.text.trim(),
      contractorPhone: _contractorPhoneCtrl.text.trim(),
      contractorEmail: _contractorEmailCtrl.text.trim(),
      date: _date == null ? null : DateFormat('yyyy-MM-dd').format(_date!),
      notes: _notesCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim(),
      items: updateItems,
    );

    // Diagnostics: compare this against a working Postman body if the
    // update still silently "does nothing" — the exact JSON being sent
    // is the fastest way to spot a mismatch.
    debugPrint('OwnerEstimateUpdateScreen: submitting update payload: '
        '${jsonEncode(request.toJson())}');

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
              debugPrint('OwnerEstimateUpdateScreen: update failed -> ${state.actionMessage}');
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(18)),
                      children: [
                        Text('Customer Details', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(12)),
                        LabeledField(
                          label: 'Customer Name',
                          field: CustomTextField(
                            hint: 'Enter customer name',
                            icon: Icons.groups_2_outlined,
                            controller: _nameCtrl,
                            validator: _validateCustomerName,
                          ),
                        ),
                        LabeledField(
                          label: 'Contact No.',
                          field: CustomTextField(
                            hint: 'Enter phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            controller: _phoneCtrl,
                            inputFormatters: DValidator.phoneNumber,
                            validator: _validateCustomerPhone,
                          ),
                        ),
                        LabeledField(
                          label: 'Address',
                          field: CustomTextField(
                            hint: 'Enter site address',
                            icon: Icons.location_on_outlined,
                            controller: _addressCtrl,
                          ),
                        ),
                        LabeledField(
                          label: 'Email',
                          field: CustomTextField(
                            hint: 'Enter customer email',
                            icon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailCtrl,
                            validator: _validateOptionalEmail,
                          ),
                        ),
                        SizedBox(height: Responsive.h(20)),

                        Text('Contractor Details', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(12)),
                        LabeledField(
                          label: 'Contractor Name',
                          field: CustomTextField(
                            hint: 'Enter contractor name',
                            icon: Icons.person_outline,
                            controller: _contractorNameCtrl,
                          ),
                        ),
                        LabeledField(
                          label: 'Contractor Phone',
                          field: CustomTextField(
                            hint: 'Enter contractor phone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            controller: _contractorPhoneCtrl,
                            inputFormatters: DValidator.phoneNumber,
                            validator: _validateOptionalPhone,
                          ),
                        ),
                        LabeledField(
                          label: 'Contractor Email',
                          field: CustomTextField(
                            hint: 'Enter contractor email',
                            icon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            controller: _contractorEmailCtrl,
                            validator: _validateOptionalEmail,
                          ),
                        ),
                        LabeledField(
                          label: 'Estimate Date',
                          field: InkWell(
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
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.calendar_today_outlined),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: Text(_date == null
                                  ? 'Select date'
                                  : DateFormat('yyyy-MM-dd').format(_date!)),
                            ),
                          ),
                        ),
                        LabeledField(
                          label: 'Notes (optional)',
                          field: CustomTextField(
                            hint: 'e.g. Customer enquiry for new project',
                            icon: Icons.notes_outlined,
                            controller: _notesCtrl,
                            inputFormatters: DValidator.textWithLimit,
                          ),
                        ),
                        LabeledField(
                          label: 'Terms & Conditions (optional)',
                          field: CustomTextField(
                            hint: 'e.g. 50% advance, balance on delivery',
                            icon: Icons.description_outlined,
                            controller: _termsCtrl,
                            inputFormatters: DValidator.textWithLimit,
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
                              _buildProductSearch(),
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
                                        inputFormatters: DValidator.textWithLimit,
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
                                        inputFormatters: DValidator.textWithLimit,
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
                                  inputFormatters: DValidator.decimalNumber,
                                  validator: (v) => DValidator.validateOptionalNumber('MRP', v),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              LabeledField(
                                label: _isBoxUnitProduct ? 'Quantity (Box)' : 'Quantity',
                                field: CustomTextField(
                                  hint: 'Enter quantity',
                                  icon: Icons.numbers_outlined,
                                  keyboardType: TextInputType.number,
                                  controller: _itemQtyCtrl,
                                  inputFormatters: DValidator.decimalNumber,
                                  validator: (v) {
                                    final n = double.tryParse((v ?? '').trim());
                                    if (n == null || n <= 0) {
                                      return _isBoxUnitProduct
                                          ? 'Enter a valid box/piece quantity'
                                          : 'Enter a valid quantity';
                                    }
                                    return null;
                                  },
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
                                        field: CustomTextField(
                                          hint: 'Enter piece qty',
                                          icon: Icons.widgets_outlined,
                                          keyboardType: TextInputType.number,
                                          controller: _itemPieceQtyCtrl,
                                          inputFormatters: DValidator.decimalNumber,
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              LabeledField(
                                label: 'Rate',
                                field: CustomTextField(
                                  hint: 'Enter rate per unit',
                                  icon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                  controller: _itemRateCtrl,
                                  inputFormatters: DValidator.decimalNumber,
                                  validator: (v) {
                                    final n = double.tryParse((v ?? '').trim());
                                    if (n == null || n <= 0) return 'Enter a valid rate';
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(6)),
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
                            onPressed: (_loadingProducts || _isAddingItem) ? null : _saveItemFromForm,
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
                                  ? 'Calculating…'
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
                            final item = entry.value;
                            return _EstimateItemTile(
                              serialNo: index + 1,
                              item: item,
                              currency: currency,
                              isEditing: _editingItemIndex == index,
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
          TextFormField(
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
            validator: (v) => DValidator.validateDropdown('product', _selectedProduct?.id),
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
    required this.onDelete,
    this.isEditing = false,
  });

  final int serialNo;
  final _EstimateEditItem item;
  final NumberFormat currency;
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