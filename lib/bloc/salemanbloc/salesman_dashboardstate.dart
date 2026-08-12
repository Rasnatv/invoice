import 'package:equatable/equatable.dart';
import '../../models/salesmanmodels/salesman_dashboardmodel.dart';

enum DashboardHomeStatus { initial, loading, refreshing, success, failure }

class DashboardHomeState extends Equatable {
  final DashboardHomeStatus status;
  final DashboardHomeData data;
  final String? errorMessage;
  final bool isUnauthorized;

  const DashboardHomeState({
    required this.status,
    required this.data,
    this.errorMessage,
    this.isUnauthorized = false,
  });

  factory DashboardHomeState.initial() => DashboardHomeState(
    status: DashboardHomeStatus.initial,
    data: DashboardHomeData.empty(),
  );

  // ---- convenience getters, mirrors the old DashboardCubit surface ----
  String get salesmanName => data.user.name;
  int get totalEstimates => data.totals.totalEstimates;
  int get pending => data.totals.pendingApprovals;
  int get quotations => data.totals.quotations;
  int get dispatchBills => data.totals.dispatched;
  List<DashboardHomeMonthlySales> get monthlySales => data.salesOverview.monthlySales;
  List<DashboardHomeRecentEstimate> get recentEstimates => data.recentEstimates;

  bool get isLoading =>
      status == DashboardHomeStatus.loading || status == DashboardHomeStatus.initial;

  DashboardHomeState copyWith({
    DashboardHomeStatus? status,
    DashboardHomeData? data,
    String? errorMessage,
    bool? isUnauthorized,
  }) {
    return DashboardHomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage, isUnauthorized];
}