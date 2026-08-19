import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/salesmanownerestimatemodel.dart';

enum OwnerEstimatesStatus { initial, loading, success, failure }

class OwnerStatusFilterOption extends Equatable {
  final String key; // 'all' or a statusKey (e.g. 'approved','pending_approval')
  final String label;
  final int count;

  const OwnerStatusFilterOption({
    required this.key,
    required this.label,
    required this.count,
  });

  @override
  List<Object?> get props => [key, label, count];
}

class OwnerEstimatesState extends Equatable {
  final OwnerEstimatesStatus status;
  final List<SalesmanowrEstimateModel> allEstimates;
  final List<SalesmanowrEstimateModel> filteredEstimates;
  final List<OwnerStatusFilterOption> filters;
  final String activeFilter;
  final String query;
  final String? errorMessage;

  const OwnerEstimatesState({
    this.status = OwnerEstimatesStatus.initial,
    this.allEstimates = const [],
    this.filteredEstimates = const [],
    this.filters = const [],
    this.activeFilter = 'all',
    this.query = '',
    this.errorMessage,
  });

  OwnerEstimatesState copyWith({
    OwnerEstimatesStatus? status,
    List<SalesmanowrEstimateModel>? allEstimates,
    List<SalesmanowrEstimateModel>? filteredEstimates,
    List<OwnerStatusFilterOption>? filters,
    String? activeFilter,
    String? query,
    String? errorMessage,
  }) {
    return OwnerEstimatesState(
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
  List<Object?> get props => [
    status,
    allEstimates,
    filteredEstimates,
    filters,
    activeFilter,
    query,
    errorMessage,
  ];
}