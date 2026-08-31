
class IncentiveReportResponseModel {
  final String status;
  final String statusCode;
  final IncentiveReportDataModel? data;
  final String message;

  IncentiveReportResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory IncentiveReportResponseModel.fromJson(Map<String, dynamic> json) {
    return IncentiveReportResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: json['data'] != null
          ? IncentiveReportDataModel.fromJson(
          json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString() ?? '',
    );
  }
}

/// Carries both the summary stats and the row list straight from the
/// server — nothing here is computed or filtered on the client.
class IncentiveReportDataModel {
  final IncentiveSummaryModel summary;
  final List<IncentiveListItemModel> list;

  IncentiveReportDataModel({required this.summary, required this.list});

  factory IncentiveReportDataModel.fromJson(Map<String, dynamic> json) {
    return IncentiveReportDataModel(
      summary: IncentiveSummaryModel.fromJson(
          (json['summary'] as Map<String, dynamic>?) ?? const {}),
      list: (json['list'] as List<dynamic>? ?? const [])
          .map((e) =>
          IncentiveListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class IncentiveSummaryModel {
  final String totalIncentive;
  final String paidCount;
  final String pendingCount;

  IncentiveSummaryModel({
    required this.totalIncentive,
    required this.paidCount,
    required this.pendingCount,
  });

  factory IncentiveSummaryModel.fromJson(Map<String, dynamic> json) {
    return IncentiveSummaryModel(
      totalIncentive: json['total_incentive']?.toString() ?? '0',
      paidCount: json['paid_count']?.toString() ?? '0',
      pendingCount: json['pending_count']?.toString() ?? '0',
    );
  }
}

class IncentiveListItemModel {
  final String id;
  final String personName;
  final String incentiveAmount;
  final String status;
  final String statusLabel;
  final String createdAt;
  final String paidAt;
  final String paymentReference;
  final String notes;

  IncentiveListItemModel({
    required this.id,
    required this.personName,
    required this.incentiveAmount,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.paidAt,
    required this.paymentReference,
    required this.notes,
  });

  factory IncentiveListItemModel.fromJson(Map<String, dynamic> json) {
    return IncentiveListItemModel(
      id: json['id']?.toString() ?? '',
      personName: json['person_name']?.toString() ?? '',
      incentiveAmount: json['incentive_amount']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      paidAt: json['paid_at']?.toString() ?? '',
      paymentReference: json['payment_reference']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }
}