//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_bloc.dart';
// import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_event.dart';
// import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_state.dart';
//
// import '../../core/validator/validationfile.dart';
// import '../../models/owner_models/ownerdespatchsheetpreparemodel.dart';
// import '../../widgets/appsnackbar.dart';
// import '../../widgets/primary_button.dart';
//
// // ---------------------------------------------------------------------
// // Shared look (mirrors the Estimate Detail screen styling).
// // If you already export these from the estimate detail widgets file,
// // you can delete these private copies and import that file instead.
// // ---------------------------------------------------------------------
//
// /// Standard column widths for the items grid.
// class _DsCol {
//   static const double sl = 60; // #
//   static const double text = 250; // Item / Company
//   static const double size = 120; // Size
//   static const double unit = 150; // Unit
//   static const double input = 110; // Box / Pcs inputs
// }
//
// BoxDecoration _cardDecoration({double radius = 14}) => BoxDecoration(
//   color: AppColors.surface,
//   borderRadius: BorderRadius.circular(radius),
//   border: Border.all(color: AppColors.border.withOpacity(0.8)),
//   boxShadow: [
//     BoxShadow(
//       color: Colors.black.withOpacity(0.04),
//       blurRadius: 10,
//       offset: const Offset(0, 3),
//     ),
//   ],
// );
//
// class _IconBadge extends StatelessWidget {
//   const _IconBadge(this.icon, {this.color, this.size = 16});
//   final IconData icon;
//   final Color? color;
//   final double size;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = color ?? AppColors.primary;
//     return Container(
//       padding: const EdgeInsets.all(7),
//       decoration: BoxDecoration(
//         color: c.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(9),
//       ),
//       child: Icon(icon, size: size, color: c),
//     );
//   }
// }
//
// /// Card with a tinted title bar (icon + title) and a padded body.
// class _SectionCard extends StatelessWidget {
//   const _SectionCard({
//     required this.title,
//     required this.icon,
//     required this.child,
//     this.trailing,
//   });
//
//   final String title;
//   final IconData icon;
//   final Widget child;
//   final Widget? trailing;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: _cardDecoration(),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(
//                 horizontal: Responsive.w(14), vertical: Responsive.h(12)),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.05),
//               border: Border(
//                 bottom: BorderSide(color: AppColors.border.withOpacity(0.7)),
//               ),
//             ),
//             child: Row(
//               children: [
//                 _IconBadge(icon),
//                 SizedBox(width: Responsive.w(10)),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: AppTextStyles.bodyBold(color: AppColors.primary)
//                         .copyWith(fontSize: Responsive.sp(14)),
//                   ),
//                 ),
//                 if (trailing != null) trailing!,
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(Responsive.w(14)),
//             child: child,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ---------------------------------------------------------------------
// // Screen
// // ---------------------------------------------------------------------
//
// class OwnerDespatchSheetScreen extends StatelessWidget {
//   const OwnerDespatchSheetScreen({super.key, required this.estimateId});
//   final String estimateId;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => OwnerDespatchSheetBloc()
//         ..add(OwnerDespatchSheetLoadRequested(estimateId)),
//       child: _OwnerDespatchSheetView(estimateId: estimateId),
//     );
//   }
// }
//
// class _OwnerDespatchSheetView extends StatelessWidget {
//   const _OwnerDespatchSheetView({required this.estimateId});
//   final String estimateId;
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return NetworkAwareWrapper(
//       child: BlocConsumer<OwnerDespatchSheetBloc, OwnerDespatchSheetState>(
//         listenWhen: (previous, current) =>
//         previous.submitStatus != current.submitStatus,
//         listener: (context, state) {
//           if (state.submitStatus == OwnerDespatchSubmitStatus.success) {
//             AppSnackbar.success(state.submitMessage ?? 'Despatch sheet created');
//             // Single place this screen is popped from; the back button is
//             // fully blocked while a submit is in progress.
//             if (context.mounted && Navigator.of(context).canPop()) {
//               Navigator.of(context).pop(true);
//             }
//           } else if (state.submitStatus == OwnerDespatchSubmitStatus.failure) {
//             AppSnackbar.error(
//                 state.submitMessage ?? 'Failed to create despatch sheet');
//           }
//         },
//         builder: (context, state) {
//           final isSubmitting =
//               state.submitStatus == OwnerDespatchSubmitStatus.inProgress;
//
//           return PopScope(
//             canPop: !isSubmitting,
//             onPopInvokedWithResult: (didPop, result) {
//               if (!didPop && isSubmitting) {
//                 AppSnackbar.error(
//                     'Please wait until the despatch sheet finishes saving.');
//               }
//             },
//             child: Scaffold(
//               backgroundColor: AppColors.background,
//               appBar: AppBar(
//                 title: Text('Create Despatch Sheet', style: AppTextStyles.h6()),
//                 automaticallyImplyLeading: !isSubmitting,
//               ),
//               body: SafeArea(
//                 child: Builder(
//                   builder: (context) {
//                     if (state.status == OwnerDespatchSheetStatus.loading ||
//                         state.status == OwnerDespatchSheetStatus.initial) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (state.status == OwnerDespatchSheetStatus.failure ||
//                         state.suggestion == null) {
//                       return Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(state.errorMessage ??
//                                 'Failed to load despatch details.'),
//                             SizedBox(height: Responsive.h(10)),
//                             ElevatedButton(
//                               onPressed: () => context
//                                   .read<OwnerDespatchSheetBloc>()
//                                   .add(OwnerDespatchSheetLoadRequested(
//                                   estimateId)),
//                               child: const Text('Retry'),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//
//                     return _DespatchForm(
//                       estimateId: estimateId,
//                       suggestion: state.suggestion!,
//                       drivers: state.drivers,
//                       isSubmitting: isSubmitting,
//                       driverLoadError:
//                       state.drivers.isEmpty ? state.errorMessage : null,
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _DespatchForm extends StatefulWidget {
//   const _DespatchForm({
//     required this.estimateId,
//     required this.suggestion,
//     required this.drivers,
//     required this.isSubmitting,
//     this.driverLoadError,
//   });
//
//   final String estimateId;
//   final DespatchSuggestionModel suggestion;
//   final List<DriverModel> drivers;
//   final bool isSubmitting;
//   final String? driverLoadError;
//
//   @override
//   State<_DespatchForm> createState() => _DespatchFormState();
// }
//
// class _DespatchFormState extends State<_DespatchForm> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController _refNoCtrl;
//   late final TextEditingController _partyNameCtrl;
//   late final TextEditingController _contactCtrl;
//   late final TextEditingController _addressCtrl;
//   late final TextEditingController _vehicleCtrl;
//   final _notesCtrl = TextEditingController();
//
//   String? _selectedDriverId;
//   String? _selectedDriverName;
//   DateTime _despatchDate = DateTime.now();
//
//   late final Map<String, TextEditingController> _boxesCtrls;
//   late final Map<String, TextEditingController> _piecesCtrls;
//   late final Map<String, TextEditingController> _qtyCtrls;
//
//   // One font size for form fields, matching the table cells on the
//   // estimate detail screen.
//   double get _fieldFontSize => Responsive.sp(13);
//
//   InputDecoration _decor(String label,
//       {IconData? icon, String? hint, String? error}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: AppTextStyles.caption().copyWith(fontSize: Responsive.sp(12.5)),
//       prefixIcon: icon != null
//           ? Icon(icon, size: 18, color: AppColors.textHint)
//           : null,
//       errorText: error,
//       filled: true,
//       fillColor: AppColors.surface,
//       isDense: true,
//       contentPadding: EdgeInsets.symmetric(
//         horizontal: Responsive.w(12),
//         vertical: Responsive.h(12),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: AppColors.border),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: AppColors.primary),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: Colors.red),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: Colors.red),
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: AppColors.border),
//       ),
//     );
//   }
//
//   TextStyle get _fieldStyle =>
//       AppTextStyles.bodyBold().copyWith(fontSize: _fieldFontSize);
//
//   @override
//   void initState() {
//     super.initState();
//     final s = widget.suggestion;
//     _refNoCtrl = TextEditingController(text: s.estimateNumber);
//     _partyNameCtrl = TextEditingController(text: s.partyName);
//     _contactCtrl = TextEditingController(text: s.contactNumber);
//     _addressCtrl = TextEditingController(text: s.deliveryAddress);
//     _vehicleCtrl = TextEditingController();
//
//     _boxesCtrls = {
//       for (final item in s.items)
//         item.estimateItemId:
//         TextEditingController(text: item.suggestedBoxes.toString()),
//     };
//     _piecesCtrls = {
//       for (final item in s.items)
//         item.estimateItemId:
//         TextEditingController(text: item.suggestedPieces.toString()),
//     };
//     _qtyCtrls = {
//       for (final item in s.items)
//         item.estimateItemId: TextEditingController(
//             text: item.suggestedQuantity.toStringAsFixed(0)),
//     };
//   }
//
//   @override
//   void dispose() {
//     _refNoCtrl.dispose();
//     _partyNameCtrl.dispose();
//     _contactCtrl.dispose();
//     _addressCtrl.dispose();
//     _vehicleCtrl.dispose();
//     _notesCtrl.dispose();
//     for (final c in _boxesCtrls.values) c.dispose();
//     for (final c in _piecesCtrls.values) c.dispose();
//     for (final c in _qtyCtrls.values) c.dispose();
//     super.dispose();
//   }
//
//   Widget _gap([double h = 12]) => SizedBox(height: Responsive.h(h));
//
//   @override
//   Widget build(BuildContext context) {
//     final s = widget.suggestion;
//
//     return Column(
//       children: [
//         Expanded(
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               padding: EdgeInsets.all(Responsive.w(16)),
//               children: [
//                 // ---- Header (same look as EstimateHeader) ----
//                 _buildHeader(s),
//                 _gap(16),
//
//                 // ---- Delivery details ----
//                 _SectionCard(
//                   title: 'Delivery Details',
//                   icon: Icons.local_shipping_outlined,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: _refNoCtrl,
//                         style: _fieldStyle,
//                         inputFormatters: DValidator.textWithLimit,
//                         decoration: _decor('Reference No.',
//                             icon: Icons.confirmation_number_outlined),
//                         validator: (v) => DValidator.validateRequired(v,
//                             message: 'Reference No. is required'),
//                       ),
//                       _gap(),
//                       TextFormField(
//                         controller: _partyNameCtrl,
//                         style: _fieldStyle,
//                         inputFormatters: DValidator.lettersOnly,
//                         decoration:
//                         _decor('Party Name', icon: Icons.groups_2_outlined),
//                         validator: (v) =>
//                             DValidator.validateName('Party Name', v),
//                       ),
//                       _gap(),
//                       TextFormField(
//                         controller: _contactCtrl,
//                         style: _fieldStyle,
//                         keyboardType: TextInputType.phone,
//                         inputFormatters: DValidator.phoneNumber,
//                         decoration:
//                         _decor('Contact Number', icon: Icons.call_outlined),
//                         validator: (v) => DValidator.validatePhoneNumber(v),
//                       ),
//                       _gap(),
//                       TextFormField(
//                         controller: _addressCtrl,
//                         style: _fieldStyle,
//                         minLines: 2,
//                         maxLines: 4,
//                         inputFormatters: DValidator.textWithLimit,
//                         decoration: _decor('Delivery Address',
//                             icon: Icons.location_on_outlined),
//                         validator: (v) => DValidator.validateRequired(v,
//                             message: 'Delivery Address is required'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _gap(16),
//
//                 // ---- Driver & vehicle ----
//                 _SectionCard(
//                   title: 'Driver & Vehicle',
//                   icon: Icons.person_pin_circle_outlined,
//                   child: Column(
//                     children: [
//                       if (widget.drivers.isEmpty)
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(Responsive.w(12)),
//                           decoration: BoxDecoration(
//                             color: AppColors.surfaceAlt.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: AppColors.border),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.info_outline,
//                                   size: 18, color: AppColors.textHint),
//                               SizedBox(width: Responsive.w(8)),
//                               Expanded(
//                                 child: Text(
//                                   widget.driverLoadError ??
//                                       'No active drivers available.',
//                                   style: AppTextStyles.caption(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       else
//                         DropdownButtonFormField<String>(
//                           value: _selectedDriverId,
//                           isExpanded: true,
//                           icon: const Icon(Icons.keyboard_arrow_down_rounded),
//                           decoration: _decor('Assign Driver',
//                               icon: Icons.person_outline),
//                           items: widget.drivers
//                               .map((d) => DropdownMenuItem(
//                             value: d.id,
//                             child: Text(d.name, style: _fieldStyle),
//                           ))
//                               .toList(),
//                           onChanged: (v) {
//                             final driver =
//                             widget.drivers.firstWhere((d) => d.id == v);
//                             setState(() {
//                               _selectedDriverId = driver.id;
//                               _selectedDriverName = driver.name;
//                             });
//                           },
//                           validator: (v) =>
//                               DValidator.validateDropdown<String>('driver', v),
//                         ),
//                       _gap(),
//                       InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: () async {
//                           final picked = await showDatePicker(
//                             context: context,
//                             initialDate: _despatchDate,
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2100),
//                           );
//                           if (picked != null) {
//                             setState(() => _despatchDate = picked);
//                           }
//                         },
//                         child: InputDecorator(
//                           decoration: _decor('Despatch Date',
//                               icon: Icons.event_outlined),
//                           child: Text(
//                             DateFormat('yyyy-MM-dd').format(_despatchDate),
//                             style: _fieldStyle,
//                           ),
//                         ),
//                       ),
//                       _gap(),
//                       TextFormField(
//                         controller: _notesCtrl,
//                         style: _fieldStyle,
//                         minLines: 1,
//                         maxLines: 3,
//                         inputFormatters: DValidator.textWithLimit,
//                         decoration: _decor('Delivery Notes (optional)',
//                             icon: Icons.notes_outlined),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _gap(18),
//
//                 // ---- Items ----
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const _IconBadge(Icons.list_alt_rounded),
//                         SizedBox(width: Responsive.w(10)),
//                         Text('Items', style: AppTextStyles.h3()),
//                       ],
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: Responsive.w(12),
//                           vertical: Responsive.h(5)),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '${s.items.length} ${s.items.length == 1 ? 'item' : 'items'}',
//                         style: AppTextStyles.bodyBold(color: AppColors.primary)
//                             .copyWith(fontSize: Responsive.sp(12)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 _gap(12),
//                 _DespatchItemsTable(
//                   items: s.items,
//                   boxesCtrls: _boxesCtrls,
//                   piecesCtrls: _piecesCtrls,
//                   qtyCtrls: _qtyCtrls,
//                 ),
//                 if (s.items.isNotEmpty) ...[
//                   _gap(6),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.swipe_rounded,
//                           size: 14, color: AppColors.textHint),
//                       SizedBox(width: Responsive.w(4)),
//                       Text('Swipe sideways to see all columns',
//                           style: AppTextStyles.caption()
//                               .copyWith(fontSize: Responsive.sp(11))),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(10),
//               Responsive.w(16), Responsive.h(16)),
//           decoration: BoxDecoration(
//             color: AppColors.background,
//             border: Border(top: BorderSide(color: AppColors.border)),
//           ),
//           child: PrimaryButton(
//             label:
//             widget.isSubmitting ? 'Please wait...' : 'Create Despatch Sheet',
//             height: 48,
//             onPressed: widget.isSubmitting ? null : _submit,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHeader(DespatchSuggestionModel s) {
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(16)),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary.withOpacity(0.10),
//             AppColors.primary.withOpacity(0.02),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.primary.withOpacity(0.16)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const _IconBadge(Icons.local_shipping_rounded, size: 20),
//           SizedBox(height: Responsive.h(14)),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('ESTIMATE NO.',
//                         style:
//                         AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
//                     SizedBox(height: Responsive.h(4)),
//                     Text(
//                       s.estimateNumber,
//                       style: AppTextStyles.bodyBold()
//                           .copyWith(fontSize: Responsive.sp(16)),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: Responsive.w(12)),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text('DS NO. (PREVIEW)',
//                       style:
//                       AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
//                   SizedBox(height: Responsive.h(4)),
//                   Text(
//                     s.previewDsNumber,
//                     style: AppTextStyles.bodyBold()
//                         .copyWith(fontSize: Responsive.sp(16)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _submit() {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedDriverId == null || _selectedDriverName == null) {
//       AppSnackbar.error('Please assign a driver');
//       return;
//     }
//
//     final items = widget.suggestion.items.map((item) {
//       final id = item.estimateItemId;
//       return OwnerDespatchItemRequest(
//         estimateItemId: id,
//         boxes: int.tryParse(_boxesCtrls[id]!.text.trim()) ?? 0,
//         pieces: int.tryParse(_piecesCtrls[id]!.text.trim()) ?? 0,
//         quantity: double.tryParse(_qtyCtrls[id]!.text.trim()) ?? 0,
//       );
//     }).toList();
//
//     final request = OwnerDespatchCreateRequest(
//       estimateId: widget.estimateId,
//       refNo: _refNoCtrl.text.trim(),
//       partyName: _partyNameCtrl.text.trim(),
//       contactNumber: _contactCtrl.text.trim(),
//       deliveryAddress: _addressCtrl.text.trim(),
//       driverId: _selectedDriverId!,
//       driverName: _selectedDriverName!,
//       vehicleNumber: _vehicleCtrl.text.trim(),
//       items: items,
//       despatchDate: DateFormat('yyyy-MM-dd').format(_despatchDate),
//       deliveryNotes:
//       _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
//     );
//
//     context
//         .read<OwnerDespatchSheetBloc>()
//         .add(OwnerDespatchCreateRequested(request));
//   }
// }
//
// // ---------------------------------------------------------------------
// // Items table — same bill-style grid as the estimate detail screen:
// // fixed column widths, tinted header, zebra rows, horizontal scroll.
// // ---------------------------------------------------------------------
//
// class _DespatchItemsTable extends StatefulWidget {
//   const _DespatchItemsTable({
//     required this.items,
//     required this.boxesCtrls,
//     required this.piecesCtrls,
//     required this.qtyCtrls,
//   });
//
//   final List<DespatchSuggestionItem> items;
//   final Map<String, TextEditingController> boxesCtrls;
//   final Map<String, TextEditingController> piecesCtrls;
//   final Map<String, TextEditingController> qtyCtrls; // kept for submit only
//
//   @override
//   State<_DespatchItemsTable> createState() => _DespatchItemsTableState();
// }
//
// class _DespatchItemsTableState extends State<_DespatchItemsTable> {
//   final _horizontalController = ScrollController();
//
//   @override
//   void dispose() {
//     _horizontalController.dispose();
//     super.dispose();
//   }
//
//   static double get _cellFontSize => Responsive.sp(12.5);
//
//   Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: Responsive.w(10), vertical: Responsive.h(12)),
//       child: Text(
//         text,
//         textAlign: align,
//         maxLines: 1,
//         softWrap: false,
//         overflow: TextOverflow.ellipsis,
//         style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(
//           fontSize: _cellFontSize,
//           letterSpacing: 0.2,
//         ),
//       ),
//     );
//   }
//
//   Widget _dataCell(String text,
//       {TextAlign align = TextAlign.left, bool bold = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: Responsive.w(10), vertical: Responsive.h(10)),
//       child: Text(
//         text,
//         textAlign: align,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
//             .copyWith(fontSize: _cellFontSize),
//       ),
//     );
//   }
//
//   Widget _inputCell(TextEditingController? ctrl, String label) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: Responsive.w(10), vertical: Responsive.h(6)),
//       child: TextFormField(
//         controller: ctrl,
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         inputFormatters: DValidator.digitsOnly,
//         style: AppTextStyles.bodyBold().copyWith(fontSize: _cellFontSize),
//         decoration: InputDecoration(
//           isDense: true,
//           filled: true,
//           fillColor: AppColors.surface,
//           contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: AppColors.border),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: AppColors.primary),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.red),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.red),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: AppColors.border),
//           ),
//         ),
//         validator: (v) => DValidator.validateOptionalNumber(label, v),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final items = widget.items;
//
//     if (items.isEmpty) {
//       return Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(Responsive.w(18)),
//         decoration: _cardDecoration(),
//         child: Text('No items to despatch.', style: AppTextStyles.caption()),
//       );
//     }
//
//     return Container(
//       decoration: _cardDecoration(),
//       clipBehavior: Clip.antiAlias,
//       child: Scrollbar(
//         controller: _horizontalController,
//         thumbVisibility: true,
//         child: SingleChildScrollView(
//           controller: _horizontalController,
//           scrollDirection: Axis.horizontal,
//           child: Table(
//             defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//             border: TableBorder(
//               horizontalInside:
//               BorderSide(color: AppColors.border.withOpacity(0.45)),
//               verticalInside:
//               BorderSide(color: AppColors.border.withOpacity(0.30)),
//             ),
//             columnWidths: const {
//               0: FixedColumnWidth(_DsCol.sl), // #
//               1: FixedColumnWidth(_DsCol.text), // Item
//               2: FixedColumnWidth(_DsCol.text), // Company
//               3: FixedColumnWidth(_DsCol.size), // Size
//               4: FixedColumnWidth(_DsCol.unit), // Unit
//               5: FixedColumnWidth(_DsCol.input), // Box
//               6: FixedColumnWidth(_DsCol.input), // Pcs
//             },
//             children: [
//               // ---- Header row ----
//               TableRow(
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.09),
//                   border: Border(
//                     bottom: BorderSide(
//                         color: AppColors.primary.withOpacity(0.35), width: 1.4),
//                   ),
//                 ),
//                 children: [
//                   _headerCell('#', align: TextAlign.center),
//                   _headerCell('Item'),
//                   _headerCell('Company'),
//                   _headerCell('Size'),
//                   _headerCell('Unit'),
//                   _headerCell('Box', align: TextAlign.center),
//                   _headerCell('Pcs', align: TextAlign.center),
//                 ],
//               ),
//               // ---- Data rows ----
//               for (var i = 0; i < items.length; i++)
//                 TableRow(
//                   decoration: BoxDecoration(
//                     color: i.isEven
//                         ? AppColors.surface
//                         : AppColors.surfaceAlt.withOpacity(0.45),
//                   ),
//                   children: [
//                     _dataCell('${i + 1}', align: TextAlign.center),
//                     _dataCell(items[i].productName, bold: true),
//                     _dataCell(items[i].companyName.isEmpty
//                         ? '-'
//                         : items[i].companyName),
//                     _dataCell(items[i].productSize.isEmpty
//                         ? '-'
//                         : items[i].productSize),
//                     _dataCell(items[i].unit.isEmpty ? '-' : items[i].unit),
//                     _inputCell(
//                         widget.boxesCtrls[items[i].estimateItemId], 'Boxes'),
//                     _inputCell(
//                         widget.piecesCtrls[items[i].estimateItemId], 'Pieces'),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_bloc.dart';
import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_event.dart';
import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_state.dart';

