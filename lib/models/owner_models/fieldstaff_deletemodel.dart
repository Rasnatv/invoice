/// Request model for POST /field-staff/delete.
/// Response "data" is empty ({}), so this model only needs the request side.
class FieldStaffDeleteModel {
  FieldStaffDeleteModel({required this.id});

  final int id;

  Map<String, dynamic> toJson() => {'id': id};
}