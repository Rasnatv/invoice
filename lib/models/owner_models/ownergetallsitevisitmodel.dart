class SiteVisitItemModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String siteAddress;
  final String visitDate;
  final String statusLabel;
  final String fieldStaffName;
  final String incentiveEarned;
  final String thumbnailUrl;

  const SiteVisitItemModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.siteAddress,
    required this.visitDate,
    required this.statusLabel,
    required this.fieldStaffName,
    required this.incentiveEarned,
    required this.thumbnailUrl,
  });

  factory SiteVisitItemModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitItemModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      siteAddress: json['site_address']?.toString() ?? '',
      visitDate: json['visit_date']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      fieldStaffName: json['field_staff_name']?.toString() ?? '',
      incentiveEarned: json['incentive_earned']?.toString() ?? '0',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
    );
  }

  double get incentiveEarnedValue => double.tryParse(incentiveEarned) ?? 0;
  DateTime? get visitDateValue => DateTime.tryParse(visitDate);
  bool get isConverted => statusLabel.toLowerCase() == 'converted';
  bool get isPending => statusLabel.toLowerCase() == 'pending';
  bool get hasThumbnail => thumbnailUrl.isNotEmpty;
}

class SiteVisitsSectionModel {
  final int count;
  final List<SiteVisitItemModel> list;

  const SiteVisitsSectionModel({required this.count, required this.list});

  factory SiteVisitsSectionModel.fromJson(Map<String, dynamic>? json) {
    final safe = json ?? const {'count': '0', 'list': []};
    return SiteVisitsSectionModel(
      count: int.tryParse(safe['count']?.toString() ?? '0') ?? 0,
      list: ((safe['list'] as List?) ?? [])
          .map((e) => SiteVisitItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SiteVisitsSummaryModel {
  final int totalVisits;
  final int todayVisits;
  final String totalIncentive;
  final SiteVisitsSectionModel today;
  final SiteVisitsSectionModel all;

  const SiteVisitsSummaryModel({
    required this.totalVisits,
    required this.todayVisits,
    required this.totalIncentive,
    required this.today,
    required this.all,
  });

  factory SiteVisitsSummaryModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitsSummaryModel(
      totalVisits: int.tryParse(json['total_visits']?.toString() ?? '0') ?? 0,
      todayVisits: int.tryParse(json['today_visits']?.toString() ?? '0') ?? 0,
      totalIncentive: json['total_incentive']?.toString() ?? '0',
      today: SiteVisitsSectionModel.fromJson(json['today'] as Map<String, dynamic>?),
      all: SiteVisitsSectionModel.fromJson(json['all'] as Map<String, dynamic>?),
    );
  }

  double get totalIncentiveValue => double.tryParse(totalIncentive) ?? 0;
}