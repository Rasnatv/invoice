import 'package:tileshop/models/salesmanmodels/salesmanownerestimatemodel.dart';


class SalesmanownrEstimateListResponseModel {
  final String status;
  final String statusCode;
  final List<SalesmanowrEstimateModel> list;
  final String message;

  const SalesmanownrEstimateListResponseModel({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  factory SalesmanownrEstimateListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawList = data['list'] as List<dynamic>? ?? [];
    return SalesmanownrEstimateListResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      list: rawList
          .whereType<Map<String, dynamic>>()
          .map(SalesmanowrEstimateModel.fromJson)
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}
