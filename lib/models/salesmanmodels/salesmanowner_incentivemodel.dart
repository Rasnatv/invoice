// Models for GET/POST /salesman-incentives/* endpoints.
// Mirrors the response-model pattern already used by DriverGetResponseModel etc.
// All numeric fields from the API arrive as strings, so they are kept as
// String on the model (matches server contract) with `...Value` getters
// that parse to double where you need to do math / formatting.

class IncentiveTarget {
  final String targetAmount;
  final String achieved;
  final String progress;
  final String bonusType;
  final String bonusValue;
  final String bonusDisplay;

  const IncentiveTarget({
    required this.targetAmount,
    required this.achieved,
    required this.progress,
    required this.bonusType,
    required this.bonusValue,
    required this.bonusDisplay,
  });

  factory IncentiveTarget.fromJson(Map<String, dynamic> json) => IncentiveTarget(
    targetAmount: json['target_amount']?.toString() ?? '0',
    achieved: json['achieved']?.toString() ?? '',
    progress: json['progress']?.toString() ?? '0',
    bonusType: json['bonus_type']?.toString() ?? '',
    bonusValue: json['bonus_value']?.toString() ?? '0',
    bonusDisplay: json['bonus_display']?.toString() ?? '',
  );

  double get targetAmountValue => double.tryParse(targetAmount) ?? 0;

  /// e.g. "5.05" meaning 5.05%
  double get progressValue => double.tryParse(progress) ?? 0;

  /// Fraction between 0 and 1, safe to feed into LinearProgressIndicator.
  double get progressFraction => (progressValue / 100).clamp(0.0, 1.0);

  bool get isAchieved => achieved.toLowerCase() == 'achieved';
}

class IncentivePeriod {
  final String year;
  final String month;
  final String monthName;

  const IncentivePeriod({
    required this.year,
    required this.month,
    required this.monthName,
  });

  factory IncentivePeriod.fromJson(Map<String, dynamic> json) => IncentivePeriod(
    year: json['year']?.toString() ?? '',
    month: json['month']?.toString() ?? '',
    monthName: json['month_name']?.toString() ?? '',
  );
}

class IncentiveProductModel {
  final String productId;
  final String productName;
  final String totalSales;
  final String totalUnits;
  final String incentiveRate;
  final String incentiveEarned;
  final String unitPrice;

  const IncentiveProductModel({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.totalUnits,
    required this.incentiveRate,
    required this.incentiveEarned,
    required this.unitPrice,
  });

  factory IncentiveProductModel.fromJson(Map<String, dynamic> json) => IncentiveProductModel(
    productId: json['product_id']?.toString() ?? '',
    productName: json['product_name']?.toString() ?? '',
    totalSales: json['total_sales']?.toString() ?? '0',
    totalUnits: json['total_units']?.toString() ?? '0',
    incentiveRate: json['incentive_rate']?.toString() ?? '0',
    incentiveEarned: json['incentive_earned']?.toString() ?? '0',
    unitPrice: json['unit_price']?.toString() ?? '0',
  );

  double get totalSalesValue => double.tryParse(totalSales) ?? 0;
  double get totalUnitsValue => double.tryParse(totalUnits) ?? 0;
  double get incentiveRateValue => double.tryParse(incentiveRate) ?? 0;
  double get incentiveEarnedValue => double.tryParse(incentiveEarned) ?? 0;
  double get unitPriceValue => double.tryParse(unitPrice) ?? 0;
  int get totalUnitsInt => totalUnitsValue.round();
}

class SalesmanIncentiveSummaryModel {
  final String salesmanId;
  final String salesmanName;
  final String totalSales;
  final String totalIncentive;
  final IncentiveTarget target;
  final IncentivePeriod period;

  const SalesmanIncentiveSummaryModel({
    required this.salesmanId,
    required this.salesmanName,
    required this.totalSales,
    required this.totalIncentive,
    required this.target,
    required this.period,
  });

  factory SalesmanIncentiveSummaryModel.fromJson(Map<String, dynamic> json) => SalesmanIncentiveSummaryModel(
    salesmanId: json['salesman_id']?.toString() ?? '',
    salesmanName: json['salesman_name']?.toString() ?? '',
    totalSales: json['total_sales']?.toString() ?? '0',
    totalIncentive: json['total_incentive']?.toString() ?? '0',
    target: IncentiveTarget.fromJson(json['target'] as Map<String, dynamic>? ?? const {}),
    period: IncentivePeriod.fromJson(json['period'] as Map<String, dynamic>? ?? const {}),
  );

  double get totalSalesValue => double.tryParse(totalSales) ?? 0;
  double get totalIncentiveValue => double.tryParse(totalIncentive) ?? 0;
}

