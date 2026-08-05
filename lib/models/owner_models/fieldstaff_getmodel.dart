/// Response wrapper for GET /field-staff.
/// Matches: { "status": "1", "status_code": "200", "data": { "list": [...] }, "message": "..." }
class FieldStaffListResponse {
  FieldStaffListResponse({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  final String status;
  final String statusCode;
  final List<FieldStaffModel> list;
  final String message;

  factory FieldStaffListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final rawList = data['list'] as List<dynamic>? ?? [];
    return FieldStaffListResponse(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      list: rawList
          .map((e) => FieldStaffModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }

  bool get isSuccess => status == '1';
}

/// Core field staff entity — used for display, list items, and prefilling
/// the edit form. Not tied to any single API's request/response shape.
class FieldStaffModel {
  FieldStaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.employeeCode,
    required this.joiningDate,
    required this.isActive,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String employeeCode;
  final String joiningDate; // "yyyy-MM-dd"
  final bool isActive;

  factory FieldStaffModel.fromJson(Map<String, dynamic> json) {
    return FieldStaffModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
      isActive: json['is_active']?.toString() == '1',
    );
  }

  FieldStaffModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? address,
    String? employeeCode,
    String? joiningDate,
    bool? isActive,
  }) {
    return FieldStaffModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      employeeCode: employeeCode ?? this.employeeCode,
      joiningDate: joiningDate ?? this.joiningDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FieldStaffModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.mobile == mobile &&
        other.address == address &&
        other.employeeCode == employeeCode &&
        other.joiningDate == joiningDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(
      id, name, email, mobile, address, employeeCode, joiningDate, isActive);
}