//
// class HSalesmanModel {
//   const HSalesmanModel({
//     required this.id,
//     required this.name,
//     required this.mobile,
//     required this.email,
//     this.designationName = '',
//     this.joiningDate,
//     this.employeeCode = '',
//     this.isActive = false,
//     this.salary = 0,
//   });
//
//   final String id;
//   final String name;
//   final String mobile;
//   final String email;
//   final String designationName;
//   final DateTime? joiningDate;
//   final String employeeCode;
//   final bool isActive;
//   final num salary;
//
//   factory HSalesmanModel.fromJson(Map<String, dynamic> json) {
//     return HSalesmanModel(
//       id: json['id']?.toString() ?? '',
//       name: (json['name'] ?? '').toString().trim(),
//       mobile: (json['mobile'] ?? '').toString().trim(),
//       email: (json['email'] ?? '').toString().trim(),
//       designationName: (json['designation_name'] ?? '').toString().trim(),
//       joiningDate: _parseDate(json['joining_date']),
//       employeeCode: (json['employee_code'] ?? '').toString().trim(),
//       isActive: json['is_active']?.toString() == '1',
//       salary: num.tryParse(json['salary']?.toString() ?? '') ?? 0,
//     );
//   }
//
//   static DateTime? _parseDate(dynamic value) {
//     if (value == null) return null;
//     return DateTime.tryParse(value.toString().trim());
//   }
//
//   HSalesmanModel copyWith({
//     String? id,
//     String? name,
//     String? mobile,
//     String? email,
//     String? designationName,
//     DateTime? joiningDate,
//     String? employeeCode,
//     bool? isActive,
//     num? salary,
//   }) {
//     return HSalesmanModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       mobile: mobile ?? this.mobile,
//       email: email ?? this.email,
//       designationName: designationName ?? this.designationName,
//       joiningDate: joiningDate ?? this.joiningDate,
//       employeeCode: employeeCode ?? this.employeeCode,
//       isActive: isActive ?? this.isActive,
//       salary: salary ?? this.salary,
//     );
//   }
// }
//
// /// GET /salesmen — the list lives at data.list
// class SalesmanGetResponseModel {
//   const SalesmanGetResponseModel({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   final String status;
//   final String message;
//   final List<HSalesmanModel> data;
//
//   factory SalesmanGetResponseModel.fromJson(Map<String, dynamic> json) {
//     final dataMap = json['data'] as Map<String, dynamic>? ?? const {};
//     final list = dataMap['list'] as List<dynamic>? ?? const [];
//     return SalesmanGetResponseModel(
//       status: json['status']?.toString() ?? '0',
//       message: json['message']?.toString() ?? '',
//       data: list
//           .map((e) => HSalesmanModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// /// POST /salesmen/create
// class SalesmanAddRequestModel {
//   const SalesmanAddRequestModel({
//     required this.name,
//     required this.email,
//     required this.designationId,
//     required this.mobile,
//     required this.salary,
//     required this.joiningDate,
//     this.password,
//   });
//
//   final String name;
//   final String email;
//   final String designationId;
//   final String mobile;
//   final num salary;
//   final String joiningDate; // yyyy-MM-dd
//   final String? password;
//
//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'email': email,
//     'designation_id': designationId,
//     'mobile': mobile,
//     'salary': salary.toString(),
//     'joining_date': joiningDate,
//     if (password != null && password!.isNotEmpty) 'password': password,
//   };
// }
//
// /// POST /salesmen/update — id is sent as a String, matching the real API.
// class SalesmanUpdateRequestModel {
//   const SalesmanUpdateRequestModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.designationId,
//     required this.mobile,
//     required this.salary,
//     required this.joiningDate,
//     this.password,
//     this.isActive,
//   });
//
//   final String id;
//   final String name;
//   final String email;
//   final String designationId;
//   final String mobile;
//   final num salary;
//   final String joiningDate;
//   final String? password;
//   final bool? isActive;
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'email': email,
//     'designation_id': designationId,
//     'mobile': mobile,
//     'salary': salary.toString(),
//     'joining_date': joiningDate,
//     if (password != null && password!.isNotEmpty) 'password': password,
//     if (isActive != null) 'is_active': isActive! ? 1 : 0,
//   };
// }
//
// /// POST /salesmen/delete — id is sent as a String, matching the real API.
// class SalesmanDeleteRequestModel {
//   const SalesmanDeleteRequestModel(this.id);
//
//   final String id;
//
//   Map<String, dynamic> toJson() => {'id': id};
// }
//
// models/owner_models/salesmanmodel.dart

