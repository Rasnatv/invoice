abstract class DesignationEvent {}

class FetchDesignations extends DesignationEvent {}

class AddDesignation extends DesignationEvent {
  final String name;

  AddDesignation(this.name);
}

class UpdateDesignation extends DesignationEvent {
  final int id;
  final String name;

  UpdateDesignation({required this.id, required this.name});
}

class DeleteDesignation extends DesignationEvent {
  final int id;

  DeleteDesignation(this.id);
}