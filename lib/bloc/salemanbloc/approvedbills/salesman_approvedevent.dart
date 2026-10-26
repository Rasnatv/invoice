import 'package:equatable/equatable.dart';

abstract class ApprovedEstimatesEvent extends Equatable {
  const ApprovedEstimatesEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the first page of approved estimates from
/// GET /estimates/myapproved.
class ApprovedEstimatesRequested extends ApprovedEstimatesEvent {
  const ApprovedEstimatesRequested();
}

/// Pull-to-refresh: reloads from page 1 and replaces the list.
class ApprovedEstimatesRefreshed extends ApprovedEstimatesEvent {
  const ApprovedEstimatesRefreshed();
}

/// Loads the next page and appends it to the list (infinite scroll).
class ApprovedEstimatesLoadMore extends ApprovedEstimatesEvent {
  const ApprovedEstimatesLoadMore();
}

/// Client-side search box filtering.
class ApprovedEstimatesSearchChanged extends ApprovedEstimatesEvent {
  final String query;
  const ApprovedEstimatesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}