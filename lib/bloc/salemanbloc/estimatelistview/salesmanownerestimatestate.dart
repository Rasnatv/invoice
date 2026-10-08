
import 'package:equatable/equatable.dart';
import 'package:tileshop/models/salesmanmodels/salesmanownerestimatemodel.dart';

enum EstimatesStatus { initial, loading, success, failure }

/// One chip in the status filter bar. Built dynamically from the statuses
/// present in the loaded data (plus "All").
class StatusFilterOption extends Equatable {
  final String key; // 'all' or a statusKey
  final String label; // 'All', 'Draft', 'Sent', 'New' ...
  final int count;

  const StatusFilterOption({
    required this.key,
    required this.label,
    required this.count,
  });

  @override
  List<Object?> get props => [key, label, count];
}

class SalesmanownerEstimatesState extends Equatable {
  final EstimatesStatus status;
  final List<SalesmanowrEstimateModel> allEstimates;
  final List<SalesmanowrEstimateModel> filteredEstimates;
  final List<StatusFilterOption> filters;
  final String activeFilter;
  final String query;
  final String? errorMessage;

  // Pagination
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  const SalesmanownerEstimatesState({
    this.status = EstimatesStatus.initial,
    this.allEstimates = const [],
    this.filteredEstimates = const [],
    this.filters = const [],
    this.activeFilter = 'all',
    this.query = '',
    this.errorMessage,
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  SalesmanownerEstimatesState copyWith({
    EstimatesStatus? status,
    List<SalesmanowrEstimateModel>? allEstimates,
    List<SalesmanowrEstimateModel>? filteredEstimates,
    List<StatusFilterOption>? filters,
    String? activeFilter,
    String? query,
    String? errorMessage,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return SalesmanownerEstimatesState(
      status: status ?? this.status,
      allEstimates: allEstimates ?? this.allEstimates,
      filteredEstimates: filteredEstimates ?? this.filteredEstimates,
      filters: filters ?? this.filters,
      activeFilter: activeFilter ?? this.activeFilter,
      query: query ?? this.query,
      errorMessage: errorMessage, // intentionally not carried over
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allEstimates,
    filteredEstimates,
    filters,
    activeFilter,
    query,
    errorMessage,
    page,
    hasMore,
    isLoadingMore,
    loadMoreFailed,
  ];
}