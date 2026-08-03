//
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../../../core/widgets/custom_text_field.dart';
// import '../../../../core/widgets/primary_button.dart';
// import '../../../../models/estimate_model.dart';
// import '../../salesman/estimates/cubit/estimates_cubit.dart';
//
//
// class _ProductCatalogItem {
//   final String id;
//   final String name;
//   final String company;
//   final String size;
//   final String unit;
//   final double mrp;
//   final double rate;
//   final double incentivePercent;
//
//   const _ProductCatalogItem({
//     required this.id,
//     required this.name,
//     required this.company,
//     required this.size,
//     required this.unit,
//     required this.mrp,
//     required this.rate,
//     required this.incentivePercent,
//   });
// }
//
// const List<_ProductCatalogItem> _productCatalog = [
//   _ProductCatalogItem(
//     id: 'p1',
//     name: 'Vitrified Tile 600x600',
//     company: 'Kajaria',
//     size: '600x600',
//     unit: 'box',
//     mrp: 65,
//     rate: 55,
//     incentivePercent: 5,
//   ),
//   _ProductCatalogItem(
//     id: 'p2',
//     name: 'Wall Tile 300x450',
//     company: 'Somany',
//     size: '300x450',
//     unit: 'box',
//     mrp: 48,
//     rate: 40,
//     incentivePercent: 4,
//   ),
//   _ProductCatalogItem(
//     id: 'p3',
//     name: 'PVC Pipe 4"',
//     company: 'Supreme',
//     size: '4"',
//     unit: 'piece',
//     mrp: 320,
//     rate: 280,
//     incentivePercent: 3,
//   ),
// ];
//
// /// One added item in the estimate. Plain data (not controllers) since items
// /// are added one at a time via a form, then shown as a read-only list.
// class _AddedItem {
//   final String id;
//   final String productId;
//   final String name;
//   final String company;
//   final String size;
//   final String unit;
//   final double quantity;
//   final double mrp;
//   final double rate;
//
//   /// Real incentive % pulled from the selected product in the catalog at
//   /// the time this item was added.
//   final double incentivePercent;
//
//   const _AddedItem({
//     required this.id,
//     required this.productId,
//     required this.name,
//     required this.company,
//     required this.size,
//     required this.unit,
//     required this.quantity,
//     required this.mrp,
//     required this.rate,
//     required this.incentivePercent,
//   });
//
//   double get amount => quantity * rate;
//   double get mrpValue => quantity * mrp;
//   double get incentiveAmount => amount * incentivePercent / 100;
//
//   EstimateItem toItem() => EstimateItem(
//     id: id,
//     name: name,
//     company: company,
//     size: size,
//     unit: unit,
//     quantity: quantity,
//     mrp: mrp,
//     rate: rate,
//   );
// }
//
// enum _Step { details, addItems, preview }
//
// /// Owner-side estimate creation. Functionally identical to the salesman
// /// flow (details -> add items -> preview) except:
// ///  - the final action creates the estimate directly as an approved bill,
// ///    since the owner IS the approver and doesn't need to route it through
// ///    a pending-approval queue.
// ///  - the "Salesman" section is relabeled "Owner".
// ///  - items are picked from a product dropdown (like the salesman flow),
// ///    so company/size/unit/MRP/rate auto-fill and the incentive % used is
// ///    the real per-product value instead of a hardcoded dummy.
// ///  - the final "Approved" button shows a confirmation dialog first,
// ///    where the owner types their name before the estimate is created.
// class OwnerCreateEstimateScreen extends StatefulWidget {
//   const OwnerCreateEstimateScreen({super.key});
//
//   @override
//   State<OwnerCreateEstimateScreen> createState() => _OwnerCreateEstimateScreenState();
// }
//
// class _OwnerCreateEstimateScreenState extends State<OwnerCreateEstimateScreen> {
//   _Step _step = _Step.details;
//
//   // --- Step 1: Party / Contractor / Owner ---
//   final _partyNameCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _contractorNameCtrl = TextEditingController();
//   final _contractorPhoneCtrl = TextEditingController();
//   final _salesmanCtrl = TextEditingController();
//   final _salesmanMobCtrl = TextEditingController();
//   final _handlingChargeCtrl = TextEditingController(text: '0');
//
//   // Name typed into the "Approve Estimate" confirmation dialog.
//   final _approverNameCtrl = TextEditingController();
//
//   DateTime _date = DateTime.now();
//   late final String _estimateNo;
//
//   // --- Step 2: Items ---
//   final _itemNameCtrl = TextEditingController();
//   final _itemCompanyCtrl = TextEditingController();
//   final _itemSizeCtrl = TextEditingController();
//   final _itemUnitCtrl = TextEditingController(text: 'sqft');
//   final _itemQtyCtrl = TextEditingController();
//   final _itemMrpCtrl = TextEditingController();
//   final _itemRateCtrl = TextEditingController();
//
//   // Currently selected product from the dropdown. Drives
//   // company/size/unit/MRP/rate auto-fill and the real incentive % used
//   // when the item is added.
//   _ProductCatalogItem? _selectedProduct;
//
//   final List<_AddedItem> _items = [];
//   int _itemCounter = 0;
//   int? _editingItemIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _estimateNo = context.read<EstimatesCubit>().nextEstimateNumber();
//   }
//
//   @override
//   void dispose() {
//     _partyNameCtrl.dispose();
//     _addressCtrl.dispose();
//     _phoneCtrl.dispose();
//     _contractorNameCtrl.dispose();
//     _contractorPhoneCtrl.dispose();
//     _salesmanCtrl.dispose();
//     _salesmanMobCtrl.dispose();
//     _handlingChargeCtrl.dispose();
//     _approverNameCtrl.dispose();
//     _itemNameCtrl.dispose();
//     _itemCompanyCtrl.dispose();
//     _itemSizeCtrl.dispose();
//     _itemUnitCtrl.dispose();
//     _itemQtyCtrl.dispose();
//     _itemMrpCtrl.dispose();
//     _itemRateCtrl.dispose();
//     super.dispose();
//   }
//
//   // ---------------- Derived totals ----------------
//
//   double get _mrpTotal => _items.fold(0.0, (s, r) => s + r.mrpValue);
//   double get _itemsTotal => _items.fold(0.0, (s, r) => s + r.amount);
//   double get _handlingCharge => double.tryParse(_handlingChargeCtrl.text) ?? 0;
//   double get _grandTotal => _itemsTotal + _handlingCharge;
//   double get _totalQty => _items.fold(0.0, (s, r) => s + r.quantity);
//   int get _totalItems => _items.length;
//
//   // Sum of all items' incentive amounts (internal-facing only, not part of
//   // the customer's grand total).
//   double get _incentiveTotal => _items.fold(0.0, (s, r) => s + r.incentiveAmount);
//
//   double get _currentItemAmount {
//     final qty = double.tryParse(_itemQtyCtrl.text) ?? 0;
//     final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
//     return qty * rate;
//   }
//
//   // Incentive preview for the item currently being entered, using the real
//   // % from whichever product is selected in the dropdown.
//   double get _currentItemIncentive {
//     final percent = _selectedProduct?.incentivePercent ?? 0;
//     return _currentItemAmount * percent / 100;
//   }
//
//   // ---------------- Validation ----------------
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
//   }
//
//   bool _validateDetails() {
//     if (_partyNameCtrl.text.trim().isEmpty) {
//       _showError('Please enter the party name');
//       return false;
//     }
//     return true;
//   }
//
//   bool _validateCurrentItemFields() {
//     if (_selectedProduct == null) {
//       _showError('Please select a product');
//       return false;
//     }
//     if ((double.tryParse(_itemQtyCtrl.text) ?? 0) <= 0) {
//       _showError('Please enter a valid quantity');
//       return false;
//     }
//     return true;
//   }
//
//   // ---------------- Actions ----------------
//
//   void _goToAddItems() {
//     if (!_validateDetails()) return;
//     setState(() => _step = _Step.addItems);
//   }
//
//   void _onProductSelected(_ProductCatalogItem? product) {
//     setState(() {
//       _selectedProduct = product;
//       if (product != null) {
//         _itemNameCtrl.text = product.name;
//         _itemCompanyCtrl.text = product.company;
//         _itemSizeCtrl.text = product.size;
//         _itemUnitCtrl.text = product.unit;
//         _itemMrpCtrl.text = product.mrp == product.mrp.roundToDouble()
//             ? product.mrp.toStringAsFixed(0)
//             : product.mrp.toString();
//         _itemRateCtrl.text = product.rate == product.rate.roundToDouble()
//             ? product.rate.toStringAsFixed(0)
//             : product.rate.toString();
//       } else {
//         _itemNameCtrl.clear();
//         _itemCompanyCtrl.clear();
//         _itemSizeCtrl.clear();
//         _itemUnitCtrl.text = 'sqft';
//         _itemMrpCtrl.clear();
//         _itemRateCtrl.clear();
//       }
//     });
//   }
//
//   void _addItemToList() {
//     if (!_validateCurrentItemFields()) return;
//     final product = _selectedProduct!;
//     setState(() {
//       final editingIndex = _editingItemIndex;
//       if (editingIndex != null) {
//         // Update the existing item in place, keeping its original id.
//         final existing = _items[editingIndex];
//         _items[editingIndex] = _AddedItem(
//           id: existing.id,
//           productId: product.id,
//           name: product.name,
//           company: product.company,
//           size: _itemSizeCtrl.text.trim(),
//           unit: _itemUnitCtrl.text.trim().isEmpty ? 'sqft' : _itemUnitCtrl.text.trim(),
//           quantity: double.tryParse(_itemQtyCtrl.text) ?? 0,
//           mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
//           rate: double.tryParse(_itemRateCtrl.text) ?? 0,
//           incentivePercent: product.incentivePercent,
//         );
//         _editingItemIndex = null;
//       } else {
//         _items.add(_AddedItem(
//           id: 'item_${_itemCounter++}',
//           productId: product.id,
//           name: product.name,
//           company: product.company,
//           size: _itemSizeCtrl.text.trim(),
//           unit: _itemUnitCtrl.text.trim().isEmpty ? 'sqft' : _itemUnitCtrl.text.trim(),
//           quantity: double.tryParse(_itemQtyCtrl.text) ?? 0,
//           mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
//           rate: double.tryParse(_itemRateCtrl.text) ?? 0,
//           incentivePercent: product.incentivePercent,
//         ));
//       }
//       _selectedProduct = null;
//       _itemNameCtrl.clear();
//       _itemCompanyCtrl.clear();
//       _itemSizeCtrl.clear();
//       _itemUnitCtrl.text = 'sqft';
//       _itemQtyCtrl.clear();
//       _itemMrpCtrl.clear();
//       _itemRateCtrl.clear();
//     });
//   }
//
//   void _editItem(int index) {
//     final item = _items[index];
//     setState(() {
//       _editingItemIndex = index;
//       // Re-select the matching catalog product so the dropdown reflects
//       // what's being edited (falls back to null if it was ever removed
//       // from the catalog).
//       _selectedProduct = _productCatalog
//           .cast<_ProductCatalogItem?>()
//           .firstWhere((p) => p?.id == item.productId, orElse: () => null);
//       _itemNameCtrl.text = item.name;
//       _itemCompanyCtrl.text = item.company;
//       _itemSizeCtrl.text = item.size;
//       _itemUnitCtrl.text = item.unit;
//       _itemQtyCtrl.text = item.quantity == item.quantity.roundToDouble()
//           ? item.quantity.toStringAsFixed(0)
//           : item.quantity.toString();
//       _itemMrpCtrl.text = item.mrp == item.mrp.roundToDouble()
//           ? item.mrp.toStringAsFixed(0)
//           : item.mrp.toString();
//       _itemRateCtrl.text = item.rate == item.rate.roundToDouble()
//           ? item.rate.toStringAsFixed(0)
//           : item.rate.toString();
//     });
//   }
//
//   void _cancelEditItem() {
//     setState(() {
//       _editingItemIndex = null;
//       _selectedProduct = null;
//       _itemNameCtrl.clear();
//       _itemCompanyCtrl.clear();
//       _itemSizeCtrl.clear();
//       _itemUnitCtrl.text = 'sqft';
//       _itemQtyCtrl.clear();
//       _itemMrpCtrl.clear();
//       _itemRateCtrl.clear();
//     });
//   }
//
//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//       // If the removed item was mid-edit (or was before the one being
//       // edited), clear/adjust the editing state so indices stay valid.
//       if (_editingItemIndex != null) {
//         if (_editingItemIndex == index) {
//           _editingItemIndex = null;
//           _selectedProduct = null;
//           _itemNameCtrl.clear();
//           _itemCompanyCtrl.clear();
//           _itemSizeCtrl.clear();
//           _itemUnitCtrl.text = 'sqft';
//           _itemQtyCtrl.clear();
//           _itemMrpCtrl.clear();
//           _itemRateCtrl.clear();
//         } else if (_editingItemIndex! > index) {
//           _editingItemIndex = _editingItemIndex! - 1;
//         }
//       }
//     });
//   }
//
//   void _goToPreview() {
//     if (_items.isEmpty) {
//       _showError('Please add at least one item');
//       return;
//     }
//     setState(() => _step = _Step.preview);
//   }
//
//   EstimateModel _buildEstimate({required EstimateBillType billType}) {
//     return EstimateModel(
//       id: _estimateNo,
//       contractorName: _contractorNameCtrl.text.trim().isEmpty
//           ? _partyNameCtrl.text.trim()
//           : _contractorNameCtrl.text.trim(),
//       siteAddress: _addressCtrl.text.trim().isEmpty ? 'Not specified' : _addressCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       salesmanName: _salesmanCtrl.text.trim().isEmpty ? 'Owner' : _salesmanCtrl.text.trim(),
//       salesmanMobile: _salesmanMobCtrl.text.trim(),
//       date: _date,
//       handlingCharge: _handlingCharge,
//       billType: billType,
//       // Owner-created bills are approved immediately — no pending-approval
//       // queue since the owner IS the approver. Quotations still save as
//       // drafts, same as the salesman flow.
//       status: billType == EstimateBillType.billed ? 'Approved' : 'Draft',
//       items: _items.map((r) => r.toItem()).toList(),
//     );
//   }
//
//   void _saveDraft() {
//     final estimate = _buildEstimate(billType: EstimateBillType.quotation);
//     context.read<EstimatesCubit>().addEstimate(estimate);
//     Navigator.of(context).pop();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Saved as Quotation')),
//     );
//   }
//
//   void _createEstimate() {
//     final estimate = _buildEstimate(billType: EstimateBillType.billed);
//     context.read<EstimatesCubit>().addEstimate(estimate);
//     Navigator.of(context).pop();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Estimate created and approved')),
//     );
//   }
//
//   /// Shows a confirmation dialog before finalizing the estimate. The owner
//   /// must type their name in the dialog; that name is used as the "Owner"
//   /// name on the estimate (overwriting whatever was on the Details step,
//   /// since this is who is actually approving it right now). Only after
//   /// confirming does `_createEstimate()` run.
//   Future<void> _showApproveDialog() async {
//     _approverNameCtrl.clear();
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (dialogContext, setDialogState) {
//             return AlertDialog(
//               title: const Text('Approve Estimate'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Are you sure you want to approve this estimate?'),
//                   SizedBox(height: Responsive.h(16)),
//
//             ]),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(dialogContext).pop(false),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_approverNameCtrl.text.trim().isEmpty) {
//                       ScaffoldMessenger.of(dialogContext).showSnackBar(
//                         const SnackBar(content: Text('Please enter your name')),
//                       );
//                       return;
//                     }
//                     Navigator.of(dialogContext).pop(true);
//                   },
//                   child: const Text('Approve'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//
//     if (confirmed == true) {
//       // Use the name entered in the dialog as the Owner name on the estimate.
//       setState(() {
//         _salesmanCtrl.text = _approverNameCtrl.text.trim();
//       });
//       _createEstimate();
//     }
//   }
//
//   // ---------------- Back handling between steps ----------------
//
//   bool _onWillPop() {
//     if (_step == _Step.preview) {
//       setState(() => _step = _Step.addItems);
//       return false;
//     }
//     if (_step == _Step.addItems) {
//       setState(() => _step = _Step.details);
//       return false;
//     }
//     return true;
//   }
//
//   String get _appBarTitle {
//     switch (_step) {
//       case _Step.details:
//         return 'Create Estimate';
//       case _Step.addItems:
//         return 'Add Items';
//       case _Step.preview:
//         return 'Estimate Preview';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return PopScope(
//       canPop: _step == _Step.details,
//       onPopInvoked: (didPop) {
//         if (didPop) return;
//         _onWillPop();
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: Text(_appBarTitle),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               if (_step == _Step.details) {
//                 Navigator.of(context).pop();
//               } else {
//                 _onWillPop();
//               }
//             },
//           ),
//         ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               _StepIndicator(step: _step),
//               Expanded(
//                 child: switch (_step) {
//                   _Step.details => _DetailsStep(
//                     estimateNo: _estimateNo,
//                     date: _date,
//                     onDateChanged: (d) => setState(() => _date = d),
//                     partyNameCtrl: _partyNameCtrl,
//                     addressCtrl: _addressCtrl,
//                     phoneCtrl: _phoneCtrl,
//                     contractorNameCtrl: _contractorNameCtrl,
//                     contractorPhoneCtrl: _contractorPhoneCtrl,
//                     salesmanCtrl: _salesmanCtrl,
//                     salesmanMobCtrl: _salesmanMobCtrl,
//                     onSaveDraft: () {
//                       if (!_validateDetails()) return;
//                       _saveDraft();
//                     },
//                     onNext: _goToAddItems,
//                   ),
//                   _Step.addItems => _AddItemsStep(
//                     catalog: _productCatalog,
//                     selectedProduct: _selectedProduct,
//                     onProductSelected: _onProductSelected,
//                     itemNameCtrl: _itemNameCtrl,
//                     itemCompanyCtrl: _itemCompanyCtrl,
//                     itemSizeCtrl: _itemSizeCtrl,
//                     itemUnitCtrl: _itemUnitCtrl,
//                     itemQtyCtrl: _itemQtyCtrl,
//                     itemMrpCtrl: _itemMrpCtrl,
//                     itemRateCtrl: _itemRateCtrl,
//                     currentAmount: _currentItemAmount,
//                     currentIncentive: _currentItemIncentive,
//                     items: _items,
//                     editingIndex: _editingItemIndex,
//                     onAddItem: _addItemToList,
//                     onEditItem: _editItem,
//                     onCancelEdit: _cancelEditItem,
//                     onRemoveItem: _removeItem,
//                     onCancel: () => setState(() => _step = _Step.details),
//                     onSaveItems: _goToPreview,
//                   ),
//                   _Step.preview => _PreviewStep(
//                     estimateNo: _estimateNo,
//                     date: _date,
//                     partyName: _partyNameCtrl.text,
//                     address: _addressCtrl.text,
//                     phone: _phoneCtrl.text,
//                     contractorName: _contractorNameCtrl.text,
//                     contractorPhone: _contractorPhoneCtrl.text,
//                     salesmanName: _salesmanCtrl.text,
//                     salesmanMobile: _salesmanMobCtrl.text,
//                     items: _items,
//                     mrpTotal: _mrpTotal,
//                     itemsTotal: _itemsTotal,
//                     handlingChargeCtrl: _handlingChargeCtrl,
//                     grandTotal: _grandTotal,
//                     totalQty: _totalQty,
//                     totalItems: _totalItems,
//                     onHandlingChargeChanged: () => setState(() {}),
//                     onSaveDraft: _saveDraft,
//                     // Route through the confirmation dialog instead of
//                     // creating the estimate directly.
//                     onCreateEstimate: _showApproveDialog,
//                   ),
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // =====================================================================
// // STEP INDICATOR
// // =====================================================================
//
// class _StepIndicator extends StatelessWidget {
//   const _StepIndicator({required this.step});
//   final _Step step;
//
//   @override
//   Widget build(BuildContext context) {
//     final index = _Step.values.indexOf(step);
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.w(18), vertical: Responsive.h(10)),
//       child: Row(
//         children: List.generate(_Step.values.length * 2 - 1, (i) {
//           if (i.isOdd) {
//             final segmentDone = (i ~/ 2) < index;
//             return Expanded(
//               child: Container(
//                 height: 3,
//                 margin: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
//                 color: segmentDone ? AppColors.primary : AppColors.border,
//               ),
//             );
//           }
//           final dotIndex = i ~/ 2;
//           final active = dotIndex == index;
//           final done = dotIndex < index;
//           return CircleAvatar(
//             radius: 13,
//             backgroundColor: (active || done) ? AppColors.primary : AppColors.border,
//             child: done
//                 ? const Icon(Icons.check, size: 14, color: Colors.white)
//                 : Text(
//               '${dotIndex + 1}',
//               style: TextStyle(
//                 color: active ? Colors.white : AppColors.textHint,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// // =====================================================================
// // STEP 1 — DETAILS
// // =====================================================================
//
// class _DetailsStep extends StatelessWidget {
//   const _DetailsStep({
//     required this.estimateNo,
//     required this.date,
//     required this.onDateChanged,
//     required this.partyNameCtrl,
//     required this.addressCtrl,
//     required this.phoneCtrl,
//     required this.contractorNameCtrl,
//     required this.contractorPhoneCtrl,
//     required this.salesmanCtrl,
//     required this.salesmanMobCtrl,
//     required this.onSaveDraft,
//     required this.onNext,
//   });
//
//   final String estimateNo;
//   final DateTime date;
//   final ValueChanged<DateTime> onDateChanged;
//   final TextEditingController partyNameCtrl;
//   final TextEditingController addressCtrl;
//   final TextEditingController phoneCtrl;
//   final TextEditingController contractorNameCtrl;
//   final TextEditingController contractorPhoneCtrl;
//   final TextEditingController salesmanCtrl;
//   final TextEditingController salesmanMobCtrl;
//   final VoidCallback onSaveDraft;
//   final VoidCallback onNext;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView(
//             padding: EdgeInsets.all(Responsive.w(18)),
//             children: [
//               Container(
//                 padding: EdgeInsets.all(Responsive.w(14)),
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceAlt,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Estimate No.', style: AppTextStyles.caption()),
//                         Text(estimateNo, style: AppTextStyles.h3()),
//                       ],
//                     ),
//                     InkWell(
//                       onTap: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: date,
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime(2030),
//                         );
//                         if (picked != null) onDateChanged(picked);
//                       },
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text('Date', style: AppTextStyles.caption()),
//                           Row(
//                             children: [
//                               Text(DateFormat('dd-MM-yyyy').format(date), style: AppTextStyles.h3()),
//                               const SizedBox(width: 4),
//                               const Icon(Icons.calendar_today_outlined, size: 16),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: Responsive.h(20)),
//
//               Text('Customer Details', style: AppTextStyles.h3()),
//               SizedBox(height: Responsive.h(12)),
//               LabeledField(
//                 label: 'Party Name',
//                 field: CustomTextField(hint: 'Enter party name', icon: Icons.groups_2_outlined, controller: partyNameCtrl),
//               ),
//               LabeledField(
//                 label: 'Address',
//                 field: CustomTextField(hint: 'Enter site address', icon: Icons.location_on_outlined, controller: addressCtrl),
//               ),
//               LabeledField(
//                 label: 'Contact No.',
//                 field: CustomTextField(
//                   hint: 'Enter phone number',
//                   icon: Icons.phone_outlined,
//                   keyboardType: TextInputType.phone,
//                   controller: phoneCtrl,
//                 ),
//               ),
//               SizedBox(height: Responsive.h(16)),
//
//               Text('Contractor Details', style: AppTextStyles.h3()),
//               SizedBox(height: Responsive.h(12)),
//               LabeledField(
//                 label: 'Contractor Name',
//                 field: CustomTextField(hint: 'Enter contractor name', icon: Icons.engineering_outlined, controller: contractorNameCtrl),
//               ),
//               LabeledField(
//                 label: 'Contact No.',
//                 field: CustomTextField(
//                   hint: 'Enter contractor phone',
//                   icon: Icons.phone_outlined,
//                   keyboardType: TextInputType.phone,
//                   controller: contractorPhoneCtrl,
//                 ),
//               ),
//               SizedBox(height: Responsive.h(16)),
//
//               Text('Owner', style: AppTextStyles.h3()),
//               SizedBox(height: Responsive.h(12)),
//               LabeledField(
//                 label: 'Name',
//                 field: CustomTextField(hint: 'Owner name', icon: Icons.badge_outlined, controller: salesmanCtrl),
//               ),
//               SizedBox(height: Responsive.h(12)),
//             ],
//           ),
//         ),
//         _BottomActionBar(
//           right: PrimaryButton(label: 'Add Items', height: 48, onPressed: onNext),
//         ),
//       ],
//     );
//   }
// }
//
// // =====================================================================
// // STEP 2 — ADD ITEMS
// // =====================================================================
//
// class _AddItemsStep extends StatelessWidget {
//   const _AddItemsStep({
//     required this.catalog,
//     required this.selectedProduct,
//     required this.onProductSelected,
//     required this.itemNameCtrl,
//     required this.itemCompanyCtrl,
//     required this.itemSizeCtrl,
//     required this.itemUnitCtrl,
//     required this.itemQtyCtrl,
//     required this.itemMrpCtrl,
//     required this.itemRateCtrl,
//     required this.currentAmount,
//     required this.currentIncentive,
//     required this.items,
//     required this.editingIndex,
//     required this.onAddItem,
//     required this.onEditItem,
//     required this.onCancelEdit,
//     required this.onRemoveItem,
//     required this.onCancel,
//     required this.onSaveItems,
//   });
//
//   final List<_ProductCatalogItem> catalog;
//   final _ProductCatalogItem? selectedProduct;
//   final ValueChanged<_ProductCatalogItem?> onProductSelected;
//   final TextEditingController itemNameCtrl;
//   final TextEditingController itemCompanyCtrl;
//   final TextEditingController itemSizeCtrl;
//   final TextEditingController itemUnitCtrl;
//   final TextEditingController itemQtyCtrl;
//   final TextEditingController itemMrpCtrl;
//   final TextEditingController itemRateCtrl;
//   final double currentAmount;
//   final double currentIncentive;
//   final List<_AddedItem> items;
//   final int? editingIndex;
//   final VoidCallback onAddItem;
//   final void Function(int) onEditItem;
//   final VoidCallback onCancelEdit;
//   final void Function(int) onRemoveItem;
//   final VoidCallback onCancel;
//   final VoidCallback onSaveItems;
//
//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//
//     return StatefulBuilder(
//       builder: (context, setLocalState) {
//         return Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.all(Responsive.w(18)),
//                 children: [
//                   LabeledField(
//                     label: 'Select Product',
//                     field: DropdownButtonFormField<_ProductCatalogItem>(
//                       value: selectedProduct,
//                       isExpanded: true,
//                       icon: const Icon(Icons.arrow_drop_down),
//                       decoration: InputDecoration(
//                         hintText: 'Choose a product',
//                         prefixIcon: const Icon(Icons.inventory_2_outlined),
//                         filled: true,
//                         fillColor: AppColors.surface,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.border),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.border),
//                         ),
//                       ),
//                       items: catalog
//                           .map((p) => DropdownMenuItem(
//                         value: p,
//                         child: Text(
//                           '${p.name} — ${p.company}',
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ))
//                           .toList(),
//                       onChanged: (p) {
//                         onProductSelected(p);
//                         setLocalState(() {});
//                       },
//                     ),
//                   ),
//
//                   SizedBox(height: Responsive.h(10)),
//                   LabeledField(
//                     label: 'Company (auto)',
//                     field: IgnorePointer(
//                       child: CustomTextField(
//                         hint: 'Select a product first',
//                         icon: Icons.factory_outlined,
//                         controller: itemCompanyCtrl,
//                       ),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: LabeledField(
//                           label: 'Size (auto)',
//                           field: CustomTextField(
//                             hint: 'e.g. 600x1200',
//                             icon: Icons.straighten_outlined,
//                             controller: itemSizeCtrl,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: Responsive.w(10)),
//                       Expanded(
//                         child: LabeledField(
//                           label: 'Unit (auto)',
//                           field: CustomTextField(
//                             hint: 'sqft',
//                             icon: Icons.square_foot_outlined,
//                             controller: itemUnitCtrl,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   LabeledField(
//                     label: 'Quantity',
//                     field: CustomTextField(
//                       hint: 'Enter quantity',
//                       icon: Icons.numbers_outlined,
//                       keyboardType: TextInputType.number,
//                       controller: itemQtyCtrl,
//                       onChanged: (_) => setLocalState(() {}),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: LabeledField(
//                           label: 'MRP (auto)',
//                           field: IgnorePointer(
//                             child: CustomTextField(
//                               hint: '0',
//                               icon: Icons.currency_rupee,
//                               keyboardType: TextInputType.number,
//                               controller: itemMrpCtrl,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: Responsive.w(10)),
//                       Expanded(
//                         child: LabeledField(
//                           label: 'Rate',
//                           field: CustomTextField(
//                             hint: '0',
//                             icon: Icons.currency_rupee,
//                             keyboardType: TextInputType.number,
//                             controller: itemRateCtrl,
//                             onChanged: (_) => setLocalState(() {}),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(6)),
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(12)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceAlt,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Amount', style: AppTextStyles.bodyBold()),
//                         Text(currency.format(currentAmount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: Responsive.h(14)),
//
//                   if (editingIndex != null) ...[
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(8)),
//                       margin: EdgeInsets.only(bottom: Responsive.h(10)),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
//                           SizedBox(width: Responsive.w(6)),
//                           Expanded(
//                             child: Text(
//                               'Editing item #${editingIndex! + 1}',
//                               style: AppTextStyles.caption(),
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () {
//                               onCancelEdit();
//                               setLocalState(() {});
//                             },
//                             child: Text(
//                               'Cancel',
//                               style: AppTextStyles.bodyBold(color: AppColors.error),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         onAddItem();
//                         setLocalState(() {});
//                       },
//                       icon: Icon(
//                         editingIndex != null ? Icons.save_outlined : Icons.add,
//                         color: Colors.white,
//                       ),
//                       label: Text(editingIndex != null ? 'Update Item' : 'Add Item'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Items Added (${items.length})', style: AppTextStyles.h3()),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(10)),
//
//                   if (items.isEmpty)
//                     Padding(
//                       padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
//                       child: Center(
//                         child: Text(
//                           'No items added yet',
//                           style: AppTextStyles.body(color: AppColors.textHint),
//                         ),
//                       ),
//                     )
//                   else
//                     ...items.asMap().entries.map((entry) {
//                       final i = entry.key;
//                       final item = entry.value;
//                       return _AddedItemTile(
//                         serialNo: i + 1,
//                         item: item,
//                         currency: currency,
//                         isEditing: editingIndex == i,
//                         onEdit: () {
//                           onEditItem(i);
//                           setLocalState(() {});
//                         },
//                         onDelete: () {
//                           onRemoveItem(i);
//                           setLocalState(() {});
//                         },
//                       );
//                     }),
//                 ],
//               ),
//             ),
//             _BottomActionBar(
//               left: OutlinedButton(
//                 onPressed: onCancel,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//               right: PrimaryButton(label: 'Save Items', height: 48, onPressed: onSaveItems),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _AddedItemTile extends StatelessWidget {
//   const _AddedItemTile({
//     required this.serialNo,
//     required this.item,
//     required this.currency,
//     required this.onEdit,
//     required this.onDelete,
//     this.isEditing = false,
//   });
//   final int serialNo;
//   final _AddedItem item;
//   final NumberFormat currency;
//   final VoidCallback onEdit;
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
//             child: Text(
//               '$serialNo',
//               style: AppTextStyles.caption(),
//             ),
//           ),
//           SizedBox(width: Responsive.w(10)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.name, style: AppTextStyles.bodyBold()),
//                 SizedBox(height: Responsive.h(2)),
//                 Text(
//                   '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}',
//                   style: AppTextStyles.caption(),
//                 ),
//                 SizedBox(height: Responsive.h(2)),
//                 Text(
//                   'Qty: ${item.quantity.toStringAsFixed(0)} ${item.unit}   MRP: ${item.mrp.toStringAsFixed(0)}   Rate: ${item.rate.toStringAsFixed(0)}',
//                   style: AppTextStyles.caption(),
//                 ),
//                 SizedBox(height: Responsive.h(2)),
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
//                   InkWell(
//                     onTap: onEdit,
//                     child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
//                   ),
//                   SizedBox(width: Responsive.w(14)),
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
// // =====================================================================
// // STEP 3 — PREVIEW
// // =====================================================================
//
// class _PreviewStep extends StatelessWidget {
//   const _PreviewStep({
//     required this.estimateNo,
//     required this.date,
//     required this.partyName,
//     required this.address,
//     required this.phone,
//     required this.contractorName,
//     required this.contractorPhone,
//     required this.salesmanName,
//     required this.salesmanMobile,
//     required this.items,
//     required this.mrpTotal,
//     required this.itemsTotal,
//     required this.handlingChargeCtrl,
//     required this.grandTotal,
//     required this.totalQty,
//     required this.totalItems,
//     required this.onHandlingChargeChanged,
//     required this.onSaveDraft,
//     required this.onCreateEstimate,
//   });
//
//   final String estimateNo;
//   final DateTime date;
//   final String partyName;
//   final String address;
//   final String phone;
//   final String contractorName;
//   final String contractorPhone;
//   final String salesmanName;
//   final String salesmanMobile;
//   final List<_AddedItem> items;
//   final double mrpTotal;
//   final double itemsTotal;
//   final TextEditingController handlingChargeCtrl;
//   final double grandTotal;
//   final double totalQty;
//   final int totalItems;
//
//   final VoidCallback onHandlingChargeChanged;
//   final VoidCallback onSaveDraft;
//   final VoidCallback onCreateEstimate;
//
//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//
//     return Column(
//       children: [
//         Expanded(
//           child: ListView(
//             padding: EdgeInsets.all(Responsive.w(18)),
//             children: [
//               Container(
//                 padding: EdgeInsets.all(Responsive.w(14)),
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceAlt,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Estimate No.', style: AppTextStyles.caption()),
//                         Text(estimateNo, style: AppTextStyles.h3()),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text('Date', style: AppTextStyles.caption()),
//                         Text(DateFormat('dd-MM-yyyy').format(date), style: AppTextStyles.h3()),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: Responsive.h(16)),
//
//               _PreviewSection(
//                 title: 'Customer Details',
//                 rows: [
//                   _PreviewRow('Party Name', partyName.isEmpty ? '-' : partyName),
//                   _PreviewRow('Address', address.isEmpty ? '-' : address),
//                   _PreviewRow('Contact No.', phone.isEmpty ? '-' : phone),
//                 ],
//               ),
//               SizedBox(height: Responsive.h(14)),
//
//               _PreviewSection(
//                 title: 'Contractor',
//                 rows: [
//                   _PreviewRow('Name', contractorName.isEmpty ? '-' : contractorName),
//                   _PreviewRow('Contact No.', contractorPhone.isEmpty ? '-' : contractorPhone),
//                 ],
//               ),
//               SizedBox(height: Responsive.h(14)),
//
//               _PreviewSection(
//                 title: 'Owner',
//                 rows: [
//                   _PreviewRow('Name', salesmanName.isEmpty ? 'Owner' : salesmanName),
//                 ],
//               ),
//               SizedBox(height: Responsive.h(20)),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Items', style: AppTextStyles.h3()),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceAlt,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       'Total Items: $totalItems',
//                       style: AppTextStyles.bodyBold(color: AppColors.primary),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: Responsive.h(10)),
//
//               // Full itemized table matching the estimate sheet layout,
//               // scrollable horizontally so every column (Sl No, Item,
//               // Company, Size, Qty, Unit, MRP, Rate, Amount) stays visible.
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: DataTable(
//                     headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
//                     headingTextStyle: AppTextStyles.bodyBold(),
//                     dataTextStyle: AppTextStyles.body(),
//                     columnSpacing: 18,
//                     columns: const [
//                       DataColumn(label: Text('Sl.No')),
//                       DataColumn(label: Text('Item')),
//                       DataColumn(label: Text('Company')),
//                       DataColumn(label: Text('Size')),
//                       DataColumn(label: Text('Qty'), numeric: true),
//                       DataColumn(label: Text('Unit')),
//                       DataColumn(label: Text('MRP'), numeric: true),
//                       DataColumn(label: Text('Rate'), numeric: true),
//                       DataColumn(label: Text('Amount'), numeric: true),
//                     ],
//                     rows: items.asMap().entries.map((entry) {
//                       final i = entry.key;
//                       final item = entry.value;
//                       return DataRow(cells: [
//                         DataCell(Text('${i + 1}')),
//                         DataCell(Text(item.name)),
//                         DataCell(Text(item.company.isEmpty ? '-' : item.company)),
//                         DataCell(Text(item.size.isEmpty ? '-' : item.size)),
//                         DataCell(Text(number.format(item.quantity))),
//                         DataCell(Text(item.unit)),
//                         DataCell(Text(number.format(item.mrp))),
//                         DataCell(Text(number.format(item.rate))),
//                         DataCell(Text(
//                           currency.format(item.amount),
//                           style: AppTextStyles.bodyBold(),
//                         )),
//                       ]);
//                     }).toList(),
//                   ),
//                 ),
//               ),
//               SizedBox(height: Responsive.h(16)),
//
//               LabeledField(
//                 label: 'Handling Charge',
//                 field: CustomTextField(
//                   hint: 'Enter handling charge',
//                   icon: Icons.currency_rupee,
//                   keyboardType: TextInputType.number,
//                   controller: handlingChargeCtrl,
//                   onChanged: (_) => onHandlingChargeChanged(),
//                 ),
//               ),
//               SizedBox(height: Responsive.h(10)),
//
//               Container(
//                 padding: EdgeInsets.all(Responsive.w(14)),
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceAlt,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Column(
//                   children: [
//                     _totalRow('Total Items', '$totalItems'),
//                     SizedBox(height: Responsive.h(6)),
//                     _totalRow('Total Qty (Sqft)', number.format(totalQty)),
//                     SizedBox(height: Responsive.h(6)),
//                     _totalRow('MRP Total', currency.format(mrpTotal)),
//                     SizedBox(height: Responsive.h(6)),
//                     _totalRow('Handling Charge', currency.format(double.tryParse(handlingChargeCtrl.text) ?? 0)),
//                     const Divider(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Grand Total', style: AppTextStyles.h3()),
//                         Text(currency.format(grandTotal), style: AppTextStyles.h2(color: AppColors.primary)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: Responsive.h(12)),
//             ],
//           ),
//         ),
//         _BottomActionBar(
//           left: OutlinedButton.icon(
//             onPressed: onSaveDraft,
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             ),
//             icon: const Icon(Icons.request_quote_outlined, size: 18),
//             label: const Text('Save as Quotation'),
//           ),
//           // Tapping this opens the "Approve Estimate" dialog (name +
//           // confirm) before the estimate is actually created.
//           right: PrimaryButton(label: 'Approved', height: 48, onPressed: onCreateEstimate),
//         ),
//       ],
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
// class _PreviewRow {
//   final String label;
//   final String value;
//   _PreviewRow(this.label, this.value);
// }
//
// class _PreviewSection extends StatelessWidget {
//   const _PreviewSection({required this.title, required this.rows});
//   final String title;
//   final List<_PreviewRow> rows;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
//           SizedBox(height: Responsive.h(8)),
//           ...rows.map((r) => Padding(
//             padding: EdgeInsets.only(bottom: Responsive.h(4)),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(width: 100, child: Text(r.label, style: AppTextStyles.caption())),
//                 Expanded(child: Text(r.value, style: AppTextStyles.body())),
//               ],
//             ),
//           )),
//         ],
//       ),
//     );
//   }
// }
//
// class _BottomActionBar extends StatelessWidget {
//   const _BottomActionBar({
//     super.key,
//     this.left,
//     required this.right,
//   });
//
//   final Widget? left;
//   final Widget right;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         Responsive.w(18),
//         Responsive.h(10),
//         Responsive.w(18),
//         Responsive.h(14),
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         border: Border(
//           top: BorderSide(color: AppColors.border),
//         ),
//       ),
//       child: Row(
//         children: [
//           if (left != null) ...[
//             Expanded(child: left!),
//             SizedBox(width: Responsive.w(10)),
//           ],
//           Expanded(child: right),
//         ],
//       ),
//     );
//   }
// }
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../models/estimate_model.dart';
import '../../salesman/estimates/cubit/estimates_cubit.dart';


class _ProductCatalogItem {
  final String id;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double mrp;
  final double rate;
  final double incentivePercent;

  const _ProductCatalogItem({
    required this.id,
    required this.name,
    required this.company,
    required this.size,
    required this.unit,
    required this.mrp,
    required this.rate,
    required this.incentivePercent,
  });
}

const List<_ProductCatalogItem> _productCatalog = [
  _ProductCatalogItem(
    id: 'p1',
    name: 'Vitrified Tile 600x600',
    company: 'Kajaria',
    size: '600x600',
    unit: 'box',
    mrp: 65,
    rate: 55,
    incentivePercent: 5,
  ),
  _ProductCatalogItem(
    id: 'p2',
    name: 'Wall Tile 300x450',
    company: 'Somany',
    size: '300x450',
    unit: 'box',
    mrp: 48,
    rate: 40,
    incentivePercent: 4,
  ),
  _ProductCatalogItem(
    id: 'p3',
    name: 'PVC Pipe 4"',
    company: 'Supreme',
    size: '4"',
    unit: 'piece',
    mrp: 320,
    rate: 280,
    incentivePercent: 3,
  ),
];

// =====================================================================
// CLIENT CATALOG (dummy data — clients previously posted by a salesman)
// =====================================================================

/// A client record as it would come back from the backend after a
/// salesman posts an estimate/party entry. Owner / CAM field staff pick
/// from this list on the Details step to auto-fill Party Name, Phone and
/// Address instead of typing them again.
class _ClientCatalogItem {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String postedBySalesman;

  const _ClientCatalogItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.postedBySalesman,
  });
}

// TODO: replace with real backend data. e.g.
//   final clients = await context.read<ClientsCubit>().fetchClients();
// This should return every party name / phone / address a salesman has
// already posted, so owner/CAM staff can reuse it instead of re-typing.
const List<_ClientCatalogItem> _clientCatalog = [
  _ClientCatalogItem(
    id: 'c1',
    name: 'Ramesh Kumar',
    phone: '9876543210',
    address: 'MG Road, Kozhikode',
    postedBySalesman: 'Anoop',
  ),
  _ClientCatalogItem(
    id: 'c2',
    name: 'Suresh Traders',
    phone: '9123456780',
    address: 'Mavoor Road, Kozhikode',
    postedBySalesman: 'Anoop',
  ),
  _ClientCatalogItem(
    id: 'c3',
    name: 'Anitha Builders',
    phone: '9988776655',
    address: 'Beach Road, Kozhikode',
    postedBySalesman: 'Vishnu',
  ),
  _ClientCatalogItem(
    id: 'c4',
    name: 'Faisal Constructions',
    phone: '9847012345',
    address: 'Palazhi, Kozhikode',
    postedBySalesman: 'Vishnu',
  ),
  _ClientCatalogItem(
    id: 'c5',
    name: 'Green Valley Interiors',
    phone: '9037765432',
    address: 'Kottooli, Kozhikode',
    postedBySalesman: 'Anoop',
  ),
];

/// One added item in the estimate. Plain data (not controllers) since items
/// are added one at a time via a form, then shown as a read-only list.
class _AddedItem {
  final String id;
  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double quantity;
  final double mrp;
  final double rate;

  /// Real incentive % pulled from the selected product in the catalog at
  /// the time this item was added.
  final double incentivePercent;

  const _AddedItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.company,
    required this.size,
    required this.unit,
    required this.quantity,
    required this.mrp,
    required this.rate,
    required this.incentivePercent,
  });

  double get amount => quantity * rate;
  double get mrpValue => quantity * mrp;
  double get incentiveAmount => amount * incentivePercent / 100;

  EstimateItem toItem() => EstimateItem(
    id: id,
    name: name,
    company: company,
    size: size,
    unit: unit,
    quantity: quantity,
    mrp: mrp,
    rate: rate,
  );
}

