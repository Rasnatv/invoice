/// Simple data model for a salesman managed by the owner.
///
/// `designation` represents the salesman's post/level — e.g. "Junior
/// Sales Executive", "Sales Executive", "Senior Sales Executive",
/// "Team Lead" — shown on the salesman list and set from the
/// Add/Edit Salesman form.
class SalesmanModel {
  const SalesmanModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.joinedDate,
    required this.status,
    this.designation = 'Sales Executive',
  });

  final String id;
  final String name;
  final String mobile;
  final String email;
  final DateTime joinedDate;
  final String status;
  final String designation;

  SalesmanModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    DateTime? joinedDate,
    String? status,
    String? designation,
  }) {
    return SalesmanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      joinedDate: joinedDate ?? this.joinedDate,
      status: status ?? this.status,
      designation: designation ?? this.designation,
    );
  }
}

/// Standard set of salesman posts/designations used across the app —
/// keep the Add/Edit screen's dropdown in sync with this list.
const List<String> kSalesmanDesignations = [
  'Junior Sales Executive',
  'Sales Executive',
  'Senior Sales Executive',
  'Team Lead',
];