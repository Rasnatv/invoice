//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../../../widgets/primary_button.dart';
// import '../../bloc/quotationitemremove/quotationitemremove_bloc.dart';
// import '../../bloc/quotationitemremove/quotationitemremove_event.dart';
// import '../../bloc/quotationitemremove/quotationitemremove_state.dart';
// import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
// import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
// import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';
// import '../../bloc/salemanbloc/estimate/salesman_estimate_bloc.dart';
// import '../../bloc/salemanbloc/estimate/salesmanestimate_event.dart';
// import '../../bloc/salemanbloc/estimate/salesmanestimate_state.dart';
// import '../../core/validator/validationfile.dart';
// import '../../models/salesmanmodels/estimate_activepdctmodel.dart';
// import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
// import '../../models/salesmanmodels/quotationupdatemodel.dart';
// import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
// import '../../widgets/appsnackbar.dart';
// // NOTE: adjust this path to match wherever QuotationProvider actually lives
// // relative to this file — it mirrors CreateEstimateScreen's own import of
// // the same provider, used the same way here: a fresh, one-shot call to
// // POST /quotations/product-incentive fired the moment Add/Update Item is
// // tapped, bypassing any cached/debounced bloc state.
// import '../../Apiprovider/salesman_quotationprovider.dart';
//
// /// CreateEstimateScreen uses.
// class QuotationEditScreen extends StatelessWidget {
//   const QuotationEditScreen({super.key, required this.estimate});
//
//   final QuotationDetailModel estimate;
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (_) => SalesmanEstimateBloc()..add(const ActiveProductsRequested()),
//         ),
//         BlocProvider(create: (_) => QuotationItemRemoveBloc()),
//       ],
//       child: _QuotationEditView(estimate: estimate),
//     );
//   }
// }
//
// /// Mirrors CreateEstimateScreen's AddedItem model and the reasoning behind
// /// it: `amount` is always the server's own figure — from
// /// POST /quotations/product-incentive when adding/editing an item here, or
// /// straight from QuotationDetailItem.amount for items already saved on the
// /// quotation — never recomputed locally as quantity * rate, since the
// /// server may derive it from square feet or a box/piece breakdown instead
// /// of a flat multiplication.
// class _EditItem {
//   const _EditItem({
//     required this.id,
//     required this.productId,
//     required this.name,
//     required this.unit,
//     required this.quantity,
//     required this.rate,
//     required this.amount,
//     this.company = '',
//     this.size = '',
//     this.mrp = 0,
//     this.boxQuantity = 0,
//     this.pieceQuantity = 0,
//     this.incentiveAmount = 0,
//     this.incentiveEligible = false,
//     this.incentiveReason,
//   });
//
//   final String id;
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
//   final double incentiveAmount;
//   final bool incentiveEligible;
//   final String? incentiveReason;
//
//   _EditItem copyWith({
//     String? company,
//     double? mrp,
//   }) {
//     return _EditItem(
//       id: id,
//       productId: productId,
//       name: name,
//       unit: unit,
//       quantity: quantity,
//       rate: rate,
//       amount: amount,
//       company: company ?? this.company,
//       size: size,
//       mrp: mrp ?? this.mrp,
//       boxQuantity: boxQuantity,
//       pieceQuantity: pieceQuantity,
//       incentiveAmount: incentiveAmount,
//       incentiveEligible: incentiveEligible,
//       incentiveReason: incentiveReason,
//     );
//   }
// }
//
// class _QuotationEditView extends StatefulWidget {
//   const _QuotationEditView({required this.estimate});
//   final QuotationDetailModel estimate;
//
//   @override
//   State<_QuotationEditView> createState() => _QuotationEditViewState();
// }
//
// class _QuotationEditViewState extends State<_QuotationEditView> {
//   // Form key for the customer/contractor/other-details section.
//   final _formKey = GlobalKey<FormState>();
//
//   // ---------------- Customer / contractor / other details ----------------
//   late final TextEditingController _customerName;
//   late final TextEditingController _customerPhone;
//   late final TextEditingController _customerEmail;
//   late final TextEditingController _customerAddress;
//   late final TextEditingController _contractorName;
//   late final TextEditingController _contractorPhone;
//   late final TextEditingController _contractorEmail;
//   late final TextEditingController _contractorAddress;
//   late final TextEditingController _handlingCharge;
//   late final TextEditingController _notes;
//
//
//   // ---------------- Items ----------------
//   late List<_EditItem> _items;
//   int _newItemCounter = 0;
//   int? _editingItemIndex;
//
//   // ---------------- Add / edit item form ----------------
//   final _itemFormKey = GlobalKey<FormState>();
//   ActiveProductModel? _selectedProduct;
//   final _itemCompanyCtrl = TextEditingController();
//   final _itemSizeCtrl = TextEditingController();
//   final _itemUnitCtrl = TextEditingController();
//   final _itemMrpCtrl = TextEditingController();
//   final _itemQtyCtrl = TextEditingController();
//   final _itemRateCtrl = TextEditingController();
//
//   // For box-unit products, Box Quantity is shown as its own visible field
//   // that auto-updates whenever Quantity changes (kept in sync, not
//   // editable independently). Piece Quantity is also shown as its own
//   // visible field but is entered independently by the user.
//   final _itemBoxQtyCtrl = TextEditingController();
//   final _itemPieceQtyCtrl = TextEditingController();
//
//   Timer? _incentiveDebounce;
//   static const _incentiveDebounceDuration = Duration(milliseconds: 450);
//
//   bool _backfilledFromCatalog = false;
//
//   // Used ONLY for the Add/Update Item call — a fresh, one-shot request
//   // fired straight from QuotationProvider (bypassing the bloc's cached
//   // state entirely), so the item that gets added/updated always matches
//   // exactly what's on screen at the moment the button is tapped. Same
//   // approach as CreateEstimateScreen's _addItemToList.
//   final QuotationProvider _quotationProvider = QuotationProvider();
//   bool _isAddingItem = false;
//
//   /// Whether the current add/edit-item form should be treated as a
//   /// box-unit product (and therefore show the Box Quantity / Piece
//   /// Quantity fields).
//   ///
//   /// Order matters here:
//   /// 1. When editing an EXISTING item, its own saved quantities are the
//   ///    source of truth. _editItem always finds a catalog match when the
//   ///    product is still active, which used to make this getter check
//   ///    `_selectedProduct!.isBoxUnit` FIRST and return early — so even
//   ///    though the item clearly had box_quantity/piece_quantity saved on
//   ///    it, the row stayed hidden whenever the catalog's current
//   ///    `is_box_unit` flag for that product happened to be false (unit
//   ///    changed since the quotation was created, flag toggled on the
//   ///    backend, etc). Checking the saved item first fixes that.
//   /// 2. Only when there's no saved item to check (adding a brand-new
//   ///    item, or editing an item that genuinely has no box/piece data)
//   ///    do we fall back to the catalog-matched product's own flag.
//   bool get _isBoxUnitProduct {
//     if (_editingItemIndex != null) {
//       final item = _items[_editingItemIndex!];
//       if (item.boxQuantity > 0 || item.pieceQuantity > 0) return true;
//     }
//     if (_selectedProduct != null) return _selectedProduct!.isBoxUnit;
//     return false;
//   }
//
//   double get _computedQuantity => double.tryParse(_itemQtyCtrl.text) ?? 0;
//
//   /// Keeps the visible Box Quantity field in sync with Quantity for
//   /// box-unit products, exactly mirroring whatever is typed there.
//   ///
//   /// NOTE: this is the "live sync while typing" behavior only. It must
//   /// only run in response to the user editing the Quantity field (see the
//   /// Quantity field's onChanged below). It must NOT be used to populate
//   /// the Box Quantity field when an existing item is first loaded into
//   /// the form for editing — that must come from the item's own saved
//   /// `boxQuantity`, not from whatever happens to be in the Quantity field
//   /// at that moment. See _editItem.
//   void _recomputeBoxQtyIfNeeded() {
//     if (!_isBoxUnitProduct) return;
//     _itemBoxQtyCtrl.text = _itemQtyCtrl.text;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     final e = widget.estimate;
//
//     debugPrint('EDIT SCREEN OPENED: contractor=${e.contractor.name}');
//
//     _customerName = TextEditingController(text: e.customer.name);
//     _customerPhone = TextEditingController(text: e.customer.phone);
//     _customerEmail = TextEditingController(text: e.customer.email);
//     _customerAddress = TextEditingController(text: e.customer.address);
//
//     _contractorName = TextEditingController(text: e.contractor.name);
//     _contractorPhone = TextEditingController(text: e.contractor.mobile);
//     _contractorEmail = TextEditingController(text: e.contractor.email);
//     _contractorAddress = TextEditingController(text: e.contractor.address);
//
//     _handlingCharge = TextEditingController(text: _formatPrice(e.handlingCharge));
//     _notes = TextEditingController(text: e.notes);
//
//     _items = e.items
//         .asMap()
//         .entries
//         .map((entry) => _EditItem(
//       // Real backend item id — needed to call POST /quotations/remove-item.
//       // Newly-added items (added on this screen, never saved) instead get
//       // an id prefixed 'new_' — see _saveItemFromForm — which is how
//       // _removeItem tells the two cases apart.
//       id: entry.value.id,
//       productId: entry.value.productId,
//       name: entry.value.productName,
//       unit: entry.value.productUnit,
//       size: entry.value.productSize,
//       quantity: entry.value.quantity,
//       rate: entry.value.rate,
//       amount: entry.value.amount,
//       boxQuantity: entry.value.boxQuantity,
//       pieceQuantity: entry.value.pieceQuantity,
//       incentiveAmount: entry.value.incentiveAmount,
//       incentiveEligible: entry.value.incentiveAmount > 0,
//     ))
//         .toList();
//   }
//
//   @override
//   void dispose() {
//     _incentiveDebounce?.cancel();
//     _customerName.dispose();
//     _customerPhone.dispose();
//     _customerEmail.dispose();
//     _customerAddress.dispose();
//     _contractorName.dispose();
//     _contractorPhone.dispose();
//     _contractorEmail.dispose();
//     _contractorAddress.dispose();
//     _handlingCharge.dispose();
//     _notes.dispose();
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
//   // ---------------- Derived totals ----------------
//
//   double get _itemsTotal => _items.fold(0.0, (s, i) => s + i.amount);
//   double get _handling => double.tryParse(_handlingCharge.text.trim()) ?? 0;
//   double get _grandTotal => _itemsTotal + _handling;
//   double get _incentiveTotal => _items.fold(0.0, (s, i) => s + i.incentiveAmount);
//
//   int get _totalItemsCount => _items.length;
//   double get _totalQty => _items.fold(0.0, (s, i) => s + i.quantity);
//
//   double get _mrpTotal => _items.fold(0.0, (s, i) => s + (i.mrp * i.quantity));
//
//   double get _totalSqft => _items.fold(0.0, (s, i) {
//     final u = i.unit.toLowerCase().replaceAll('.', '').replaceAll(' ', '').replaceAll('²', '2');
//     final isSqft = u == 'sqft' ||
//         u == 'sqfeet' ||
//         u == 'squarefeet' ||
//         u == 'squareft' ||
//         u == 'sft' ||
//         u == 'ft2' ||
//         u.contains('sqft') ||
//         u.contains('squareft') ||
//         u.contains('squarefeet');
//     return s + (isSqft ? i.quantity : 0);
//   });
//
//   // REMOVED: _currentItemAmount getter — the pre-add "Amount" preview box
//   // is gone (see below), so nothing reads a local qty*rate approximation
//   // that could disagree with what the server actually calculates. Same
//   // change CreateEstimateScreen already made.
//
//   static String _formatPrice(double value) =>
//       value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
//
//   /// Items added on this screen and not yet saved to the server carry an
//   /// id prefixed 'new_' (see _saveItemFromForm). Anything else is a real
//   /// backend item id and must go through POST /quotations/remove-item to
//   /// actually be deleted.
//   bool _isUnsavedItem(_EditItem item) => item.id.startsWith('new_');
//
//   void _showError(String msg) {
//     AppSnackbar.error(msg);
//   }
//
//   ActiveProductModel? _findCatalogMatch(List<ActiveProductModel> products, String productId) {
//     for (final p in products) {
//       if (p.id == productId) return p;
//     }
//     return null;
//   }
//
//   void _backfillCompanyAndMrp(List<ActiveProductModel> products) {
//     if (products.isEmpty) return;
//
//     var changed = false;
//     final updated = _items.map((item) {
//       if (item.company.isNotEmpty) return item;
//       final match = _findCatalogMatch(products, item.productId);
//       if (match == null) return item;
//       changed = true;
//       return item.copyWith(company: match.company, mrp: match.mrp);
//     }).toList();
//
//     if (changed) {
//       setState(() {
//         _items = updated;
//         _backfilledFromCatalog = true;
//       });
//     } else {
//       _backfilledFromCatalog = true;
//     }
//   }
//
//   // ---------------- Field-level validators (DValidator) ----------------
//
//   String? _validatePartyName(String? v) => DValidator.validateName('Party name', v);
//
//   String? _validateCustomerPhone(String? v) => DValidator.validatePhoneNumber(v);
//
//   String? _validateCustomerAddress(String? v) =>
//       DValidator.validateRequired(v, message: 'Site address is required');
//
//   /// Email is optional on this screen — only validate format if something
//   /// was typed.
//   String? _validateOptionalEmail(String? v) {
//     if (v == null || v.trim().isEmpty) return null;
//     return DValidator.validateEmail(v);
//   }
//
//   /// Contractor name is optional — but becomes required once contractor
//   /// phone is filled in, since a phone without a name to attach it to
//   /// isn't useful on the quotation.
//   String? _validateOptionalName(String fieldName, String? v) {
//     final name = (v ?? '').trim();
//     final phone = _contractorPhone.text.trim();
//
//     if (name.isEmpty && phone.isNotEmpty) {
//       return '$fieldName is required when contractor phone number is entered';
//     }
//     if (name.isEmpty) return null;
//     return DValidator.validateAlphaOnly(fieldName, name);
//   }
//
//   /// Contractor phone is optional — but becomes required once contractor
//   /// name is filled in, mirroring _validateOptionalName above.
//   String? _validateOptionalPhone(String? v) {
//     final phone = (v ?? '').trim();
//     final name = _contractorName.text.trim();
//
//     if (phone.isEmpty && name.isNotEmpty) {
//       return 'Contractor phone number is required when contractor name is entered';
//     }
//     if (phone.isEmpty) return null;
//     return DValidator.validatePhoneNumber(phone);
//   }
//
//   String? _validateHandlingCharge(String? v) =>
//       DValidator.validateOptionalNumber('Handling charge', v);
//
//   // ---------------- Add-item form wiring ----------------
//
//   void _onProductSelected(ActiveProductModel? product) {
//     setState(() {
//       _selectedProduct = product;
//       if (product != null) {
//         _itemCompanyCtrl.text = product.company;
//         _itemSizeCtrl.text = product.size;
//         _itemUnitCtrl.text = product.unit;
//         _itemMrpCtrl.text = _formatPrice(product.mrp);
//         _itemRateCtrl.text = _formatPrice(product.rate);
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
//     _scheduleIncentiveFetch();
//   }
//
//   void _scheduleIncentiveFetch() {
//     _incentiveDebounce?.cancel();
//
//     final product = _selectedProduct;
//     final qty = _computedQuantity;
//     final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
//     final fallbackProductId =
//     _editingItemIndex != null ? _items[_editingItemIndex!].productId : null;
//     final productId = product != null
//         ? int.tryParse(product.id)
//         : (fallbackProductId != null ? int.tryParse(fallbackProductId) : null);
//
//     if (productId == null || qty <= 0 || rate <= 0) {
//       context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
//       return;
//     }
//
//     _incentiveDebounce = Timer(_incentiveDebounceDuration, () {
//       if (!mounted) return;
//       context.read<SalesmanEstimateBloc>().add(ProductIncentiveRequested(
//         productId: productId,
//         quantity: qty,
//         rate: rate,
//       ));
//     });
//   }
//
//   void _resetItemForm() {
//     _incentiveDebounce?.cancel();
//     setState(() {
//       _selectedProduct = null;
//       _editingItemIndex = null;
//       _itemCompanyCtrl.clear();
//       _itemSizeCtrl.clear();
//       _itemUnitCtrl.clear();
//       _itemMrpCtrl.clear();
//       _itemQtyCtrl.clear();
//       _itemBoxQtyCtrl.clear();
//       _itemPieceQtyCtrl.clear();
//       _itemRateCtrl.clear();
//     });
//     context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
//     // Clear any stale validation messages left on the item form.
//     _itemFormKey.currentState?.reset();
//   }
//
//   /// Fires a FRESH, one-shot POST /quotations/product-incentive with
//   /// exactly what's on the form right now (product_id, quantity, rate,
//   /// box_quantity, piece_quantity), waits for the real response, and
//   /// builds/updates the item using ONLY that response's amount/incentive
//   /// fields. No cached bloc state, no local qty*rate math — identical
//   /// approach to CreateEstimateScreen's _addItemToList, so an item added
//   /// or edited here always reflects exactly what the server computed.
//   Future<void> _saveItemFromForm() async {
//     if (_isAddingItem) return;
//
//     // Validate quantity/rate formatting via the item form before doing
//     // anything else. Product-selection and >0 checks stay as explicit
//     // checks below since they aren't plain text-field concerns.
//     if (!(_itemFormKey.currentState?.validate() ?? true)) {
//       return;
//     }
//
//     final qty = _computedQuantity;
//     final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
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
//       _showError('Please select a product');
//       return;
//     }
//     if (qty <= 0) {
//       _showError(_isBoxUnitProduct
//           ? 'Please enter a valid box quantity or piece quantity'
//           : 'Please enter a valid quantity');
//       return;
//     }
//     if (rate <= 0) {
//       _showError('Please enter a valid rate');
//       return;
//     }
//
//     final productId = int.tryParse(productIdStr);
//     if (productId == null) {
//       _showError('Invalid product selected.');
//       return;
//     }
//
//     // Box Quantity mirrors Quantity (same convention as Create Estimate);
//     // Piece Quantity is entered independently by the user in its own
//     // field. Non-box-unit items send null for both.
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
//       _showError(result.errorMessage ?? 'Could not calculate the amount for this item. Please try again.');
//       return;
//     }
//
//     final incentive = result.incentive!;
//     final editingIndex = _editingItemIndex;
//
//     final formCompany = _itemCompanyCtrl.text.trim();
//     final formMrp = double.tryParse(_itemMrpCtrl.text);
//     final previousCompany = editingIndex != null ? _items[editingIndex].company : '';
//     final previousMrp = editingIndex != null ? _items[editingIndex].mrp : 0.0;
//
//     final newItem = _EditItem(
//       id: editingIndex != null ? _items[editingIndex].id : 'new_${_newItemCounter++}',
//       productId: productIdStr,
//       name: name,
//       company: formCompany.isNotEmpty ? formCompany : previousCompany,
//       size: _itemSizeCtrl.text.trim(),
//       unit: _itemUnitCtrl.text.trim(),
//       quantity: qty,
//       rate: rate,
//       amount: incentive.amount,
//       mrp: formMrp ?? previousMrp,
//       boxQuantity: _isBoxUnitProduct ? (boxQuantity ?? 0) : 0,
//       pieceQuantity: _isBoxUnitProduct ? (pieceQuantity ?? 0) : 0,
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
//     final products = context.read<SalesmanEstimateBloc>().state.products;
//     final match = _findCatalogMatch(products, item.productId);
//
//     setState(() {
//       _editingItemIndex = index;
//       _selectedProduct = match;
//       _itemCompanyCtrl.text = match?.company ?? item.company;
//       _itemSizeCtrl.text = item.size;
//       _itemUnitCtrl.text = item.unit;
//       _itemMrpCtrl.text = _formatPrice(match?.mrp ?? item.mrp);
//       _itemQtyCtrl.text = _formatPrice(item.quantity);
//       _itemRateCtrl.text = _formatPrice(item.rate);
//       // Show the item's own saved box quantity here — do NOT derive it
//       // from the Quantity field (that's only for live-sync while the
//       // user is actively typing, see the Quantity field's onChanged).
//       // Quantity and Box Quantity are separate stored values and must
//       // each be populated from their own field on the item.
//       _itemBoxQtyCtrl.text = _formatPrice(item.boxQuantity);
//       _itemPieceQtyCtrl.text = _formatPrice(item.pieceQuantity);
//     });
//
//     context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
//     if (match != null) _scheduleIncentiveFetch();
//   }
//
//   void _cancelEditItem() => _resetItemForm();
//
//   /// For an unsaved (locally-added) item, removes it from the list
//   /// immediately — there's nothing on the server to delete. For an
//   /// existing item, dispatches the remove-item API call instead; the
//   /// item is only dropped from [_items] once that call succeeds (handled
//   /// in the BlocListener in build()).
//   void _removeItem(int index) {
//     final item = _items[index];
//
//     if (_isUnsavedItem(item)) {
//       setState(() {
//         _items.removeAt(index);
//         if (_editingItemIndex != null) {
//           if (_editingItemIndex == index) {
//             _editingItemIndex = null;
//             _resetItemForm();
//           } else if (_editingItemIndex! > index) {
//             _editingItemIndex = _editingItemIndex! - 1;
//           }
//         }
//       });
//       return;
//     }
//
//     context.read<QuotationItemRemoveBloc>().add(QuotationItemRemoveRequested(
//       quotationId: widget.estimate.id,
//       quotationItemId: item.id,
//     ));
//   }
//
//   /// Called once the remove-item API call for [itemId] has succeeded —
//   /// actually drops the item from the local list and fixes up the
//   /// editing index the same way the old synchronous _removeItem did.
//   void _dropItemById(String itemId) {
//     final index = _items.indexWhere((i) => i.id == itemId);
//     if (index == -1) return;
//
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
//   // ---------------- Submit ----------------
//
//   bool _validate() {
//     // Runs every validator attached to the customer/contractor/other-details
//     // Form below (party name, phone, address, optional email/contractor
//     // fields, handling charge).
//     final formValid = _formKey.currentState?.validate() ?? true;
//     if (!formValid) {
//       _showError('Please fix the highlighted fields');
//       return false;
//     }
//     if (_items.isEmpty) {
//       _showError('Add at least one item');
//       return false;
//     }
//     return true;
//   }
//
//   void _submit() {
//     if (!_validate()) return;
//
//     final request = QuotationUpdateRequest(
//       id: widget.estimate.id,
//       customerName: _customerName.text.trim(),
//       customerPhone: _customerPhone.text.trim(),
//       customerEmail: _customerEmail.text.trim().isEmpty ? null : _customerEmail.text.trim(),
//       customerAddress:
//       _customerAddress.text.trim().isEmpty ? null : _customerAddress.text.trim(),
//       contractorName:
//       _contractorName.text.trim().isEmpty ? null : _contractorName.text.trim(),
//       contractorPhone:
//       _contractorPhone.text.trim().isEmpty ? null : _contractorPhone.text.trim(),
//       contractorEmail:
//       _contractorEmail.text.trim().isEmpty ? null : _contractorEmail.text.trim(),
//       contractorAddress:
//       _contractorAddress.text.trim().isEmpty ? null : _contractorAddress.text.trim(),
//       handlingCharge: _handling,
//       notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
//       items: _items
//           .map((i) => QuotationUpdateItemRequest(
//         productId: i.productId,
//         quantity: i.quantity,
//         rate: i.rate,
//         // Only sent when actually a box-unit item with a positive
//         // value — QuotationUpdateItemRequest.toJson() omits nulls, so
//         // regular (non-box) items are unaffected.
//         boxQuantity: i.boxQuantity > 0 ? i.boxQuantity : null,
//         pieceQuantity: i.pieceQuantity > 0 ? i.pieceQuantity : null,
//       ))
//           .toList(),
//     );
//
//     // DEBUG: shows exactly what is sent to POST /quotations/update.
//     // Remove once the contractor issue is resolved.
//     debugPrint('UPDATE BODY: ${jsonEncode(request.toJson())}');
//
//     context.read<SalesmanQuotationBloc>().add(QuotationUpdateSubmitted(request));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//
//     return NetworkAwareWrapper(child: Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Edit Quotation', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: MultiBlocListener(
//           listeners: [
//             BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
//               listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
//               listener: (context, state) {
//                 if (state.submitStatus == QuotationActionStatus.success) {
//                   AppSnackbar.success(state.submitMessage ?? 'Quotation updated.');
//                   context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
//                   Navigator.of(context).pop();
//                 } else if (state.submitStatus == QuotationActionStatus.failure) {
//                   _showError(state.submitError ?? 'Failed to update quotation.');
//                   context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
//                 }
//               },
//             ),
//             BlocListener<SalesmanEstimateBloc, SalesmanEstimateState>(
//               listenWhen: (prev, curr) =>
//               !_backfilledFromCatalog &&
//                   prev.productsStatus != curr.productsStatus &&
//                   curr.productsStatus == LoadStatus.success,
//               listener: (context, state) => _backfillCompanyAndMrp(state.products),
//             ),
//             BlocListener<QuotationItemRemoveBloc, QuotationItemRemoveState>(
//               listenWhen: (prev, curr) => prev.status != curr.status,
//               listener: (context, state) {
//                 if (state.status == QuotationItemRemoveStatus.success) {
//                   final removedId = state.removedItemId;
//                   if (removedId != null) _dropItemById(removedId);
//                   AppSnackbar.success(state.message ?? 'Item removed successfully');
//                   context.read<QuotationItemRemoveBloc>().add(const QuotationItemRemoveResultConsumed());
//                 } else if (state.status == QuotationItemRemoveStatus.failure) {
//                   _showError(state.errorMessage ?? 'Failed to remove item');
//                   context.read<QuotationItemRemoveBloc>().add(const QuotationItemRemoveResultConsumed());
//                 }
//               },
//             ),
//           ],
//           child: Column(
//             children: [
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   child: ListView(
//                     padding: EdgeInsets.all(Responsive.w(18)),
//                     children: [
//                       Text('Customer Details', style: AppTextStyles.h3()),
//                       SizedBox(height: Responsive.h(12)),
//                       LabeledField(
//                         label: 'Party Name',
//                         field: IgnorePointer(
//                           child: CustomTextField(
//                             hint: 'Enter party name',
//                             icon: Icons.groups_2_outlined,
//                             controller: _customerName,
//                             validator: _validatePartyName,
//                           ),
//                         ),
//                       ),
//                       LabeledField(
//                         label: 'Contact No.',
//                         field: IgnorePointer(
//                           child: CustomTextField(
//                             hint: 'Enter phone number',
//                             icon: Icons.phone_outlined,
//                             keyboardType: TextInputType.phone,
//                             controller: _customerPhone,
//                             validator: _validateCustomerPhone,
//                           ),
//                         ),
//                       ),
//                       LabeledField(
//                         label: 'Address',
//                         field: IgnorePointer(
//                           child: CustomTextField(
//                             hint: 'Enter site address',
//                             icon: Icons.location_on_outlined,
//                             controller: _customerAddress,
//                             validator: _validateCustomerAddress,
//                           ),
//                         ),
//                       ),
//                       LabeledField(
//                         label: 'Email',
//                         field: IgnorePointer(
//                           child: CustomTextField(
//                             hint: 'Enter customer email',
//                             icon: Icons.alternate_email,
//                             keyboardType: TextInputType.emailAddress,
//                             controller: _customerEmail,
//                             validator: _validateOptionalEmail,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(16)),
//
//                       Text('Contractor Details', style: AppTextStyles.h3()),
//                       SizedBox(height: Responsive.h(12)),
//                       LabeledField(
//                         label: 'Contractor Name',
//                         field: CustomTextField(
//                           hint: 'Enter contractor name',
//                           icon: Icons.engineering_outlined,
//                           controller: _contractorName,
//                           inputFormatters: DValidator.lettersOnly,
//                           validator: (v) => _validateOptionalName('Contractor name', v),
//                           onChanged: (_) => _formKey.currentState?.validate(),
//                         ),
//                       ),
//                       LabeledField(
//                         label: 'Contact No.',
//                         field: CustomTextField(
//                           hint: 'Enter contractor phone number',
//                           icon: Icons.phone_outlined,
//                           keyboardType: TextInputType.phone,
//                           controller: _contractorPhone,
//                           inputFormatters: DValidator.phoneNumber,
//                           validator: _validateOptionalPhone,
//                           onChanged: (_) => _formKey.currentState?.validate(),
//                         ),
//                       ),
//                       LabeledField(
//                         label: 'Email (optional)',
//                         field: CustomTextField(
//                           hint: 'Enter contractor email',
//                           icon: Icons.alternate_email,
//                           keyboardType: TextInputType.emailAddress,
//                           controller: _contractorEmail,
//                           validator: _validateOptionalEmail,
//                         ),
//                       ),
//                       // NEW: contractor address field. The controller was
//                       // always created and sent in _submit, but there was
//                       // no input for it, so an empty address could never
//                       // be filled in from this screen.
//                       LabeledField(
//                         label: 'Address (optional)',
//                         field: CustomTextField(
//                           hint: 'Enter contractor address',
//                           icon: Icons.location_on_outlined,
//                           controller: _contractorAddress,
//                           inputFormatters: DValidator.textWithLimit,
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(20)),
//
//                       Text('Add / Edit Item', style: AppTextStyles.h3()),
//                       SizedBox(height: Responsive.h(10)),
//                       Form(
//                         key: _itemFormKey,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         child: Column(
//                           children: [
//                             _buildProductDropdown(),
//                             SizedBox(height: Responsive.h(10)),
//                             LabeledField(
//                               label: 'Company (auto)',
//                               field: IgnorePointer(
//                                 child: CustomTextField(
//                                   hint: 'Select a product first',
//                                   icon: Icons.factory_outlined,
//                                   controller: _itemCompanyCtrl,
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: LabeledField(
//                                     label: 'Size (auto)',
//                                     field: CustomTextField(
//                                       hint: 'e.g. 600x1200',
//                                       icon: Icons.straighten_outlined,
//                                       controller: _itemSizeCtrl,
//                                       inputFormatters: DValidator.textWithLimit,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: Responsive.w(10)),
//                                 Expanded(
//                                   child: LabeledField(
//                                     label: 'Unit (auto)',
//                                     field: CustomTextField(
//                                       hint: 'e.g. sqft',
//                                       icon: Icons.square_foot_outlined,
//                                       controller: _itemUnitCtrl,
//                                       inputFormatters: DValidator.textWithLimit,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             LabeledField(
//                               label: 'MRP (auto)',
//                               field: CustomTextField(
//                                 hint: '0',
//                                 icon: Icons.currency_rupee,
//                                 keyboardType: TextInputType.number,
//                                 controller: _itemMrpCtrl,
//                                 inputFormatters: DValidator.decimalNumber,
//                                 validator: (v) => DValidator.validateOptionalNumber('MRP', v),
//                                 onChanged: (_) => setState(() {}),
//                               ),
//                             ),
//                             LabeledField(
//                               label: 'Quantity',
//                               field: CustomTextField(
//                                 hint: 'Enter quantity',
//                                 icon: Icons.numbers_outlined,
//                                 keyboardType: TextInputType.number,
//                                 controller: _itemQtyCtrl,
//                                 inputFormatters: DValidator.decimalNumber,
//                                 validator: (v) {
//                                   final n = double.tryParse((v ?? '').trim());
//                                   if (n == null || n <= 0) {
//                                     return _isBoxUnitProduct
//                                         ? 'Enter a valid box/piece quantity'
//                                         : 'Enter a valid quantity';
//                                   }
//                                   return null;
//                                 },
//                                 onChanged: (_) {
//                                   // Live-sync only: this is the one place Box
//                                   // Quantity should be derived from Quantity —
//                                   // while the user is actively editing it.
//                                   setState(_recomputeBoxQtyIfNeeded);
//                                   _scheduleIncentiveFetch();
//                                 },
//                               ),
//                             ),
//                             if (_isBoxUnitProduct)
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: LabeledField(
//                                       label: 'Box Quantity (auto)',
//                                       field: IgnorePointer(
//                                         child: CustomTextField(
//                                           hint: '0',
//                                           icon: Icons.inventory_2_outlined,
//                                           keyboardType: TextInputType.number,
//                                           controller: _itemBoxQtyCtrl,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: Responsive.w(10)),
//                                   Expanded(
//                                     child: LabeledField(
//                                       label: 'Piece Quantity',
//                                       field: CustomTextField(
//                                         hint: 'Enter piece qty',
//                                         icon: Icons.widgets_outlined,
//                                         keyboardType: TextInputType.number,
//                                         controller: _itemPieceQtyCtrl,
//                                         inputFormatters: DValidator.decimalNumber,
//                                         onChanged: (_) => setState(() {}),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             LabeledField(
//                               label: 'Rate',
//                               field: CustomTextField(
//                                 hint: 'Enter rate per unit',
//                                 icon: Icons.currency_rupee,
//                                 keyboardType: TextInputType.number,
//                                 controller: _itemRateCtrl,
//                                 inputFormatters: DValidator.decimalNumber,
//                                 validator: (v) {
//                                   final n = double.tryParse((v ?? '').trim());
//                                   if (n == null || n <= 0) return 'Enter a valid rate';
//                                   return null;
//                                 },
//                                 onChanged: (_) {
//                                   setState(() {});
//                                   _scheduleIncentiveFetch();
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(6)),
//                       // REMOVED: pre-add "Amount" preview box. It used to
//                       // show a local quantity*rate approximation, which
//                       // could disagree with what the server actually
//                       // calculates (square feet, box/piece breakdown,
//                       // incentive rules). The server's own `amount` is now
//                       // only ever read after Add/Update Item succeeds —
//                       // see the Items list below, and _saveItemFromForm.
//
//                       if (_selectedProduct != null || _editingItemIndex != null) ...[
//                         SizedBox(height: Responsive.h(8)),
//                         const _IncentivePreviewCard(),
//                       ],
//
//                       SizedBox(height: Responsive.h(14)),
//
//                       if (_editingItemIndex != null) ...[
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: Responsive.w(12), vertical: Responsive.h(8)),
//                           margin: EdgeInsets.only(bottom: Responsive.h(10)),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.08),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
//                               SizedBox(width: Responsive.w(6)),
//                               Expanded(
//                                 child: Text(
//                                   'Editing item #${_editingItemIndex! + 1}',
//                                   style: AppTextStyles.caption(),
//                                 ),
//                               ),
//                               InkWell(
//                                 onTap: _cancelEditItem,
//                                 child: Text('Cancel',
//                                     style: AppTextStyles.bodyBold(color: AppColors.error)),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: _isAddingItem ? null : _saveItemFromForm,
//                           icon: _isAddingItem
//                               ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                           )
//                               : Icon(
//                             _editingItemIndex != null ? Icons.save_outlined : Icons.add,
//                             color: Colors.white,
//                           ),
//                           label: Text(
//                             _isAddingItem
//                                 ? 'Calculating…'
//                                 : (_editingItemIndex != null ? 'Update Item' : 'Add Item'),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(20)),
//
//                       Text('Items (${_items.length})', style: AppTextStyles.h3()),
//                       SizedBox(height: Responsive.h(10)),
//                       if (_items.isEmpty)
//                         Padding(
//                           padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
//                           child: Center(
//                             child: Text('No items added yet',
//                                 style: AppTextStyles.body(color: AppColors.textHint)),
//                           ),
//                         )
//                       else
//                         BlocBuilder<QuotationItemRemoveBloc, QuotationItemRemoveState>(
//                           buildWhen: (prev, curr) =>
//                           prev.status != curr.status || prev.removedItemId != curr.removedItemId,
//                           builder: (context, removeState) {
//                             final removingId = removeState.status == QuotationItemRemoveStatus.inProgress
//                                 ? removeState.removedItemId
//                                 : null;
//                             return Column(
//                               children: _items.asMap().entries.map((entry) {
//                                 final i = entry.key;
//                                 final item = entry.value;
//                                 return _EditItemTile(
//                                   serialNo: i + 1,
//                                   item: item,
//                                   currency: currency,
//                                   isEditing: _editingItemIndex == i,
//                                   isRemoving: item.id == removingId,
//                                   onEdit: () => _editItem(i),
//                                   onDelete: () => _removeItem(i),
//                                 );
//                               }).toList(),
//                             );
//                           },
//                         ),
//                       SizedBox(height: Responsive.h(20)),
//
//                       Text('Other Details', style: AppTextStyles.h3()),
//                       SizedBox(height: Responsive.h(12)),
//                       LabeledField(
//                         label: 'Handling Charge',
//                         field: CustomTextField(
//                           hint: 'Enter handling charge',
//                           icon: Icons.currency_rupee,
//                           keyboardType: TextInputType.number,
//                           controller: _handlingCharge,
//                           inputFormatters: DValidator.decimalNumber,
//                           validator: _validateHandlingCharge,
//                           onChanged: (_) => setState(() {}),
//                         ),
//                       ),
//                       LabeledField(
//                         label: 'Notes (optional)',
//                         field: CustomTextField(
//                           hint: 'e.g. Customer enquiry for new project',
//                           icon: Icons.notes_outlined,
//                           controller: _notes,
//                           inputFormatters: DValidator.textWithLimit,
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(10)),
//
//                       Container(
//                         padding: EdgeInsets.all(Responsive.w(14)),
//                         decoration: BoxDecoration(
//                           color: AppColors.surfaceAlt,
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Column(
//                           children: [
//                             // _totalRow('Total Items', '$_totalItemsCount'),
//                             // SizedBox(height: Responsive.h(6)),
//                             //  _totalRow('Total Qty', number.format(_totalQty)),
//                             SizedBox(height: Responsive.h(6)),
//                             _totalRow('Total Sq.Ft', number.format(_totalSqft)),
//                             if (_mrpTotal > 0) ...[
//                               SizedBox(height: Responsive.h(6)),
//                               _totalRow('Total MRP', currency.format(_mrpTotal)),
//                             ],
//                             SizedBox(height: Responsive.h(6)),
//                             _totalRow('Items Total', currency.format(_itemsTotal)),
//                             SizedBox(height: Responsive.h(6)),
//                             _totalRow('Handling Charge', currency.format(_handling)),
//                             const Divider(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('Grand Total', style: AppTextStyles.h3()),
//                                 Text(currency.format(_grandTotal),
//                                     style: AppTextStyles.h2(color: AppColors.primary)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(12)),
//
//                       if (_incentiveTotal > 0)
//                         Container(
//                           padding: EdgeInsets.all(Responsive.w(14)),
//                           decoration: BoxDecoration(
//                             color: AppColors.success.withOpacity(0.08),
//                             borderRadius: BorderRadius.circular(14),
//                             border: Border.all(color: AppColors.success.withOpacity(0.3)),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.percent, size: 18, color: AppColors.success),
//                                   SizedBox(width: Responsive.w(8)),
//                                   Text('Incentive Total',
//                                       style: AppTextStyles.bodyBold(color: AppColors.success)),
//                                 ],
//                               ),
//                               Text(currency.format(_incentiveTotal),
//                                   style: AppTextStyles.h3(color: AppColors.success)),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
//                 buildWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
//                 builder: (context, state) {
//                   final saving = state.submitStatus == QuotationActionStatus.inProgress;
//                   return Container(
//                     padding: EdgeInsets.fromLTRB(
//                         Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
//                     decoration: BoxDecoration(
//                       color: AppColors.background,
//                       border: Border(top: BorderSide(color: AppColors.border)),
//                     ),
//                     child: PrimaryButton(
//                       label: saving ? 'Saving…' : 'Save Changes',
//                       height: 48,
//                       onPressed: saving ? null : _submit,
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildProductDropdown() {
//     return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
//       buildWhen: (prev, curr) =>
//       prev.products != curr.products || prev.productsStatus != curr.productsStatus,
//       builder: (context, state) {
//         if (state.productsStatus == LoadStatus.loading && state.products.isEmpty) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(vertical: 12),
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (state.productsStatus == LoadStatus.failure && state.products.isEmpty) {
//           return Container(
//             padding: EdgeInsets.all(Responsive.w(12)),
//             decoration: BoxDecoration(
//               color: AppColors.error.withOpacity(0.06),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     state.productsError ?? 'Failed to load products.',
//                     style: AppTextStyles.caption(color: AppColors.error),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () =>
//                       context.read<SalesmanEstimateBloc>().add(const ActiveProductsRequested()),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final products = state.products;
//         final selected =
//         _selectedProduct != null && products.any((p) => p.id == _selectedProduct!.id)
//             ? _selectedProduct
//             : null;
//
//         return LabeledField(
//           label: 'Select Product',
//           field: DropdownButtonFormField<ActiveProductModel>(
//             value: selected,
//             isExpanded: true,
//             icon: const Icon(Icons.arrow_drop_down),
//             decoration: InputDecoration(
//               hintText: 'Choose a product',
//               prefixIcon: const Icon(Icons.inventory_2_outlined),
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
//             items: products
//                 .map((p) => DropdownMenuItem(
//               value: p,
//               child: Text('${p.name} — ${p.company}', overflow: TextOverflow.ellipsis),
//             ))
//                 .toList(),
//             onChanged: _onProductSelected,
//             validator: (v) => DValidator.validateDropdown('product', v),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _totalRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: AppTextStyles.body()),
//         Text(value, style: AppTextStyles.body()),
//       ],
//     );
//   }
// }
//
// // _IncentivePreviewCard and _EditItemTile are unchanged from your original file.
//
// /// Shows the live /quotations/product-incentive result for whatever is
// /// currently in the product/quantity/rate fields on the add-item form.
// class _IncentivePreviewCard extends StatelessWidget {
//   const _IncentivePreviewCard();
//
//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//
//     return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
//       buildWhen: (prev, curr) =>
//       prev.incentiveStatus != curr.incentiveStatus ||
//           prev.incentive != curr.incentive ||
//           prev.incentiveError != curr.incentiveError,
//       builder: (context, state) {
//         if (state.incentiveStatus == LoadStatus.initial) {
//           return const SizedBox.shrink();
//         }
//
//         if (state.incentiveStatus == LoadStatus.loading) {
//           return Container(
//             padding: EdgeInsets.all(Responsive.w(12)),
//             decoration: BoxDecoration(
//               color: AppColors.surfaceAlt,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(
//                   width: 14,
//                   height: 14,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//                 SizedBox(width: Responsive.w(10)),
//                 Text('Checking incentive…', style: AppTextStyles.caption()),
//               ],
//             ),
//           );
//         }
//
//         if (state.incentiveStatus == LoadStatus.failure) {
//           return Container(
//             padding: EdgeInsets.all(Responsive.w(12)),
//             decoration: BoxDecoration(
//               color: AppColors.error.withOpacity(0.06),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               state.incentiveError ?? 'Couldn\'t fetch incentive for this item.',
//               style: AppTextStyles.caption(color: AppColors.error),
//             ),
//           );
//         }
//
//         final incentive = state.incentive;
//         if (incentive == null) return const SizedBox.shrink();
//
//         if (!incentive.isEligible) {
//           return Container(
//             padding: EdgeInsets.all(Responsive.w(12)),
//             decoration: BoxDecoration(
//               color: AppColors.surfaceAlt,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
//                 SizedBox(width: Responsive.w(8)),
//                 Expanded(
//                   child: Text(
//                     incentive.eligibilityReason.isNotEmpty
//                         ? incentive.eligibilityReason
//                         : 'Not eligible for incentive on this quantity/rate.',
//                     style: AppTextStyles.caption(),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Container(
//           padding: EdgeInsets.all(Responsive.w(12)),
//           decoration: BoxDecoration(
//             color: AppColors.success.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: AppColors.success.withOpacity(0.3)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.percent, size: 16, color: AppColors.success),
//                       SizedBox(width: Responsive.w(6)),
//                       Text('Incentive on this item',
//                           style: AppTextStyles.bodyBold(color: AppColors.success)),
//                     ],
//                   ),
//                   Text(currency.format(incentive.totalIncentive),
//                       style: AppTextStyles.bodyBold(color: AppColors.success)),
//                 ],
//               ),
//               if (incentive.eligibilityReason.isNotEmpty) ...[
//                 SizedBox(height: Responsive.h(4)),
//                 Text(incentive.eligibilityReason, style: AppTextStyles.caption()),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _EditItemTile extends StatelessWidget {
//   const _EditItemTile({
//     required this.serialNo,
//     required this.item,
//     required this.currency,
//     required this.onEdit,
//     required this.onDelete,
//     this.isEditing = false,
//     this.isRemoving = false,
//   });
//
//   final int serialNo;
//   final _EditItem item;
//   final NumberFormat currency;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final bool isEditing;
//   final bool isRemoving;
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
//                   'Qty: ${item.quantity.toStringAsFixed(0)} ${item.unit}'
//                       '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
//                       '   Rate: ${item.rate.toStringAsFixed(0)}',
//                   style: AppTextStyles.caption(),
//                 ),
//                 if (item.incentiveEligible && item.incentiveAmount > 0) ...[
//                   SizedBox(height: Responsive.h(2)),
//                   Row(
//                     children: [
//                       Icon(Icons.percent, size: 12, color: AppColors.success),
//                       SizedBox(width: Responsive.w(3)),
//                       Text(
//                         'Incentive: ${currency.format(item.incentiveAmount)}',
//                         style: AppTextStyles.caption(color: AppColors.success),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(currency.format(item.amount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
//               SizedBox(height: Responsive.h(8)),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Edit pencil removed — existing items can only be
//                   // deleted here, not edited in place. To re-enable,
//                   // restore the InkWell(onTap: onEdit, ...) block that
//                   // used to sit here (see version history / previous copy
//                   // of this file).
//                   if (isRemoving)
//                     const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   else
//                     InkWell(
//                       onTap: onDelete,
//                       child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../widgets/custom_text_field.dart';
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
import '../../core/validator/validationfile.dart';
import '../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../models/salesmanmodels/quotationupdatemodel.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../../widgets/appsnackbar.dart';
// NOTE: adjust this path to match wherever QuotationProvider actually lives
// relative to this file — it mirrors CreateEstimateScreen's own import of
// the same provider, used the same way here: a fresh, one-shot call to
// POST /quotations/product-incentive fired the moment Add/Update Item is
// tapped, bypassing any cached/debounced bloc state.
import '../../Apiprovider/salesman_quotationprovider.dart';

/// CreateEstimateScreen uses.
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

/// Mirrors CreateEstimateScreen's AddedItem model and the reasoning behind
/// it: `amount` is always the server's own figure — from
/// POST /quotations/product-incentive when adding/editing an item here, or
/// straight from QuotationDetailItem.amount for items already saved on the
/// quotation — never recomputed locally as quantity * rate, since the
/// server may derive it from square feet or a box/piece breakdown instead
/// of a flat multiplication.
class _EditItem {
  const _EditItem({
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

  _EditItem copyWith({
    String? company,
    double? mrp,
  }) {
    return _EditItem(
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

class _QuotationEditView extends StatefulWidget {
  const _QuotationEditView({required this.estimate});
  final QuotationDetailModel estimate;

  @override
  State<_QuotationEditView> createState() => _QuotationEditViewState();
}

class _QuotationEditViewState extends State<_QuotationEditView> {
  // Form key for the customer/contractor/other-details section.
  final _formKey = GlobalKey<FormState>();

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


  // ---------------- Items ----------------
  late List<_EditItem> _items;
  int _newItemCounter = 0;
  int? _editingItemIndex;

  // ---------------- Add / edit item form ----------------
  final _itemFormKey = GlobalKey<FormState>();
  ActiveProductModel? _selectedProduct;
  final _itemCompanyCtrl = TextEditingController();
  final _itemSizeCtrl = TextEditingController();
  final _itemUnitCtrl = TextEditingController();
  final _itemMrpCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();

  // For box-unit products, Box Quantity is shown as its own visible field
  // that auto-updates whenever Quantity changes (kept in sync, not
  // editable independently). Piece Quantity is also shown as its own
  // visible field but is entered independently by the user.
  final _itemBoxQtyCtrl = TextEditingController();
  final _itemPieceQtyCtrl = TextEditingController();

  Timer? _incentiveDebounce;
  static const _incentiveDebounceDuration = Duration(milliseconds: 450);

  bool _backfilledFromCatalog = false;

  // Used ONLY for the Add/Update Item call — a fresh, one-shot request
  // fired straight from QuotationProvider (bypassing the bloc's cached
  // state entirely), so the item that gets added/updated always matches
  // exactly what's on screen at the moment the button is tapped. Same
  // approach as CreateEstimateScreen's _addItemToList.
  final QuotationProvider _quotationProvider = QuotationProvider();
  bool _isAddingItem = false;

  // Holds the item built from the /quotations/product-incentive response
  // while a PUT /quotations/update-item call for that same item is in
  // flight (existing, already-saved items only — see _saveItemFromForm).
  // Applied to _items only once the bloc reports itemUpdateStatus success;
  // discarded on failure so the on-screen list never shows a change the
  // server didn't actually accept.
  _EditItem? _pendingItemUpdate;

  /// Whether the current add/edit-item form should be treated as a
  /// box-unit product (and therefore show the Box Quantity / Piece
  /// Quantity fields).
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

  @override
  void initState() {
    super.initState();
    final e = widget.estimate;

    debugPrint('EDIT SCREEN OPENED: contractor=${e.contractor.name}');

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
      // Real backend item id — needed to call POST /quotations/remove-item
      // and PUT /quotations/update-item. Newly-added items (added on this
      // screen, never saved) instead get an id prefixed 'new_' — see
      // _saveItemFromForm.
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

  // ---------------- Derived totals ----------------

  double get _itemsTotal => _items.fold(0.0, (s, i) => s + i.amount);
  double get _handling => double.tryParse(_handlingCharge.text.trim()) ?? 0;
  double get _grandTotal => _itemsTotal + _handling;
  double get _incentiveTotal => _items.fold(0.0, (s, i) => s + i.incentiveAmount);

  int get _totalItemsCount => _items.length;
  double get _totalQty => _items.fold(0.0, (s, i) => s + i.quantity);

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

  /// Items added on this screen and not yet saved to the server carry an
  /// id prefixed 'new_' (see _saveItemFromForm). Anything else is a real
  /// backend item id — deleting it goes through POST /quotations/remove-item
  /// and editing it goes through PUT /quotations/update-item, both of which
  /// hit the server immediately rather than only updating local state.
  bool _isUnsavedItem(_EditItem item) => item.id.startsWith('new_');

  void _showError(String msg) {
    AppSnackbar.error(msg);
  }

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

  // ---------------- Field-level validators (DValidator) ----------------

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
      DValidator.validateOptionalNumber('Handling charge', v);

  // ---------------- Add-item form wiring ----------------

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

  /// Fires a FRESH, one-shot POST /quotations/product-incentive with
  /// exactly what's on the form right now, waits for the real response,
  /// and builds/updates the item using ONLY that response's amount/
  /// incentive fields.
  ///
  /// For an item that's already saved on the server (a real backend id,
  /// not one of this screen's own 'new_' ids), the resulting
  /// quantity/rate/box/piece are ALSO persisted right away via PUT
  /// /quotations/update-item (see QuotationItemUpdateSubmitted below) —
  /// the item is only applied to [_items] once that call succeeds, so the
  /// on-screen list never shows a change the server rejected. A brand-new
  /// (never-saved) item has nothing to persist yet and is simply added to
  /// local state, same as before — it's saved for the first time only
  /// when "Save Changes" submits the whole quotation.
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

    final newItem = _EditItem(
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
      // Existing, already-saved item — persist the change immediately via
      // PUT /quotations/update-item. _isAddingItem stays true (button
      // keeps its spinner) until the itemUpdateStatus BlocListener below
      // reports success or failure; only on success is [newItem] applied
      // to [_items] and the form reset.
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

    // Brand-new item (or one added earlier on this screen and not yet
    // saved) — nothing to persist yet, keep it purely local as before.
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
      _itemCompanyCtrl.text = match?.company ?? item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemMrpCtrl.text = _formatPrice(match?.mrp ?? item.mrp);
      _itemQtyCtrl.text = _formatPrice(item.quantity);
      _itemRateCtrl.text = _formatPrice(item.rate);
      _itemBoxQtyCtrl.text = _formatPrice(item.boxQuantity);
      _itemPieceQtyCtrl.text = _formatPrice(item.pieceQuantity);
    });

    context.read<SalesmanEstimateBloc>().add(const ProductIncentiveCleared());
    if (match != null) _scheduleIncentiveFetch();
  }

  void _cancelEditItem() => _resetItemForm();

  void _removeItem(int index) {
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

    context.read<QuotationItemRemoveBloc>().add(QuotationItemRemoveRequested(
      quotationId: widget.estimate.id,
      quotationItemId: item.id,
    ));
  }

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
  /// to [_items] and resets the add/edit-item form, mirroring what the
  /// brand-new-item branch of _saveItemFromForm does synchronously.
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

    context.read<SalesmanQuotationBloc>().add(QuotationUpdateSubmitted(request));
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
            // Reacts to PUT /quotations/update-item, fired from
            // _saveItemFromForm whenever "Update Item" is tapped on an
            // item that's already saved on the server. Only on success is
            // the locally-built item (held in _pendingItemUpdate) actually
            // applied to _items — a failure leaves the list untouched and
            // the form open so the salesman can retry or cancel.
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
                    padding: EdgeInsets.all(Responsive.w(18)),
                    children: [
                      Text('Customer Details', style: AppTextStyles.h3()),
                      SizedBox(height: Responsive.h(12)),
                      LabeledField(
                        label: 'Party Name',
                        field: IgnorePointer(
                          child: CustomTextField(
                            hint: 'Enter party name',
                            icon: Icons.groups_2_outlined,
                            controller: _customerName,
                            validator: _validatePartyName,
                          ),
                        ),
                      ),
                      LabeledField(
                        label: 'Contact No.',
                        field: IgnorePointer(
                          child: CustomTextField(
                            hint: 'Enter phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            controller: _customerPhone,
                            validator: _validateCustomerPhone,
                          ),
                        ),
                      ),
                      LabeledField(
                        label: 'Address',
                        field: IgnorePointer(
                          child: CustomTextField(
                            hint: 'Enter site address',
                            icon: Icons.location_on_outlined,
                            controller: _customerAddress,
                            validator: _validateCustomerAddress,
                          ),
                        ),
                      ),
                      LabeledField(
                        label: 'Email',
                        field: IgnorePointer(
                          child: CustomTextField(
                            hint: 'Enter customer email',
                            icon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            controller: _customerEmail,
                            validator: _validateOptionalEmail,
                          ),
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
                          inputFormatters: DValidator.lettersOnly,
                          validator: (v) => _validateOptionalName('Contractor name', v),
                          onChanged: (_) => _formKey.currentState?.validate(),
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
                          onChanged: (_) => _formKey.currentState?.validate(),
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
                      LabeledField(
                        label: 'Address (optional)',
                        field: CustomTextField(
                          hint: 'Enter contractor address',
                          icon: Icons.location_on_outlined,
                          controller: _contractorAddress,
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
                              label: 'Quantity',
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
                                onChanged: (_) {
                                  setState(() {});
                                  _scheduleIncentiveFetch();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(6)),

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
                                return _EditItemTile(
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
                          inputFormatters: DValidator.decimalNumber,
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
    ));
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
            validator: (v) => DValidator.validateDropdown('product', v),
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
    this.isRemoving = false,
  });

  final int serialNo;
  final _EditItem item;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEditing;
  final bool isRemoving;

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
                  // Edit tap goes through onEdit — reopens an already-saved
                  // item into the add/edit form, where "Update Item" now
                  // persists it immediately via PUT /quotations/update-item
                  // (see _saveItemFromForm / QuotationItemUpdateSubmitted).
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