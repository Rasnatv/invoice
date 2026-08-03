import 'package:tileshop/features/dashboard/owner/data/model/salesman_getmodel.dart';


/// Maps the response of: POST /salesmen/update
class SalesmanUpdateModel {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final double salary;
  final DateTime? joiningDate;

  SalesmanUpdateModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.salary,
    this.joiningDate,
  });

  factory SalesmanUpdateModel.fromJson(Map<String, dynamic> json) {
    return SalesmanUpdateModel(
      id: HSalesmanModel.parseId(json['id']),
      name: (json['name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      salary: HSalesmanModel.parseDouble(json['salary']),
      joiningDate: HSalesmanModel.parseDate(json['joining_date']),
    );
  }

  HSalesmanModel toSalesmanModel() => HSalesmanModel(
    id: id,
    name: name,
    mobile: mobile,
    email: email,
    salary: salary,
    joiningDate: joiningDate,
  );
}