enum _Step { details, addItems, preview }

/// Owner-side estimate creation. Functionally identical to the salesman
/// flow (details -> add items -> preview) except:
///  - the final action creates the estimate directly as an approved bill,
///    since the owner IS the approver and doesn't need to route it through
///    a pending-approval queue.
///  - the "Salesman" section is relabeled "Owner".
///  - items are picked from a product dropdown (like the salesman flow),
///    so company/size/unit/MRP/rate auto-fill and the incentive % used is
///    the real per-product value instead of a hardcoded dummy.
///  - the final "Approved" button shows a confirmation dialog first,
///    where the owner types their name before the estimate is created.
///  - on the Details step, Party Name can be filled from an existing
///    client (previously posted by a salesman) via search + confirm,
///    which auto-fills Phone and Address too.
class OwnerCreateEstimateScreen extends StatefulWidget {
  const OwnerCreateEstimateScreen({super.key});

  @override
  State<OwnerCreateEstimateScreen> createState() => _OwnerCreateEstimateScreenState();
}

class _OwnerCreateEstimateScreenState extends State<OwnerCreateEstimateScreen> {
  _Step _step = _Step.details;

  // --- Step 1: Party / Contractor / Owner ---
  final _partyNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _contractorNameCtrl = TextEditingController();
  final _contractorPhoneCtrl = TextEditingController();
  final _salesmanCtrl = TextEditingController();
  final _salesmanMobCtrl = TextEditingController();
  final _handlingChargeCtrl = TextEditingController(text: '0');

