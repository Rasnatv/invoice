import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';

enum EstimateDetailStatus { initial, loading, success, failure }

class EstimateDetailState extends Equatable {
  final EstimateDetailStatus status;
  final EstimateDetailModel? detail;
  final String? error;

  const EstimateDetailState({
    this.status = EstimateDetailStatus.initial,
    this.detail,
    this.error,
  });

  EstimateDetailState copyWith({
    EstimateDetailStatus? status,
    EstimateDetailModel? detail,
    String? error,
    bool clearDetail = false,
    bool clearError = false,
  }) {
    return EstimateDetailState(
      status: status ?? this.status,
      detail: clearDetail ? null : (detail ?? this.detail),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, detail, error];
}