

import 'package:tileshop/models/owner_reportmodel/reportentrymodel.dart';

class SalesmanPerformanceSummary {
  final int quotationsMade;
  final int estimatesMade;
  final double totalSales;
  final double conversionRate; // percent, e.g. 121.43
  final double incentiveEarned;
  final double targetAchieved; // percent, e.g. 37.18

  const SalesmanPerformanceSummary({
    required this.quotationsMade,
    required this.estimatesMade,
    required this.totalSales,
    required this.conversionRate,
    required this.incentiveEarned,
    required this.targetAchieved,
  });

  factory SalesmanPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return SalesmanPerformanceSummary(
      quotationsMade: _int(json['quotations_made']),
      estimatesMade: _int(json['estimates_made']),
      totalSales: _dbl(json['total_sales']),
      conversionRate: _dbl(json['conversion_rate']),
      incentiveEarned: _dbl(json['incentive_earned']),
      targetAchieved: _dbl(json['target_achieved']),
    );
  }

  static int _int(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
  static double _dbl(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
}

class SalesmanPerformanceReportModel {
  final String salesmanName;
  final SalesmanPerformanceSummary summary;
  final List<ReportEntryModel> quotations;
  final List<ReportEntryModel> estimates;

  const SalesmanPerformanceReportModel({
    required this.salesmanName,
    required this.summary,
    required this.quotations,
    required this.estimates,
  });

  factory SalesmanPerformanceReportModel.fromJson(Map<String, dynamic> json) {
    final quotationsJson = json['quotations'] as List<dynamic>? ?? const [];
    final estimatesJson = json['estimates'] as List<dynamic>? ?? const [];
    return SalesmanPerformanceReportModel(
      salesmanName: json['salesman_name']?.toString() ?? '',
      summary: SalesmanPerformanceSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      quotations: quotationsJson
          .map((e) => ReportEntryModel.fromQuotationJson(e as Map<String, dynamic>))
          .toList(),
      estimates: estimatesJson
          .map((e) => ReportEntryModel.fromEstimateJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SalesmanPerformanceResponseModel {
  final String status;
  final String statusCode;
  final SalesmanPerformanceReportModel? data;
  final String message;

  const SalesmanPerformanceResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory SalesmanPerformanceResponseModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    return SalesmanPerformanceResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: dataJson != null ? SalesmanPerformanceReportModel.fromJson(dataJson) : null,
      message: json['message']?.toString() ?? '',
    );
  }
}