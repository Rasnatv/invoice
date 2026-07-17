import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// "My Estimates", "Recent Estimates  View All" style row header used
/// throughout the dashboard list screens.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h3()),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.bodyBold(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

/// Red curved app bar used across dashboard sub-screens: back arrow /
/// menu icon, centered title, optional trailing action icon.
class SectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final List<Widget>? actions;

  const SectionAppBar({
    super.key,
    required this.title,
    this.leadingIcon = Icons.arrow_back,
    this.onLeadingTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(leadingIcon, color: Colors.white),
        onPressed: onLeadingTap ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(title, style: AppTextStyles.h3(color: Colors.white)),
      centerTitle: true,
      actions: actions,
    );
  }
}