import '../../core/validator/validationfile.dart';
import '../../models/owner_models/ownerdespatchsheetpreparemodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/primary_button.dart';

// ---------------------------------------------------------------------
// Shared look (mirrors the Estimate Detail screen styling).
// If you already export these from the estimate detail widgets file,
// you can delete these private copies and import that file instead.
// ---------------------------------------------------------------------

/// Standard column widths for the items grid.
class _DsCol {
  static const double sl = 60; // #
  static const double text = 250; // Item / Company
  static const double size = 120; // Size
  static const double unit = 150; // Unit
  static const double input = 110; // Box / Pcs inputs
}

BoxDecoration _cardDecoration({double radius = 14}) => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border.withOpacity(0.8)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, {this.color, this.size = 16});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

/// Card with a tinted title bar (icon + title) and a padded body.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: AppColors.border.withOpacity(0.7)),
              ),
            ),
            child: Row(
              children: [
                _IconBadge(icon),
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyBold(color: AppColors.primary)
                        .copyWith(fontSize: Responsive.sp(14)),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------

class OwnerDespatchSheetScreen extends StatelessWidget {
  const OwnerDespatchSheetScreen({super.key, required this.estimateId});
  final String estimateId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerDespatchSheetBloc()
        ..add(OwnerDespatchSheetLoadRequested(estimateId)),
      child: _OwnerDespatchSheetView(estimateId: estimateId),
    );
  }
}

