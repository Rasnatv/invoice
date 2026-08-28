import 'package:equatable/equatable.dart';

abstract class EstimateDetailEvent extends Equatable {
  const EstimateDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches full detail for a single estimate from POST /estimates/show.
class EstimateDetailRequested extends EstimateDetailEvent {
  final String id;
  const EstimateDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clears whatever detail is currently loaded — call when leaving the
/// detail screen so a stale record doesn't flash the next time it opens.
class EstimateDetailCleared extends EstimateDetailEvent {
  const EstimateDetailCleared();
}