  // Name typed into the "Approve Estimate" confirmation dialog.
  final _approverNameCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  late final String _estimateNo;

  // --- Step 2: Items ---
  final _itemNameCtrl = TextEditingController();
  final _itemCompanyCtrl = TextEditingController();
  final _itemSizeCtrl = TextEditingController();
  final _itemUnitCtrl = TextEditingController(text: 'sqft');
  final _itemQtyCtrl = TextEditingController();
  final _itemMrpCtrl = TextEditingController();
  final _itemRateCtrl = TextEditingController();

  // Currently selected product from the dropdown. Drives
  // company/size/unit/MRP/rate auto-fill and the real incentive % used
  // when the item is added.
  _ProductCatalogItem? _selectedProduct;

  final List<_AddedItem> _items = [];
  int _itemCounter = 0;
  int? _editingItemIndex;

  // --- Step 3: Discount / Payment (owner can settle right when creating) ---

  // Extra discount the owner grants on top of the grand total, entered
  // through the "Give Additional Discount" button on the Preview step.
  // Null until the owner actually adds one.
  double? _additionalDiscount;

  // Amount already received from the party against this estimate,
  // entered through the "Add Payment" button on the Preview step. Null
  // until the owner records a payment.
  double? _paymentReceived;

  @override
  void initState() {
    super.initState();
    _estimateNo = context.read<EstimatesCubit>().nextEstimateNumber();
  }

