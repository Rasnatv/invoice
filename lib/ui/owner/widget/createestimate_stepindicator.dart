//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import '../../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_bloc.dart';
// import '../../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_event.dart';
// import '../../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_state.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../../core/validator/validationfile.dart';
// import '../../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
// import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
// import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../../../widgets/primary_button.dart';
// import 'ownerestimatetype.dart';
//
//
//
// class _UnitFieldVisibility {
//   final bool showSize;
//   final bool showPacking;
//
//   const _UnitFieldVisibility({
//     required this.showSize,
//     required this.showPacking,
//   });
//
//   factory _UnitFieldVisibility.forProduct(ActiveProductModel? product) {
//     if (product == null) {
//       return const _UnitFieldVisibility(showSize: false, showPacking: false);
//     }
//     return _UnitFieldVisibility(
//       showSize: product.size.trim().isNotEmpty,
//       showPacking: product.packing.trim().isNotEmpty,
//     );
//   }
// }
//
// // =====================================================================
// // STEP INDICATOR
// // =====================================================================
//
// class StepIndicator extends StatelessWidget {
//   const StepIndicator({super.key, required this.step});
//   final EstimateStep step;
//
//   @override
//   Widget build(BuildContext context) {
//     final index = EstimateStep.values.indexOf(step);
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.w(18), vertical: Responsive.h(10)),
//       child: Row(
//         children: List.generate(EstimateStep.values.length * 2 - 1, (i) {
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
// class DetailsStep extends StatelessWidget {
//   const DetailsStep({
//     super.key,
//     required this.date,
//     required this.onDateChanged,
//     required this.partyNameCtrl,
//     required this.addressCtrl,
//     required this.phoneCtrl,
//     required this.customerEmailCtrl,
//     required this.contractorNameCtrl,
//     required this.contractorPhoneCtrl,
//     required this.contractorEmailCtrl,
//     required this.contractorAddressCtrl,
//     required this.onSelectSiteVisit,
//     required this.onNext,
//   });
//
//   final DateTime date;
//   final ValueChanged<DateTime> onDateChanged;
//   final TextEditingController partyNameCtrl;
//   final TextEditingController addressCtrl;
//   final TextEditingController phoneCtrl;
//   final TextEditingController customerEmailCtrl;
//   final TextEditingController contractorNameCtrl;
//   final TextEditingController contractorPhoneCtrl;
//   final TextEditingController contractorEmailCtrl;
//   final TextEditingController contractorAddressCtrl;
//   final ValueChanged<SiteVisitDropdownItem> onSelectSiteVisit;
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
//                     Text('New Estimate', style: AppTextStyles.h3()),
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
//               _PhoneSiteVisitField(
//                 phoneCtrl: phoneCtrl,
//                 onSelectSiteVisit: onSelectSiteVisit,
//               ),
//               SizedBox(height: Responsive.h(10)),
//               LabeledField(
//                 label: 'Party Name',
//                 field: CustomTextField(
//                   hint: 'Enter party name',
//                   icon: Icons.groups_2_outlined,
//                   controller: partyNameCtrl,
//                   inputFormatters: DValidator.lettersOnly,
//                 ),
//               ),
//               LabeledField(
//                 label: 'Address',
//                 field: CustomTextField(
//                   hint: 'Enter site address',
//                   icon: Icons.location_on_outlined,
//                   controller: addressCtrl,
//                   inputFormatters: DValidator.textWithLimit,
//                 ),
//               ),
//               LabeledField(
//                 label: 'Email (optional)',
//                 field: CustomTextField(
//                   hint: 'Enter customer email',
//                   icon: Icons.alternate_email,
//                   keyboardType: TextInputType.emailAddress,
//                   controller: customerEmailCtrl,
//                   inputFormatters: DValidator.textWithLimit,
//                 ),
//               ),
//               SizedBox(height: Responsive.h(16)),
//
//               Text('Contractor Details', style: AppTextStyles.h3()),
//               SizedBox(height: Responsive.h(12)),
//               LabeledField(
//                 label: 'Contractor Name',
//                 field: CustomTextField(
//                   hint: 'Enter contractor name',
//                   icon: Icons.engineering_outlined,
//                   controller: contractorNameCtrl,
//                   inputFormatters: DValidator.lettersOnly,
//                 ),
//               ),
//               LabeledField(
//                 label: 'Contact No.',
//                 field: CustomTextField(
//                   hint: 'Enter contractor phone number',
//                   icon: Icons.phone_outlined,
//                   keyboardType: TextInputType.phone,
//                   controller: contractorPhoneCtrl,
//                   inputFormatters: DValidator.phoneNumber,
//                 ),
//               ),
//               LabeledField(
//                 label: 'Email (optional)',
//                 field: CustomTextField(
//                   hint: 'Enter contractor email',
//                   icon: Icons.alternate_email,
//                   keyboardType: TextInputType.emailAddress,
//                   controller: contractorEmailCtrl,
//                   inputFormatters: DValidator.textWithLimit,
//                 ),
//               ),
//               SizedBox(height: Responsive.h(16)),
//             ],
//           ),
//         ),
//         BottomActionBar(
//           right: PrimaryButton(label: 'Add Items', height: 48, onPressed: onNext),
//         ),
//       ],
//     );
//   }
// }
//
// class _PhoneSiteVisitField extends StatelessWidget {
//   const _PhoneSiteVisitField({
//     required this.phoneCtrl,
//     required this.onSelectSiteVisit,
//   });
//
//   final TextEditingController phoneCtrl;
//   final ValueChanged<SiteVisitDropdownItem> onSelectSiteVisit;
//
//   static const int _minDigitsToSearch = 2;
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<TextEditingValue>(
//       valueListenable: phoneCtrl,
//       builder: (context, value, _) {
//         final query = value.text.trim();
//
//         return BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
//           buildWhen: (prev, curr) =>
//           prev.siteVisits != curr.siteVisits ||
//               prev.siteVisitsStatus != curr.siteVisitsStatus ||
//               prev.selectedSiteVisit != curr.selectedSiteVisit,
//           builder: (context, state) {
//             List<SiteVisitDropdownItem> matches = [];
//             if (query.length >= _minDigitsToSearch) {
//               matches = state.siteVisits.where((v) => v.customerPhone.contains(query)).toList();
//             }
//             final selected = state.selectedSiteVisit;
//             final alreadySelected = selected != null && selected.customerPhone == query;
//             final showSuggestions = matches.isNotEmpty && !alreadySelected;
//             final loading = state.siteVisitsStatus == LoadStatus.loading;
//             final failed = state.siteVisitsStatus == LoadStatus.failure;
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 LabeledField(
//                   label: 'Contact No.',
//                   field: CustomTextField(
//                     hint: 'Enter phone number',
//                     icon: Icons.phone_outlined,
//                     keyboardType: TextInputType.phone,
//                     controller: phoneCtrl,
//                     inputFormatters: DValidator.phoneNumber,
//                   ),
//                 ),
//                 if (query.length >= _minDigitsToSearch && loading) ...[
//                   SizedBox(height: Responsive.h(6)),
//                   Text('Searching pending site visits…', style: AppTextStyles.caption()),
//                 ] else if (query.length >= _minDigitsToSearch && failed) ...[
//                   SizedBox(height: Responsive.h(6)),
//                   InkWell(
//                     onTap: () => context.read<OwnerEstimateBloc>().add(const OwnerPendingSiteVisitsRequested()),
//                     child: Text(
//                       'Couldn\'t load site visits — tap to retry',
//                       style: AppTextStyles.caption(color: AppColors.error),
//                     ),
//                   ),
//                 ] else if (showSuggestions) ...[
//                   SizedBox(height: Responsive.h(6)),
//                   Container(
//                     width: double.infinity,
//                     constraints: BoxConstraints(maxHeight: Responsive.h(220)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     clipBehavior: Clip.antiAlias,
//                     child: ListView.separated(
//                       shrinkWrap: true,
//                       padding: EdgeInsets.zero,
//                       itemCount: matches.length,
//                       separatorBuilder: (_, __) => const Divider(height: 1),
//                       itemBuilder: (context, i) {
//                         final v = matches[i];
//                         return ListTile(
//                           dense: true,
//                           leading: CircleAvatar(
//                             radius: 16,
//                             backgroundColor: AppColors.surfaceAlt,
//                             child: Text(
//                               v.customerName.isNotEmpty ? v.customerName[0].toUpperCase() : '?',
//                               style: AppTextStyles.caption(),
//                             ),
//                           ),
//                           title: Text(v.customerName, style: AppTextStyles.bodyBold()),
//                           subtitle: Text(
//                             '${v.customerPhone} · ${v.siteAddress}',
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: AppTextStyles.caption(),
//                           ),
//                           trailing: const Icon(Icons.north_west, size: 16, color: AppColors.primary),
//                           onTap: () => onSelectSiteVisit(v),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(4)),
//                   Text('Tap a match to fill party name and address', style: AppTextStyles.caption()),
//                 ],
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// // =====================================================================
// // STEP 2 — ADD ITEMS
// // Amount is never computed locally (no quantity*rate preview). Box Qty
// // / Piece Qty only render for box-unit products, with Box Qty auto-set
// // from Quantity and Piece Qty user-editable. The Add/Update Item button
// // shows a spinner while the fresh product-incentive call is in flight.
// // =====================================================================
//
// class AddItemsStep extends StatelessWidget {
//   const AddItemsStep({
//     super.key,
//     required this.selectedProduct,
//     required this.onProductSelected,
//     required this.itemCompanyCtrl,
//     required this.itemSizeCtrl,
//     required this.itemUnitCtrl,
//     required this.itemPackingCtrl,
//     required this.itemMrpCtrl,
//     required this.itemQtyCtrl,
//     required this.itemBoxQtyCtrl,
//     required this.itemPieceQtyCtrl,
//     required this.itemRateCtrl,
//     required this.isAdding,
//     required this.onQuantityChanged,
//     this.onQtyRateChanged,
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
//   final ActiveProductModel? selectedProduct;
//   final ValueChanged<ActiveProductModel?> onProductSelected;
//   final TextEditingController itemCompanyCtrl;
//   final TextEditingController itemSizeCtrl;
//   final TextEditingController itemUnitCtrl;
//   final TextEditingController itemPackingCtrl;
//   final TextEditingController itemMrpCtrl;
//   final TextEditingController itemQtyCtrl;
//   final TextEditingController itemBoxQtyCtrl;
//   final TextEditingController itemPieceQtyCtrl;
//   final TextEditingController itemRateCtrl;
//   final bool isAdding;
//
//   final VoidCallback onQuantityChanged;
//   /// Optional — fired on rate/piece-qty edits. Owner screen may leave
//   /// this unset since it doesn't run a live incentive preview.
//   final VoidCallback? onQtyRateChanged;
//
//   final List<AddedItem> items;
//   final int? editingIndex;
//   final VoidCallback onAddItem;
//   final void Function(int) onEditItem;
//   final VoidCallback onCancelEdit;
//   final void Function(int) onRemoveItem;
//   final VoidCallback onCancel;
//   final VoidCallback onSaveItems;
//
//   _UnitFieldVisibility get _fieldVisibility => _UnitFieldVisibility.forProduct(selectedProduct);
//   bool get _isBoxUnit => selectedProduct?.isBoxUnit ?? false;
//
//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final visibility = _fieldVisibility;
//
//     return StatefulBuilder(
//       builder: (context, setLocalState) {
//         return Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.all(Responsive.w(18)),
//                 children: [
//                   BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
//                     buildWhen: (prev, curr) =>
//                     prev.products != curr.products || prev.productsStatus != curr.productsStatus,
//                     builder: (context, state) {
//                       if (state.productsStatus == LoadStatus.loading && state.products.isEmpty) {
//                         return const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 12),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }
//                       if (state.productsStatus == LoadStatus.failure && state.products.isEmpty) {
//                         return Container(
//                           padding: EdgeInsets.all(Responsive.w(12)),
//                           decoration: BoxDecoration(
//                             color: AppColors.error.withOpacity(0.06),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   state.productsError ?? 'Failed to load products.',
//                                   style: AppTextStyles.caption(color: AppColors.error),
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () =>
//                                     context.read<OwnerEstimateBloc>().add(const OwnerActiveProductsRequested()),
//                                 child: const Text('Retry'),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                       return LabeledField(
//                         label: 'Select Product',
//                         field: KeyedSubtree(
//                           key: ValueKey(selectedProduct?.id ?? 'none'),
//                           child: Autocomplete<ActiveProductModel>(
//                             displayStringForOption: (p) => '${p.name} — ${p.company}',
//                             initialValue: TextEditingValue(
//                               text: selectedProduct != null
//                                   ? '${selectedProduct!.name} — ${selectedProduct!.company}'
//                                   : '',
//                             ),
//                             optionsBuilder: (textEditingValue) {
//                               final query = textEditingValue.text.trim().toLowerCase();
//                               if (query.isEmpty) return state.products;
//                               return state.products.where((p) =>
//                               p.name.toLowerCase().contains(query) ||
//                                   p.company.toLowerCase().contains(query));
//                             },
//                             onSelected: (p) {
//                               onProductSelected(p);
//                               setLocalState(() {});
//                             },
//                             fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
//                               return TextField(
//                                 controller: controller,
//                                 focusNode: focusNode,
//                                 decoration: InputDecoration(
//                                   hintText: 'Search product by name',
//                                   prefixIcon: const Icon(Icons.search),
//                                   suffixIcon: controller.text.isNotEmpty
//                                       ? IconButton(
//                                     icon: const Icon(Icons.clear, size: 18),
//                                     onPressed: () {
//                                       controller.clear();
//                                       onProductSelected(null);
//                                       setLocalState(() {});
//                                     },
//                                   )
//                                       : null,
//                                   filled: true,
//                                   fillColor: AppColors.surface,
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.border),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.border),
//                                   ),
//                                 ),
//                               );
//                             },
//                             optionsViewBuilder: (context, onSelected, options) {
//                               return Align(
//                                 alignment: Alignment.topLeft,
//                                 child: Material(
//                                   elevation: 4,
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: ConstrainedBox(
//                                     constraints: BoxConstraints(maxHeight: Responsive.h(260)),
//                                     child: options.isEmpty
//                                         ? Padding(
//                                       padding: EdgeInsets.all(Responsive.w(14)),
//                                       child: Text('No matching products', style: AppTextStyles.caption()),
//                                     )
//                                         : ListView.separated(
//                                       padding: EdgeInsets.zero,
//                                       shrinkWrap: true,
//                                       itemCount: options.length,
//                                       separatorBuilder: (_, __) => const Divider(height: 1),
//                                       itemBuilder: (context, i) {
//                                         final p = options.elementAt(i);
//                                         return ListTile(
//                                           dense: true,
//                                           title: Text(p.name, overflow: TextOverflow.ellipsis),
//                                           subtitle: Text(p.company, overflow: TextOverflow.ellipsis),
//                                           onTap: () => onSelected(p),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//
//                   SizedBox(height: Responsive.h(10)),
//
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
//                           field: IgnorePointer(
//                             child: CustomTextField(
//                               hint: 'Select a product first',
//                               icon: Icons.straighten_outlined,
//                               controller: itemSizeCtrl,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: Responsive.w(10)),
//                       Expanded(
//                         child: LabeledField(
//                           label: 'Unit (auto)',
//                           field: IgnorePointer(
//                             child: CustomTextField(
//                               hint: 'Select a product first',
//                               icon: Icons.square_foot_outlined,
//                               controller: itemUnitCtrl,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (visibility.showPacking)
//                     LabeledField(
//                       label: 'Packing (auto)',
//                       field: IgnorePointer(
//                         child: CustomTextField(
//                           hint: 'Select a product first',
//                           icon: Icons.inventory_outlined,
//                           controller: itemPackingCtrl,
//                         ),
//                       ),
//                     ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: LabeledField(
//                           label: 'MRP (auto)',
//                           field: IgnorePointer(
//                             child: CustomTextField(
//                               hint: 'MRP',
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
//                             hint: 'Rate',
//                             icon: Icons.currency_rupee,
//                             keyboardType: TextInputType.number,
//                             controller: itemRateCtrl,
//                             inputFormatters: DValidator.decimalNumber,
//                             onChanged: (_) {
//                               setLocalState(() {});
//                               onQtyRateChanged?.call();
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   LabeledField(
//                     label: 'Quantity',
//                     field: CustomTextField(
//                       hint: 'Enter quantity',
//                       icon: Icons.numbers_outlined,
//                       keyboardType: TextInputType.number,
//                       controller: itemQtyCtrl,
//                       inputFormatters: DValidator.decimalNumber,
//                       onChanged: (_) {
//                         setLocalState(() {});
//                         onQuantityChanged();
//                       },
//                     ),
//                   ),
//                   if (_isBoxUnit)
//                     Row(
//                       children: [
//                         Expanded(
//                           child: LabeledField(
//                             label: 'Box Qty (auto)',
//                             field: IgnorePointer(
//                               child: CustomTextField(
//                                 hint: '0',
//                                 icon: Icons.inventory_2_outlined,
//                                 keyboardType: TextInputType.number,
//                                 controller: itemBoxQtyCtrl,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: Responsive.w(10)),
//                         Expanded(
//                           child: LabeledField(
//                             label: 'Piece Qty',
//                             field: CustomTextField(
//                               hint: '0',
//                               icon: Icons.view_module_outlined,
//                               keyboardType: TextInputType.number,
//                               controller: itemPieceQtyCtrl,
//                               inputFormatters: DValidator.decimalNumber,
//                               onChanged: (_) {
//                                 setLocalState(() {});
//                                 onQtyRateChanged?.call();
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
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
//                             child: Text('Editing item #${editingIndex! + 1}', style: AppTextStyles.caption()),
//                           ),
//                           InkWell(
//                             onTap: () {
//                               onCancelEdit();
//                               setLocalState(() {});
//                             },
//                             child: Text('Cancel', style: AppTextStyles.bodyBold(color: AppColors.error)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: isAdding
//                           ? null
//                           : () {
//                         onAddItem();
//                         setLocalState(() {});
//                       },
//                       icon: isAdding
//                           ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                       )
//                           : Icon(
//                         editingIndex != null ? Icons.save_outlined : Icons.add,
//                         color: Colors.white,
//                       ),
//                       label: Text(
//                         isAdding ? 'Calculating…' : (editingIndex != null ? 'Update Item' : 'Add Item'),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//
//                   Text('Items Added (${items.length})', style: AppTextStyles.h3()),
//                   SizedBox(height: Responsive.h(10)),
//
//                   if (items.isEmpty)
//                     Padding(
//                       padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
//                       child: Center(
//                         child: Text('No items added yet', style: AppTextStyles.body(color: AppColors.textHint)),
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
//             BottomActionBar(
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
//   final AddedItem item;
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
//             child: Text('$serialNo', style: AppTextStyles.caption()),
//           ),
//           SizedBox(width: Responsive.w(10)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.name, style: AppTextStyles.bodyBold()),
//                 SizedBox(height: Responsive.h(2)),
//                 Text(
//                   '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}'
//                       '${item.packing.isNotEmpty ? ' | ${item.packing}' : ''}',
//                   style: AppTextStyles.caption(),
//                 ),
//                 SizedBox(height: Responsive.h(2)),
//                 Text(
//                   'Qty: ${item.quantity.toStringAsFixed(2)} ${item.unit}'
//                       '${item.boxQuantity > 0 ? '   Box Qty: ${item.boxQuantity.toStringAsFixed(0)}' : ''}'
//                       '${item.boxQuantity > 0 ? '   Piece Qty: ${item.pieceQuantity.toStringAsFixed(0)}' : ''}'
//                       '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
//                       '   Rate: ${item.rate.toStringAsFixed(0)}',
//                   style: AppTextStyles.caption(),
//                 ),
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
//                   InkWell(onTap: onEdit, child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary)),
//                   SizedBox(width: Responsive.w(14)),
//                   InkWell(onTap: onDelete, child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error)),
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
// // Box Qty / Piece Qty columns only render when at least one item in the
// // preview actually has box/piece quantities. Discount and Payment are
// // owner-only add-ons captured here for the Approve step; they don't
// // change the server-calculated preview totals shown below them.
// // =====================================================================
//
// class PreviewStep extends StatelessWidget {
//   const PreviewStep({
//     super.key,
//     required this.date,
//     required this.partyName,
//     required this.address,
//     required this.phone,
//     required this.customerEmail,
//     required this.contractorName,
//     required this.contractorPhone,
//     required this.contractorEmail,
//     required this.handlingChargeCtrl,
//     required this.notesCtrl,
//     this.discountType,
//     this.discountValue,
//     this.paymentAmount,
//     required this.onHandlingChargeChanged,
//     required this.onAddDiscount,
//     required this.onEditDiscount,
//     required this.onClearDiscount,
//     required this.onAddPayment,
//     required this.onEditPayment,
//     required this.onClearPayment,
//     required this.onRetryPreview,
//     required this.onSaveDraft,
//     required this.onApprove,
//   });
//
//   final DateTime date;
//   final String partyName;
//   final String address;
//   final String phone;
//   final String customerEmail;
//   final String contractorName;
//   final String contractorPhone;
//   final String contractorEmail;
//   final TextEditingController handlingChargeCtrl;
//   final TextEditingController notesCtrl;
//
//   final String? discountType;
//   final double? discountValue;
//   final double? paymentAmount;
//
//   final VoidCallback onHandlingChargeChanged;
//   final VoidCallback onAddDiscount;
//   final VoidCallback onEditDiscount;
//   final VoidCallback onClearDiscount;
//   final VoidCallback onAddPayment;
//   final VoidCallback onEditPayment;
//   final VoidCallback onClearPayment;
//   final VoidCallback onRetryPreview;
//   final VoidCallback onSaveDraft;
//   final VoidCallback onApprove;
//
//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//
//     return Column(
//       children: [
//         Expanded(
//           child: BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
//             buildWhen: (prev, curr) =>
//             prev.previewStatus != curr.previewStatus ||
//                 prev.preview != curr.preview ||
//                 prev.previewError != curr.previewError,
//             builder: (context, state) {
//               if (state.previewStatus == LoadStatus.loading && state.preview == null) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state.previewStatus == LoadStatus.failure && state.preview == null) {
//                 return Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(Responsive.w(24)),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           state.previewError ?? 'Failed to calculate preview.',
//                           textAlign: TextAlign.center,
//                           style: AppTextStyles.body(color: AppColors.error),
//                         ),
//                         SizedBox(height: Responsive.h(12)),
//                         ElevatedButton(onPressed: onRetryPreview, child: const Text('Retry')),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//
//               final preview = state.preview;
//               if (preview == null) return const SizedBox.shrink();
//
//               // Only show Box Qty / Piece Qty columns if at least one
//               // item actually has box/piece quantities.
//               final hasBoxPieceData =
//               preview.items.any((item) => item.boxQuantity > 0 || item.pieceQuantity > 0);
//
//               return ListView(
//                 padding: EdgeInsets.all(Responsive.w(18)),
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(14)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceAlt,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('New Estimate', style: AppTextStyles.h3()),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text('Date', style: AppTextStyles.caption()),
//                             Text(DateFormat('dd-MM-yyyy').format(date), style: AppTextStyles.h3()),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(16)),
//
//                   _PreviewSection(
//                     title: 'Customer Details',
//                     rows: [
//                       _PreviewRow('Party Name', partyName.isEmpty ? '-' : partyName),
//                       _PreviewRow('Address', address.isEmpty ? '-' : address),
//                       _PreviewRow('Contact No.', phone.isEmpty ? '-' : phone),
//                       _PreviewRow('Email', customerEmail.isEmpty ? '-' : customerEmail),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(14)),
//
//                   _PreviewSection(
//                     title: 'Contractor',
//                     rows: [
//                       _PreviewRow('Name', contractorName.isEmpty ? '-' : contractorName),
//                       _PreviewRow('Contact No.', contractorPhone.isEmpty ? '-' : contractorPhone),
//                       _PreviewRow('Email', contractorEmail.isEmpty ? '-' : contractorEmail),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Items', style: AppTextStyles.h3()),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
//                         decoration: BoxDecoration(
//                           color: AppColors.surfaceAlt,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           'Total Items: ${preview.totals.totalItems}',
//                           style: AppTextStyles.bodyBold(color: AppColors.primary),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(10)),
//
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     clipBehavior: Clip.antiAlias,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
//                         headingTextStyle: AppTextStyles.bodyBold(),
//                         dataTextStyle: AppTextStyles.body(),
//                         columnSpacing: 18,
//                         columns: [
//                           const DataColumn(label: Text('Sl.No')),
//                           const DataColumn(label: Text('Item')),
//                           const DataColumn(label: Text('Company')),
//                           const DataColumn(label: Text('Size')),
//                           const DataColumn(label: Text('Qty'), numeric: true),
//                           const DataColumn(label: Text('Unit')),
//                           if (hasBoxPieceData) const DataColumn(label: Text('Box Qty'), numeric: true),
//                           if (hasBoxPieceData) const DataColumn(label: Text('Piece Qty'), numeric: true),
//                           const DataColumn(label: Text('MRP'), numeric: true),
//                           const DataColumn(label: Text('Rate'), numeric: true),
//                           const DataColumn(label: Text('Amount'), numeric: true),
//                         ],
//                         rows: preview.items.asMap().entries.map((entry) {
//                           final i = entry.key;
//                           final item = entry.value;
//                           return DataRow(cells: [
//                             DataCell(Text('${i + 1}')),
//                             DataCell(Text(item.productName)),
//                             DataCell(Text(item.productCompany.isEmpty ? '-' : item.productCompany)),
//                             DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
//                             DataCell(Text(number.format(item.quantity))),
//                             DataCell(Text(item.productUnit)),
//                             if (hasBoxPieceData)
//                               DataCell(Text(item.boxQuantity > 0 ? number.format(item.boxQuantity) : '-')),
//                             if (hasBoxPieceData)
//                               DataCell(Text(item.pieceQuantity > 0 ? number.format(item.pieceQuantity) : '-')),
//                             DataCell(Text(item.mrp > 0 ? number.format(item.mrp) : '-')),
//                             DataCell(Text(number.format(item.rate))),
//                             DataCell(Text(currency.format(item.amount), style: AppTextStyles.bodyBold())),
//                           ]);
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(16)),
//
//                   LabeledField(
//                     label: 'Handling Charge',
//                     field: CustomTextField(
//                       hint: 'Enter handling charge',
//                       icon: Icons.currency_rupee,
//                       keyboardType: TextInputType.number,
//                       controller: handlingChargeCtrl,
//                       inputFormatters: DValidator.decimalNumber,
//                       onChanged: (_) => onHandlingChargeChanged(),
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(10)),
//                   LabeledField(
//                     label: 'Notes (optional)',
//                     field: CustomTextField(
//                       hint: 'e.g. Customer enquiry for new project',
//                       icon: Icons.notes_outlined,
//                       controller: notesCtrl,
//                       inputFormatters: DValidator.textWithLimit,
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(10)),
//
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(14)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceAlt,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Column(
//                       children: [
//                         _totalRow('Total Sq.Ft', number.format(preview.totals.totalSquareFeet)),
//                         if (preview.totals.mrpTotal > 0) ...[
//                           SizedBox(height: Responsive.h(6)),
//                           _totalRow('Total MRP', currency.format(preview.totals.mrpTotal)),
//                         ],
//                         SizedBox(height: Responsive.h(6)),
//                         _totalRow('Subtotal', currency.format(preview.totals.subtotal)),
//                         SizedBox(height: Responsive.h(6)),
//                         _totalRow('Handling Charge', currency.format(preview.totals.handlingCharge)),
//                         const Divider(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Grand Total', style: AppTextStyles.h3()),
//                             Text(currency.format(preview.totals.grandTotal),
//                                 style: AppTextStyles.h2(color: AppColors.primary)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(16)),
//
//                   Text('Owner Adjustments', style: AppTextStyles.h3()),
//                   SizedBox(height: Responsive.h(10)),
//
//                   _AdjustmentCard(
//                     icon: Icons.discount_outlined,
//                     title: 'Additional Discount',
//                     valueLabel: discountType == null || discountValue == null
//                         ? null
//                         : (discountType == QuotationDiscountType.percentage
//                         ? '${_formatNum(discountValue!)}%'
//                         : currency.format(discountValue!)),
//                     onAdd: onAddDiscount,
//                     onEdit: onEditDiscount,
//                     onClear: onClearDiscount,
//                   ),
//                   SizedBox(height: Responsive.h(10)),
//
//                   _AdjustmentCard(
//                     icon: Icons.payments_outlined,
//                     title: 'Payment Received',
//                     valueLabel: paymentAmount == null ? null : currency.format(paymentAmount!),
//                     onAdd: onAddPayment,
//                     onEdit: onEditPayment,
//                     onClear: onClearPayment,
//                   ),
//                   SizedBox(height: Responsive.h(12)),
//                 ],
//               );
//             },
//           ),
//         ),
//         BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
//           buildWhen: (prev, curr) =>
//           prev.submitStatus != curr.submitStatus || prev.submitAction != curr.submitAction,
//           builder: (context, state) {
//             final submitting = state.submitStatus == SubmitStatus.submitting;
//             final savingDraft = submitting && state.submitAction == 'save_quotation';
//             final approving = submitting && state.submitAction == 'approve';
//
//             return BottomActionBar(
//               left: OutlinedButton.icon(
//                 onPressed: submitting ? null : onSaveDraft,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                 ),
//                 icon: savingDraft
//                     ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
//                     : const Icon(Icons.request_quote_outlined, size: 18),
//                 label: Text(savingDraft ? 'Saving…' : 'Save as Quotation'),
//               ),
//               right: PrimaryButton(
//                 label: approving ? 'Approving…' : 'Approve',
//                 height: 48,
//                 onPressed: submitting ? null : onApprove,
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   static String _formatNum(double value) =>
//       value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
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
// class _AdjustmentCard extends StatelessWidget {
//   const _AdjustmentCard({
//     required this.icon,
//     required this.title,
//     required this.valueLabel,
//     required this.onAdd,
//     required this.onEdit,
//     required this.onClear,
//   });
//
//   final IconData icon;
//   final String title;
//   final String? valueLabel;
//   final VoidCallback onAdd;
//   final VoidCallback onEdit;
//   final VoidCallback onClear;
//
//   @override
//   Widget build(BuildContext context) {
//     final hasValue = valueLabel != null;
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: AppColors.primary),
//           SizedBox(width: Responsive.w(10)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: AppTextStyles.bodyBold()),
//                 if (hasValue) ...[
//                   SizedBox(height: Responsive.h(2)),
//                   Text(valueLabel!, style: AppTextStyles.caption(color: AppColors.primary)),
//                 ],
//               ],
//             ),
//           ),
//           if (hasValue) ...[
//             InkWell(onTap: onEdit, child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary)),
//             SizedBox(width: Responsive.w(10)),
//             InkWell(onTap: onClear, child: const Icon(Icons.close, size: 18, color: AppColors.error)),
//           ] else
//             InkWell(
//               onTap: onAdd,
//               child: Text('Add', style: AppTextStyles.bodyBold(color: AppColors.primary)),
//             ),
//         ],
//       ),
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
// class BottomActionBar extends StatelessWidget {
//   const BottomActionBar({
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
//       padding: EdgeInsets.fromLTRB(Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         border: Border(top: BorderSide(color: AppColors.border)),
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_bloc.dart';
import '../../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_event.dart';
import '../../../bloc/ownerbloc/ownerestimatecreate/ownerestimatecreate_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';
import 'ownerestimatetype.dart';



