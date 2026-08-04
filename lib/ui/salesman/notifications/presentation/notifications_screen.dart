import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../dummymodels/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    NotificationModel(
      title: 'Estimate #2546 approved',
      subtitle: 'by Admin',
      time: '10:30 AM',
      type: NotificationType.estimate,
    ),
    NotificationModel(
      title: 'Dispatch DB #1256 generated',
      subtitle: 'ABC Builders',
      time: 'Yesterday',
      type: NotificationType.dispatch,
    ),
    NotificationModel(
      title: 'Payment of DB #1254 completed',
      subtitle: 'Royal Builders',
      time: 'Yesterday',
      type: NotificationType.payment,
    ),
    NotificationModel(
      title: 'New estimate #2547 created',
      subtitle: 'Today',
      time: '09:15 AM',
      type: NotificationType.estimate,
    ),
    NotificationModel(
      title: 'Follow up: Site visit tomorrow',
      subtitle: 'Skyline Constructions',
      time: '08:45 AM',
      type: NotificationType.followUp,
    ),
  ];

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.estimate:
        return Icons.description_rounded;
      case NotificationType.dispatch:
        return Icons.local_shipping_rounded;
      case NotificationType.payment:
        return Icons.payments_rounded;
      case NotificationType.followUp:
        return Icons.event_available_rounded;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.estimate:
        return AppColors.primary;
      case NotificationType.dispatch:
        return AppColors.info;
      case NotificationType.payment:
        return AppColors.success;
      case NotificationType.followUp:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Clear All', style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.all(Responsive.w(16)),
          itemCount: _items.length,
          separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
          itemBuilder: (context, i) {
            final n = _items[i];
            final color = _colorFor(n.type);
            return Container(
              padding: EdgeInsets.all(Responsive.w(14)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_iconFor(n.type), color: color),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: AppTextStyles.bodyBold()),
                        Text(n.subtitle, style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                  Text(n.time, style: AppTextStyles.caption()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
