import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';

/// The bold red "Total Earnings — This Month" banner on Dashboard Home.
class EarningsBanner extends StatelessWidget {
  final double amount;
  const EarningsBanner({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(18)),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Earnings', style: AppTextStyles.subtitle(color: Colors.white70)),
              SizedBox(height: Responsive.h(6)),
              Text(formatted, style: AppTextStyles.h1(color: Colors.white)),
              SizedBox(height: Responsive.h(4)),
              Text('This Month', style: AppTextStyles.caption(color: Colors.white70)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

/// The greeting + notification bell + avatar header on Dashboard Home.
class DashboardTopBar extends StatelessWidget {
  final String name;
  final String dateLabel;
  final VoidCallback? onBellTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onMenuTap;

  const DashboardTopBar({
    super.key,
    required this.name,
    required this.dateLabel,
    this.onBellTap,
    this.onAvatarTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onMenuTap,
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning,', style: AppTextStyles.subtitle()),
              Row(
                children: [
                  Text(name, style: AppTextStyles.h3()),
                  const SizedBox(width: 4),
                  const Text('👋'),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onBellTap,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onAvatarTap,
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
