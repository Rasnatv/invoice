class ScheduleEventModel {
  final String title;
  final String subtitle;
  final String time;
  final ScheduleEventType type;

  const ScheduleEventModel({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}

enum ScheduleEventType { meeting, siteVisit, call }
