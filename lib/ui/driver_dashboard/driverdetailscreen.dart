import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import 'despatchrepository.dart';

/// Full-detail view of a single despatch bill, opened from the Driver
/// Dashboard. Looks the bill up live from [DespatchRepository] (by id) so it
/// stays in sync if delivered status changes elsewhere.
class DriverBillDetailScreen extends StatelessWidget {
  const DriverBillDetailScreen({
    super.key,
    required this.billId,
    required this.onDelivered,
  });

  final String billId;
  final VoidCallback onDelivered;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Despatch Details', style: AppTextStyles.h6()),
      ),
      body: AnimatedBuilder(
        animation: DespatchRepository.instance,
        builder: (context, _) {
          final bill = DespatchRepository.instance.billById(billId);

          if (bill == null) {
            return Center(
              child: Text('This bill is no longer available', style: AppTextStyles.body()),
            );
          }

          final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
          final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.w(18)),
                    children: [
                      _StatusBanner(delivered: bill.isDelivered, deliveredAt: bill.deliveredAt, dateFmt: dateFmt),
                      SizedBox(height: Responsive.h(16)),
                      Container(
                        padding: EdgeInsets.all(Responsive.w(14)),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _infoRow('DS Number', bill.dsNumber),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Ref. No.', bill.refNo),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Party Name', bill.contractorName),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Contact Number', bill.phone),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Delivery Address', bill.address),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Salesman', bill.salesmanName),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Despatched At', dateFmt.format(bill.despatchedAt)),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Driver name', "Aju"),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Driver Contact No', "+91 9632254132"),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(18)),
                      Text('Items', style: AppTextStyles.h3()),
                      SizedBox(height: Responsive.h(10)),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Container(
                              color: AppColors.surfaceAlt,
                              padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                              child: Row(
                                children: [
                                  SizedBox(width: 24, child: Text('#', style: AppTextStyles.captionnew())),
                                  Expanded(flex: 3, child: Text('Item', style: AppTextStyles.captionnew())),
                                  Expanded(flex: 2, child: Text('Company', style: AppTextStyles.captionnew())),
                                  Expanded(flex: 2, child: Text('Size', style: AppTextStyles.captionnew())),
                                  SizedBox(width: 44, child: Text('Box', style: AppTextStyles.captionnew())),
                                  SizedBox(width: 44, child: Text('Pcs', style: AppTextStyles.captionnew())),
                                ],
                              ),
                            ),
                            for (var i = 0; i < bill.items.length; i++)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: AppColors.border)),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 24, child: Text('${i + 1}', style: AppTextStyles.body())),
                                    Expanded(
                                      flex: 3,
                                      child: Text(bill.items[i].name,
                                          style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(bill.items[i].company,
                                          style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(bill.items[i].size,
                                          style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                    ),
                                    SizedBox(width: 44, child: Text(bill.items[i].boxes, style: AppTextStyles.body())),
                                    SizedBox(width: 44, child: Text(bill.items[i].pieces, style: AppTextStyles.body())),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Grand Total', style: AppTextStyles.bodyBold()),
                          Text(
                            currency.format(bill.grandTotal),
                            style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
                          ),
                        ],
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
                  child: SizedBox(
                    width: double.infinity,
                    child: bill.isDelivered
                        ? OutlinedButton.icon(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Delivered'),
                    )
                        : ElevatedButton.icon(
                      onPressed: () {
                        onDelivered();
                        // Bill status updates via the repository's
                        // ChangeNotifier, so this screen refreshes
                        // itself automatically — no need to pop.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.local_shipping_rounded, size: 18),
                      label: const Text('Mark as Delivered'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
        Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.delivered, required this.deliveredAt, required this.dateFmt});
  final bool delivered;
  final DateTime? deliveredAt;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    final color = delivered ? AppColors.info : AppColors.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(delivered ? Icons.check_circle_rounded : Icons.local_shipping_outlined, color: color, size: 20),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(
              delivered
                  ? 'Delivered on ${deliveredAt != null ? dateFmt.format(deliveredAt!) : '-'}'
                  : 'Pending delivery',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: Responsive.sp(12.5)),
            ),
          ),
        ],
      ),
    );
  }
}