  @override
  void dispose() {
    _partyNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _contractorNameCtrl.dispose();
    _contractorPhoneCtrl.dispose();
    _salesmanCtrl.dispose();
    _salesmanMobCtrl.dispose();
    _handlingChargeCtrl.dispose();
    _approverNameCtrl.dispose();
    _itemNameCtrl.dispose();
    _itemCompanyCtrl.dispose();
    _itemSizeCtrl.dispose();
    _itemUnitCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemMrpCtrl.dispose();
    _itemRateCtrl.dispose();
    super.dispose();
  }

  // ---------------- Derived totals ----------------

  double get _mrpTotal => _items.fold(0.0, (s, r) => s + r.mrpValue);
  double get _itemsTotal => _items.fold(0.0, (s, r) => s + r.amount);
  double get _handlingCharge => double.tryParse(_handlingChargeCtrl.text) ?? 0;
  double get _grandTotal => _itemsTotal + _handlingCharge;
  double get _totalQty => _items.fold(0.0, (s, r) => s + r.quantity);
  int get _totalItems => _items.length;

  // Sum of all items' incentive amounts (internal-facing only, not part of
  // the customer's grand total).
  double get _incentiveTotal => _items.fold(0.0, (s, r) => s + r.incentiveAmount);

  // What's left to collect after discount and any payment already
  // received. Clamped at 0 so it never shows negative if the owner
  // over-records a payment or discount.
  double get _balanceAmount {
    final discount = _additionalDiscount ?? 0;
    final paid = _paymentReceived ?? 0;
    final remaining = _grandTotal - discount - paid;
    return remaining < 0 ? 0 : remaining;
  }

