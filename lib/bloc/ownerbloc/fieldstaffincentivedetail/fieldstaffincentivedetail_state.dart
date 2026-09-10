

import '../../../models/owner_models/fieldstaffincentivemodel.dart';
enum IncentiveDetailStatus { initial, loading, loaded, error }

class IncentiveDetailState {
  final IncentiveDetailStatus status;
  final FieldStaffIncentiveModel? incentive;
  final bool isSubmitting; // true while mark-as-paid is in flight
  final bool isUnauthorized;
  final String? errorMessage;
  final String? successMessage;

  const IncentiveDetailState({
    this.status = IncentiveDetailStatus.initial,
    this.incentive,
    this.isSubmitting = false,
    this.isUnauthorized = false,
    this.errorMessage,
    this.successMessage,
  });

  factory IncentiveDetailState.initial() => const IncentiveDetailState();

  IncentiveDetailState copyWith({
    IncentiveDetailStatus? status,
    FieldStaffIncentiveModel? incentive,
    bool? isSubmitting,
    bool? isUnauthorized,
    String? errorMessage,
    String? successMessage,
    bool clearFeedback = false,
  }) {
    return IncentiveDetailState(
      status: status ?? this.status,
      incentive: incentive ?? this.incentive,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      errorMessage: clearFeedback ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearFeedback ? null : (successMessage ?? this.successMessage),
    );
  }
}