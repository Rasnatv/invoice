abstract class SalesmanEvent {}

class FetchSalesmen extends SalesmanEvent {}

class AddSalesman extends SalesmanEvent {
  final String name;
  final String email;
  final String designationId;
  final String mobile;
  final num salary;
  final String joiningDate; // yyyy-MM-dd
  final String? password;

  AddSalesman({
    required this.name,
    required this.email,
    required this.designationId,
    required this.mobile,
    required this.salary,
    required this.joiningDate,
    this.password,
  });
}

class UpdateSalesman extends SalesmanEvent {
  final int id;
  final String name;
  final String email;
  final String designationId;
  final String mobile;
  final num salary;
  final String joiningDate;
  final String? password;
  final bool? isActive;

  UpdateSalesman({
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
}

class DeleteSalesman extends SalesmanEvent {
  final int id;

  DeleteSalesman(this.id);
}