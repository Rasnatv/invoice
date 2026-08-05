class ActiveDriverResponseModel {
  ActiveDriverResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final List<ActiveDriverModel> data;
  final String message;

  factory ActiveDriverResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    final list = dataMap['list'] as List<dynamic>? ?? [];
    return ActiveDriverResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: list
          .map((e) => ActiveDriverModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}

/// Lightweight driver record returned by GET /drivers/active.
class ActiveDriverModel {
  ActiveDriverModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.vehicleNumber,
    required this.joiningDate,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String vehicleNumber;
  final String joiningDate;

  factory ActiveDriverModel.fromJson(Map<String, dynamic> json) {
    return ActiveDriverModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}