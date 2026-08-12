import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/salesmanapprovedbillsmodel.dart';

enum ApprovedEstimatesStatus { initial, loading, refreshing, success, failure }

class ApprovedEstimatesState extends Equatable {
  final ApprovedEstimatesStatus status;
  final List<ApprovedEstimateListItem> list;
  final String query;
  final String? errorMessage;

  const ApprovedEstimatesState({
    this.status = ApprovedEstimatesStatus.initial,
    this.list = const [],
    this.query = '',
    this.errorMessage,
  });

  /// List filtered by the current search query — matches estimate
  /// number or customer name, case-insensitive.
  List<ApprovedEstimateListItem> get filtered {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((e) {
      return e.estimateNumber.toLowerCase().contains(q) ||
          e.customerName.toLowerCase().contains(q);
    }).toList();
  }

  bool get isLoading =>
      status == ApprovedEstimatesStatus.loading || status == ApprovedEstimatesStatus.initial;

  ApprovedEstimatesState copyWith({
    ApprovedEstimatesStatus? status,
    List<ApprovedEstimateListItem>? list,
    String? query,
    String? errorMessage,
  }) {
    return ApprovedEstimatesState(
      status: status ?? this.status,
      list: list ?? this.list,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, list, query, errorMessage];
}