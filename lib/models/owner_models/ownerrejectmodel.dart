/// Request body for POST /quotations/reject:
/// { "id": 1, "rejection_notes": "..." }
class QuotationRejectRequest {
  final String id;
  final String rejectionNotes;

  const QuotationRejectRequest({
    required this.id,
    required this.rejectionNotes,
  });

  Map<String, dynamic> toJson() => {
    'id': int.tryParse(id) ?? id,
    'rejection_notes': rejectionNotes,
  };
}

/// Response body for POST /quotations/reject:
/// { "status": "1", "status_code": "200", "data": {}, "message": "..." }
class QuotationRejectResponseModel {
  final String status;
  final String message;

  const QuotationRejectResponseModel({
    required this.status,
    required this.message,
  });

  factory QuotationRejectResponseModel.fromJson(Map<String, dynamic> json) {
    return QuotationRejectResponseModel(
      status: json['status']?.toString() ?? '0',
      message: json['message']?.toString() ?? '',
    );
  }
}