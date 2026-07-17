import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('My Profile', style: AppTextStyles.h6())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(Responsive.w(20)),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: Responsive.w(46),
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(Icons.person, size: Responsive.w(46), color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(24)),
            _ProfileField(label: 'Full Name', value: 'Rahul Kumar'),
            _ProfileField(label: 'Phone Number', value: '+91 98765 43210'),
            _ProfileField(label: 'Email', value: 'rahul.sales@dreams.com'),
            _ProfileField(label: 'Employee ID', value: 'EMP1024'),
            _ProfileField(label: 'Designation', value: 'Sales Executive'),
            SizedBox(height: Responsive.h(28)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // TODO: navigate to edit profile flow
                },
                child: Text('Edit Profile', style: AppTextStyles.bodyBold(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(12)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption()),
          SizedBox(height: Responsive.h(4)),
          Text(value, style: AppTextStyles.bodyBold(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}