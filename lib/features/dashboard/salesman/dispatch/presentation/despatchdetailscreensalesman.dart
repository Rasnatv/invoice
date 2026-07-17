
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';

/// Full-detail view of a single despatch bill, opened from the Driver
/// Dashboard. Currently shows placeholder/dummy data.
class _DummyItem {
  const _DummyItem({
    required this.name,
    required this.company,
    required this.size,
    required this.boxes,
    required this.pieces,
  });
  final String name;
  final String company;
  final String size;
  final String boxes;
  final String pieces;
}

class SalesDepatchBillDetailScreen extends StatelessWidget {
  const SalesDepatchBillDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // Dummy data used to build this screen until it's wired up to a real
    // data source.
    const dsNumber = '250';
    const refNo = 'ref230';
    const partyName = 'aju';
    const contactNumber = '7925005014';
    const deliveryAddress = 'kanhangad';
    const salesman = 'salesmanname';
    const despatchedAt = '12-10-2026';
    const driverName = 'driver name';
    const delivered = false;
    const DateTime? deliveredAt = null;
    const grandTotal = 12500;
    const items = [
      _DummyItem(name: 'Item A', company: 'Company X', size: '100sqft', boxes: '4', pieces: '20'),
      _DummyItem(name: 'Item B', company: 'Company Y', size: '100sqrft', boxes: '2', pieces: '10'),
    ];

    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Despatch Details', style: AppTextStyles.h6()),
      ),
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.w(18)),
                    children: [
                      _StatusBanner(
                        delivered: delivered,
                        deliveredAt: deliveredAt,
                        dateFmt: dateFmt,
                      ),
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
                            _infoRow('DS Number', dsNumber),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Ref. No.', refNo),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Party Name', partyName),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Contact Number', contactNumber),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Delivery Address', deliveryAddress),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Salesman', salesman),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Despatched At', despatchedAt),
                            SizedBox(height: Responsive.h(6)),
                            _infoRow('Driver Name', driverName),
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
                            for (var i = 0; i < items.length; i++)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                                decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: AppColors.border)),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 24, child: Text('${i + 1}', style: AppTextStyles.body())),
                                    Expanded(
                                      flex: 3,
                                      child: Text(items[i].name,
                                          style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(items[i].company,
                                          style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(items[i].size,
                                          style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                    ),
                                    SizedBox(width: 44, child: Text(items[i].boxes, style: AppTextStyles.body())),
                                    SizedBox(width: 44, child: Text(items[i].pieces, style: AppTextStyles.body())),
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
                            currency.format(grandTotal),
                            style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(20)),
                      const _SignatureBlock(),
                      SizedBox(height: Responsive.h(12)),
                    ],
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

class _SignatureBlock extends StatelessWidget {
  const _SignatureBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: Responsive.h(6)),
        Text('Customer Signature', style: AppTextStyles.caption()),
      ],
    );
  }
}