class _OwnerDespatchSheetView extends StatelessWidget {
  const _OwnerDespatchSheetView({required this.estimateId});
  final String estimateId;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return NetworkAwareWrapper(
      child: BlocConsumer<OwnerDespatchSheetBloc, OwnerDespatchSheetState>(
        listenWhen: (previous, current) =>
        previous.submitStatus != current.submitStatus,
        listener: (context, state) {
          if (state.submitStatus == OwnerDespatchSubmitStatus.success) {
            AppSnackbar.success(state.submitMessage ?? 'Despatch sheet created');
            // Single place this screen is popped from; the back button is
            // fully blocked while a submit is in progress.
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            }
          } else if (state.submitStatus == OwnerDespatchSubmitStatus.failure) {
            AppSnackbar.error(
                state.submitMessage ?? 'Failed to create despatch sheet');
          }
        },
        builder: (context, state) {
          final isSubmitting =
              state.submitStatus == OwnerDespatchSubmitStatus.inProgress;

          return PopScope(
            canPop: !isSubmitting,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && isSubmitting) {
                AppSnackbar.error(
                    'Please wait until the despatch sheet finishes saving.');
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text('Create Despatch Sheet', style: AppTextStyles.h6()),
                automaticallyImplyLeading: !isSubmitting,
              ),
              body: SafeArea(
                child: Builder(
                  builder: (context) {
                    if (state.status == OwnerDespatchSheetStatus.loading ||
                        state.status == OwnerDespatchSheetStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == OwnerDespatchSheetStatus.failure ||
                        state.suggestion == null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.errorMessage ??
                                'Failed to load despatch details.'),
                            SizedBox(height: Responsive.h(10)),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<OwnerDespatchSheetBloc>()
                                  .add(OwnerDespatchSheetLoadRequested(
                                  estimateId)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return _DespatchForm(
                      estimateId: estimateId,
                      suggestion: state.suggestion!,
                      drivers: state.drivers,
                      isSubmitting: isSubmitting,
                      driverLoadError:
                      state.drivers.isEmpty ? state.errorMessage : null,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DespatchForm extends StatefulWidget {
  const _DespatchForm({
    required this.estimateId,
    required this.suggestion,
    required this.drivers,
    required this.isSubmitting,
    this.driverLoadError,
  });

  final String estimateId;
  final DespatchSuggestionModel suggestion;
  final List<DriverModel> drivers;
  final bool isSubmitting;
  final String? driverLoadError;

  @override
  State<_DespatchForm> createState() => _DespatchFormState();
}

class _DespatchFormState extends State<_DespatchForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _refNoCtrl;
  late final TextEditingController _partyNameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _vehicleCtrl;
  final _notesCtrl = TextEditingController();

  String? _selectedDriverId;
  String? _selectedDriverName;
  DateTime _despatchDate = DateTime.now();

  late final Map<String, TextEditingController> _boxesCtrls;
  late final Map<String, TextEditingController> _piecesCtrls;
  late final Map<String, TextEditingController> _qtyCtrls;

  // Font sizes now follow the Estimate Detail screen: form values use the
  // default bodyBold style and labels use the default caption style.
  InputDecoration _decor(String label,
      {IconData? icon, String? hint, String? error}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.caption(),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: AppColors.textHint)
          : null,
      errorText: error,
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.w(12),
        vertical: Responsive.h(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
    );
  }

  TextStyle get _fieldStyle => AppTextStyles.bodyBold();

  @override
  void initState() {
    super.initState();
    final s = widget.suggestion;
    _refNoCtrl = TextEditingController(text: s.estimateNumber);
    _partyNameCtrl = TextEditingController(text: s.partyName);
    _contactCtrl = TextEditingController(text: s.contactNumber);
    _addressCtrl = TextEditingController(text: s.deliveryAddress);
    _vehicleCtrl = TextEditingController();

    _boxesCtrls = {
      for (final item in s.items)
        item.estimateItemId:
        TextEditingController(text: item.suggestedBoxes.toString()),
    };
    _piecesCtrls = {
      for (final item in s.items)
        item.estimateItemId:
        TextEditingController(text: item.suggestedPieces.toString()),
    };
    _qtyCtrls = {
      for (final item in s.items)
        item.estimateItemId: TextEditingController(
            text: item.suggestedQuantity.toStringAsFixed(0)),
    };
  }

  @override
  void dispose() {
    _refNoCtrl.dispose();
    _partyNameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _vehicleCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _boxesCtrls.values) c.dispose();
    for (final c in _piecesCtrls.values) c.dispose();
    for (final c in _qtyCtrls.values) c.dispose();
    super.dispose();
  }

  Widget _gap([double h = 12]) => SizedBox(height: Responsive.h(h));

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;

    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(Responsive.w(16)),
              children: [
                // ---- Header (same look as EstimateHeader) ----
                _buildHeader(s),
                _gap(16),

                // ---- Delivery details ----
                _SectionCard(
                  title: 'Delivery Details',
                  icon: Icons.local_shipping_outlined,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _refNoCtrl,
                        style: _fieldStyle,
                        inputFormatters: DValidator.textWithLimit,
                        decoration: _decor('Reference No.',
                            icon: Icons.confirmation_number_outlined),
                        validator: (v) => DValidator.validateRequired(v,
                            message: 'Reference No. is required'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: _partyNameCtrl,
                        style: _fieldStyle,
                        inputFormatters: DValidator.lettersOnly,
                        decoration:
                        _decor('Party Name', icon: Icons.groups_2_outlined),
                        validator: (v) =>
                            DValidator.validateName('Party Name', v),
                      ),
                      _gap(),
                      TextFormField(
                        controller: _contactCtrl,
                        style: _fieldStyle,
                        keyboardType: TextInputType.phone,
                        inputFormatters: DValidator.phoneNumber,
                        decoration:
                        _decor('Contact Number', icon: Icons.call_outlined),
                        validator: (v) => DValidator.validatePhoneNumber(v),
                      ),
                      _gap(),
                      TextFormField(
                        controller: _addressCtrl,
                        style: _fieldStyle,
                        minLines: 2,
                        maxLines: 4,
                        inputFormatters: DValidator.textWithLimit,
                        decoration: _decor('Delivery Address',
                            icon: Icons.location_on_outlined),
                        validator: (v) => DValidator.validateRequired(v,
                            message: 'Delivery Address is required'),
                      ),
                    ],
                  ),
                ),
                _gap(16),

                // ---- Driver & vehicle ----
                _SectionCard(
                  title: 'Driver & Vehicle',
                  icon: Icons.person_pin_circle_outlined,
                  child: Column(
                    children: [
                      if (widget.drivers.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(Responsive.w(12)),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: AppColors.textHint),
                              SizedBox(width: Responsive.w(8)),
                              Expanded(
                                child: Text(
                                  widget.driverLoadError ??
                                      'No active drivers available.',
                                  style: AppTextStyles.caption(),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedDriverId,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          decoration: _decor('Assign Driver',
                              icon: Icons.person_outline),
                          items: widget.drivers
                              .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name, style: _fieldStyle),
                          ))
                              .toList(),
                          onChanged: (v) {
                            final driver =
                            widget.drivers.firstWhere((d) => d.id == v);
                            setState(() {
                              _selectedDriverId = driver.id;
                              _selectedDriverName = driver.name;
                            });
                          },
                          validator: (v) =>
                              DValidator.validateDropdown<String>('driver', v),
                        ),
                      _gap(),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _despatchDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _despatchDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: _decor('Despatch Date',
                              icon: Icons.event_outlined),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(_despatchDate),
                            style: _fieldStyle,
                          ),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: _notesCtrl,
                        style: _fieldStyle,
                        minLines: 1,
                        maxLines: 3,
                        inputFormatters: DValidator.textWithLimit,
                        decoration: _decor('Delivery Notes (optional)',
                            icon: Icons.notes_outlined),
                      ),
                    ],
                  ),
                ),
                _gap(18),

