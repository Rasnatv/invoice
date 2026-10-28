// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import '../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
// import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_bloc.dart';
// import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_event.dart';
// import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_state.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_styles.dart';
// import '../../core/utils/responsive.dart';
// import '../../models/owner_models/fieldstaffincentivemodel.dart';
// import '../../widgets/appsnackbar.dart';
// import '../../widgets/owner_estimateshimmer.dart';
// import 'fieldstaff_incentivedetailscreen.dart';
//
// /// Status colours shared by the list pill (same palette as Estimates).
// Color _incentiveStatusColor(String status) {
//   switch (status) {
//     case 'paid':
//       return AppColors.success;
//     case 'approved':
//       return Colors.blue.shade700;
//     case 'pending':
//     default:
//       return const Color(0xFFF59E0B);
//   }
// }
//
// /// Public entry point - provides the bloc, loads current-month data.
// class FieldStaffIncentiveScreen extends StatelessWidget {
//   const FieldStaffIncentiveScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final firstOfMonth = DateTime(now.year, now.month, 1);
//     final lastOfMonth = DateTime(now.year, now.month + 1, 0);
//
//     return BlocProvider(
//       create: (_) => FieldStaffIncentiveBloc(provider: IncentiveProvider())
//         ..add(LoadFieldStaffIncentives(
//           dateFrom: _fmt(firstOfMonth),
//           dateTo: _fmt(lastOfMonth),
//         )),
//       child: const _FieldStaffIncentiveView(),
//     );
//   }
//
//   static String _fmt(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
// }
//
// class _FieldStaffIncentiveView extends StatefulWidget {
//   const _FieldStaffIncentiveView();
//
//   @override
//   State<_FieldStaffIncentiveView> createState() =>
//       _FieldStaffIncentiveViewState();
// }
//
// class _FieldStaffIncentiveViewState extends State<_FieldStaffIncentiveView> {
//   final _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         context.read<FieldStaffIncentiveBloc>().add(const LoadMoreIncentives());
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _pickFieldStaff(
//       BuildContext context, FieldStaffIncentiveState state) async {
//     final selected = await showModalBottomSheet<String?>(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (sheetContext) {
//         return SafeArea(
//           child: ListView(
//             shrinkWrap: true,
//             padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
//             children: [
//               ListTile(
//                 leading: Icon(Icons.groups_outlined, color: AppColors.primary),
//                 title: Text('All Field Staff', style: AppTextStyles.body()),
//                 selected: state.selectedFieldStaffId == null,
//                 onTap: () => Navigator.pop(sheetContext, ''),
//               ),
//               const Divider(height: 1),
//               ...state.fieldStaffOptions.map(
//                     (staff) => ListTile(
//                   leading:
//                   Icon(Icons.person_outline, color: AppColors.primary),
//                   title: Text(staff.name, style: AppTextStyles.body()),
//                   selected: state.selectedFieldStaffId == staff.id,
//                   onTap: () => Navigator.pop(sheetContext, staff.id),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//
//     if (selected == null || !context.mounted) return;
//     context
//         .read<FieldStaffIncentiveBloc>()
//         .add(FilterByFieldStaff(selected.isEmpty ? null : selected));
//   }
//
//   void _pickDateRange(
//       BuildContext context, FieldStaffIncentiveState state) async {
//     final initialRange = DateTimeRange(
//       start: DateTime.tryParse(state.dateFrom) ?? DateTime.now(),
//       end: DateTime.tryParse(state.dateTo) ?? DateTime.now(),
//     );
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       initialDateRange: initialRange,
//     );
//
//     if (picked == null || !context.mounted) return;
//     context.read<FieldStaffIncentiveBloc>().add(FilterByDateRange(
//       dateFrom: _fmtDate(picked.start),
//       dateTo: _fmtDate(picked.end),
//     ));
//   }
//
//   static String _fmtDate(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//
//   String _dateRangeLabel(FieldStaffIncentiveState state) {
//     if (state.dateFrom.isEmpty || state.dateTo.isEmpty) {
//       return 'Select Date Range';
//     }
//     return '${state.dateFrom}  to  ${state.dateTo}';
//   }
//
//   Widget _buildFilters(BuildContext context, FieldStaffIncentiveState state) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//           Responsive.w(20), Responsive.h(14), Responsive.w(20), 0),
//       child: Column(
//         children: [
//           _FilterTile(
//             icon: Icons.groups_outlined,
//             text: state.selectedFieldStaffName,
//             onTap: () => _pickFieldStaff(context, state),
//           ),
//           SizedBox(height: Responsive.h(10)),
//           _FilterTile(
//             icon: Icons.date_range_outlined,
//             text: _dateRangeLabel(state),
//             onTap: () => _pickDateRange(context, state),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return NetworkAwareWrapper(
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//
//         // ---------- APPBAR (same as Estimates) ----------
//         appBar: AppBar(
//           title: Text('Field Staff Incentives', style: AppTextStyles.h6()),
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//         ),
//
//         body: SafeArea(
//           child: BlocConsumer<FieldStaffIncentiveBloc, FieldStaffIncentiveState>(
//             listener: (context, state) {
//               if (state.errorMessage != null) {
//                 AppSnackbar.error(state.errorMessage!);
//                 context
//                     .read<FieldStaffIncentiveBloc>()
//                     .add(const ClearIncentiveListFeedback());
//               }
//             },
//             builder: (context, state) {
//               final listPadding = EdgeInsets.fromLTRB(
//                   Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));
//
//               // ---- loading skeleton ----
//               if (state.status == FieldStaffIncentiveStatus.loading &&
//                   state.incentives.isEmpty) {
//                 return Column(
//                   children: [
//                     _buildFilters(context, state),
//                     SizedBox(height: Responsive.h(14)),
//                     Expanded(
//                       child: ShimmerListPlaceholder(
//                         itemCount: 6,
//                         padding: listPadding,
//                         separatorHeight: Responsive.h(10),
//                         itemBuilder: (context, i) =>
//                         const _IncentiveCardSkeleton(),
//                       ),
//                     ),
//                   ],
//                 );
//               }
//
//               return RefreshIndicator(
//                 onRefresh: () async => context
//                     .read<FieldStaffIncentiveBloc>()
//                     .add(const RefreshFieldStaffIncentives()),
//                 child: CustomScrollView(
//                   controller: _scrollController,
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   slivers: [
//                     SliverToBoxAdapter(child: _buildFilters(context, state)),
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: EdgeInsets.fromLTRB(Responsive.w(20),
//                             Responsive.h(14), Responsive.w(20), 0),
//                         child: _SummaryCard(state: state),
//                       ),
//                     ),
//                     SliverToBoxAdapter(child: _StatusTabs(state: state)),
//                     if (state.incentives.isEmpty)
//                       const SliverFillRemaining(
//                         hasScrollBody: false,
//                         child: _EmptyIncentiveState(),
//                       )
//                     else
//                       SliverPadding(
//                         padding: listPadding,
//                         sliver: SliverList(
//                           delegate: SliverChildBuilderDelegate(
//                                 (context, index) {
//                               if (index == state.incentives.length) {
//                                 return const Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 16),
//                                   child: Center(
//                                     child: SizedBox(
//                                       width: 22,
//                                       height: 22,
//                                       child: CircularProgressIndicator(
//                                           strokeWidth: 2),
//                                     ),
//                                   ),
//                                 );
//                               }
//                               final incentive = state.incentives[index];
//                               return Padding(
//                                 padding:
//                                 EdgeInsets.only(bottom: Responsive.h(10)),
//                                 child: _IncentiveCard(
//                                   key: ValueKey(incentive.id),
//                                   incentive: incentive,
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => IncentiveDetailScreen(
//                                             id: incentive.id),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                             childCount: state.incentives.length +
//                                 (state.status ==
//                                     FieldStaffIncentiveStatus.loadingMore
//                                     ? 1
//                                     : 0),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // =====================================================================
// // SMALL REUSABLE PIECES (private to this file)
// // =====================================================================
//
// class _ListCard extends StatelessWidget {
//   const _ListCard({required this.child, this.onTap});
//   final Widget child;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(Responsive.w(14)),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppColors.border),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// class _IconTile extends StatelessWidget {
//   const _IconTile({required this.icon});
//   final IconData icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 42,
//       height: 42,
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(icon, color: AppColors.primary, size: 20),
//     );
//   }
// }
//
// class _FilterTile extends StatelessWidget {
//   const _FilterTile({
//     required this.icon,
//     required this.text,
//     required this.onTap,
//   });
//   final IconData icon;
//   final String text;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(
//             horizontal: Responsive.w(14),
//             vertical: Responsive.h(12),
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: AppColors.border),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: AppColors.primary, size: 18),
//               SizedBox(width: Responsive.w(8)),
//               Expanded(
//                 child: Text(
//                   text,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.body(),
//                 ),
//               ),
//               Icon(Icons.keyboard_arrow_down,
//                   color: AppColors.textSecondary, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _SummaryCard extends StatelessWidget {
//   const _SummaryCard({required this.state});
//
//   final FieldStaffIncentiveState state;
//
//   @override
//   Widget build(BuildContext context) {
//     final summary = state.summary;
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: Responsive.w(14),
//         vertical: Responsive.h(14),
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _StatColumn(
//               value: '₹${summary.totalIncentive.toStringAsFixed(0)}',
//               label: 'Total Incentive',
//               valueColor: AppColors.primary,
//             ),
//           ),
//           const _StatDivider(),
//           Expanded(
//             child: _StatColumn(
//               value: '${summary.statusBreakdown.pending}',
//               label: 'Pending',
//               valueColor: const Color(0xFFF59E0B),
//             ),
//           ),
//           const _StatDivider(),
//           Expanded(
//             child: _StatColumn(
//               value: '${summary.statusBreakdown.paid}',
//               label: 'Paid',
//               valueColor: AppColors.success,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatDivider extends StatelessWidget {
//   const _StatDivider();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 1,
//       height: Responsive.h(34),
//       color: AppColors.border,
//     );
//   }
// }
//
// class _StatColumn extends StatelessWidget {
//   const _StatColumn({
//     required this.value,
//     required this.label,
//     required this.valueColor,
//   });
//
//   final String value;
//   final String label;
//   final Color valueColor;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontFamily: AppTextStyles.fontFamily,
//             fontSize: Responsive.sp(16),
//             fontWeight: FontWeight.w700,
//             color: valueColor,
//           ),
//         ),
//         SizedBox(height: Responsive.h(2)),
//         Text(
//           label,
//           style: AppTextStyles.caption(color: AppColors.textSecondary),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }
//
// class _StatusTabs extends StatelessWidget {
//   const _StatusTabs({required this.state});
//
//   final FieldStaffIncentiveState state;
//
//   /// Reads the label straight off an already-loaded record's `status_label`
//   /// (comes from the API, e.g. "Paid") instead of hardcoding it here.
//   /// Only falls back to a plain word if no loaded record currently has
//   /// this status - there's no dedicated "list of statuses" endpoint to
//   /// source a label from in that case.
//   static String? _apiLabelFor(
//       List<FieldStaffIncentiveModel> incentives, String status) {
//     for (final incentive in incentives) {
//       if (incentive.status == status && incentive.statusLabel.isNotEmpty) {
//         return incentive.statusLabel;
//       }
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final breakdown = state.summary.statusBreakdown;
//     final incentives = state.incentives;
//     final tabs = <_StatusTab>[
//       _StatusTab('all', 'All',
//           breakdown.pending + breakdown.approved + breakdown.paid),
//       if (breakdown.pending > 0)
//         _StatusTab('pending', _apiLabelFor(incentives, 'pending') ?? 'Pending',
//             breakdown.pending),
//       if (breakdown.approved > 0)
//         _StatusTab('approved',
//             _apiLabelFor(incentives, 'approved') ?? 'Approved',
//             breakdown.approved),
//       if (breakdown.paid > 0)
//         _StatusTab(
//             'paid', _apiLabelFor(incentives, 'paid') ?? 'Paid', breakdown.paid),
//     ];
//
//     return SizedBox(
//       height: 34 + Responsive.h(28),
//       child: Center(
//         child: SizedBox(
//           height: 34,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
//             itemCount: tabs.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 8),
//             itemBuilder: (context, i) {
//               final tab = tabs[i];
//               return _FilterChip(
//                 label: '${tab.label} (${tab.count})',
//                 selected: tab.value == state.selectedStatus,
//                 onTap: () => context
//                     .read<FieldStaffIncentiveBloc>()
//                     .add(FilterByStatus(tab.value)),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _StatusTab {
//   const _StatusTab(this.value, this.label, this.count);
//   final String value;
//   final String label;
//   final int count;
// }
//
// class _FilterChip extends StatelessWidget {
//   const _FilterChip({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 160),
//         padding: EdgeInsets.symmetric(
//             horizontal: Responsive.w(12), vertical: Responsive.h(6)),
//         decoration: BoxDecoration(
//           color: selected ? AppColors.primary : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//               color: selected ? AppColors.primary : AppColors.border),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontFamily: AppTextStyles.fontFamily,
//                 fontSize: Responsive.sp(11.5),
//                 fontWeight: FontWeight.w600,
//                 color: selected ? Colors.white : AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _StatusPill extends StatelessWidget {
//   const _StatusPill({required this.status, required this.label});
//
//   final String status;
//   final String label;
//
//   @override
//   Widget build(BuildContext context) {
//     final color = _incentiveStatusColor(status);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontFamily: AppTextStyles.fontFamily,
//           fontSize: Responsive.sp(10.5),
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }
// }
//
// // =====================================================================
// // INCENTIVE CARD
// // =====================================================================
//
// class _IncentiveCard extends StatelessWidget {
//   const _IncentiveCard({super.key, required this.incentive, required this.onTap});
//
//   final FieldStaffIncentiveModel incentive;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return _ListCard(
//       onTap: onTap,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ---- top: icon, staff + visited customer, status ----
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const _IconTile(icon: Icons.payments_outlined),
//               SizedBox(width: Responsive.w(12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       incentive.fieldStaffName,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTextStyles.bodyBold(),
//                     ),
//                     SizedBox(height: Responsive.h(2)),
//                     Text(
//                       'Visited: ${incentive.siteVisit.customerName}',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style:
//                       AppTextStyles.caption(color: AppColors.textSecondary),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: Responsive.w(8)),
//               _StatusPill(
//                   status: incentive.status, label: incentive.statusLabel),
//             ],
//           ),
//
//           SizedBox(height: Responsive.h(12)),
//           const Divider(height: 1, color: AppColors.border),
//           SizedBox(height: Responsive.h(10)),
//
//           // ---- bottom: estimate number, amount ----
//           Row(
//             children: [
//               Icon(Icons.description_outlined,
//                   size: 13, color: AppColors.textSecondary),
//               SizedBox(width: Responsive.w(6)),
//               Expanded(
//                 child: Text(
//                   'Est: ${incentive.estimateNumber}',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.caption(color: AppColors.textSecondary),
//                 ),
//               ),
//               SizedBox(width: Responsive.w(6)),
//               Text(
//                 '₹${incentive.incentiveAmountFormatted}',
//                 style: AppTextStyles.amount(color: AppColors.success),
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
// // SKELETON / EMPTY
// // =====================================================================
//
// class _IncentiveCardSkeleton extends StatelessWidget {
//   const _IncentiveCardSkeleton();
//
//   @override
//   Widget build(BuildContext context) {
//     return _ListCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const ShimmerBox(width: 42, height: 42, borderRadius: 12),
//               SizedBox(width: Responsive.w(12)),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ShimmerBox(width: 120, height: 13),
//                     SizedBox(height: 8),
//                     ShimmerBox(width: 160, height: 11),
//                   ],
//                 ),
//               ),
//               const ShimmerBox(width: 60, height: 20, borderRadius: 20),
//             ],
//           ),
//           SizedBox(height: Responsive.h(12)),
//           const Divider(height: 1, color: AppColors.border),
//           SizedBox(height: Responsive.h(10)),
//           const Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               ShimmerBox(width: 80, height: 12),
//               ShimmerBox(width: 90, height: 16),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EmptyIncentiveState extends StatelessWidget {
//   const _EmptyIncentiveState();
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.bar_chart_rounded,
//               size: 44,
//               color: AppColors.textSecondary.withOpacity(0.4),
//             ),
//             SizedBox(height: Responsive.h(10)),
//             Text('No incentives found', style: AppTextStyles.subtitle()),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_bloc.dart';
import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_event.dart';
import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/owner_models/fieldstaffincentivemodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'fieldstaff_incentivedetailscreen.dart';

/// Status colours shared by the list pill (same palette as Estimates).
Color _incentiveStatusColor(String status) {
  switch (status) {
    case 'paid':
      return AppColors.success;
    case 'approved':
      return Colors.blue.shade700;
    case 'pending':
    default:
      return const Color(0xFFF59E0B);
  }
}

/// Public entry point - provides the bloc, loads current-month data.
class FieldStaffIncentiveScreen extends StatelessWidget {
  const FieldStaffIncentiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final lastOfMonth = DateTime(now.year, now.month + 1, 0);

    return BlocProvider(
      create: (_) => FieldStaffIncentiveBloc(provider: IncentiveProvider())
        ..add(LoadFieldStaffIncentives(
          dateFrom: _fmt(firstOfMonth),
          dateTo: _fmt(lastOfMonth),
        )),
      child: const _FieldStaffIncentiveView(),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _FieldStaffIncentiveView extends StatefulWidget {
  const _FieldStaffIncentiveView();

  @override
  State<_FieldStaffIncentiveView> createState() =>
      _FieldStaffIncentiveViewState();
}

class _FieldStaffIncentiveViewState extends State<_FieldStaffIncentiveView> {
  final _scrollController = ScrollController();

  // FIX: named listener so it can be removed and also called manually.
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  // FIX: asks the bloc for the next page when the user is near the bottom
  // OR when the content is too short to scroll at all (maxScrollExtent = 0).
  // The bloc ignores the event when hasMore is false or a load is running.
  void _maybeLoadMore() {
    if (!mounted || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<FieldStaffIncentiveBloc>().add(const LoadMoreIncentives());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_maybeLoadMore); // FIX
    _scrollController.dispose();
    super.dispose();
  }

  void _pickFieldStaff(
      BuildContext context, FieldStaffIncentiveState state) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
            children: [
              ListTile(
                leading: Icon(Icons.groups_outlined, color: AppColors.primary),
                title: Text('All Field Staff', style: AppTextStyles.body()),
                selected: state.selectedFieldStaffId == null,
                onTap: () => Navigator.pop(sheetContext, ''),
              ),
              const Divider(height: 1),
              ...state.fieldStaffOptions.map(
                    (staff) => ListTile(
                  leading:
                  Icon(Icons.person_outline, color: AppColors.primary),
                  title: Text(staff.name, style: AppTextStyles.body()),
                  selected: state.selectedFieldStaffId == staff.id,
                  onTap: () => Navigator.pop(sheetContext, staff.id),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;
    context
        .read<FieldStaffIncentiveBloc>()
        .add(FilterByFieldStaff(selected.isEmpty ? null : selected));
  }

  void _pickDateRange(
      BuildContext context, FieldStaffIncentiveState state) async {
    final initialRange = DateTimeRange(
      start: DateTime.tryParse(state.dateFrom) ?? DateTime.now(),
      end: DateTime.tryParse(state.dateTo) ?? DateTime.now(),
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
    );

    if (picked == null || !context.mounted) return;
    context.read<FieldStaffIncentiveBloc>().add(FilterByDateRange(
      dateFrom: _fmtDate(picked.start),
      dateTo: _fmtDate(picked.end),
    ));
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dateRangeLabel(FieldStaffIncentiveState state) {
    if (state.dateFrom.isEmpty || state.dateTo.isEmpty) {
      return 'Select Date Range';
    }
    return '${state.dateFrom}  to  ${state.dateTo}';
  }

  Widget _buildFilters(BuildContext context, FieldStaffIncentiveState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Responsive.w(20), Responsive.h(14), Responsive.w(20), 0),
      child: Column(
        children: [
          _FilterTile(
            icon: Icons.groups_outlined,
            text: state.selectedFieldStaffName,
            onTap: () => _pickFieldStaff(context, state),
          ),
          SizedBox(height: Responsive.h(10)),
          _FilterTile(
            icon: Icons.date_range_outlined,
            text: _dateRangeLabel(state),
            onTap: () => _pickDateRange(context, state),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates) ----------
        appBar: AppBar(
          title: Text('Field Staff Incentives', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          // FIX: after every successful load / reload, re-check whether the
          // list still fits on screen. If it does (so it can't scroll), the
          // next page is requested automatically.
          // Uses list reference change (not length) so a reload that returns
          // the same number of items still triggers the check, while a FAILED
          // load-more (list unchanged) does not cause a retry loop.
          child: BlocListener<FieldStaffIncentiveBloc, FieldStaffIncentiveState>(
            listenWhen: (prev, curr) => prev.incentives != curr.incentives,
            listener: (context, state) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _maybeLoadMore());
            },
            child: BlocConsumer<FieldStaffIncentiveBloc, FieldStaffIncentiveState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  AppSnackbar.error(state.errorMessage!);
                  context
                      .read<FieldStaffIncentiveBloc>()
                      .add(const ClearIncentiveListFeedback());
                }
              },
              builder: (context, state) {
                final listPadding = EdgeInsets.fromLTRB(
                    Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));

                // ---- loading skeleton ----
                if (state.status == FieldStaffIncentiveStatus.loading &&
                    state.incentives.isEmpty) {
                  return Column(
                    children: [
                      _buildFilters(context, state),
                      SizedBox(height: Responsive.h(14)),
                      Expanded(
                        child: ShimmerListPlaceholder(
                          itemCount: 6,
                          padding: listPadding,
                          separatorHeight: Responsive.h(10),
                          itemBuilder: (context, i) =>
                          const _IncentiveCardSkeleton(),
                        ),
                      ),
                    ],
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<FieldStaffIncentiveBloc>()
                      .add(const RefreshFieldStaffIncentives()),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildFilters(context, state)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(Responsive.w(20),
                              Responsive.h(14), Responsive.w(20), 0),
                          child: _SummaryCard(state: state),
                        ),
                      ),
                      SliverToBoxAdapter(child: _StatusTabs(state: state)),
                      if (state.incentives.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyIncentiveState(),
                        )
                      else
                        SliverPadding(
                          padding: listPadding,
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                if (index == state.incentives.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }
                                final incentive = state.incentives[index];
                                return Padding(
                                  padding:
                                  EdgeInsets.only(bottom: Responsive.h(10)),
                                  child: _IncentiveCard(
                                    key: ValueKey(incentive.id),
                                    incentive: incentive,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => IncentiveDetailScreen(
                                              id: incentive.id),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: state.incentives.length +
                                  (state.status ==
                                      FieldStaffIncentiveStatus.loadingMore
                                      ? 1
                                      : 0),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(14),
            vertical: Responsive.h(12),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              SizedBox(width: Responsive.w(8)),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(),
                ),
              ),
              Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final FieldStaffIncentiveState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(14),
        vertical: Responsive.h(14),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              value: '₹${summary.totalIncentive.toStringAsFixed(0)}',
              label: 'Total Incentive',
              valueColor: AppColors.primary,
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatColumn(
              value: '${summary.statusBreakdown.pending}',
              label: 'Pending',
              valueColor: const Color(0xFFF59E0B),
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatColumn(
              value: '${summary.statusBreakdown.paid}',
              label: 'Paid',
              valueColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: Responsive.h(34),
      color: AppColors.border,
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: Responsive.sp(16),
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(
          label,
          style: AppTextStyles.caption(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.state});

  final FieldStaffIncentiveState state;

  /// Reads the label straight off an already-loaded record's `status_label`
  /// (comes from the API, e.g. "Paid") instead of hardcoding it here.
  /// Only falls back to a plain word if no loaded record currently has
  /// this status - there's no dedicated "list of statuses" endpoint to
  /// source a label from in that case.
  static String? _apiLabelFor(
      List<FieldStaffIncentiveModel> incentives, String status) {
    for (final incentive in incentives) {
      if (incentive.status == status && incentive.statusLabel.isNotEmpty) {
        return incentive.statusLabel;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = state.summary.statusBreakdown;
    final incentives = state.incentives;
    final tabs = <_StatusTab>[
      _StatusTab('all', 'All',
          breakdown.pending + breakdown.approved + breakdown.paid),
      if (breakdown.pending > 0)
        _StatusTab('pending', _apiLabelFor(incentives, 'pending') ?? 'Pending',
            breakdown.pending),
      if (breakdown.approved > 0)
        _StatusTab('approved',
            _apiLabelFor(incentives, 'approved') ?? 'Approved',
            breakdown.approved),
      if (breakdown.paid > 0)
        _StatusTab(
            'paid', _apiLabelFor(incentives, 'paid') ?? 'Paid', breakdown.paid),
    ];

    return SizedBox(
      height: 34 + Responsive.h(28),
      child: Center(
        child: SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            itemCount: tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final tab = tabs[i];
              return _FilterChip(
                label: '${tab.label} (${tab.count})',
                selected: tab.value == state.selectedStatus,
                onTap: () => context
                    .read<FieldStaffIncentiveBloc>()
                    .add(FilterByStatus(tab.value)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusTab {
  const _StatusTab(this.value, this.label, this.count);
  final String value;
  final String label;
  final int count;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(12), vertical: Responsive.h(6)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: Responsive.sp(11.5),
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _incentiveStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// =====================================================================
// INCENTIVE CARD
// =====================================================================

class _IncentiveCard extends StatelessWidget {
  const _IncentiveCard({super.key, required this.incentive, required this.onTap});

  final FieldStaffIncentiveModel incentive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: icon, staff + visited customer, status ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(icon: Icons.payments_outlined),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incentive.fieldStaffName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      'Visited: ${incentive.siteVisit.customerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _StatusPill(
                  status: incentive.status, label: incentive.statusLabel),
            ],
          ),

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: estimate number, amount ----
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 13, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  'Est: ${incentive.estimateNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ),
              SizedBox(width: Responsive.w(6)),
              Text(
                '₹${incentive.incentiveAmountFormatted}',
                style: AppTextStyles.amount(color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SKELETON / EMPTY
// =====================================================================

class _IncentiveCardSkeleton extends StatelessWidget {
  const _IncentiveCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: Responsive.w(12)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 13),
                    SizedBox(height: 8),
                    ShimmerBox(width: 160, height: 11),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 80, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyIncentiveState extends StatelessWidget {
  const _EmptyIncentiveState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 44,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            SizedBox(height: Responsive.h(10)),
            Text('No incentives found', style: AppTextStyles.subtitle()),
          ],
        ),
      ),
    );
  }
}