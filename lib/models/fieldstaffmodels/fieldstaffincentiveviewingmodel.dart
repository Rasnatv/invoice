/// Model for a single row returned by
/// GET /field-staff-incentives?page={page}&per_page={perPage}
class FieldStaffIncentive {
  final String id;
  final String fieldStaffId;
  final String fieldStaffName;
  final String siteVisitId;
  final String estimateId;
  final String estimateNumber;
  final String incentiveAmount;
  final String incentiveAmountFormatted;
  final String status;
  final String statusLabel;
  final String statusColor;
  final String paidAt;
  final String createdAt;

  const FieldStaffIncentive({
    required this.id,
    required this.fieldStaffId,
    required this.fieldStaffName,
    required this.siteVisitId,
    required this.estimateId,
    required this.estimateNumber,
    required this.incentiveAmount,
    required this.incentiveAmountFormatted,
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    required this.paidAt,
    required this.createdAt,
  });

  factory FieldStaffIncentive.fromJson(Map<String, dynamic> json) {
    return FieldStaffIncentive(
      id: json['id']?.toString() ?? '',
      fieldStaffId: json['field_staff_id']?.toString() ?? '',
      fieldStaffName: json['field_staff_name']?.toString() ?? '',
      siteVisitId: json['site_visit_id']?.toString() ?? '',
      estimateId: json['estimate_id']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      incentiveAmount: json['incentive_amount']?.toString() ?? '',
      incentiveAmountFormatted:
      json['incentive_amount_formatted']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      statusColor: json['status_color']?.toString() ?? '',
      paidAt: json['paid_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_staff_id': fieldStaffId,
      'field_staff_name': fieldStaffName,
      'site_visit_id': siteVisitId,
      'estimate_id': estimateId,
      'estimate_number': estimateNumber,
      'incentive_amount': incentiveAmount,
      'incentive_amount_formatted': incentiveAmountFormatted,
      'status': status,
      'status_label': statusLabel,
      'status_color': statusColor,
      'paid_at': paidAt,
      'created_at': createdAt,
    };
  }
}

/// Wraps the full envelope: status / status_code / data.list / message.
class FieldStaffIncentivesResponse {
  final String status;
  final String statusCode;
  final String message;
  final List<FieldStaffIncentive> list;

  const FieldStaffIncentivesResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.list,
  });

  factory FieldStaffIncentivesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final listJson = data['list'] as List<dynamic>? ?? const [];

    return FieldStaffIncentivesResponse(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      list: listJson
          .map((e) => FieldStaffIncentive.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}