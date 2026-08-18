import 'package:equatable/equatable.dart';
import '../../models/owner_models/ownerdespatchsheetpreparemodel.dart';

enum OwnerDespatchSheetStatus { initial, loading, success, failure }

enum OwnerDespatchSubmitStatus { idle, inProgress, success, failure }

class OwnerDespatchSheetState extends Equatable {
  final OwnerDespatchSheetStatus status;
  final DespatchSuggestionModel? suggestion;
  final List<DriverModel> drivers;
  final String? errorMessage;

  final OwnerDespatchSubmitStatus submitStatus;
  final String? submitMessage;

  const OwnerDespatchSheetState({
    this.status = OwnerDespatchSheetStatus.initial,
    this.suggestion,
    this.drivers = const [],
    this.errorMessage,
    this.submitStatus = OwnerDespatchSubmitStatus.idle,
    this.submitMessage,
  });

  OwnerDespatchSheetState copyWith({
    OwnerDespatchSheetStatus? status,
    DespatchSuggestionModel? suggestion,
    List<DriverModel>? drivers,
    String? errorMessage,
    OwnerDespatchSubmitStatus? submitStatus,
    String? submitMessage,
  }) {
    return OwnerDespatchSheetState(
      status: status ?? this.status,
      suggestion: suggestion ?? this.suggestion,
      drivers: drivers ?? this.drivers,
      errorMessage: errorMessage,
      submitStatus: submitStatus ?? this.submitStatus,
      submitMessage: submitMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, suggestion, drivers, errorMessage, submitStatus, submitMessage];
}