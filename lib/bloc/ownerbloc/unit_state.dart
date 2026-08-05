
import '../../models/owner_models/uintmodel.dart';

enum UnitStatus { initial, loading, loaded, failure }

class UnitState {
  const UnitState({
    this.status = UnitStatus.initial,
    this.units = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final UnitStatus status;
  final List<UnitModel> units;

  /// True while an add/update/delete call is in flight. Kept separate from
  /// [status] so the list stays visible instead of flashing a full loader
  /// every time the user adds or edits a unit.
  final bool isSubmitting;

  final String? errorMessage;
  final String? successMessage;

  UnitState copyWith({
    UnitStatus? status,
    List<UnitModel>? units,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return UnitState(
      status: status ?? this.status,
      units: units ?? this.units,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
      clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}