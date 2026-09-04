//
// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../../core/utils/logout_helper.dart';
// import '../salesman/changepassword.dart';
// import 'editprofile.dart';
//
// class OwnerProfileScreen extends StatefulWidget {
//   const OwnerProfileScreen({super.key});
//
//   @override
//   State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
// }
//
// class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
//   String _name = 'Rahul Kumar';
//   String _phone = '+91 98765 43210';
//   String _email = 'rahul.sales@dreams.com';
//
//   Future<void> _openEditProfile() async {
//     final result = await Navigator.of(context).push<Map<String, String>>(
//       MaterialPageRoute(
//         builder: (_) => EditProfileScreen(
//           initialName: _name,
//           initialPhone: _phone,
//           initialEmail: _email,
//         ),
//       ),
//     );
//
//     if (result != null && mounted) {
//       setState(() {
//         _name = result['name'] ?? _name;
//         _phone = result['phone'] ?? _phone;
//         _email = result['email'] ?? _email;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Profile', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.all(Responsive.w(20)),
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: Responsive.w(46),
//                         backgroundColor: AppColors.primarySoft,
//                         child: Icon(Icons.person, size: Responsive.w(46), color: AppColors.primary),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: GestureDetector(
//                           onTap: _openEditProfile,
//                           child: Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
//                             child: const Icon(Icons.edit, color: Colors.white, size: 14),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(14)),
//                   Text(_name, style: AppTextStyles.h2()),
//                   Text(_phone, style: AppTextStyles.body()),
//                   Text(_email, style: AppTextStyles.caption()),
//                 ],
//               ),
//             ),
//             SizedBox(height: Responsive.h(28)),
//             _ProfileTile(
//               icon: Icons.person_outline_rounded,
//               label: 'Edit Profile',
//               onTap: _openEditProfile,
//             ),
//             _ProfileTile(
//               icon: Icons.lock_outline_rounded,
//               label: 'Change Password',
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
//                 );
//               },
//             ),
//             _ProfileTile(
//               icon: Icons.logout_rounded,
//               label: 'Logout',
//               color: AppColors.error,
//               onTap: () => logout(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ProfileTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color? color;
//   final VoidCallback onTap;
//   const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     final c = color ?? AppColors.textPrimary;
//     return Container(
//       margin: EdgeInsets.only(bottom: Responsive.h(10)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: ListTile(
//         onTap: onTap,
//         leading: Icon(icon, color: c),
//         title: Text(label, style: AppTextStyles.bodyBold(color: c)),
//         trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/logout_helper.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../models/profilemodel.dart';
import 'editprofile.dart';
import 'owner_changepassword.dart';


class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bloc lives here so the same instance (and its loaded profile) is
    // shared with EditProfileScreen and OwnerChangePasswordScreen when
    // they're pushed on top — no more manual result-passing via pop().
    return BlocProvider(
      create: (_) => ProfileBloc()..add(const LoadProfile()),
      child: const _OwnerProfileView(),
    );
  }
}

class _OwnerProfileView extends StatelessWidget {
  const _OwnerProfileView();

  Future<void> _openEditProfile(BuildContext context, ProfileModel? profile) {
    final bloc = context.read<ProfileBloc>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: EditProfileScreen(
            initialName: profile?.name ?? '',
            initialPhone: profile?.mobile ?? '',
            initialEmail: profile?.email ?? '',
          ),
        ),
      ),
    );
  }

  void _openChangePassword(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const OwnerChangePasswordScreen(),
        ),
      ),
    );
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
            // First load, nothing to show yet.
            if (state.isLoading && state.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // First load failed outright.
            if (state.errorMessage != null && state.profile == null) {
              return _ProfileErrorState(
                message: state.errorMessage!,
                onRetry: () => context.read<ProfileBloc>().add(const LoadProfile()),
              );
            }

            final profile = state.profile;

            return RefreshIndicator(
              onRefresh: () async => context.read<ProfileBloc>().add(const LoadProfile()),
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
                              child: GestureDetector(
                                onTap: () => _openEditProfile(context, profile),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),
                        // Only render what the API actually returned —
                        // no placeholder/dummy text for missing fields.
                        if (profile?.name != null)
                          Text(profile!.name!, style: AppTextStyles.h2()),
                        if (profile?.mobile != null)
                          Text(profile!.mobile!, style: AppTextStyles.body()),
                        if (profile?.email != null)
                          Text(profile!.email!, style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(28)),
                  _ProfileTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () => _openEditProfile(context, profile),
                  ),
                  _ProfileTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () => _openChangePassword(context),
                  ),
                  _ProfileTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    color: AppColors.error,
                    onTap: () => logout(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: Responsive.w(40)),
            SizedBox(height: Responsive.h(12)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(16)),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
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