import '../../models/owner_models/fieldstaff_getmodel.dart';

enum FieldStaffStatus {
  initial,
  loading, // loading the list
  loaded, // list loaded successfully
  loadError, // list failed to load
  submitting, // add/update in progress
  submitSuccess, // add/update succeeded
  submitError, // add/update failed
  deleting, // delete in progress
  deleteSuccess, // delete succeeded
  deleteError, // delete failed
}

class FieldStaffState {
  const FieldStaffState({
    this.status = FieldStaffStatus.initial,
    this.staffList = const [],
    this.message,
    this.hasLoadedOnce = false,
  });

  factory FieldStaffState.initial() => const FieldStaffState();

  final FieldStaffStatus status;
  final List<FieldStaffModel> staffList;
  final String? message;

  /// Flips true after the first successful list fetch. The list page should
  /// check this in initState and only dispatch FetchFieldStaffListEvent if
  /// it's still false, or on an explicit RefreshIndicator pull — not on
  /// every rebuild / navigation back to the page.
  final bool hasLoadedOnce;

  bool get isLoading => status == FieldStaffStatus.loading;
  bool get isSubmitting => status == FieldStaffStatus.submitting;
  bool get isDeleting => status == FieldStaffStatus.deleting;

  FieldStaffState copyWith({
    FieldStaffStatus? status,
    List<FieldStaffModel>? staffList,
    String? message,
    bool? hasLoadedOnce,
  }) {
    return FieldStaffState(
      status: status ?? this.status,
      staffList: staffList ?? this.staffList,
      message: message,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}