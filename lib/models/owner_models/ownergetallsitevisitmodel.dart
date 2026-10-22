/// Parses numbers like "395,000.00" or "395000.00" safely.
double _parseAmount(dynamic value) {
  final cleaned = value?.toString().replaceAll(',', '').trim() ?? '';
  return double.tryParse(cleaned) ?? 0;
}

/// Parses the API's "dd-MM-yyyy" dates (e.g. "22-10-2026").
/// Falls back to ISO ("yyyy-MM-dd") if the server ever sends that instead.
DateTime? _parseVisitDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;

  final parts = text.split('-');
  if (parts.length == 3 && parts[0].length <= 2) {
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day != null &&
        month != null &&
        year != null &&
        month >= 1 &&
        month <= 12 &&
        day >= 1 &&
        day <= 31) {
      return DateTime(year, month, day);
    }
    return null;
  }

  return DateTime.tryParse(text);
}

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

  double get incentiveEarnedValue => _parseAmount(incentiveEarned);
  DateTime? get visitDateValue => _parseVisitDate(visitDate);
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
    final rawList = safe['list'];
    return SiteVisitsSectionModel(
      count: int.tryParse(safe['count']?.toString() ?? '0') ?? 0,
      list: rawList is List
          ? rawList
          .whereType<Map>()
          .map((e) =>
          SiteVisitItemModel.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
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
      today: SiteVisitsSectionModel.fromJson(
          json['today'] is Map
              ? (json['today'] as Map).cast<String, dynamic>()
              : null),
      all: SiteVisitsSectionModel.fromJson(
          json['all'] is Map
              ? (json['all'] as Map).cast<String, dynamic>()
              : null),
    );
  }

  /// "395,000.00" -> 395000.0
  double get totalIncentiveValue => _parseAmount(totalIncentive);
}