class SalesmanIncentiveSummaryData {
  final SalesmanIncentiveSummaryModel summary;
  final List<IncentiveProductModel> productList;
  final String totalProducts;

  const SalesmanIncentiveSummaryData({
    required this.summary,
    required this.productList,
    required this.totalProducts,
  });

  factory SalesmanIncentiveSummaryData.fromJson(Map<String, dynamic> json) => SalesmanIncentiveSummaryData(
    summary: SalesmanIncentiveSummaryModel.fromJson(json['summary'] as Map<String, dynamic>? ?? const {}),
    productList: (json['product_list'] as List<dynamic>? ?? const [])
        .map((e) => IncentiveProductModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalProducts: json['total_products']?.toString() ?? '0',
  );
}

class SalesmanIncentiveSummaryResponseModel {
  final String status;
  final String statusCode;
  final SalesmanIncentiveSummaryData? data;
  final String message;

  const SalesmanIncentiveSummaryResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory SalesmanIncentiveSummaryResponseModel.fromJson(Map<String, dynamic> json) =>
      SalesmanIncentiveSummaryResponseModel(
        status: json['status']?.toString() ?? '0',
        statusCode: json['status_code']?.toString() ?? '',
        data: json['data'] != null
            ? SalesmanIncentiveSummaryData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
        message: json['message']?.toString() ?? '',
      );
}

// ---------------------------------------------------------------------
// Products — paginated "View All" list (/salesman-incentives/products)
// ---------------------------------------------------------------------

class IncentiveProductListData {
  final List<IncentiveProductModel> list;
  final String total;

  const IncentiveProductListData({required this.list, required this.total});

  factory IncentiveProductListData.fromJson(Map<String, dynamic> json) => IncentiveProductListData(
    list: (json['list'] as List<dynamic>? ?? const [])
        .map((e) => IncentiveProductModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: json['total']?.toString() ?? '0',
  );
}

class IncentiveProductListResponseModel {
  final String status;
  final String statusCode;
  final IncentiveProductListData? data;
  final String message;

  const IncentiveProductListResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory IncentiveProductListResponseModel.fromJson(Map<String, dynamic> json) =>
      IncentiveProductListResponseModel(
        status: json['status']?.toString() ?? '0',
        statusCode: json['status_code']?.toString() ?? '',
        data: json['data'] != null
            ? IncentiveProductListData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
        message: json['message']?.toString() ?? '',
      );
}

// ---------------------------------------------------------------------
// Product bills (/salesman-incentives/product-bills)
// ---------------------------------------------------------------------

class ProductBillModel {
  final String estimateNumber;
  final String date;
  final String unitPrice;
  final String units;
  final String billTotal;
  final String incentiveEarned;

  const ProductBillModel({
    required this.estimateNumber,
    required this.date,
    required this.unitPrice,
    required this.units,
    required this.billTotal,
    required this.incentiveEarned,
  });

  factory ProductBillModel.fromJson(Map<String, dynamic> json) => ProductBillModel(
    estimateNumber: json['estimate_number']?.toString() ?? '',
    date: json['date']?.toString() ?? '',
    unitPrice: json['unit_price']?.toString() ?? '0',
    units: json['units']?.toString() ?? '0',
    billTotal: json['bill_total']?.toString() ?? '0',
    incentiveEarned: json['incentive_earned']?.toString() ?? '0',
  );

  double get unitPriceValue => double.tryParse(unitPrice) ?? 0;
  double get unitsValue => double.tryParse(units) ?? 0;
  double get billTotalValue => double.tryParse(billTotal) ?? 0;
  double get incentiveEarnedValue => double.tryParse(incentiveEarned) ?? 0;
  DateTime? get dateValue => DateTime.tryParse(date);
}

class ProductBillListData {
  final List<ProductBillModel> list;
  final String total;

  const ProductBillListData({required this.list, required this.total});

  factory ProductBillListData.fromJson(Map<String, dynamic> json) => ProductBillListData(
    list: (json['list'] as List<dynamic>? ?? const [])
        .map((e) => ProductBillModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: json['total']?.toString() ?? '0',
  );
}

class ProductBillListResponseModel {
  final String status;
  final String statusCode;
  final ProductBillListData? data;
  final String message;

