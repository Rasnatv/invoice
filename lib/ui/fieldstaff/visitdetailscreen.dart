import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import 'addfieldstaff.dart';
import 'fieldstaff repository.dart';
import 'fieldstaffvisitmodel.dart';

/// Full detail view of a single logged party visit.
class FieldStaffVisitDetailScreen extends StatelessWidget {
  const FieldStaffVisitDetailScreen({super.key, required this.visit});

  final FieldStaffVisitModel visit;

  Future<void> _callNumber(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start a call on this device')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Visit'),
        content: Text('Remove the visit to "${visit.partyName}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      FieldStaffRepository.instance.deleteVisit(visit.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateLabel = DateFormat('dd MMM yyyy, EEEE').format(visit.visitDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Visit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddFieldVisitScreen(staffName: visit.staffName, existing: visit),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(Responsive.w(20)),
          children: [
            _photoCard(),
            SizedBox(height: Responsive.h(18)),
            _infoCard(context, dateLabel: dateLabel, currency: currency),
            if (visit.notes != null) ...[
              SizedBox(height: Responsive.h(14)),
              _notesCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _photoCard() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        image: visit.hasImage
            ? DecorationImage(image: FileImage(visit.imageFile!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: !visit.hasImage
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 34, color: AppColors.textSecondary.withOpacity(0.5)),
          SizedBox(height: Responsive.h(8)),
          Text('No photo attached', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12))),
        ],
      )
          : null,
    );
  }

  Widget _infoCard(BuildContext context, {required String dateLabel, required NumberFormat currency}) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(visit.partyName, style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(17))),
          SizedBox(height: Responsive.h(4)),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text(dateLabel, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12))),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.08)),
          SizedBox(height: Responsive.h(14)),
          _detailRow(icon: Icons.location_on_outlined, label: 'Address', value: visit.address),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: _detailRow(icon: Icons.phone_outlined, label: 'Phone', value: visit.phoneNo),
              ),
              Material(
                color: AppColors.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _callNumber(context, visit.phoneNo),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.call_rounded, color: AppColors.info, size: 19),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(16)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: Responsive.w(8)),
                Text('Incentive Earned', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12.5), fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(
                  currency.format(visit.incentiveAmount),
                  style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: Responsive.w(6)),
              Text('Notes', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13))),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          Text(visit.notes ?? '', style: TextStyle(fontSize: Responsive.sp(12.5), color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _detailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: Responsive.w(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(10.5))),
              SizedBox(height: Responsive.h(2)),
              Text(value, style: TextStyle(fontSize: Responsive.sp(13), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}