import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/salesmanapprovedbillsmodel.dart';

enum ApprovedEstimatesStatus {
  initial,
  loading,
  refreshing,
  loadingMore,
  success,
  failure,
}

class ApprovedEstimatesState extends Equatable {
  final ApprovedEstimatesStatus status;
  final List<ApprovedEstimateListItem> list;
  final String query;
  final String? errorMessage;

  /// Last page that was loaded successfully (1-based).
  final int page;

  /// False once the server returns fewer items than a full page.
  final bool hasMore;

  /// True when the last "load next page" request failed (shows Retry in footer).
  final bool loadMoreFailed;

  const ApprovedEstimatesState({
    this.status = ApprovedEstimatesStatus.initial,
    this.list = const [],
    this.query = '',
    this.errorMessage,
    this.page = 1,
    this.hasMore = true,
    this.loadMoreFailed = false,
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
      status == ApprovedEstimatesStatus.loading ||
          status == ApprovedEstimatesStatus.initial;

  bool get isLoadingMore => status == ApprovedEstimatesStatus.loadingMore;

  ApprovedEstimatesState copyWith({
    ApprovedEstimatesStatus? status,
    List<ApprovedEstimateListItem>? list,
    String? query,
    String? errorMessage,
    int? page,
    bool? hasMore,
    bool? loadMoreFailed,
  }) {
    return ApprovedEstimatesState(
      status: status ?? this.status,
      list: list ?? this.list,
      query: query ?? this.query,
      errorMessage: errorMessage,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props =>
      [status, list, query, errorMessage, page, hasMore, loadMoreFailed];
}