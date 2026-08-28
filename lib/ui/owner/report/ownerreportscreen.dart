import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import 'ownerestimate_reportfilterscreen.dart';
import 'ownerincentive_reportfilterscreen.dart';
import 'ownerquotation_reportfilterscreen.dart';
import 'ownerreportfilterscreen.dart';

/// Reports home screen — "Select a report to generate".
/// Matches mockup frame 1.
class OwnerReportsScreen extends StatelessWidget {
  const OwnerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:  AppBar(
          title: Text(' Reports', style: AppTextStyles.h6())),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(20),
              Responsive.h(18),
              Responsive.w(20),
              Responsive.h(30),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ReportTile(
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Quotation Report',
                  subtitle: 'All quotations by salesman / contractor',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OwnerQuotationReportFilterScreen(),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                _ReportTile(
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF60A5FA),
                  title: 'Estimate Report',
                  subtitle: 'All estimates by salesman / contractor',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OwnerEstimateReportFilterScreen(),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                _ReportTile(
                  icon: Icons.savings_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Incentive Report',
                  subtitle: 'Salesman & field staff incentives',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OwnerIncentiveReportFilterScreen(),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(22)),
                Text(
                  'PERFORMANCE REPORTS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.sp(11),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                _ReportTile(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Salesman Report',
                  subtitle: 'Full performance summary per salesman',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OwnerReportFilterScreen(
                        type: ReportPersonType.salesman,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                _ReportTile(
                  icon: Icons.flag_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Contractor Report',
                  subtitle: 'Business summary per contractor',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OwnerReportFilterScreen(
                        type: ReportPersonType.contractor,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(10)),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              SizedBox(width: Responsive.w(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyBold(color: AppColors.black)
                          .copyWith(fontSize: Responsive.sp(14.5)),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(subtitle, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}