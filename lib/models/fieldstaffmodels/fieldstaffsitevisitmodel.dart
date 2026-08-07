/// Models for:
/// - GET  /site-visits/my
/// - POST /site-visits/create
///
/// Also hosts [SiteVisitActionResponseModel], the shared
/// {status, status_code, data: {}, message} envelope returned by
/// create / update / delete.

class SiteVisitListItemModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String siteAddress;
  final String visitDate;
  final String statusLabel;
  final String fieldStaffName;
  final String incentiveEarned;
  final String thumbnailUrl;

  const SiteVisitListItemModel({
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

  factory SiteVisitListItemModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitListItemModel(
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

  bool get hasThumbnail => thumbnailUrl.isNotEmpty;
}

/// The "today" / "all" blocks in the /my response — both share this shape:
/// {"count": "1", "list": [...]}
class SiteVisitGroupModel {
  final int count;
  final List<SiteVisitListItemModel> list;

  const SiteVisitGroupModel({required this.count, required this.list});

  factory SiteVisitGroupModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'];
    return SiteVisitGroupModel(
      count: int.tryParse(json['count']?.toString() ?? '') ?? 0,
      list: rawList is List
          ? rawList
          .whereType<Map>()
          .map((e) => SiteVisitListItemModel.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
    );
  }

  static const empty = SiteVisitGroupModel(count: 0, list: []);
}

class SiteVisitMyDataModel {
  final int totalVisits;
  final int todayVisits;
  final double totalIncentive;
  final SiteVisitGroupModel today;
  final SiteVisitGroupModel all;

  const SiteVisitMyDataModel({
    required this.totalVisits,
    required this.todayVisits,
    required this.totalIncentive,
    required this.today,
    required this.all,
  });

  factory SiteVisitMyDataModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitMyDataModel(
      totalVisits: int.tryParse(json['total_visits']?.toString() ?? '') ?? 0,
      todayVisits: int.tryParse(json['today_visits']?.toString() ?? '') ?? 0,
      totalIncentive: double.tryParse(json['total_incentive']?.toString() ?? '') ?? 0,
      today: json['today'] is Map
          ? SiteVisitGroupModel.fromJson((json['today'] as Map).cast<String, dynamic>())
          : SiteVisitGroupModel.empty,
      all: json['all'] is Map
          ? SiteVisitGroupModel.fromJson((json['all'] as Map).cast<String, dynamic>())
          : SiteVisitGroupModel.empty,
    );
  }

  static const empty = SiteVisitMyDataModel(
    totalVisits: 0,
    todayVisits: 0,
    totalIncentive: 0,
    today: SiteVisitGroupModel.empty,
    all: SiteVisitGroupModel.empty,
  );
}

class SiteVisitMyResponseModel {
  final String status;
  final String statusCode;
  final SiteVisitMyDataModel data;
  final String message;

  const SiteVisitMyResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory SiteVisitMyResponseModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitMyResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: json['data'] is Map
          ? SiteVisitMyDataModel.fromJson((json['data'] as Map).cast<String, dynamic>())
          : SiteVisitMyDataModel.empty,
      message: json['message']?.toString() ?? '',
    );
  }
}

/// POST /site-visits/create request body.
/// area_sqft / project_type / estimated_budget / preferred_products are
/// commented-out/optional in your sample payload, so they're only sent
/// when actually provided.
class SiteVisitCreateRequestModel {
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String siteAddress;
  final double? areaSqft;
  final String? projectType;
  final double? estimatedBudget;
  final String? preferredProducts;
  final String visitDate;
  final String? notes;
  final List<String>? images;

  const SiteVisitCreateRequestModel({
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.siteAddress,
    this.areaSqft,
    this.projectType,
    this.estimatedBudget,
    this.preferredProducts,
    required this.visitDate,
    this.notes,
    this.images,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'site_address': siteAddress,
      'visit_date': visitDate,
    };
    if (customerEmail != null && customerEmail!.isNotEmpty) {
      map['customer_email'] = customerEmail;
    }
    if (areaSqft != null) map['area_sqft'] = areaSqft;
    if (projectType != null) map['project_type'] = projectType;
    if (estimatedBudget != null) map['estimated_budget'] = estimatedBudget;
    if (preferredProducts != null) map['preferred_products'] = preferredProducts;
    if (notes != null) map['notes'] = notes;
    if (images != null && images!.isNotEmpty) map['images'] = images;
    return map;
  }
}

/// Shared response shape for create / update / delete — all three return
/// the same {status, status_code, data: {}, message} envelope.
class SiteVisitActionResponseModel {
  final String status;
  final String statusCode;
  final String message;

  const SiteVisitActionResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  factory SiteVisitActionResponseModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitActionResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  bool get isSuccess => status == '1';
}