  double get _currentItemAmount {
    final qty = double.tryParse(_itemQtyCtrl.text) ?? 0;
    final rate = double.tryParse(_itemRateCtrl.text) ?? 0;
    return qty * rate;
  }

  // Incentive preview for the item currently being entered, using the real
  // % from whichever product is selected in the dropdown.
  double get _currentItemIncentive {
    final percent = _selectedProduct?.incentivePercent ?? 0;
    return _currentItemAmount * percent / 100;
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
    return true;
  }

  // ---------------- Actions ----------------

  void _goToAddItems() {
    if (!_validateDetails()) return;
    setState(() => _step = _Step.addItems);
  }

  void _onProductSelected(_ProductCatalogItem? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _itemNameCtrl.text = product.name;
        _itemCompanyCtrl.text = product.company;
        _itemSizeCtrl.text = product.size;
        _itemUnitCtrl.text = product.unit;
        _itemMrpCtrl.text = product.mrp == product.mrp.roundToDouble()
            ? product.mrp.toStringAsFixed(0)
            : product.mrp.toString();
        _itemRateCtrl.text = product.rate == product.rate.roundToDouble()
            ? product.rate.toStringAsFixed(0)
            : product.rate.toString();
      } else {
        _itemNameCtrl.clear();
        _itemCompanyCtrl.clear();
        _itemSizeCtrl.clear();
        _itemUnitCtrl.text = 'sqft';
        _itemMrpCtrl.clear();
        _itemRateCtrl.clear();
      }
    });
  }

  void _addItemToList() {
    if (!_validateCurrentItemFields()) return;
    final product = _selectedProduct!;
    setState(() {
      final editingIndex = _editingItemIndex;
      if (editingIndex != null) {
        // Update the existing item in place, keeping its original id.
        final existing = _items[editingIndex];
        _items[editingIndex] = _AddedItem(
          id: existing.id,
          productId: product.id,
          name: product.name,
          company: product.company,
          size: _itemSizeCtrl.text.trim(),
          unit: _itemUnitCtrl.text.trim().isEmpty ? 'sqft' : _itemUnitCtrl.text.trim(),
          quantity: double.tryParse(_itemQtyCtrl.text) ?? 0,
          mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
          rate: double.tryParse(_itemRateCtrl.text) ?? 0,
          incentivePercent: product.incentivePercent,
        );
        _editingItemIndex = null;
      } else {
        _items.add(_AddedItem(
          id: 'item_${_itemCounter++}',
          productId: product.id,
          name: product.name,
          company: product.company,
          size: _itemSizeCtrl.text.trim(),
          unit: _itemUnitCtrl.text.trim().isEmpty ? 'sqft' : _itemUnitCtrl.text.trim(),
          quantity: double.tryParse(_itemQtyCtrl.text) ?? 0,
          mrp: double.tryParse(_itemMrpCtrl.text) ?? 0,
          rate: double.tryParse(_itemRateCtrl.text) ?? 0,
          incentivePercent: product.incentivePercent,
        ));
      }
      _selectedProduct = null;
      _itemNameCtrl.clear();
      _itemCompanyCtrl.clear();
      _itemSizeCtrl.clear();
      _itemUnitCtrl.text = 'sqft';
      _itemQtyCtrl.clear();
      _itemMrpCtrl.clear();
      _itemRateCtrl.clear();
    });
  }

  void _editItem(int index) {
    final item = _items[index];
    setState(() {
      _editingItemIndex = index;
      // Re-select the matching catalog product so the dropdown reflects
      // what's being edited (falls back to null if it was ever removed
      // from the catalog).
      _selectedProduct = _productCatalog
          .cast<_ProductCatalogItem?>()
          .firstWhere((p) => p?.id == item.productId, orElse: () => null);
      _itemNameCtrl.text = item.name;
      _itemCompanyCtrl.text = item.company;
      _itemSizeCtrl.text = item.size;
      _itemUnitCtrl.text = item.unit;
      _itemQtyCtrl.text = item.quantity == item.quantity.roundToDouble()
          ? item.quantity.toStringAsFixed(0)
          : item.quantity.toString();
      _itemMrpCtrl.text = item.mrp == item.mrp.roundToDouble()
          ? item.mrp.toStringAsFixed(0)
          : item.mrp.toString();
      _itemRateCtrl.text = item.rate == item.rate.roundToDouble()
          ? item.rate.toStringAsFixed(0)
          : item.rate.toString();
    });
  }

  void _cancelEditItem() {
    setState(() {
      _editingItemIndex = null;
      _selectedProduct = null;
      _itemNameCtrl.clear();
      _itemCompanyCtrl.clear();
      _itemSizeCtrl.clear();
      _itemUnitCtrl.text = 'sqft';
      _itemQtyCtrl.clear();
      _itemMrpCtrl.clear();
      _itemRateCtrl.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      // If the removed item was mid-edit (or was before the one being
      // edited), clear/adjust the editing state so indices stay valid.
      if (_editingItemIndex != null) {
        if (_editingItemIndex == index) {
          _editingItemIndex = null;
          _selectedProduct = null;
          _itemNameCtrl.clear();
          _itemCompanyCtrl.clear();
          _itemSizeCtrl.clear();
          _itemUnitCtrl.text = 'sqft';
          _itemQtyCtrl.clear();
          _itemMrpCtrl.clear();
          _itemRateCtrl.clear();
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

  EstimateModel _buildEstimate({required EstimateBillType billType}) {
    return EstimateModel(
      id: _estimateNo,
      contractorName: _contractorNameCtrl.text.trim().isEmpty
          ? _partyNameCtrl.text.trim()
          : _contractorNameCtrl.text.trim(),
      siteAddress: _addressCtrl.text.trim().isEmpty ? 'Not specified' : _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      salesmanName: _salesmanCtrl.text.trim().isEmpty ? 'Owner' : _salesmanCtrl.text.trim(),
      salesmanMobile: _salesmanMobCtrl.text.trim(),
      date: _date,
      handlingCharge: _handlingCharge,
      billType: billType,
      // Owner-created bills are approved immediately — no pending-approval
      // queue since the owner IS the approver. Quotations still save as
      // drafts, same as the salesman flow.
      status: billType == EstimateBillType.billed ? 'Approved' : 'Draft',
      items: _items.map((r) => r.toItem()).toList(),
    );
  }

  void _saveDraft() {
    final estimate = _buildEstimate(billType: EstimateBillType.quotation);
    context.read<EstimatesCubit>().addEstimate(estimate);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved as Quotation')),
    );
  }

  void _createEstimate() {
    final estimate = _buildEstimate(billType: EstimateBillType.billed);
    context.read<EstimatesCubit>().addEstimate(estimate);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estimate created and approved')),
    );
  }

  /// Shows a confirmation dialog before finalizing the estimate. The owner
  /// must type their name in the dialog; that name is used as the "Owner"
  /// name on the estimate (overwriting whatever was on the Details step,
  /// since this is who is actually approving it right now). Only after
  /// confirming does `_createEstimate()` run.
  Future<void> _showApproveDialog() async {
    _approverNameCtrl.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Approve Estimate'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Are you sure you want to approve this estimate?'),
                  SizedBox(height: Responsive.h(16)),
                  TextField(
                    controller: _approverNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your name to confirm',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_approverNameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please enter your name')),
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Approve'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      // Use the name entered in the dialog as the Owner name on the estimate.
      setState(() {
        _salesmanCtrl.text = _approverNameCtrl.text.trim();
      });
      _createEstimate();
    }
  }

  // ---------------- Discount / Payment (Preview step) ----------------

  // Shared numeric-amount prompt used by both the discount and payment
  // dialogs below — keeps validation/formatting logic in one place.
  Future<double?> _showAmountInputDialog({
    required String title,
    required String label,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: label,
                prefixText: '₹ ',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return null;
    return double.tryParse(result);
  }

  Future<void> _showAddDiscountDialog() async {
    final amount = await _showAmountInputDialog(
      title: 'Additional Discount',
      label: 'Discount Amount',
      initialValue: _additionalDiscount?.toStringAsFixed(0),
    );
    if (amount == null) return;

    setState(() => _additionalDiscount = amount);

    // TODO(owner-discount): replace this with the real API/cubit call once
    // the estimate is persisted, e.g.
    //   context.read<EstimatesCubit>().addDiscount(_estimateNo, amount);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Additional discount added')),
      );
    }
  }

  Future<void> _showAddPaymentDialog() async {
    final amount = await _showAmountInputDialog(
      title: 'Payment Received',
      label: 'Amount Received',
      initialValue: _paymentReceived?.toStringAsFixed(0),
    );
    if (amount == null) return;

    setState(() => _paymentReceived = amount);

    // TODO(owner-payment): replace this with the real API/cubit call once
    // the estimate is persisted, e.g.
    //   context.read<EstimatesCubit>().recordPayment(_estimateNo, amount);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded')),
      );
    }
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

    return PopScope(
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
                    estimateNo: _estimateNo,
                    date: _date,
                    onDateChanged: (d) => setState(() => _date = d),
                    partyNameCtrl: _partyNameCtrl,
                    addressCtrl: _addressCtrl,
                    phoneCtrl: _phoneCtrl,
                    contractorNameCtrl: _contractorNameCtrl,
                    contractorPhoneCtrl: _contractorPhoneCtrl,
                    salesmanCtrl: _salesmanCtrl,
                    salesmanMobCtrl: _salesmanMobCtrl,
                    onSaveDraft: () {
                      if (!_validateDetails()) return;
                      _saveDraft();
                    },
                    onNext: _goToAddItems,
                  ),
                  _Step.addItems => _AddItemsStep(
                    catalog: _productCatalog,
                    selectedProduct: _selectedProduct,
                    onProductSelected: _onProductSelected,
                    itemNameCtrl: _itemNameCtrl,
                    itemCompanyCtrl: _itemCompanyCtrl,
                    itemSizeCtrl: _itemSizeCtrl,
                    itemUnitCtrl: _itemUnitCtrl,
                    itemQtyCtrl: _itemQtyCtrl,
                    itemMrpCtrl: _itemMrpCtrl,
                    itemRateCtrl: _itemRateCtrl,
                    currentAmount: _currentItemAmount,
                    currentIncentive: _currentItemIncentive,
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
                    estimateNo: _estimateNo,
                    date: _date,
                    partyName: _partyNameCtrl.text,
                    address: _addressCtrl.text,
                    phone: _phoneCtrl.text,
                    contractorName: _contractorNameCtrl.text,
                    contractorPhone: _contractorPhoneCtrl.text,
                    salesmanName: _salesmanCtrl.text,
                    salesmanMobile: _salesmanMobCtrl.text,
                    items: _items,
                    mrpTotal: _mrpTotal,
                    itemsTotal: _itemsTotal,
                    handlingChargeCtrl: _handlingChargeCtrl,
                    grandTotal: _grandTotal,
                    totalQty: _totalQty,
                    totalItems: _totalItems,
                    additionalDiscount: _additionalDiscount,
                    paymentReceived: _paymentReceived,
                    balanceAmount: _balanceAmount,
                    onAddDiscount: _showAddDiscountDialog,
                    onAddPayment: _showAddPaymentDialog,
                    onHandlingChargeChanged: () => setState(() {}),
                    onSaveDraft: _saveDraft,
                    // Route through the confirmation dialog instead of
                    // creating the estimate directly.
                    onCreateEstimate: _showApproveDialog,
                  ),
                },
              ),
            ],
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
    required this.estimateNo,
    required this.date,
    required this.onDateChanged,
    required this.partyNameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.contractorNameCtrl,
    required this.contractorPhoneCtrl,
    required this.salesmanCtrl,
    required this.salesmanMobCtrl,
    required this.onSaveDraft,
    required this.onNext,
  });

  final String estimateNo;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController partyNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController contractorNameCtrl;
  final TextEditingController contractorPhoneCtrl;
  final TextEditingController salesmanCtrl;
  final TextEditingController salesmanMobCtrl;
  final VoidCallback onSaveDraft;
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimate No.', style: AppTextStyles.caption()),
                        Text(estimateNo, style: AppTextStyles.h3()),
                      ],
                    ),
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
              // Phone is entered first: as soon as 2 or 3 digits are typed,
              // matching clients (posted earlier by a salesman) are shown
              // right below the field, updating live on every keystroke.
              // Tapping a match auto-fills Party Name and Address instantly.
              _PhoneClientField(
                phoneCtrl: phoneCtrl,
                partyNameCtrl: partyNameCtrl,
                addressCtrl: addressCtrl,
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
                  hint: 'Enter contractor phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: contractorPhoneCtrl,
                ),
              ),
              SizedBox(height: Responsive.h(16)),

              Text('Owner', style: AppTextStyles.h3()),
              SizedBox(height: Responsive.h(12)),
              LabeledField(
                label: 'Name',
                field: CustomTextField(hint: 'Owner name', icon: Icons.badge_outlined, controller: salesmanCtrl),
              ),
              SizedBox(height: Responsive.h(12)),
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
// PHONE FIELD WITH LIVE CLIENT-MATCH SUGGESTIONS
// =====================================================================

