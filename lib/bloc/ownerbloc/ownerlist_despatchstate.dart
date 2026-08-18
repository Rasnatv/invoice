
import '../../models/owner_models/owner_despatchmodellist.dart';

enum DispatchListStatus { initial, loading, refreshing, success, failure }

class DispatchListState {
  final DispatchListStatus status;
  final List<DispatchListItem> allDispatches;
  final List<DispatchListItem> filteredDispatches;
  final String searchQuery;
  final String? errorMessage;

  const DispatchListState({
    this.status = DispatchListStatus.initial,
    this.allDispatches = const [],
    this.filteredDispatches = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  DispatchListState copyWith({
    DispatchListStatus? status,
    List<DispatchListItem>? allDispatches,
    List<DispatchListItem>? filteredDispatches,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DispatchListState(
      status: status ?? this.status,
      allDispatches: allDispatches ?? this.allDispatches,
      filteredDispatches: filteredDispatches ?? this.filteredDispatches,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
