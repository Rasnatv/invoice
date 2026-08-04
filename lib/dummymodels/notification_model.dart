class NotificationModel {
  final String title;
  final String subtitle;
  final String time;
  final NotificationType type;

  const NotificationModel({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}

enum NotificationType { estimate, dispatch, payment, followUp }
