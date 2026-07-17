
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/model/estimate_model.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/widgets/primary_button.dart';
import '../../../../../../core/widgets/status_badge.dart';
import '../../../../../../models/estimate_model.dart' ;
import '../cubit/estimates_cubit.dart';
import '../widgets/biltypebadge.dart';

// TODO(admin-config): incentive % is currently a hardcoded dummy value for
// UI purposes only, mirroring the placeholder used in CreateEstimateScreen.
// Once the backend/admin panel exposes a per-product incentive %, replace
// `_dummyIncentivePercent` (and the helper below) with the real value
// coming from EstimateItem / product master data.
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
      buffer.writeln('${item.name} (${item.company}) x ${item.quantityLabel} = ${currency.format(item.amount)}');
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
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');
    final date = DateFormat('dd MMM yyyy').format(estimate.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Estimate DetailScreen')),
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
                        _InfoRow(label: 'Contractor', value: estimate.contractorName),
                        _InfoRow(label: 'Site Address', value: estimate.siteAddress),
                        _InfoRow(label: 'Phone', value: estimate.phone),
                        if (estimate.salesmanName.isNotEmpty)
                          _InfoRow(label: 'Salesman', value: estimate.salesmanName),
                      ],
                    ),
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
                          'Total Items: ${estimate.items.length}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(12)),

                  if (estimate.items.isEmpty)
                    Text('No item breakdown available.', style: AppTextStyles.subtitle())
                  else
                  // Full itemized table (Sl.No, Item, Company, Size, Qty,
                  // Unit, MRP, Rate, Amount, Incentive), scrollable
                  // horizontally so every column stays visible on smaller
                  // screens. Incentive column is dummy/admin-configured,
                  // same as CreateEstimateScreen's preview step.
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
                            Text(currency.format(estimate.totalAmount), style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  // Separate, visually distinct box for incentive so it's
                  // clear this is internal/salesman info, not part of the
                  // customer's bill total above. Values are dummy until
                  // admin config lands (same pattern as the create screen).
            //       Container(
            //         padding: EdgeInsets.all(Responsive.w(14)),
            //         decoration: BoxDecoration(
            //           color: AppColors.success.withOpacity(0.08),
            //           borderRadius: BorderRadius.circular(14),
            //           border: Border.all(color: AppColors.success.withOpacity(0.3)),
            //         ),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Row(
            //               children: [
            //                 Icon(Icons.percent, size: 18, color: AppColors.success),
            //                 SizedBox(width: Responsive.w(8)),
            //                 Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
            //                 SizedBox(width: Responsive.w(6)),
            //                 Container(
            //                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            //                   decoration: BoxDecoration(
            //                     color: AppColors.success.withOpacity(0.12),
            //                     borderRadius: BorderRadius.circular(6),
            //                   ),
            //                   child: Text(
            //                     '${_dummyIncentivePercent.toStringAsFixed(0)}% · dummy',
            //                     style: AppTextStyles.caption(color: AppColors.success),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             Text(
            //               currency.format(_incentiveTotal),
            //               style: AppTextStyles.h3(color: AppColors.success),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
            //   child: Row(
            //     children: [
            //       // Compact icon-only button for Edit.
            //       _RoundIconButton(
            //         icon: Icons.edit_outlined,
            //         tooltip: 'Edit',
            //         onPressed: () {
            //           // Hand the same EstimatesCubit + estimate to your
            //           // edit flow (e.g. re-open CreateEstimateScreen
            //           // pre-filled with these values).
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(content: Text('Wire this up to your edit flow')),
            //           );
            //         },
            //       ),
            //       SizedBox(width: Responsive.w(10)),
            //       // Compact icon-only button for Share.
            //       _RoundIconButton(
            //         icon: Icons.share_outlined,
            //         tooltip: 'Share',
            //         onPressed: () async {
            //           // Swap for `Share.share(...)` (share_plus package)
            //           // once it's added to pubspec.yaml. For now this
            //           // copies a shareable summary to the clipboard.
            //           await Clipboard.setData(ClipboardData(text: _buildShareText(currency)));
            //           if (context.mounted) {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(content: Text('Estimate summary copied to clipboard')),
            //             );
            //           }
            //         },
            //       ),
            //       SizedBox(width: Responsive.w(10)),
            //       Expanded(
            //         child: estimate.billType == EstimateBillType.quotation
            //             ? PrimaryButton(
            //           label: 'Send to Admin',
            //           height: 48,
            //           onPressed: () {
            //             context.read<EstimatesCubit>().sendForApproval(estimate.id);
            //             Navigator.of(context).pop();
            //           },
            //         )
            //             : PrimaryButton(
            //           label: 'Rensend for Approval',
            //           height: 48,
            //           onPressed: null,
            //         ),
            //       ),
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
