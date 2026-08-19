import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';

enum OwnerEstimateDetailStatus { initial, loading, success, failure }

enum OwnerEstimateActionStatus { idle, inProgress, success, failure }

class OwnerEstimateDetailState extends Equatable {
  final OwnerEstimateDetailStatus status;
  final EstimateDetailModel? detail;
  final String? errorMessage;

  // Tracks the approve/reject call separately so the screen can show a
  // button-level spinner without re-rendering the whole detail as loading.
  final OwnerEstimateActionStatus actionStatus;
  final String? actionMessage;

  const OwnerEstimateDetailState({
    this.status = OwnerEstimateDetailStatus.initial,
    this.detail,
    this.errorMessage,
    this.actionStatus = OwnerEstimateActionStatus.idle,
    this.actionMessage,
  });

  OwnerEstimateDetailState copyWith({
    OwnerEstimateDetailStatus? status,
    EstimateDetailModel? detail,
    String? errorMessage,
    OwnerEstimateActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return OwnerEstimateDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, detail, errorMessage, actionStatus, actionMessage];
}