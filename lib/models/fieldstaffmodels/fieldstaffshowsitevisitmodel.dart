/// Models for POST /site-visits/show

class SiteVisitImageModel {
  final String imageId;
  final String imageUrl;

  const SiteVisitImageModel({required this.imageId, required this.imageUrl});

  factory SiteVisitImageModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitImageModel(
      imageId: json['image_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}

class SiteVisitDetailModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String siteAddress;
  final String visitDate;
  final String notes;
  final String statusLabel;
  final String incentiveEarned;
  final String incentiveStatusLabel;
  final List<SiteVisitImageModel> images;

  const SiteVisitDetailModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.siteAddress,
    required this.visitDate,
    required this.notes,
    required this.statusLabel,
    required this.incentiveEarned,
    required this.incentiveStatusLabel,
    required this.images,
  });

  factory SiteVisitDetailModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    return SiteVisitDetailModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      customerEmail: json['customer_email']?.toString() ?? '',
      siteAddress: json['site_address']?.toString() ?? '',
      visitDate: json['visit_date']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      incentiveEarned: json['incentive_earned']?.toString() ?? '0',
      incentiveStatusLabel: json['incentive_status_label']?.toString() ?? '',
      images: rawImages is List
          ? rawImages
          .whereType<Map>()
          .map((e) => SiteVisitImageModel.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
    );
  }
}

class SiteVisitShowResponseModel {
  final String status;
  final String statusCode;
  final SiteVisitDetailModel? data;
  final String message;

  const SiteVisitShowResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory SiteVisitShowResponseModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitShowResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: json['data'] is Map
          ? SiteVisitDetailModel.fromJson((json['data'] as Map).cast<String, dynamic>())
          : null,
      message: json['message']?.toString() ?? '',
    );
  }
}

/// POST /site-visits/show request body: {"id": "6"}
class SiteVisitShowRequestModel {
  final String id;

  const SiteVisitShowRequestModel({required this.id});

  Map<String, dynamic> toJson() => {'id': id};
}