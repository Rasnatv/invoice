import '../../../models/owner_models/fieldstaff_cretaemodel.dart';
import '../../../models/owner_models/fieldstaff_updatemodel.dart';
import '../../../models/owner_models/fieldstaff_deletemodel.dart';

abstract class FieldStaffEvent {
  const FieldStaffEvent();
}

/// Dispatch only on first page load or explicit pull-to-refresh — the bloc
/// updates its local list after add/update/delete instead of refetching.
class FetchFieldStaffListEvent extends FieldStaffEvent {
  const FetchFieldStaffListEvent();
}

class AddFieldStaffEvent extends FieldStaffEvent {
  const AddFieldStaffEvent(this.staff);
  final FieldStaffCreateModel staff;
}

class UpdateFieldStaffEvent extends FieldStaffEvent {
  const UpdateFieldStaffEvent(this.staff);
  final FieldStaffUpdateModel staff;
}

class DeleteFieldStaffEvent extends FieldStaffEvent {
  const DeleteFieldStaffEvent(this.staff);
  final FieldStaffDeleteModel staff;
}