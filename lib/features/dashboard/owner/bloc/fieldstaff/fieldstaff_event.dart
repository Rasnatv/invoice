import '../../data/model/fieldstaff_cretaemodel.dart';
import '../../data/model/fieldstaff_deletemodel.dart';
import '../../data/model/fieldstaff_updatemodel.dart';


abstract class FieldStaffEvent {
  const FieldStaffEvent();
}

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