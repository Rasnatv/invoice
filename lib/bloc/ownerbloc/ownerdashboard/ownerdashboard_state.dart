import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/salesman_dashboardmodel.dart';

enum OwnerDashboardStatus { initial, loading, refreshing, success, failure }

class OwnerDashboardState extends Equatable {
  final OwnerDashboardStatus status;
  final DashboardHomeData data;
  final String? errorMessage;
  final bool isUnauthorized;

  const OwnerDashboardState({
    required this.status,
    required this.data,
    this.errorMessage,
    this.isUnauthorized = false,
  });

  factory OwnerDashboardState.initial() => OwnerDashboardState(
    status: OwnerDashboardStatus.initial,
    data: DashboardHomeData.empty(),
  );

  // ---- convenience getters, mirrors the salesman DashboardHomeState surface ----
  String get userName => data.user.name;
  int get totalEstimates => data.totals.totalEstimates;
  int get pending => data.totals.pendingApprovals;
  int get quotations => data.totals.quotations;
  int get dispatchBills => data.totals.dispatched;
  List<DashboardHomeMonthlySales> get monthlySales => data.salesOverview.monthlySales;
  List<DashboardHomeRecentEstimate> get recentEstimates => data.recentEstimates;

  bool get isLoading =>
      status == OwnerDashboardStatus.loading || status == OwnerDashboardStatus.initial;

  OwnerDashboardState copyWith({
    OwnerDashboardStatus? status,
    DashboardHomeData? data,
    String? errorMessage,
    bool? isUnauthorized,
  }) {
    return OwnerDashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage, isUnauthorized];
}