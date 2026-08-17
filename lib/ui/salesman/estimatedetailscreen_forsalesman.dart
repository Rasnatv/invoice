import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/estimate/estimate_detail_event.dart';
import '../../bloc/salemanbloc/estimate/estimate_detail_state.dart';
import '../../bloc/salemanbloc/estimate/estimatedetail_bloc.dart';
import '../../models/salesmanmodels/estimatedetail.model.dart';


class SalesmanEstimateDetailsScreen extends StatefulWidget {
  const SalesmanEstimateDetailsScreen({super.key, required this.id});

  final String id;

  @override
  State<SalesmanEstimateDetailsScreen> createState() => _EstimateDetailsScreenState();
}

class _EstimateDetailsScreenState extends State<SalesmanEstimateDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstimateDetailBloc()..add(EstimateDetailRequested(widget.id)),
      child: _EstimateDetailsView(id: widget.id),
    );
  }
}

class _EstimateDetailsView extends StatelessWidget {
  const _EstimateDetailsView({required this.id});

  final String id;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending_approval':
        return Colors.orange;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  void _openDespatchSheet(BuildContext context, EstimateDetailModel estimate) {
    // TODO: wire to your real DespatchSheetScreen once it's adapted to
    // accept EstimateDetailModel instead of the dummy EstimateModel.
    // Left as a placeholder so this doesn't silently crash on tap.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Despatch sheet screen not wired yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estimate Detail', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: BlocBuilder<EstimateDetailBloc, EstimateDetailState>(
          builder: (context, state) {
            if (state.status == EstimateDetailStatus.loading && state.detail == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == EstimateDetailStatus.failure && state.detail == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 40, color: AppColors.error),
                    SizedBox(height: Responsive.h(10)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                      child: Text(
                        state.error ?? 'Failed to load estimate.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(color: AppColors.error),
                      ),
                    ),
                    SizedBox(height: Responsive.h(10)),
                    TextButton(
                      onPressed: () =>
                          context.read<EstimateDetailBloc>().add(EstimateDetailRequested(id)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final estimate = state.detail;
            if (estimate == null) return const SizedBox.shrink();

            final statusColor = _statusColor(estimate.status);

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
                                Text(
                                  estimate.estimateNumber.isEmpty
                                      ? '#${estimate.id}'
                                      : estimate.estimateNumber,
                                  style: AppTextStyles.h3(),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Date', style: AppTextStyles.caption()),
                                Text(
                                  estimate.date != null
                                      ? DateFormat('dd-MM-yyyy').format(estimate.date!)
                                      : estimate.dateRaw,
                                  style: AppTextStyles.h3(),
                                ),
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
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(estimate.status),
                            style: AppTextStyles.bodyBold(color: statusColor),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(16)),

                      _DetailSection(
                        title: 'Customer Details',
                        rows: [
                          _Row('Party Name', estimate.customer.name.isNotEmpty ? estimate.customer.name : estimate.customerName, icon: Icons.groups_2_outlined),
                          _Row('Address', estimate.customer.address.isNotEmpty ? estimate.customer.address : estimate.customerAddress, icon: Icons.location_on_outlined),
                          _Row('Contact No.', estimate.customer.phone.isNotEmpty ? estimate.customer.phone : estimate.customerPhone, icon: Icons.phone_outlined),
                          _Row('Email', estimate.customer.email.isNotEmpty ? estimate.customer.email : estimate.customerEmail, icon: Icons.alternate_email),
                        ],
                      ),
                      SizedBox(height: Responsive.h(14)),

                      _DetailSection(
                        title: 'Salesman',
                        rows: [
                          _Row('Name', estimate.salesman.name, icon: Icons.badge_outlined),
                          _Row('Code', estimate.salesman.employeeCode, icon: Icons.badge_outlined),
                        ],
                      ),
                      SizedBox(height: Responsive.h(14)),

                      if (estimate.siteVisit.id.isNotEmpty)
                        _DetailSection(
                          title: 'Site Visit',
                          rows: [
                            _Row('Visit Date', estimate.siteVisit.visitDate, icon: Icons.event_outlined),
                            _Row('Status', estimate.siteVisit.statusLabel, icon: Icons.flag_outlined),
                            _Row('Field Staff', estimate.siteVisit.fieldStaffName, icon: Icons.engineering_outlined),
                          ],
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
                              'Total Items: ${estimate.itemsCount}',
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
                              DataColumn(label: Text('Size')),
                              DataColumn(label: Text('Qty'), numeric: true),
                              DataColumn(label: Text('Rate'), numeric: true),
                              DataColumn(label: Text('Amount'), numeric: true),
                              DataColumn(label: Text('Incentive'), numeric: true),
                            ],
                            rows: estimate.items.asMap().entries.map((entry) {
                              final i = entry.key;
                              final item = entry.value;
                              return DataRow(cells: [
                                DataCell(Text('${i + 1}')),
                                DataCell(Text(item.productName)),
                                DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
                                DataCell(Text(number.format(item.quantity))),
                                DataCell(Text(number.format(item.rate))),
                                DataCell(Text(
                                  currency.format(item.amount),
                                  style: AppTextStyles.bodyBold(),
                                )),
                                DataCell(Text(
                                  item.incentiveAmount > 0 ? currency.format(item.incentiveAmount) : '-',
                                  style: AppTextStyles.bodyBold(color: AppColors.success),
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(16)),

                      if (estimate.notes.isNotEmpty) ...[
                        _DetailSection(title: 'Notes', rows: [_Row('', estimate.notes)]),
                        SizedBox(height: Responsive.h(14)),
                      ],

                      Container(
                        padding: EdgeInsets.all(Responsive.w(14)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _totalRow('Total Items', '${estimate.itemsCount}'),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Total Qty', number.format(estimate.totalQuantity)),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Total Sq.Ft', number.format(estimate.totalSquareFeet)),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Items Total', currency.format(estimate.subtotal)),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Handling Charge', currency.format(estimate.handlingCharge)),

                            // Discount, payment, and balance are only
                            // meaningful once the estimate is approved —
                            // while pending, these fields are still
                            // zero/unset on the server, so showing them
                            // would just display misleading zeros.
                            if (estimate.isApproved && estimate.hasDiscount) ...[
                              SizedBox(height: Responsive.h(6)),
                              _totalRow(
                                'Discount (${estimate.discountTypeLabel})',
                                '- ${currency.format(estimate.discountAmount)}',
                              ),
                            ],

                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Grand Total', style: AppTextStyles.h3()),
                                Text(currency.format(estimate.grandTotal),
                                    style: AppTextStyles.h2(color: AppColors.primary)),
                              ],
                            ),

                            if (estimate.isApproved) ...[
                              SizedBox(height: Responsive.h(6)),
                              _totalRow('Amount After Discount', currency.format(estimate.amountAfterDiscount)),
                              SizedBox(height: Responsive.h(6)),
                              _totalRow('Total Paid', currency.format(estimate.totalPaid)),
                              SizedBox(height: Responsive.h(6)),
                              _totalRow('Balance Due', currency.format(estimate.balanceAmount)),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(12)),

                      if (estimate.isApproved)
                        Container(
                          padding: EdgeInsets.all(Responsive.w(14)),
                          decoration: BoxDecoration(
                            color: (estimate.isFullyPaid ? AppColors.success : Colors.orange)
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (estimate.isFullyPaid ? AppColors.success : Colors.orange)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    estimate.isFullyPaid ? Icons.check_circle_outline : Icons.hourglass_bottom_outlined,
                                    size: 18,
                                    color: estimate.isFullyPaid ? AppColors.success : Colors.orange,
                                  ),
                                  SizedBox(width: Responsive.w(8)),
                                  Text(
                                    'Payment Status',
                                    style: AppTextStyles.bodyBold(
                                      color: estimate.isFullyPaid ? AppColors.success : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                estimate.balanceStatusLabel,
                                style: AppTextStyles.h3(
                                  color: estimate.isFullyPaid ? AppColors.success : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),

                if (estimate.isApproved)
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _openDespatchSheet(context, estimate),
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
            );
          },
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
                if (r.label.isNotEmpty)
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