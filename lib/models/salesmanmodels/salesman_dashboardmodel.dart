class DashboardHomeApiResponse {
  final String status;
  final String statusCode;
  final DashboardHomeData data;
  final String message;

  const DashboardHomeApiResponse({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory DashboardHomeApiResponse.fromJson(Map<String, dynamic> json) {
    return DashboardHomeApiResponse(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: DashboardHomeData.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? const {},
      ),
      message: json['message']?.toString() ?? '',
    );
  }
}

class DashboardHomeData {
  final DashboardHomeUser user;
  final DashboardHomeTotals totals;
  final DashboardHomeSalesOverview salesOverview;
  final List<DashboardHomeRecentEstimate> recentEstimates;

  const DashboardHomeData({
    required this.user,
    required this.totals,
    required this.salesOverview,
    required this.recentEstimates,
  });

  factory DashboardHomeData.fromJson(Map<String, dynamic> json) {
    return DashboardHomeData(
      user: DashboardHomeUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
      totals: DashboardHomeTotals.fromJson(
        (json['totals'] as Map<String, dynamic>?) ?? const {},
      ),
      salesOverview: DashboardHomeSalesOverview.fromJson(
        (json['sales_overview'] as Map<String, dynamic>?) ?? const {},
      ),
      recentEstimates: ((json['recent_estimates'] as List?) ?? const [])
          .map((e) => DashboardHomeRecentEstimate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static DashboardHomeData empty() => DashboardHomeData(
    user: const DashboardHomeUser(id: '', name: '', role: '', roleLabel: ''),
    totals: const DashboardHomeTotals(
      totalEstimates: 0,
      dispatched: 0,
      quotations: 0,
      pendingApprovals: 0,
    ),
    salesOverview: const DashboardHomeSalesOverview(
      currentMonthTotal: 0,
      currentMonthTotalFormatted: '₹0.00',
      monthlySales: [],
    ),
    recentEstimates: const [],
  );
}

class DashboardHomeUser {
  final String id;
  final String name;
  final String role;
  final String roleLabel;

  const DashboardHomeUser({
    required this.id,
    required this.name,
    required this.role,
    required this.roleLabel,
  });

  factory DashboardHomeUser.fromJson(Map<String, dynamic> json) {
    return DashboardHomeUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      roleLabel: json['role_label']?.toString() ?? '',
    );
  }
}

class DashboardHomeTotals {
  final int totalEstimates;
  final int dispatched;
  final int quotations;
  final int pendingApprovals;

  const DashboardHomeTotals({
    required this.totalEstimates,
    required this.dispatched,
    required this.quotations,
    required this.pendingApprovals,
  });

  factory DashboardHomeTotals.fromJson(Map<String, dynamic> json) {
    return DashboardHomeTotals(
      totalEstimates: int.tryParse(json['total_estimates']?.toString() ?? '') ?? 0,
      dispatched: int.tryParse(json['dispatched']?.toString() ?? '') ?? 0,
      quotations: int.tryParse(json['quotations']?.toString() ?? '') ?? 0,
      pendingApprovals: int.tryParse(json['pending_approvals']?.toString() ?? '') ?? 0,
    );
  }
}

class DashboardHomeSalesOverview {
  final num currentMonthTotal;
  final String currentMonthTotalFormatted;
  final List<DashboardHomeMonthlySales> monthlySales;

  const DashboardHomeSalesOverview({
    required this.currentMonthTotal,
    required this.currentMonthTotalFormatted,
    required this.monthlySales,
  });

  factory DashboardHomeSalesOverview.fromJson(Map<String, dynamic> json) {
    return DashboardHomeSalesOverview(
      currentMonthTotal: num.tryParse(json['current_month_total']?.toString() ?? '') ?? 0,
      currentMonthTotalFormatted: json['current_month_total_formatted']?.toString() ?? '₹0.00',
      monthlySales: ((json['monthly_sales'] as List?) ?? const [])
          .map((e) => DashboardHomeMonthlySales.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardHomeMonthlySales {
  final String month;
  final String year;
  final num total;
  final String totalFormatted;

  const DashboardHomeMonthlySales({
    required this.month,
    required this.year,
    required this.total,
    required this.totalFormatted,
  });

  factory DashboardHomeMonthlySales.fromJson(Map<String, dynamic> json) {
    return DashboardHomeMonthlySales(
      month: json['month']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
      totalFormatted: json['total_formatted']?.toString() ?? '₹0.00',
    );
  }
}

class DashboardHomeRecentEstimate {
  final String id;
  final String estimateNumber;
  final String customerName;
  final String dateFormatted;
  final String statusLabel;
  final num grandTotal;
  final String grandTotalFormatted;

  const DashboardHomeRecentEstimate({
    required this.id,
    required this.estimateNumber,
    required this.customerName,
    required this.dateFormatted,
    required this.statusLabel,
    required this.grandTotal,
    required this.grandTotalFormatted,
  });

  factory DashboardHomeRecentEstimate.fromJson(Map<String, dynamic> json) {
    return DashboardHomeRecentEstimate(
      id: json['id']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      dateFormatted: json['date_formatted']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      grandTotal: num.tryParse(json['grand_total']?.toString() ?? '') ?? 0,
      grandTotalFormatted: json['grand_total_formatted']?.toString() ?? '₹0.00',
    );
  }
}