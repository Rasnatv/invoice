
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/estimate_model.dart';
import 'despatchsheet.dart';

class ApprovedDetailsScreen extends StatelessWidget {
  const ApprovedDetailsScreen({super.key, required this.estimate});

  final EstimateModel estimate;

  // TODO(admin-config): incentive % is currently a hardcoded dummy value for
  // UI purposes only, same placeholder used on the Create Estimate preview
  // step. Once the backend/admin panel exposes a per-product incentive %,
  // replace `_dummyIncentivePercent` with the real value from item/master
  // data and remove this constant.
  static const double _dummyIncentivePercent = 5.0;

  double get _mrpTotal => estimate.items.fold(0.0, (s, r) => s + r.quantity * r.mrp);
  double get _itemsTotal => estimate.items.fold(0.0, (s, r) => s + r.quantity * r.rate);
  double get _grandTotal => _itemsTotal + estimate.handlingCharge;
  double get _totalQty => estimate.items.fold(0.0, (s, r) => s + r.quantity);

  double _itemIncentive(EstimateItem item) =>
      item.quantity * item.rate * _dummyIncentivePercent / 100;

  double get _incentiveTotal =>
      estimate.items.fold(0.0, (s, r) => s + _itemIncentive(r));

  Color _statusColor() {
    switch (estimate.status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'draft':
        return AppColors.textHint;
      default:
        return AppColors.primary;
    }
  }

  void _shareOnWhatsApp() {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final buffer = StringBuffer()
      ..writeln('*Estimate ${estimate.id}*')
      ..writeln('Date: ${DateFormat('dd-MM-yyyy').format(estimate.date)}')
      ..writeln('Party: ${estimate.contractorName}')
      ..writeln('Address: ${estimate.siteAddress}')
      ..writeln('Contact: ${estimate.phone}')
      ..writeln('')
      ..writeln('Items:');
    for (final item in estimate.items) {
      buffer.writeln(
        '- ${item.name} (${item.company}) | ${item.quantity.toStringAsFixed(0)} ${item.unit} x ${currency.format(item.rate)} = ${currency.format(item.quantity * item.rate)}',
      );
    }
    buffer
      ..writeln('')
      ..writeln('Grand Total: ${currency.format(_grandTotal)}');
    Share.share(buffer.toString(), subject: 'Estimate ${estimate.id}');
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estimate Details', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: Column(
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
                            Text(estimate.id, style: AppTextStyles.h3()),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Date', style: AppTextStyles.caption()),
                            Text(DateFormat('dd-MM-yyyy').format(estimate.date), style: AppTextStyles.h3()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estimate.status,
                        style: AppTextStyles.bodyBold(color: _statusColor()),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  _DetailSection(
                    title: 'Party Details',
                    rows: [
                      _Row('Party Name', estimate.contractorName, icon: Icons.groups_2_outlined),
                      _Row('Address', estimate.siteAddress, icon: Icons.location_on_outlined),
                      _Row('Contact No.', estimate.phone.isEmpty ? '-' : estimate.phone, icon: Icons.phone_outlined),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: 'Contractor Details',
                    rows: [
                      _Row('Contractor Name', estimate.contractorName, icon: Icons.engineering_outlined),
                      _Row('Contact No.', estimate.phone.isEmpty ? '-' : estimate.phone, icon: Icons.phone_outlined),

                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: 'Salesman',
                    rows: [
                      _Row('Name', estimate.salesmanName.isEmpty ? '-' : estimate.salesmanName, icon: Icons.badge_outlined),
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
                          'Total Items: ${estimate.items.length}',
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
                        columns: const [
                          DataColumn(label: Text('Sl.No')),
                          DataColumn(label: Text('Item')),
                          DataColumn(label: Text('Company')),
                          DataColumn(label: Text('Size')),
                          DataColumn(label: Text('Qty'), numeric: true),
                          DataColumn(label: Text('Unit')),
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
                            DataCell(Text(number.format(item.rate))),
                            DataCell(Text(currency.format(item.quantity * item.rate), style: AppTextStyles.bodyBold())),
                            DataCell(Text(
                              currency.format(_itemIncentive(item)),
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
                        _totalRow('Total Items', '${estimate.items.length}'),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Total Qty', number.format(_totalQty)),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('MRP Total', currency.format(_mrpTotal)),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Handling Charge', currency.format(estimate.handlingCharge)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grand Total', style: AppTextStyles.h3()),
                            Text(currency.format(_grandTotal), style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  // Separate, visually distinct box for incentive so it's
                  // clear this is internal/salesman info, not part of the
                  // customer's bill total above. Values are dummy (5%)
                  // until admin-configured incentive data is wired up.
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
                            Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
                            SizedBox(width: Responsive.w(6)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_dummyIncentivePercent.toStringAsFixed(0)}% · dummy',
                                style: AppTextStyles.caption(color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currency.format(_incentiveTotal),
                          style: AppTextStyles.h3(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareOnWhatsApp,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DespatchSheetScreen(estimate: estimate),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.local_shipping_outlined, size: 18),
                      label: const Text('Create Despatch Sheet'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

class _Row {
  final String label;
  final String value;
  final IconData? icon;
  _Row(this.label, this.value, {this.icon});
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

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
          SizedBox(height: Responsive.h(10)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 16, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                SizedBox(
                  width: r.icon != null ? 88 : 100,
                  child: Text(r.label, style: AppTextStyles.caption()),
                ),
                Expanded(
                  child: Text(
                    r.value.isEmpty ? '-' : r.value,
                    style: AppTextStyles.bodyBold(),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}