class _UnitFieldVisibility {
  final bool showSize;
  final bool showPacking;

  const _UnitFieldVisibility({
    required this.showSize,
    required this.showPacking,
  });

  factory _UnitFieldVisibility.forProduct(ActiveProductModel? product) {
    if (product == null) {
      return const _UnitFieldVisibility(showSize: false, showPacking: false);
    }
    return _UnitFieldVisibility(
      showSize: product.size.trim().isNotEmpty,
      showPacking: product.packing.trim().isNotEmpty,
    );
  }
}

// =====================================================================
// STEP INDICATOR
// =====================================================================

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.step});
  final EstimateStep step;

  @override
  Widget build(BuildContext context) {
    final index = EstimateStep.values.indexOf(step);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(18), vertical: Responsive.h(10)),
      child: Row(
        children: List.generate(EstimateStep.values.length * 2 - 1, (i) {
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

class DetailsStep extends StatelessWidget {
  const DetailsStep({
    super.key,
    required this.date,
    required this.onDateChanged,
    required this.partyNameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.customerEmailCtrl,
    required this.contractorNameCtrl,
    required this.contractorPhoneCtrl,
    required this.contractorEmailCtrl,
    required this.contractorAddressCtrl,
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
  final TextEditingController contractorAddressCtrl;
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
                field: CustomTextField(
                  hint: 'Enter party name',
                  icon: Icons.groups_2_outlined,
                  controller: partyNameCtrl,
                  inputFormatters: DValidator.lettersOnly,
                ),
              ),
              LabeledField(
                label: 'Address',
                field: CustomTextField(
                  hint: 'Enter site address',
                  icon: Icons.location_on_outlined,
                  controller: addressCtrl,
                  inputFormatters: DValidator.textWithLimit,
                ),
              ),
              LabeledField(
                label: 'Email (optional)',
                field: CustomTextField(
                  hint: 'Enter customer email',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  controller: customerEmailCtrl,
                  inputFormatters: DValidator.textWithLimit,
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
                  controller: contractorNameCtrl,
                  inputFormatters: DValidator.lettersOnly,
                ),
              ),
              LabeledField(
                label: 'Contact No.',
                field: CustomTextField(
                  hint: 'Enter contractor phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: contractorPhoneCtrl,
                  inputFormatters: DValidator.phoneNumber,
                ),
              ),
              LabeledField(
                label: 'Email (optional)',
                field: CustomTextField(
                  hint: 'Enter contractor email',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  controller: contractorEmailCtrl,
                  inputFormatters: DValidator.textWithLimit,
                ),
              ),
              SizedBox(height: Responsive.h(16)),
            ],
          ),
        ),
        BottomActionBar(
          right: PrimaryButton(label: 'Add Items', height: 48, onPressed: onNext),
        ),
      ],
    );
  }
}

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

        return BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
          buildWhen: (prev, curr) =>
          prev.siteVisits != curr.siteVisits ||
              prev.siteVisitsStatus != curr.siteVisitsStatus ||
              prev.selectedSiteVisit != curr.selectedSiteVisit,
          builder: (context, state) {
            List<SiteVisitDropdownItem> matches = [];
            if (query.length >= _minDigitsToSearch) {
              matches = state.siteVisits.where((v) => v.customerPhone.contains(query)).toList();
            }
            final selected = state.selectedSiteVisit;
            final alreadySelected = selected != null && selected.customerPhone == query;
            final showSuggestions = matches.isNotEmpty && !alreadySelected;
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
                    inputFormatters: DValidator.phoneNumber,
                  ),
                ),
                if (query.length >= _minDigitsToSearch && loading) ...[
                  SizedBox(height: Responsive.h(6)),
                  Text('Searching pending site visits…', style: AppTextStyles.caption()),
                ] else if (query.length >= _minDigitsToSearch && failed) ...[
                  SizedBox(height: Responsive.h(6)),
                  InkWell(
                    onTap: () => context.read<OwnerEstimateBloc>().add(const OwnerPendingSiteVisitsRequested()),
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
                  Text('Tap a match to fill party name and address', style: AppTextStyles.caption()),
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
// Amount is never computed locally (no quantity*rate preview). Box Qty
// / Piece Qty only render for box-unit products, with Box Qty auto-set
// from Quantity and Piece Qty user-editable. The Add/Update Item button
// shows a spinner while the fresh product-incentive call is in flight.
// =====================================================================

class AddItemsStep extends StatelessWidget {
  const AddItemsStep({
    super.key,
    required this.selectedProduct,
    required this.onProductSelected,
    required this.itemCompanyCtrl,
    required this.itemSizeCtrl,
    required this.itemUnitCtrl,
    required this.itemPackingCtrl,
    required this.itemMrpCtrl,
    required this.itemQtyCtrl,
    required this.itemBoxQtyCtrl,
    required this.itemPieceQtyCtrl,
    required this.itemRateCtrl,
    required this.isAdding,
    required this.onQuantityChanged,
    this.onQtyRateChanged,
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
  final TextEditingController itemPackingCtrl;
  final TextEditingController itemMrpCtrl;
  final TextEditingController itemQtyCtrl;
  final TextEditingController itemBoxQtyCtrl;
  final TextEditingController itemPieceQtyCtrl;
  final TextEditingController itemRateCtrl;
  final bool isAdding;

  final VoidCallback onQuantityChanged;
  /// Optional — fired on rate/piece-qty edits. Owner screen may leave
  /// this unset since it doesn't run a live incentive preview.
  final VoidCallback? onQtyRateChanged;

  final List<AddedItem> items;
  final int? editingIndex;
  final VoidCallback onAddItem;
  final void Function(int) onEditItem;
  final VoidCallback onCancelEdit;
  final void Function(int) onRemoveItem;
  final VoidCallback onCancel;
  final VoidCallback onSaveItems;

  _UnitFieldVisibility get _fieldVisibility => _UnitFieldVisibility.forProduct(selectedProduct);
  bool get _isBoxUnit => selectedProduct?.isBoxUnit ?? false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final visibility = _fieldVisibility;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
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
                                    context.read<OwnerEstimateBloc>().add(const OwnerActiveProductsRequested()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      return LabeledField(
                        label: 'Select Product',
                        field: KeyedSubtree(
                          key: ValueKey(selectedProduct?.id ?? 'none'),
                          child: Autocomplete<ActiveProductModel>(
                            displayStringForOption: (p) => '${p.name} — ${p.company}',
                            initialValue: TextEditingValue(
                              text: selectedProduct != null
                                  ? '${selectedProduct!.name} — ${selectedProduct!.company}'
                                  : '',
                            ),
                            optionsBuilder: (textEditingValue) {
                              final query = textEditingValue.text.trim().toLowerCase();
                              if (query.isEmpty) return state.products;
                              return state.products.where((p) =>
                              p.name.toLowerCase().contains(query) ||
                                  p.company.toLowerCase().contains(query));
                            },
                            onSelected: (p) {
                              onProductSelected(p);
                              setLocalState(() {});
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Search product by name',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: controller.text.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      controller.clear();
                                      onProductSelected(null);
                                      setLocalState(() {});
                                    },
                                  )
                                      : null,
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
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: Responsive.h(260)),
                                    child: options.isEmpty
                                        ? Padding(
                                      padding: EdgeInsets.all(Responsive.w(14)),
                                      child: Text('No matching products', style: AppTextStyles.caption()),
                                    )
                                        : ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      separatorBuilder: (_, __) => const Divider(height: 1),
                                      itemBuilder: (context, i) {
                                        final p = options.elementAt(i);
                                        return ListTile(
                                          dense: true,
                                          title: Text(p.name, overflow: TextOverflow.ellipsis),
                                          subtitle: Text(p.company, overflow: TextOverflow.ellipsis),
                                          onTap: () => onSelected(p),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
                          field: IgnorePointer(
                            child: CustomTextField(
                              hint: 'Select a product first',
                              icon: Icons.straighten_outlined,
                              controller: itemSizeCtrl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        child: LabeledField(
                          label: 'Unit (auto)',
                          field: IgnorePointer(
                            child: CustomTextField(
                              hint: 'Select a product first',
                              icon: Icons.square_foot_outlined,
                              controller: itemUnitCtrl,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (visibility.showPacking)
                    LabeledField(
                      label: 'Packing (auto)',
                      field: IgnorePointer(
                        child: CustomTextField(
                          hint: 'Select a product first',
                          icon: Icons.inventory_outlined,
                          controller: itemPackingCtrl,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'MRP (auto)',
                          field: IgnorePointer(
                            child: CustomTextField(
                              hint: 'MRP',
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
                            hint: 'Rate',
                            icon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                            controller: itemRateCtrl,
                            inputFormatters: DValidator.decimalNumber,
                            onChanged: (_) {
                              setLocalState(() {});
                              onQtyRateChanged?.call();
                            },
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
                      inputFormatters: DValidator.decimalNumber,
                      onChanged: (_) {
                        setLocalState(() {});
                        onQuantityChanged();
                      },
                    ),
                  ),
                  if (_isBoxUnit)
                    Row(
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'Box Qty (auto)',
                            field: IgnorePointer(
                              child: CustomTextField(
                                hint: '0',
                                icon: Icons.inventory_2_outlined,
                                keyboardType: TextInputType.number,
                                controller: itemBoxQtyCtrl,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.w(10)),
                        Expanded(
                          child: LabeledField(
                            label: 'Piece Qty',
                            field: CustomTextField(
                              hint: '0',
                              icon: Icons.view_module_outlined,
                              keyboardType: TextInputType.number,
                              controller: itemPieceQtyCtrl,
                              inputFormatters: DValidator.decimalNumber,
                              onChanged: (_) {
                                setLocalState(() {});
                                onQtyRateChanged?.call();
                              },
                            ),
                          ),
                        ),
                      ],
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
                            child: Text('Editing item #${editingIndex! + 1}', style: AppTextStyles.caption()),
                          ),
                          InkWell(
                            onTap: () {
                              onCancelEdit();
                              setLocalState(() {});
                            },
                            child: Text('Cancel', style: AppTextStyles.bodyBold(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAdding
                          ? null
                          : () {
                        onAddItem();
                        setLocalState(() {});
                      },
                      icon: isAdding
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Icon(
                        editingIndex != null ? Icons.save_outlined : Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(
                        isAdding ? 'Calculating…' : (editingIndex != null ? 'Update Item' : 'Add Item'),
                      ),
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
                        child: Text('No items added yet', style: AppTextStyles.body(color: AppColors.textHint)),
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
            BottomActionBar(
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
  final AddedItem item;
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
                  '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}'
                      '${item.packing.isNotEmpty ? ' | ${item.packing}' : ''}',
                  style: AppTextStyles.caption(),
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Qty: ${item.quantity.toStringAsFixed(2)} ${item.unit}'
                      '${item.boxQuantity > 0 ? '   Box Qty: ${item.boxQuantity.toStringAsFixed(0)}' : ''}'
                      '${item.boxQuantity > 0 ? '   Piece Qty: ${item.pieceQuantity.toStringAsFixed(0)}' : ''}'
                      '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
                      '   Rate: ${item.rate.toStringAsFixed(0)}',
                  style: AppTextStyles.caption(),
                ),
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
// Box Qty / Piece Qty columns only render when at least one item in the
// preview actually has box/piece quantities. Discount and Payment are
// owner-only add-ons captured here for the Approve step; they don't
// change the server-calculated preview totals shown below them.
// =====================================================================

class PreviewStep extends StatelessWidget {
  const PreviewStep({
    super.key,
    required this.date,
    required this.partyName,
    required this.address,
    required this.phone,
    required this.customerEmail,
    required this.contractorName,
    required this.contractorPhone,
    required this.contractorEmail,
    required this.handlingChargeCtrl,
    required this.notesCtrl,
    this.discountType,
    this.discountValue,
    this.paymentAmount,
    required this.onHandlingChargeChanged,
    required this.onAddDiscount,
    required this.onEditDiscount,
    required this.onClearDiscount,
    required this.onAddPayment,
    required this.onEditPayment,
    required this.onClearPayment,
    required this.onRetryPreview,
    required this.onSaveDraft,
    required this.onApprove,
  });

  final DateTime date;
  final String partyName;
  final String address;
  final String phone;
  final String customerEmail;
  final String contractorName;
  final String contractorPhone;
  final String contractorEmail;
  final TextEditingController handlingChargeCtrl;
  final TextEditingController notesCtrl;

  final String? discountType;
  final double? discountValue;
  final double? paymentAmount;

  final VoidCallback onHandlingChargeChanged;
  final VoidCallback onAddDiscount;
  final VoidCallback onEditDiscount;
  final VoidCallback onClearDiscount;
  final VoidCallback onAddPayment;
  final VoidCallback onEditPayment;
  final VoidCallback onClearPayment;
  final VoidCallback onRetryPreview;
  final VoidCallback onSaveDraft;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return Column(
      children: [
        Expanded(
          child: BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
            buildWhen: (prev, curr) =>
            prev.previewStatus != curr.previewStatus ||
                prev.preview != curr.preview ||
                prev.previewError != curr.previewError,
            builder: (context, state) {
              if (state.previewStatus == LoadStatus.loading && state.preview == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.previewStatus == LoadStatus.failure && state.preview == null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(24)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.previewError ?? 'Failed to calculate preview.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.error),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        ElevatedButton(onPressed: onRetryPreview, child: const Text('Retry')),
                      ],
                    ),
                  ),
                );
              }

              final preview = state.preview;
              if (preview == null) return const SizedBox.shrink();

              // Only show Box Qty / Piece Qty columns if at least one
              // item actually has box/piece quantities.
              final hasBoxPieceData =
              preview.items.any((item) => item.boxQuantity > 0 || item.pieceQuantity > 0);

              // ---- Grand total / discount / payment (display only) ----
              final grandTotal = preview.totals.grandTotal;
              final hasDiscount =
                  discountType != null && discountValue != null && discountValue! > 0;
              double discountAmount = 0;
              if (hasDiscount) {
                discountAmount = discountType == QuotationDiscountType.percentage
                    ? grandTotal * discountValue! / 100
                    : discountValue!;
                if (discountAmount > grandTotal) discountAmount = grandTotal;
              }
              final totalAfterDiscount = grandTotal - discountAmount;
              final hasPayment = paymentAmount != null && paymentAmount! > 0;
              final balanceDue = (totalAfterDiscount - (paymentAmount ?? 0))
                  .clamp(0, double.infinity)
                  .toDouble();

              return ListView(
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
                      _PreviewRow('Email', customerEmail.isEmpty ? '-' : customerEmail),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),

                  _PreviewSection(
                    title: 'Contractor',
                    rows: [
                      _PreviewRow('Name', contractorName.isEmpty ? '-' : contractorName),
                      _PreviewRow('Contact No.', contractorPhone.isEmpty ? '-' : contractorPhone),
                      _PreviewRow('Email', contractorEmail.isEmpty ? '-' : contractorEmail),
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
                          'Total Items: ${preview.totals.totalItems}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary),
                        ),
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
                        columns: [
                          const DataColumn(label: Text('Sl.No')),
                          const DataColumn(label: Text('Item')),
                          const DataColumn(label: Text('Company')),
                          const DataColumn(label: Text('Size')),
                          const DataColumn(label: Text('Qty'), numeric: true),
                          const DataColumn(label: Text('Unit')),
                          if (hasBoxPieceData) const DataColumn(label: Text('Box Qty'), numeric: true),
                          if (hasBoxPieceData) const DataColumn(label: Text('Piece Qty'), numeric: true),
                          const DataColumn(label: Text('MRP'), numeric: true),
                          const DataColumn(label: Text('Rate'), numeric: true),
                          const DataColumn(label: Text('Amount'), numeric: true),
                        ],
                        rows: preview.items.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(item.productName)),
                            DataCell(Text(item.productCompany.isEmpty ? '-' : item.productCompany)),
                            DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
                            DataCell(Text(number.format(item.quantity))),
                            DataCell(Text(item.productUnit)),
                            if (hasBoxPieceData)
                              DataCell(Text(item.boxQuantity > 0 ? number.format(item.boxQuantity) : '-')),
                            if (hasBoxPieceData)
                              DataCell(Text(item.pieceQuantity > 0 ? number.format(item.pieceQuantity) : '-')),
                            DataCell(Text(item.mrp > 0 ? number.format(item.mrp) : '-')),
                            DataCell(Text(number.format(item.rate))),
                            DataCell(Text(currency.format(item.amount), style: AppTextStyles.bodyBold())),
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
                      inputFormatters: DValidator.decimalNumber,
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
                        _totalRow('Total Sq.Ft', number.format(preview.totals.totalSquareFeet)),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Subtotal', currency.format(preview.totals.subtotal)),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Handling Charge', currency.format(preview.totals.handlingCharge)),
                        const Divider(height: 20),
                        // Grand total (server value, before any owner discount).
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grand Total',
                              style: hasDiscount ? AppTextStyles.body() : AppTextStyles.h3(),
                            ),
                            Text(
                              currency.format(grandTotal),
                              style: hasDiscount
                                  ? AppTextStyles.body()
                                  : AppTextStyles.h2(color: AppColors.primary),
                            ),
                          ],
                        ),
                        // Discount applied -> show "Discount - value" and the
                        // total after discount.
                        if (hasDiscount) ...[
                          SizedBox(height: Responsive.h(6)),
                          _totalRow(
                            discountType == QuotationDiscountType.percentage
                                ? 'Discount (${_formatNum(discountValue!)}%)'
                                : 'Discount',
                            '- ${currency.format(discountAmount)}',
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total After Discount', style: AppTextStyles.h3()),
                              Text(currency.format(totalAfterDiscount),
                                  style: AppTextStyles.h2(color: AppColors.primary)),
                            ],
                          ),
                        ],
                        // Payment received is shown only here, in the totals section.
                        if (hasPayment) ...[
                          SizedBox(height: Responsive.h(6)),
                          _totalRow('Payment Received', '- ${currency.format(paymentAmount!)}'),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Balance Due', style: AppTextStyles.h3()),
                              Text(currency.format(balanceDue),
                                  style: AppTextStyles.h2(color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  Text('Owner Adjustments', style: AppTextStyles.h3()),
                  SizedBox(height: Responsive.h(10)),

                  _AdjustmentCard(
                    icon: Icons.discount_outlined,
                    title: 'Additional Discount',
                    valueLabel: discountType == null || discountValue == null
                        ? null
                        : (discountType == QuotationDiscountType.percentage
                        ? '${_formatNum(discountValue!)}%'
                        : currency.format(discountValue!)),
                    onAdd: onAddDiscount,
                    onEdit: onEditDiscount,
                    onClear: onClearDiscount,
                  ),
                  SizedBox(height: Responsive.h(10)),

                  _AdjustmentCard(
                    icon: Icons.payments_outlined,
                    title: 'Payment Received',
                    valueLabel: paymentAmount == null ? null : currency.format(paymentAmount!),
                    onAdd: onAddPayment,
                    onEdit: onEditPayment,
                    onClear: onClearPayment,
                  ),
                  SizedBox(height: Responsive.h(12)),
                ],
              );
            },
          ),
        ),
        BlocBuilder<OwnerEstimateBloc, OwnerEstimateState>(
          buildWhen: (prev, curr) =>
          prev.submitStatus != curr.submitStatus || prev.submitAction != curr.submitAction,
          builder: (context, state) {
            final submitting = state.submitStatus == SubmitStatus.submitting;
            final savingDraft = submitting && state.submitAction == 'save_quotation';
            final approving = submitting && state.submitAction == 'approve';

            return BottomActionBar(
              left: OutlinedButton.icon(
                onPressed: submitting ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: savingDraft
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.request_quote_outlined, size: 18),
                label: Text(savingDraft ? 'Saving…' : 'Save as Quotation'),
              ),
              right: PrimaryButton(
                label: approving ? 'Approving…' : 'Approve',
                height: 48,
                onPressed: submitting ? null : onApprove,
              ),
            );
          },
        ),
      ],
    );
  }

  static String _formatNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

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

class _AdjustmentCard extends StatelessWidget {
  const _AdjustmentCard({
    required this.icon,
    required this.title,
    required this.valueLabel,
    required this.onAdd,
    required this.onEdit,
    required this.onClear,
  });

  final IconData icon;
  final String title;
  final String? valueLabel;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasValue = valueLabel != null;
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold()),
                if (hasValue) ...[
                  SizedBox(height: Responsive.h(2)),
                  Text(valueLabel!, style: AppTextStyles.caption(color: AppColors.primary)),
                ],
              ],
            ),
          ),
          if (hasValue) ...[
            InkWell(onTap: onEdit, child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary)),
            SizedBox(width: Responsive.w(10)),
            InkWell(onTap: onClear, child: const Icon(Icons.close, size: 18, color: AppColors.error)),
          ] else
            InkWell(
              onTap: onAdd,
              child: Text('Add', style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ),
        ],
      ),
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

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    this.left,
    required this.right,
  });

  final Widget? left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
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