                // ---- Items ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const _IconBadge(Icons.list_alt_rounded),
                        SizedBox(width: Responsive.w(10)),
                        Text('Items', style: AppTextStyles.h3()),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(12),
                          vertical: Responsive.h(5)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${s.items.length} ${s.items.length == 1 ? 'item' : 'items'}',
                        style: AppTextStyles.bodyBold(color: AppColors.primary)
                            .copyWith(fontSize: Responsive.sp(12)),
                      ),
                    ),
                  ],
                ),
                _gap(12),
                _DespatchItemsTable(
                  items: s.items,
                  boxesCtrls: _boxesCtrls,
                  piecesCtrls: _piecesCtrls,
                  qtyCtrls: _qtyCtrls,
                ),
                if (s.items.isNotEmpty) ...[
                  _gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_rounded,
                          size: 14, color: AppColors.textHint),
                      SizedBox(width: Responsive.w(4)),
                      Text('Swipe sideways to see all columns',
                          style: AppTextStyles.caption()
                              .copyWith(fontSize: Responsive.sp(11))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(10),
              Responsive.w(16), Responsive.h(16)),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: PrimaryButton(
            label:
            widget.isSubmitting ? 'Please wait...' : 'Create Despatch Sheet',
            height: 48,
            onPressed: widget.isSubmitting ? null : _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(DespatchSuggestionModel s) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.10),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconBadge(Icons.local_shipping_rounded, size: 20),
          SizedBox(height: Responsive.h(14)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ESTIMATE NO.',
                        style:
                        AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
                    SizedBox(height: Responsive.h(4)),
                    // Same style as the Estimate Detail reference number.
                    Text(
                      s.estimateNumber,
                      style: AppTextStyles.h6(color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DS NO. (PREVIEW)',
                      style:
                      AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
                  SizedBox(height: Responsive.h(4)),
                  // Same style as the Estimate Detail date value.
                  Text(
                    s.previewDsNumber,
                    style: AppTextStyles.bodyBold(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDriverId == null || _selectedDriverName == null) {
      AppSnackbar.error('Please assign a driver');
      return;
    }

    final items = widget.suggestion.items.map((item) {
      final id = item.estimateItemId;
      return OwnerDespatchItemRequest(
        estimateItemId: id,
        boxes: int.tryParse(_boxesCtrls[id]!.text.trim()) ?? 0,
        pieces: int.tryParse(_piecesCtrls[id]!.text.trim()) ?? 0,
        quantity: double.tryParse(_qtyCtrls[id]!.text.trim()) ?? 0,
      );
    }).toList();

    final request = OwnerDespatchCreateRequest(
      estimateId: widget.estimateId,
      refNo: _refNoCtrl.text.trim(),
      partyName: _partyNameCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      deliveryAddress: _addressCtrl.text.trim(),
      driverId: _selectedDriverId!,
      driverName: _selectedDriverName!,
      vehicleNumber: _vehicleCtrl.text.trim(),
      items: items,
      despatchDate: DateFormat('yyyy-MM-dd').format(_despatchDate),
      deliveryNotes:
      _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    context
        .read<OwnerDespatchSheetBloc>()
        .add(OwnerDespatchCreateRequested(request));
  }
}

// ---------------------------------------------------------------------
// Items table — same bill-style grid as the estimate detail screen:
// fixed column widths, tinted header, zebra rows, horizontal scroll.
// ---------------------------------------------------------------------

class _DespatchItemsTable extends StatefulWidget {
  const _DespatchItemsTable({
    required this.items,
    required this.boxesCtrls,
    required this.piecesCtrls,
    required this.qtyCtrls,
  });

  final List<DespatchSuggestionItem> items;
  final Map<String, TextEditingController> boxesCtrls;
  final Map<String, TextEditingController> piecesCtrls;
  final Map<String, TextEditingController> qtyCtrls; // kept for submit only

  @override
  State<_DespatchItemsTable> createState() => _DespatchItemsTableState();
}

class _DespatchItemsTableState extends State<_DespatchItemsTable> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  // Same table font size as the Estimate Detail screen.
  static double get _cellFontSize => Responsive.sp(12.5);

  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(12)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(
          fontSize: _cellFontSize,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _dataCell(String text,
      {TextAlign align = TextAlign.left, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(10)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
            .copyWith(fontSize: _cellFontSize),
      ),
    );
  }

  Widget _inputCell(TextEditingController? ctrl, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(6)),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: DValidator.digitsOnly,
        style: AppTextStyles.bodyBold().copyWith(fontSize: _cellFontSize),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border),
          ),
        ),
        validator: (v) => DValidator.validateOptionalNumber(label, v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(18)),
        decoration: _cardDecoration(),
        child: Text('No items to despatch.', style: AppTextStyles.caption()),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(
              horizontalInside:
              BorderSide(color: AppColors.border.withOpacity(0.45)),
              verticalInside:
              BorderSide(color: AppColors.border.withOpacity(0.30)),
            ),
            columnWidths: const {
              0: FixedColumnWidth(_DsCol.sl), // #
              1: FixedColumnWidth(_DsCol.text), // Item
              2: FixedColumnWidth(_DsCol.text), // Company
              3: FixedColumnWidth(_DsCol.size), // Size
              4: FixedColumnWidth(_DsCol.unit), // Unit
              5: FixedColumnWidth(_DsCol.input), // Box
              6: FixedColumnWidth(_DsCol.input), // Pcs
            },
            children: [
              // ---- Header row ----
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.09),
                  border: Border(
                    bottom: BorderSide(
                        color: AppColors.primary.withOpacity(0.35), width: 1.4),
                  ),
                ),
                children: [
                  _headerCell('#', align: TextAlign.center),
                  _headerCell('Item'),
                  _headerCell('Company'),
                  _headerCell('Size'),
                  _headerCell('Unit'),
                  _headerCell('Box', align: TextAlign.center),
                  _headerCell('Pcs', align: TextAlign.center),
                ],
              ),
              // ---- Data rows ----
              for (var i = 0; i < items.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    color: i.isEven
                        ? AppColors.surface
                        : AppColors.surfaceAlt.withOpacity(0.45),
                  ),
                  children: [
                    _dataCell('${i + 1}', align: TextAlign.center),
                    _dataCell(items[i].productName, bold: true),
                    _dataCell(items[i].companyName.isEmpty
                        ? '-'
                        : items[i].companyName),
                    _dataCell(items[i].productSize.isEmpty
                        ? '-'
                        : items[i].productSize),
                    _dataCell(items[i].unit.isEmpty ? '-' : items[i].unit),
                    _inputCell(
                        widget.boxesCtrls[items[i].estimateItemId], 'Boxes'),
                    _inputCell(
                        widget.piecesCtrls[items[i].estimateItemId], 'Pieces'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}