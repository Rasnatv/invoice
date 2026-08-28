/// GET /field-staff/active
///
/// {
///   "status": "1",
///   "status_code": "200",
///   "data": {
///     "list": [
///       { "id": "27", "name": "Field Staff" },
///       { "id": "78", "name": "Kannan" }
///     ]
///   },
///   "message": "Active field staff fetched successfully"
/// }

class ActiveFieldStaffModel {
  final String id;
  final String name;

  ActiveFieldStaffModel({required this.id, required this.name});

  factory ActiveFieldStaffModel.fromJson(Map<String, dynamic> json) {
    return ActiveFieldStaffModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class ActiveFieldStaffResponseModel {
  final String status;
  final String statusCode;
  final List<ActiveFieldStaffModel> data;
  final String message;

  ActiveFieldStaffResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory ActiveFieldStaffResponseModel.fromJson(Map<String, dynamic> json) {
    final listJson =
        (json['data'] as Map<String, dynamic>?)?['list'] as List<dynamic>? ??
            const [];
    return ActiveFieldStaffResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: listJson
          .map((e) => ActiveFieldStaffModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}