/// Phone input that doubles as a client lookup: once 2+ digits are typed,
/// any clients (previously posted by a salesman) whose phone number
/// contains that digit sequence are listed right below the field. Tapping
/// a match fills Phone, Party Name and Address in one go — no separate
/// confirm step, since the person is actively typing the number.
class _PhoneClientField extends StatelessWidget {
  const _PhoneClientField({
    required this.phoneCtrl,
    required this.partyNameCtrl,
    required this.addressCtrl,
  });

  final TextEditingController phoneCtrl;
  final TextEditingController partyNameCtrl;
  final TextEditingController addressCtrl;

  static const int _minDigitsToSearch = 2;

  void _selectClient(_ClientCatalogItem client) {
    phoneCtrl.text = client.phone;
    phoneCtrl.selection = TextSelection.collapsed(offset: phoneCtrl.text.length);
    partyNameCtrl.text = client.name;
    addressCtrl.text = client.address;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: phoneCtrl,
      builder: (context, value, _) {
        final query = value.text.trim();

        List<_ClientCatalogItem> matches = [];
        if (query.length >= _minDigitsToSearch) {
          matches = _clientCatalog.where((c) => c.phone.contains(query)).toList();
        }

        // Hide the list once the field already holds exactly the matched
        // client's own details — nothing left to suggest.
        final alreadyApplied = matches.length == 1 &&
            matches.first.phone == query &&
            partyNameCtrl.text == matches.first.name &&
            addressCtrl.text == matches.first.address;
        final showSuggestions = matches.isNotEmpty && !alreadyApplied;

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
            if (showSuggestions) ...[
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
                    final c = matches[i];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceAlt,
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          style: AppTextStyles.caption(),
                        ),
                      ),
                      title: Text(c.name, style: AppTextStyles.bodyBold()),
                      subtitle: Text(
                        '${c.phone} · ${c.address}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(),
                      ),
                      trailing: const Icon(Icons.north_west, size: 16, color: AppColors.primary),
                      onTap: () => _selectClient(c),
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
  }
}

