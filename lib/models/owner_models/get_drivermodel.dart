
import 'package:intl/intl.dart';

class DriverGetResponseModel {
  DriverGetResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final List<DriverGetModel> data;
  final String message;

  bool get isSuccess => status == '1';

  factory DriverGetResponseModel.fromJson(Map<String, dynamic> json) {
    // Backends sometimes return [] instead of {} when empty, so don't hard-cast.
    final raw = json['data'];
    final dataMap = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    final listRaw = dataMap['list'];
    final list = listRaw is List<dynamic> ? listRaw : <dynamic>[];

    return DriverGetResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: list
          .whereType<Map<String, dynamic>>()
          .map(DriverGetModel.fromJson)
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}

/// A single driver.
class DriverGetModel {
  DriverGetModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.joiningDate,
    required this.isActive,
    this.createdAt = '',
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;

  /// "dd-MM-yyyy" exactly as returned by the API (e.g. "01-10-2026").
  final String joiningDate;
  final bool isActive;
  final String createdAt; // not returned by this API, kept for UI compatibility

  factory DriverGetModel.fromJson(Map<String, dynamic> json) {
    return DriverGetModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
      isActive: _asBool(json['is_active']),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  /// Safe parse of [joiningDate] (dd-MM-yyyy) for pre-filling the edit
  /// screen's date picker. Returns null if empty / invalid.
  DateTime? get joiningDateValue {
    final s = joiningDate.trim();
    if (s.isEmpty) return null;
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(s);
    } catch (_) {
      return DateTime.tryParse(s); // fallback for yyyy-MM-dd
    }
  }

  DriverGetModel copyWith({
    int? id,
    String? name,
    String? email,
    String? mobile,
    String? licenseNumber,
    String? vehicleNumber,
    String? joiningDate,
    bool? isActive,
    String? createdAt,
  }) {
    return DriverGetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      joiningDate: joiningDate ?? this.joiningDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value?.toString().toLowerCase();
    return s == 'true' || s == '1';
  }
}