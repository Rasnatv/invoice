
import '../../../models/owner_models/owner_despatchmodellist.dart';

enum DispatchListStatus { initial, loading, refreshing, success, failure }

class DispatchListState {
  final DispatchListStatus status;
  final List<DispatchListItem> allDispatches;
  final List<DispatchListItem> filteredDispatches;
  final String searchQuery;
  final String? errorMessage;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const DispatchListState({
    this.status = DispatchListStatus.initial,
    this.allDispatches = const [],
    this.filteredDispatches = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  DispatchListState copyWith({
    DispatchListStatus? status,
    List<DispatchListItem>? allDispatches,
    List<DispatchListItem>? filteredDispatches,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DispatchListState(
      status: status ?? this.status,
      allDispatches: allDispatches ?? this.allDispatches,
      filteredDispatches: filteredDispatches ?? this.filteredDispatches,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}