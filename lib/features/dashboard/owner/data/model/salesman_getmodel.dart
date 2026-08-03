/// Maps a single item from: GET /salesmen
class HSalesmanModel {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final double salary;
  final DateTime? joiningDate;

  HSalesmanModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.salary,
    this.joiningDate,
  });

  factory HSalesmanModel.fromJson(Map<String, dynamic> json) {
    return HSalesmanModel(
      id: parseId(json['id']),
      name: (json['name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      salary: parseDouble(json['salary']),
      joiningDate: parseDate(json['joining_date']),
    );
  }

  static int parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString().trim()) ?? 0;
  }

  static double parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0;
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString().trim());
  }
}