  const ProductBillListResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory ProductBillListResponseModel.fromJson(Map<String, dynamic> json) => ProductBillListResponseModel(
    status: json['status']?.toString() ?? '0',
    statusCode: json['status_code']?.toString() ?? '',
    data: json['data'] != null ? ProductBillListData.fromJson(json['data'] as Map<String, dynamic>) : null,
    message: json['message']?.toString() ?? '',
  );
}

// ---------------------------------------------------------------------
// Mark as paid (/salesman-incentives/mark-paid)
// ---------------------------------------------------------------------

class MarkPaidModel {
  final String id;
  final String salesmanId;
  final String salesmanName;
  final String year;
  final String month;
  final String salary;
  final String monthBonusType;
  final String monthBonusValue;
  final String monthBonusAmount;
  final String productBonusAmount;
  final String totalIncentive;
  final String status;
  final String statusLabel;
  final String? paymentDate;
  final String? paymentReference;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const MarkPaidModel({
    required this.id,
    required this.salesmanId,
    required this.salesmanName,
    required this.year,
    required this.month,
    required this.salary,
    required this.monthBonusType,
    required this.monthBonusValue,
    required this.monthBonusAmount,
    required this.productBonusAmount,
    required this.totalIncentive,
    required this.status,
    required this.statusLabel,
    this.paymentDate,
    this.paymentReference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarkPaidModel.fromJson(Map<String, dynamic> json) => MarkPaidModel(
    id: json['id']?.toString() ?? '',
    salesmanId: json['salesman_id']?.toString() ?? '',
    salesmanName: json['salesman_name']?.toString() ?? '',
    year: json['year']?.toString() ?? '',
    month: json['month']?.toString() ?? '',
    salary: json['salary']?.toString() ?? '0',
    monthBonusType: json['month_bonus_type']?.toString() ?? '',
    monthBonusValue: json['month_bonus_value']?.toString() ?? '0',
    monthBonusAmount: json['month_bonus_amount']?.toString() ?? '0',
    productBonusAmount: json['product_bonus_amount']?.toString() ?? '0',
    totalIncentive: json['total_incentive']?.toString() ?? '0',
    status: json['status']?.toString() ?? '',
    statusLabel: json['status_label']?.toString() ?? '',
    paymentDate: json['payment_date']?.toString(),
    paymentReference: json['payment_reference']?.toString(),
    notes: json['notes']?.toString(),
    createdAt: json['created_at']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',
  );

  bool get isPaid => status.toLowerCase() == 'paid';
  double get totalIncentiveValue => double.tryParse(totalIncentive) ?? 0;
}

class MarkPaidResponseModel {
  final String status;
  final String statusCode;
  final MarkPaidModel? data;
  final String message;

  const MarkPaidResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory MarkPaidResponseModel.fromJson(Map<String, dynamic> json) => MarkPaidResponseModel(
    status: json['status']?.toString() ?? '0',
    statusCode: json['status_code']?.toString() ?? '',
    data: json['data'] != null ? MarkPaidModel.fromJson(json['data'] as Map<String, dynamic>) : null,
    message: json['message']?.toString() ?? '',
  );
}

// ---------------------------------------------------------------------
// Request DTOs
// ---------------------------------------------------------------------

class SalesmanIncentiveSummaryRequest {
  /// Owner-only. Leave null when a salesman is viewing their own incentives.
  final int? salesmanId;
  final int year;
  final int month;

  const SalesmanIncentiveSummaryRequest({
    this.salesmanId,
    required this.year,
    required this.month,
  });

  Map<String, dynamic> toJson() => {
    if (salesmanId != null) 'salesman_id': salesmanId,
    'year': year,
    'month': month,
  };
}

class IncentiveProductsRequest {
  final int? salesmanId;
  final int year;
  final int month;
  final int page;
  final int perPage;

  const IncentiveProductsRequest({
    this.salesmanId,
    required this.year,
    required this.month,
    this.page = 1,
    this.perPage = 10,
  });

  Map<String, dynamic> toJson() => {
    if (salesmanId != null) 'salesman_id': salesmanId,
    'year': year,
    'month': month,
    'page': page,
    'per_page': perPage,
  };
}

class ProductBillsRequest {
  final int? salesmanId;
  final int productId;
  final int year;
  final int month;
  final int page;
  final int perPage;

  const ProductBillsRequest({
    this.salesmanId,
    required this.productId,
    required this.year,
    required this.month,
    this.page = 1,
    this.perPage = 10,
  });

  Map<String, dynamic> toJson() => {
    if (salesmanId != null) 'salesman_id': salesmanId,
    'product_id': productId,
    'year': year,
    'month': month,
  };
}

class MarkIncentivePaidRequest {
  final int? salesmanId;
  final int year;
  final int month;
  final String paymentReference;
  final String paymentDate; // yyyy-MM-dd
  final String? notes;

  const MarkIncentivePaidRequest({
    this.salesmanId,
    required this.year,
    required this.month,
    required this.paymentReference,
    required this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    if (salesmanId != null) 'salesman_id': salesmanId,
    'year': year,
    'month': month,
    'payment_reference': paymentReference,
    'payment_date': paymentDate,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}