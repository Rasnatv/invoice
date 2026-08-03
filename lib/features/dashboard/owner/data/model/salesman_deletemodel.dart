/// Maps the response of: POST /salesmen/delete
class SalesmanDeleteModel {
  final bool success;
  final String message;

  SalesmanDeleteModel({
    required this.success,
    required this.message,
  });

  factory SalesmanDeleteModel.fromJson(Map<String, dynamic> json) {
    return SalesmanDeleteModel(
      success: json['status']?.toString() == '1',
      message: (json['message'] ?? '').toString(),
    );
  }
}