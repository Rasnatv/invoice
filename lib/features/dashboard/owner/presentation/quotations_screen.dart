
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/features/dashboard/owner/presentation/quotation_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';


class OwnerQuotationsScreen extends StatefulWidget {
  const OwnerQuotationsScreen({super.key});

  @override
  State<OwnerQuotationsScreen> createState() => _OwnerQuotationsScreenState();
}

class _OwnerQuotationsScreenState extends State<OwnerQuotationsScreen> {
  final _searchCtrl = TextEditingController();

  // Dummy quotation data
  final List<QuotationModel> _quotations = [
    QuotationModel(
      id: 'Est.No.015',
      customerName: 'Rajesh Constructions',
      customerPhone: '+91 98765 43210',
      date: DateTime(2026, 7, 5),
      items: 5,
      grandTotal: 519500,
      status: 'Sent',
    ),
    QuotationModel(
      id: 'Est.No.015',
      customerName: 'Sunrise Developers',
      customerPhone: '+91 76543 21098',
      date: DateTime(2026, 7, 8),
      items: 3,
      grandTotal: 731000,
      status: 'Accepted',
    ),
    QuotationModel(
      id: 'Est.No.016',
      customerName: 'Metro Infrastructure',
      customerPhone: '+91 54321 09876',
      date: DateTime(2026, 7, 10),
      items: 4,
      grandTotal: 2138500,
      status: 'Draft',

    ),
    QuotationModel(
      id: 'Est.No.017',
      customerName: 'Green Valley Projects',
      customerPhone: '+91 32109 87654',
      date: DateTime(2026, 7, 12),
      items: 6,
      grandTotal: 1403400,
      status: 'Viewed',

    ),
    QuotationModel(
      id: 'Est.No.018',
      customerName: 'Urban Spaces Ltd',
      customerPhone: '+91 10987 65432',
      date: DateTime(2026, 7, 15),
      items: 8,
      grandTotal: 2820000,
      status: 'Expired',
    ),
  ];

  List<QuotationModel> _getFilteredQuotations() {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _quotations;

    return _quotations.where((q) {
      return q.customerName.toLowerCase().contains(query) ||
          q.id.toLowerCase().contains(query) ||
          q.customerPhone.contains(query);
    }).toList();
  }

  // Navigates to the quotation details screen, passing the tapped card's
  // info through so the header there matches what was tapped. Swap for a
  // real "fetch quotation by id" call once that API/cubit exists.
  void _openQuotationDetails(QuotationModel q) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerQuotationDetailsScreen(
          quotationId: q.id,
          customerName: q.customerName,
          customerPhone: q.customerPhone,
          date: q.date,
          grandTotal: q.grandTotal,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final filteredQuotations = _getFilteredQuotations();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quotations', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(16),
                Responsive.h(14),
                Responsive.w(16),
                Responsive.h(10),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search by customer, ID or salesman',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),

            // Quotation List
            Expanded(
              child: filteredQuotations.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: Responsive.h(16)),
                    Text(
                      'No quotations found',
                      style: AppTextStyles.subtitle(),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(16),
                  0,
                  Responsive.w(16),
                  Responsive.h(20),
                ),
                itemCount: filteredQuotations.length,
                separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                itemBuilder: (context, index) {
                  final q = filteredQuotations[index];
                  return _QuotationCard(
                    quotation: q,
                    currency: currency,
                    onTap: () => _openQuotationDetails(q),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quotation Card Widget
class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.currency,
    required this.onTap,
  });

  final QuotationModel quotation;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row - Customer Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quotation.customerName,
                    style: AppTextStyles.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              ],
            ),

            SizedBox(height: Responsive.h(4)),

            // Quotation ID & Salesman
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Text(
                  quotation.id,
                  style: AppTextStyles.caption(),
                ),
                const Spacer(),
                SizedBox(width: Responsive.w(4)),
              ],
            ),

            SizedBox(height: Responsive.h(4)),

            // Phone
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Text(
                  quotation.customerPhone,
                  style: AppTextStyles.caption(),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(8)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(8)),

            // Footer - Date, Items & Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd-MM-yyyy').format(quotation.date),
                      style: AppTextStyles.caption(),
                    ),
                    Text(
                      '${quotation.items} items',
                      style: AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Text(
                  currency.format(quotation.grandTotal),
                  style: AppTextStyles.bodyBold(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class QuotationModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final int items;
  final double grandTotal;
  final String status;


  QuotationModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.items,
    required this.grandTotal,
    required this.status,

  });
}