// models/owner_models/salesmanmodel.dart

import 'package:intl/intl.dart';

class HSalesmanModel {
  final String id;
  final String name;
  final String mobile;
  final String designationName;
  final String email;
  final DateTime? joiningDate;
  final String employeeCode;
  final double salary;
  final bool isActive;

  HSalesmanModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.designationName,
    required this.email,
    this.joiningDate,
    this.employeeCode = '',
    required this.salary,
    required this.isActive,
  });

  factory HSalesmanModel.fromJson(Map<String, dynamic> json) {
    // Fix: Properly parse isActive
    bool isActive = false;
    final isActiveValue = json['is_active'];
    if (isActiveValue != null) {
      if (isActiveValue is String) {
        isActive = isActiveValue == '1';
      } else if (isActiveValue is int) {
        isActive = isActiveValue == 1;
      } else if (isActiveValue is bool) {
        isActive = isActiveValue;
      }
    }

    // Parse salary
    double salary = 0.0;
    final salaryValue = json['salary'];
    if (salaryValue != null) {
      if (salaryValue is String) {
        salary = double.tryParse(salaryValue) ?? 0.0;
      } else if (salaryValue is num) {
        salary = salaryValue.toDouble();
      }
    }

    return HSalesmanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      designationName: json['designation_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      joiningDate: json['joining_date'] != null && json['joining_date'].toString().isNotEmpty
          ? DateTime.tryParse(json['joining_date'].toString())
          : null,
      employeeCode: json['employee_code']?.toString() ?? '',
      salary: salary,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'designation_name': designationName,
      'email': email,
      'joining_date': joiningDate != null
          ? DateFormat('yyyy-MM-dd').format(joiningDate!)
          : null,
      'employee_code': employeeCode,
      'salary': salary.toString(),
      'is_active': isActive ? '1' : '0',
    };
  }
}

// Response model for GET /salesmen
class SalesmanGetResponseModel {
  final String status;
  final String statusCode;
  final List<HSalesmanModel> data;
  final String message;

  SalesmanGetResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory SalesmanGetResponseModel.fromJson(Map<String, dynamic> json) {
    List<HSalesmanModel> salesmen = [];

    // Handle the nested data.list structure
    if (json['data'] != null) {
      final dataMap = json['data'];

      if (dataMap is Map<String, dynamic> && dataMap.containsKey('list')) {
        final list = dataMap['list'];
        if (list is List) {
          salesmen = list
              .map((item) => HSalesmanModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else if (dataMap is List) {
        salesmen = dataMap
            .map((item) => HSalesmanModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return SalesmanGetResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: salesmen,
      message: json['message']?.toString() ?? '',
    );
  }
}

// Request models
class SalesmanAddRequestModel {
  final String name;
  final String email;
  final String designationId;
  final String mobile;
  final num salary;
  final String joiningDate;
  final String? password;
  final bool isActive;

  SalesmanAddRequestModel({
    required this.name,
    required this.email,
    required this.designationId,
    required this.mobile,
    required this.salary,
    required this.joiningDate,
    this.password,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'designation_id': designationId,
      'mobile': mobile,
      'salary': salary.toString(),
      'joining_date': joiningDate,
      if (password != null && password!.isNotEmpty) 'password': password,
      'is_active': isActive ? '1' : '0',
    };
  }
}

class SalesmanUpdateRequestModel {
  final String id;
  final String name;
  final String email;
  final String designationId;
  final String mobile;
  final num salary;
  final String joiningDate;
  final String? password;
  final bool? isActive;

  SalesmanUpdateRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.designationId,
    required this.mobile,
    required this.salary,
    required this.joiningDate,
    this.password,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'designation_id': designationId,
      'mobile': mobile,
      'salary': salary.toString(),
      'joining_date': joiningDate,
      if (password != null && password!.isNotEmpty) 'password': password,
      if (isActive != null) 'is_active': isActive! ? '1' : '0',
    };
  }
}

class SalesmanDeleteRequestModel {
  final String id;

  SalesmanDeleteRequestModel(this.id);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}