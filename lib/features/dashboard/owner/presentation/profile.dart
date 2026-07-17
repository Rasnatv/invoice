import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../salesman/profile/presentation/changepassword.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title:  Text('Profile',style: AppTextStyles.h6(),)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(Responsive.w(20)),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
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
                  SizedBox(height: Responsive.h(14)),
                  Text('Rahul Kumar', style: AppTextStyles.h2()),
                  Text('+91 98765 43210', style: AppTextStyles.body()),
                  Text('rahul.sales@dreams.com', style: AppTextStyles.caption()),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(28)),
            _ProfileTile(icon: Icons.lock_outline_rounded, label: 'Change Password', onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            }),
            _ProfileTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: AppColors.error,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: c),
        title: Text(label, style: AppTextStyles.bodyBold(color: c)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      ),
    );
  }
}
