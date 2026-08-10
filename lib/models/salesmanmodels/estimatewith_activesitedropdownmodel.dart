class SiteVisitDropdownItem {
  final String id;
  final String customerName;
  final String customerPhone;
  final String siteAddress;
  final String fieldStaffName;
  final String visitDate;

  const SiteVisitDropdownItem({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.siteAddress,
    required this.fieldStaffName,
    required this.visitDate,
  });

  factory SiteVisitDropdownItem.fromJson(Map<String, dynamic> json) {
    return SiteVisitDropdownItem(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      siteAddress: json['site_address']?.toString() ?? '',
      fieldStaffName: json['field_staff_name']?.toString() ?? '',
      visitDate: json['visit_date']?.toString() ?? '',
    );
  }
}

class SiteVisitDropdownResponseModel {
  final String status;
  final String statusCode;
  final List<SiteVisitDropdownItem> list;
  final String message;

  const SiteVisitDropdownResponseModel({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  factory SiteVisitDropdownResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawList = (data is Map<String, dynamic>) ? data['list'] : null;
    return SiteVisitDropdownResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      list: rawList is List
          ? rawList
          .whereType<Map<String, dynamic>>()
          .map(SiteVisitDropdownItem.fromJson)
          .toList()
          : const [],
      message: json['message']?.toString() ?? '',
    );
  }
}