
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../core/utils/logout_helper.dart';
import 'changepassword.dart';
import 'viewprofile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Always fetch the logged-in user's profile when this screen opens.
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Profile', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null && state.profile == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage!),
                    SizedBox(height: Responsive.h(12)),
                    TextButton(
                      onPressed: () => context
                          .read<ProfileBloc>()
                          .add(const LoadProfile()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final profile = state.profile;

            return ListView(
              padding: EdgeInsets.all(Responsive.w(20)),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: Responsive.w(46),
                        backgroundColor: AppColors.primarySoft,
                        child: Icon(Icons.person,
                            size: Responsive.w(46), color: AppColors.primary),
                      ),
                      SizedBox(height: Responsive.h(14)),
                      Text(profile?.name ?? '-', style: AppTextStyles.h2()),
                      Text(profile?.mobile ?? '-', style: AppTextStyles.body()),
                      Text(profile?.email ?? '-',
                          style: AppTextStyles.caption()),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(28)),
                _ProfileTile(
                  icon: Icons.person_outline_rounded,
                  label: 'My Profile',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ViewProfileScreen()),
                    );
                  },
                ),
                _ProfileTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),
                _ProfileTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  color: AppColors.error,
                  onTap: () => logout(context),
                ),
              ],
            );
          },
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
  const _ProfileTile(
      {required this.icon, required this.label, required this.onTap, this.color});

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
        trailing:
        const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      ),
    );
  }
}