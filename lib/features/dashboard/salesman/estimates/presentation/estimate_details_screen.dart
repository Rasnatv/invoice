//
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../../../core/constants/app_colors.dart';
// import '../../../../../../core/constants/app_text_styles.dart';
// import '../../../../../../core/model/estimate_model.dart';
// import '../../../../../../core/utils/responsive.dart';
// import '../../../../../../core/widgets/primary_button.dart';
// import '../../../../../../core/widgets/status_badge.dart';
// import '../../../../../../models/estimate_model.dart' ;
// import '../cubit/estimates_cubit.dart';
// import '../widgets/biltypebadge.dart';
//
// const double _dummyIncentivePercent = 5.0;
//
// double _incentiveAmountFor(EstimateItem item) =>
//     item.amount * _dummyIncentivePercent / 100;
//
// class EstimateDetailsScreen extends StatelessWidget {
//   final EstimateModel estimate;
//   const EstimateDetailsScreen({super.key, required this.estimate});
//
//   double get _incentiveTotal =>
//       estimate.items.fold(0.0, (s, item) => s + _incentiveAmountFor(item));
//
//   String _buildShareText(NumberFormat currency) {
//     final buffer = StringBuffer()
//       ..writeln('Estimate ${estimate.id}')
//       ..writeln('Party: ${estimate.contractorName}')
//       ..writeln('Address: ${estimate.siteAddress}')
//       ..writeln('Date: ${DateFormat('dd MMM yyyy').format(estimate.date)}')
//       ..writeln('---');
//     for (final item in estimate.items) {
//       buffer.writeln('${item.name} (${item.company}) x ${item.quantityLabel} = ${currency.format(item.amount)}');
//     }
//     buffer
//       ..writeln('---')
//       ..writeln('Total: ${currency.format(estimate.totalAmount)}')
//       ..writeln('Type: ${estimate.billType.label}');
//     return buffer.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//     final date = DateFormat('dd MMM yyyy').format(estimate.date);
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: const Text('Estimate DetailScreen')),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.all(Responsive.w(18)),
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(16)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(estimate.id, style: AppTextStyles.h2()),
//                             Row(
//                               children: [
//                                 BillTypeBadge(billType: estimate.billType),
//                                 const SizedBox(width: 6),
//                                 StatusBadge(status: estimate.status),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(4)),
//                         Text(date, style: AppTextStyles.caption()),
//                         const Divider(height: 28),
//                         _InfoRow(label: 'Contractor', value: estimate.contractorName),
//                         _InfoRow(label: 'Site Address', value: estimate.siteAddress),
//                         _InfoRow(label: 'Phone', value: estimate.phone),
//                         if (estimate.salesmanName.isNotEmpty)
//                           _InfoRow(label: 'Salesman', value: estimate.salesmanName),
//                       ],
//                     ),
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
//                           'Total Items: ${estimate.items.length}',
//                           style: AppTextStyles.bodyBold(color: AppColors.primary),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(12)),
//
//                   if (estimate.items.isEmpty)
//                     Text('No item breakdown available.', style: AppTextStyles.subtitle())
//                   else
//                   // Full itemized table (Sl.No, Item, Company, Size, Qty,
//                   // Unit, MRP, Rate, Amount, Incentive), scrollable
//                   // horizontally so every column stays visible on smaller
//                   // screens. Incentive column is dummy/admin-configured,
//                   // same as CreateEstimateScreen's preview step.
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: AppColors.border),
//                       ),
//                       clipBehavior: Clip.antiAlias,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: DataTable(
//                           headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
//                           headingTextStyle: AppTextStyles.bodyBold(),
//                           dataTextStyle: AppTextStyles.body(),
//                           columnSpacing: 18,
//                           columns: const [
//                             DataColumn(label: Text('Sl.No')),
//                             DataColumn(label: Text('Item')),
//                             DataColumn(label: Text('Company')),
//                             DataColumn(label: Text('Size')),
//                             DataColumn(label: Text('Qty'), numeric: true),
//                             DataColumn(label: Text('Unit')),
//                             DataColumn(label: Text('MRP'), numeric: true),
//                             DataColumn(label: Text('Rate'), numeric: true),
//                             DataColumn(label: Text('Amount'), numeric: true),
//                             DataColumn(label: Text('Incentive'), numeric: true),
//                           ],
//                           rows: estimate.items.asMap().entries.map((entry) {
//                             final i = entry.key;
//                             final item = entry.value;
//                             return DataRow(cells: [
//                               DataCell(Text('${i + 1}')),
//                               DataCell(Text(item.name)),
//                               DataCell(Text(item.company.isEmpty ? '-' : item.company)),
//                               DataCell(Text(item.size.isEmpty ? '-' : item.size)),
//                               DataCell(Text(number.format(item.quantity))),
//                               DataCell(Text(item.unit)),
//                               DataCell(Text(number.format(item.mrp))),
//                               DataCell(Text(number.format(item.rate))),
//                               DataCell(Text(
//                                 currency.format(item.amount),
//                                 style: AppTextStyles.bodyBold(),
//                               )),
//                               DataCell(Text(
//                                 currency.format(_incentiveAmountFor(item)),
//                                 style: AppTextStyles.bodyBold(color: AppColors.success),
//                               )),
//                             ]);
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                   SizedBox(height: Responsive.h(16)),
//
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(14)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceAlt,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Total Items', style: AppTextStyles.body()),
//                             Text('${estimate.items.length}', style: AppTextStyles.body()),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(6)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('MRP Total', style: AppTextStyles.body()),
//                             Text(currency.format(estimate.mrpTotal), style: AppTextStyles.body()),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(6)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Handling Charge', style: AppTextStyles.body()),
//                             Text(currency.format(estimate.handlingCharge), style: AppTextStyles.body()),
//                           ],
//                         ),
//                         const Divider(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Total Amount', style: AppTextStyles.h3()),
//                             Text(currency.format(estimate.totalAmount), style: AppTextStyles.h2(color: AppColors.primary)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(12)),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Compact square icon button used for the secondary Edit/Share actions,
// /// so the primary "Send for Approval" action gets the visual emphasis.
// class _RoundIconButton extends StatelessWidget {
//   const _RoundIconButton({
//     required this.icon,
//     required this.onPressed,
//     this.tooltip,
//   });
//
//   final IconData icon;
//   final VoidCallback? onPressed;
//   final String? tooltip;
//
//   @override
//   Widget build(BuildContext context) {
//     final button = InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Icon(icon, size: 20, color: AppColors.primary),
//       ),
//     );
//     if (tooltip == null) return button;
//     return Tooltip(message: tooltip!, child: button);
//   }
// }
//
// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//   const _InfoRow({required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(width: 110, child: Text(label, style: AppTextStyles.caption())),
//           Expanded(child: Text(value, style: AppTextStyles.bodyBold())),
//         ],
//       ),
//     );
//   }
// }
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/widgets/primary_button.dart';
import '../../../../../../core/widgets/status_badge.dart';
import '../../../../../../models/estimate_model.dart';
import '../widgets/biltypebadge.dart';
import 'fullestimatedetail.dart';


