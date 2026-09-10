import '../../../models/owner_models/activefieldstaffmodel.dart';
import '../../../models/owner_models/fieldstaffincentivemodel.dart';
import '../../../models/owner_models/incentivesummarymodel.dart';


enum FieldStaffIncentiveStatus { initial, loading, loadingMore, loaded, error }

class FieldStaffIncentiveState {
  final FieldStaffIncentiveStatus status;
  final IncentiveSummaryModel summary;
  final List<ActiveFieldStaffModel> fieldStaffOptions;
  final List<FieldStaffIncentiveModel> incentives;
  final String? selectedFieldStaffId; // null = All Field Staff
  final String selectedStatus; // all | pending | approved | paid
  final String dateFrom;
  final String dateTo;
  final int page;
  final bool hasMore;
  final bool isUnauthorized;
  final String? errorMessage;
  final String? successMessage;

  const FieldStaffIncentiveState({
    this.status = FieldStaffIncentiveStatus.initial,
    required this.summary,
    this.fieldStaffOptions = const [],
    this.incentives = const [],
    this.selectedFieldStaffId,
    this.selectedStatus = 'all',
    this.dateFrom = '',
    this.dateTo = '',
    this.page = 1,
    this.hasMore = false,
    this.isUnauthorized = false,
    this.errorMessage,
    this.successMessage,
  });

  factory FieldStaffIncentiveState.initial() => FieldStaffIncentiveState(
    summary: IncentiveSummaryModel.empty(),
  );

  /// The name shown in the dropdown for the current selection.
  String get selectedFieldStaffName {
    if (selectedFieldStaffId == null) return 'All Field Staff';
    final match = fieldStaffOptions.where((f) => f.id == selectedFieldStaffId);
    return match.isNotEmpty ? match.first.name : 'All Field Staff';
  }

  FieldStaffIncentiveState copyWith({
    FieldStaffIncentiveStatus? status,
    IncentiveSummaryModel? summary,
    List<ActiveFieldStaffModel>? fieldStaffOptions,
    List<FieldStaffIncentiveModel>? incentives,
    String? selectedFieldStaffId,
    bool clearSelectedFieldStaffId = false,
    String? selectedStatus,
    String? dateFrom,
    String? dateTo,
    int? page,
    bool? hasMore,
    bool? isUnauthorized,
    String? errorMessage,
    String? successMessage,
    bool clearFeedback = false,
  }) {
    return FieldStaffIncentiveState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      fieldStaffOptions: fieldStaffOptions ?? this.fieldStaffOptions,
      incentives: incentives ?? this.incentives,
      selectedFieldStaffId: clearSelectedFieldStaffId
          ? null
          : (selectedFieldStaffId ?? this.selectedFieldStaffId),
      selectedStatus: selectedStatus ?? this.selectedStatus,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      errorMessage: clearFeedback ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearFeedback ? null : (successMessage ?? this.successMessage),
    );
  }
}