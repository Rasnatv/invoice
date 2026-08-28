import 'package:equatable/equatable.dart';
import 'package:tileshop/models/salesmanmodels/salesmanownerestimatemodel.dart';

enum EstimatesStatus { initial, loading, success, failure }

/// One tab in the status tab bar. Built dynamically from whatever statuses
/// actually come back in the API response - however many distinct statuses
/// exist in the data, that many tabs show up (plus "All").
class StatusFilterOption extends Equatable {
  final String key; // 'all' or a statusKey
  final String label; // 'All', 'Draft', 'Sent', 'New' ...
  final int count;

  const StatusFilterOption({required this.key, required this.label, required this.count});

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

  const SalesmanownerEstimatesState({
    this.status = EstimatesStatus.initial,
    this.allEstimates = const [],
    this.filteredEstimates = const [],
    this.filters = const [],
    this.activeFilter = 'all',
    this.query = '',
    this.errorMessage,
  });

  SalesmanownerEstimatesState copyWith({
    EstimatesStatus? status,
    List<SalesmanowrEstimateModel>? allEstimates,
    List<SalesmanowrEstimateModel>? filteredEstimates,
    List<StatusFilterOption>? filters,
    String? activeFilter,
    String? query,
    String? errorMessage,
  }) {
    return SalesmanownerEstimatesState(
      status: status ?? this.status,
      allEstimates: allEstimates ?? this.allEstimates,
      filteredEstimates: filteredEstimates ?? this.filteredEstimates,
      filters: filters ?? this.filters,
      activeFilter: activeFilter ?? this.activeFilter,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, allEstimates, filteredEstimates, filters, activeFilter, query, errorMessage];
}