// =====================================================================
// STEP 2 — ADD ITEMS
// =====================================================================

class _AddItemsStep extends StatelessWidget {
  const _AddItemsStep({
    required this.catalog,
    required this.selectedProduct,
    required this.onProductSelected,
    required this.itemNameCtrl,
    required this.itemCompanyCtrl,
    required this.itemSizeCtrl,
    required this.itemUnitCtrl,
    required this.itemQtyCtrl,
    required this.itemMrpCtrl,
    required this.itemRateCtrl,
    required this.currentAmount,
    required this.currentIncentive,
    required this.items,
    required this.editingIndex,
    required this.onAddItem,
    required this.onEditItem,
    required this.onCancelEdit,
    required this.onRemoveItem,
    required this.onCancel,
    required this.onSaveItems,
  });

  final List<_ProductCatalogItem> catalog;
  final _ProductCatalogItem? selectedProduct;
  final ValueChanged<_ProductCatalogItem?> onProductSelected;
  final TextEditingController itemNameCtrl;
  final TextEditingController itemCompanyCtrl;
  final TextEditingController itemSizeCtrl;
  final TextEditingController itemUnitCtrl;
  final TextEditingController itemQtyCtrl;
  final TextEditingController itemMrpCtrl;
  final TextEditingController itemRateCtrl;
  final double currentAmount;
  final double currentIncentive;
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
                  LabeledField(
                    label: 'Select Product',
                    field: DropdownButtonFormField<_ProductCatalogItem>(
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
                      items: catalog
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
                            hint: 'sqft',
                            icon: Icons.square_foot_outlined,
                            controller: itemUnitCtrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                  LabeledField(
                    label: 'Quantity',
                    field: CustomTextField(
                      hint: 'Enter quantity',
                      icon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                      controller: itemQtyCtrl,
                      onChanged: (_) => setLocalState(() {}),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'MRP (auto)',
                          field: IgnorePointer(
                            child: CustomTextField(
                              hint: '0',
                              icon: Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                              controller: itemMrpCtrl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        child: LabeledField(
                          label: 'Rate',
                          field: CustomTextField(
                            hint: '0',
                            icon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                            controller: itemRateCtrl,
                            onChanged: (_) => setLocalState(() {}),
                          ),
                        ),
                      ),
                    ],
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items Added (${items.length})', style: AppTextStyles.h3()),
                    ],
                  ),
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
            child: Text(
              '$serialNo',
              style: AppTextStyles.caption(),
            ),
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
                  'Qty: ${item.quantity.toStringAsFixed(0)} ${item.unit}   MRP: ${item.mrp.toStringAsFixed(0)}   Rate: ${item.rate.toStringAsFixed(0)}',
                  style: AppTextStyles.caption(),
                ),
                SizedBox(height: Responsive.h(2)),
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
                  InkWell(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  ),
                  SizedBox(width: Responsive.w(14)),
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

// =====================================================================
// STEP 3 — PREVIEW
// =====================================================================

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({
    required this.estimateNo,
    required this.date,
    required this.partyName,
    required this.address,
    required this.phone,
    required this.contractorName,
    required this.contractorPhone,
    required this.salesmanName,
    required this.salesmanMobile,
    required this.items,
    required this.mrpTotal,
    required this.itemsTotal,
    required this.handlingChargeCtrl,
    required this.grandTotal,
    required this.totalQty,
    required this.totalItems,
    required this.additionalDiscount,
    required this.paymentReceived,
    required this.balanceAmount,
    required this.onAddDiscount,
    required this.onAddPayment,
    required this.onHandlingChargeChanged,
    required this.onSaveDraft,
    required this.onCreateEstimate,
  });

  final String estimateNo;
  final DateTime date;
  final String partyName;
  final String address;
  final String phone;
  final String contractorName;
  final String contractorPhone;
  final String salesmanName;
  final String salesmanMobile;
  final List<_AddedItem> items;
  final double mrpTotal;
  final double itemsTotal;
  final TextEditingController handlingChargeCtrl;
  final double grandTotal;
  final double totalQty;
  final int totalItems;

  // Extra discount the owner can grant on top of the grand total. Null
  // until one has been added via onAddDiscount.
  final double? additionalDiscount;

  // Amount already received from the party. Null until recorded via
  // onAddPayment.
  final double? paymentReceived;

  // Grand total minus discount and payment received — what's still owed.
  final double balanceAmount;

  final VoidCallback onAddDiscount;
  final VoidCallback onAddPayment;
  final VoidCallback onHandlingChargeChanged;
  final VoidCallback onSaveDraft;
  final VoidCallback onCreateEstimate;

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimate No.', style: AppTextStyles.caption()),
                        Text(estimateNo, style: AppTextStyles.h3()),
                      ],
                    ),
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
                title: 'Owner',
                rows: [
                  _PreviewRow('Name', salesmanName.isEmpty ? 'Owner' : salesmanName),
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
                    child: Text(
                      'Total Items: $totalItems',
                      style: AppTextStyles.bodyBold(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(10)),

              // Full itemized table matching the estimate sheet layout,
              // scrollable horizontally so every column (Sl No, Item,
              // Company, Size, Qty, Unit, MRP, Rate, Amount) stays visible.
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
                      DataColumn(label: Text('MRP'), numeric: true),
                      DataColumn(label: Text('Rate'), numeric: true),
                      DataColumn(label: Text('Amount'), numeric: true),
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
                        DataCell(Text(number.format(item.mrp))),
                        DataCell(Text(number.format(item.rate))),
                        DataCell(Text(
                          currency.format(item.amount),
                          style: AppTextStyles.bodyBold(),
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
                    _totalRow('Total Qty (Sqft)', number.format(totalQty)),
                    SizedBox(height: Responsive.h(6)),
                    _totalRow('MRP Total', currency.format(mrpTotal)),
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
                    SizedBox(height: Responsive.h(12)),

                    // Additional Discount — shows a "Give Additional
                    // Discount" button until one is added, then shows the
                    // amount with a small edit affordance.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Additional Discount', style: AppTextStyles.body()),
                            if (additionalDiscount != null) ...[
                              SizedBox(width: Responsive.w(6)),
                              InkWell(
                                onTap: onAddDiscount,
                                child: Icon(Icons.edit_outlined, size: 14, color: AppColors.textHint),
                              ),
                            ],
                          ],
                        ),
                        additionalDiscount == null
                            ? TextButton.icon(
                          onPressed: onAddDiscount,
                          icon: const Icon(Icons.local_offer_outlined, size: 16),
                          label: const Text('Give Additional Discount'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                            : Text(
                          '- ${currency.format(additionalDiscount!)}',
                          style: AppTextStyles.bodyBold(color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(10)),

                    // Payment Received — what the party has already paid
                    // against this estimate. Same add/edit pattern as the
                    // discount row above.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Payment Received', style: AppTextStyles.body()),
                            if (paymentReceived != null) ...[
                              SizedBox(width: Responsive.w(6)),
                              InkWell(
                                onTap: onAddPayment,
                                child: Icon(Icons.edit_outlined, size: 14, color: AppColors.textHint),
                              ),
                            ],
                          ],
                        ),
                        paymentReceived == null
                            ? TextButton.icon(
                          onPressed: onAddPayment,
                          icon: const Icon(Icons.payments_outlined, size: 16),
                          label: const Text('Add Payment'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                            : Text(
                          currency.format(paymentReceived!),
                          style: AppTextStyles.bodyBold(color: AppColors.success),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Balance Amount — Grand Total minus discount and
                    // payment received. Red while still owed, green once
                    // fully settled.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Balance Amount', style: AppTextStyles.h3()),
                        Text(
                          currency.format(balanceAmount),
                          style: AppTextStyles.h2(
                            color: balanceAmount > 0 ? Colors.red : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(12)),
            ],
          ),
        ),
        _BottomActionBar(
          left: OutlinedButton.icon(
            onPressed: onSaveDraft,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.request_quote_outlined, size: 18),
            label: const Text('Save as Quotation'),
          ),
          // Tapping this opens the "Approve Estimate" dialog (name +
          // confirm) before the estimate is actually created.
          right: PrimaryButton(label: 'Approved', height: 48, onPressed: onCreateEstimate),
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
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
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