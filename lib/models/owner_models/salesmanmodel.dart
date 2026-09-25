

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