const double _dummyIncentivePercent = 5.0;

double _incentiveAmountFor(EstimateItem item) =>
    item.amount * _dummyIncentivePercent / 100;

class EstimateDetailsScreen extends StatelessWidget {
  final EstimateModel estimate;
  const EstimateDetailsScreen({super.key, required this.estimate});

  double get _incentiveTotal =>
      estimate.items.fold(0.0, (s, item) => s + _incentiveAmountFor(item));

  String _buildShareText(NumberFormat currency) {
    final buffer = StringBuffer()
      ..writeln('Estimate ${estimate.id}')
      ..writeln('Party: ${estimate.contractorName}')
      ..writeln('Address: ${estimate.siteAddress}')
      ..writeln('Date: ${DateFormat('dd MMM yyyy').format(estimate.date)}')
      ..writeln('---');
    for (final item in estimate.items) {
      buffer.writeln(
          '${item.name} (${item.company}) x ${item.quantityLabel} = ${currency.format(item.amount)}');
    }
    buffer
      ..writeln('---')
      ..writeln('Total: ${currency.format(estimate.totalAmount)}')
      ..writeln('Type: ${estimate.billType.label}');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');
    final date = DateFormat('dd MMM yyyy').format(estimate.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estimate Detail',style: AppTextStyles.h6()),
        actions: [
          IconButton(
            tooltip: 'View Full Details',
            icon: const Icon(Icons.description_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EstimateFullDetailsScreen(estimate: estimate),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(16)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(estimate.id, style: AppTextStyles.h2()),
                            Row(
                              children: [
                                BillTypeBadge(billType: estimate.billType),
                                const SizedBox(width: 6),
                                StatusBadge(status: estimate.status),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(4)),
                        Text(date, style: AppTextStyles.caption()),
                        const Divider(height: 28),
                        // ---- Party / contractor details ----
                        Text('Party Details', style: AppTextStyles.bodyBold()),
                        SizedBox(height: Responsive.h(8)),
                        _InfoRow(label: 'Contractor', value: estimate.contractorName),
                        _InfoRow(label: 'Site Address', value: estimate.siteAddress),
                        _InfoRow(label: 'Phone', value: estimate.phone),
                        if (estimate.salesmanName.isNotEmpty)
                          _InfoRow(label: 'Salesman', value: estimate.salesmanName),
                        _InfoRow(label: 'Bill Type', value: estimate.billType.label),
                        _InfoRow(label: 'Status', value: estimate.status.toString().split('.').last),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items', style: AppTextStyles.h3()),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Items: ${estimate.items.length}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(12)),
                  if (estimate.items.isEmpty)
                    Text('No item breakdown available.',
                        style: AppTextStyles.subtitle())
                  else
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
                          headingRowColor:
                          MaterialStateProperty.all(AppColors.surfaceAlt),
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
                            DataColumn(label: Text('Incentive'), numeric: true),
                          ],
                          rows: estimate.items.asMap().entries.map((entry) {
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
                              DataCell(Text(
                                currency.format(_incentiveAmountFor(item)),
                                style: AppTextStyles.bodyBold(color: AppColors.success),
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  SizedBox(height: Responsive.h(16)),
                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Items', style: AppTextStyles.body()),
                            Text('${estimate.items.length}', style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MRP Total', style: AppTextStyles.body()),
                            Text(currency.format(estimate.mrpTotal), style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Handling Charge', style: AppTextStyles.body()),
                            Text(currency.format(estimate.handlingCharge), style: AppTextStyles.body()),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTextStyles.h3()),
                            Text(currency.format(estimate.totalAmount),
                                style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  // ---- Button to open the second (full details) page ----
                  PrimaryButton(
                    label: 'View Full Estimate',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EstimateFullDetailsScreen(estimate: estimate),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.h(12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact square icon button used for the secondary Edit/Share actions,
/// so the primary "Send for Approval" action gets the visual emphasis.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: AppTextStyles.caption())),
          Expanded(child: Text(value, style: AppTextStyles.bodyBold())),
        ],
      ),
    );
  }
}