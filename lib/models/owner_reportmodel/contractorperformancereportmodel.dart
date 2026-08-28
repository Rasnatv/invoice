import 'package:tileshop/models/owner_reportmodel/reportentrymodel.dart';

class ContractorPerformanceSummary {
  final int quotationsMade;
  final double quotationsValue;
  final int estimatesMade;
  final double estimatesValue;
  final double outstanding;
  // Sample payload sends "last_order": "0" when there is none, otherwise
  // presumably a date string — kept as raw String and parsed on demand.
  final String lastOrderRaw;

  const ContractorPerformanceSummary({
    required this.quotationsMade,
    required this.quotationsValue,
    required this.estimatesMade,
    required this.estimatesValue,
    required this.outstanding,
    required this.lastOrderRaw,
  });

  DateTime? get lastOrderDate => DateTime.tryParse(lastOrderRaw);

  factory ContractorPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return ContractorPerformanceSummary(
      quotationsMade: _int(json['quotations_made']),
      quotationsValue: _dbl(json['quotations_value']),
      estimatesMade: _int(json['estimates_made']),
      estimatesValue: _dbl(json['estimates_value']),
      outstanding: _dbl(json['outstanding']),
      lastOrderRaw: json['last_order']?.toString() ?? '',
    );
  }

  static int _int(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
  static double _dbl(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
}

class ContractorPerformanceReportModel {
  final String contractorName;
  final ContractorPerformanceSummary summary;
  final List<ReportEntryModel> quotations;
  final List<ReportEntryModel> estimates;

  const ContractorPerformanceReportModel({
    required this.contractorName,
    required this.summary,
    required this.quotations,
    required this.estimates,
  });

  factory ContractorPerformanceReportModel.fromJson(Map<String, dynamic> json) {
    final quotationsJson = json['quotations'] as List<dynamic>? ?? const [];
    final estimatesJson = json['estimates'] as List<dynamic>? ?? const [];
    return ContractorPerformanceReportModel(
      contractorName: json['contractor_name']?.toString() ?? '',
      summary: ContractorPerformanceSummary.fromJson(
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

class ContractorPerformanceResponseModel {
  final String status;
  final String statusCode;
  final ContractorPerformanceReportModel? data;
  final String message;

  const ContractorPerformanceResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory ContractorPerformanceResponseModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    return ContractorPerformanceResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: dataJson != null ? ContractorPerformanceReportModel.fromJson(dataJson) : null,
      message: json['message']?.toString() ?? '',
    );
  }
}