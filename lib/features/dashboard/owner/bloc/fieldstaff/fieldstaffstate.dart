import '../../data/model/fieldstaff_getmodel.dart';


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
  });

  factory FieldStaffState.initial() => const FieldStaffState();

  final FieldStaffStatus status;
  final List<FieldStaffModel> staffList;
  final String? message;

  bool get isLoading => status == FieldStaffStatus.loading;
  bool get isSubmitting => status == FieldStaffStatus.submitting;
  bool get isDeleting => status == FieldStaffStatus.deleting;

  FieldStaffState copyWith({
    FieldStaffStatus? status,
    List<FieldStaffModel>? staffList,
    String? message,
  }) {
    return FieldStaffState(
      status: status ?? this.status,
      staffList: staffList ?? this.staffList,
      message: message,
    );
  }
}