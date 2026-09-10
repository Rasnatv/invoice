import 'package:equatable/equatable.dart';
import '../../../models/fieldstaffmodels/fieldstaffincentiveviewingmodel.dart';

enum FieldStaffIncentivesListStatus { initial, loading, loadingMore, loaded, error }

/// Special value meaning "no status filter applied".
const String kAllStatusFilter = 'All';

class FieldStaffIncentivesListState extends Equatable {
  final FieldStaffIncentivesListStatus status;
  final List<FieldStaffIncentive> list;
  final int page;
  final int perPage;
  final bool hasReachedMax;
  final Map<String, dynamic> filters;
  final String? errorMessage;

  /// Currently selected chip. 'All' means no status filter.
  final String selectedStatus;

  /// Every distinct status label seen so far, in first-seen order.
  /// Drives the chip row: UI should render ['All', ...statusOptions].
  final List<String> statusOptions;

  const FieldStaffIncentivesListState({
    this.status = FieldStaffIncentivesListStatus.initial,
    this.list = const [],
    this.page = 1,
    this.perPage = 10,
    this.hasReachedMax = false,
    this.filters = const {},
    this.errorMessage,
    this.selectedStatus = kAllStatusFilter,
    this.statusOptions = const [],
  });

  double get loadedTotal =>
      list.fold(0.0, (sum, item) => sum + (double.tryParse(item.incentiveAmount) ?? 0));

  bool get isInitialLoading =>
      status == FieldStaffIncentivesListStatus.loading && list.isEmpty;

  /// Convenience for the UI: 'All' plus every status seen so far.
  List<String> get chipOptions => [kAllStatusFilter, ...statusOptions];

  FieldStaffIncentivesListState copyWith({
    FieldStaffIncentivesListStatus? status,
    List<FieldStaffIncentive>? list,
    int? page,
    int? perPage,
    bool? hasReachedMax,
    Map<String, dynamic>? filters,
    String? errorMessage,
    String? selectedStatus,
    List<String>? statusOptions,
  }) {
    return FieldStaffIncentivesListState(
      status: status ?? this.status,
      list: list ?? this.list,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      filters: filters ?? this.filters,
      errorMessage: errorMessage,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      statusOptions: statusOptions ?? this.statusOptions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    list,
    page,
    perPage,
    hasReachedMax,
    filters,
    errorMessage,
    selectedStatus,
    statusOptions,
  ];
}