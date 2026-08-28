import 'package:equatable/equatable.dart';

abstract class ApprovedEstimatesEvent extends Equatable {
  const ApprovedEstimatesEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches (or refreshes) the approved-estimates list from
/// GET /estimates/myapproved.
class ApprovedEstimatesRequested extends ApprovedEstimatesEvent {
  const ApprovedEstimatesRequested();
}

class ApprovedEstimatesRefreshed extends ApprovedEstimatesEvent {
  const ApprovedEstimatesRefreshed();
}

/// Client-side search box filtering.
class ApprovedEstimatesSearchChanged extends ApprovedEstimatesEvent {
  final String query;
  const ApprovedEstimatesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}