/// Request body for POST /products/delete.
class ProductDeleteRequestModel {
  const ProductDeleteRequestModel({required this.id});

  final String id;

  Map<String, dynamic> toJson() => {'id': id};
}

class ProductDeleteResponseModel {
  const ProductDeleteResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  final String status;
  final String statusCode;
  final String message;

  factory ProductDeleteResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductDeleteResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}
