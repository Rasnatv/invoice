

import 'package:tileshop/features/dashboard/owner/data/model/salesman_getmodel.dart';

/// Maps the response of: POST /salesmen
class SalesmanCreateModel {
  final int id;
  final String name;
  final String email;
  final double salary;
  final String? designation;
  final String? emailStatus;
  final String? emailMessage;

  SalesmanCreateModel({
    required this.id,
    required this.name,
    required this.email,
    required this.salary,
    this.designation,
    this.emailStatus,
    this.emailMessage,
  });

  factory SalesmanCreateModel.fromJson(Map<String, dynamic> json) {
    return SalesmanCreateModel(
      id: HSalesmanModel.parseId(json['id']),
      name: (json['name'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      salary: HSalesmanModel.parseDouble(json['salary']),
      designation: json['designation']?.toString(),
      emailStatus: json['email_status']?.toString(),
      emailMessage: json['email_message']?.toString(),
    );
  }

  bool get emailSent => emailStatus == null || emailStatus == 'sent' || emailStatus == 'success';
}