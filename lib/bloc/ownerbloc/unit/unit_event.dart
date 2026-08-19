abstract class UnitEvent {
  const UnitEvent();
}

/// Fetches the current list of units from the API.
class LoadUnits extends UnitEvent {
  const LoadUnits();
}

class AddUnitRequested extends UnitEvent {
  const AddUnitRequested({required this.name, required this.abbreviation});

  final String name;
  final String abbreviation;
}

class UpdateUnitRequested extends UnitEvent {
  const UpdateUnitRequested({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  final String id;
  final String name;
  final String abbreviation;
}

class DeleteUnitRequested extends UnitEvent {
  const DeleteUnitRequested(this.id);

  final String id;
}

/// Fired once the UI has shown the current error/success message, so the
/// same message doesn't re-trigger a snackbar on the next rebuild.
class UnitMessageConsumed extends UnitEvent {
  const UnitMessageConsumed();
}