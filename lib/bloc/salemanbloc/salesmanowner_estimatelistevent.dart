import 'package:equatable/equatable.dart';

abstract class SalesmanowrEstimatesEvent extends Equatable {
  const SalesmanowrEstimatesEvent ();
  @override
  List<Object?> get props => [];
}

class EstimatesLoadRequested extends SalesmanowrEstimatesEvent  {
  const EstimatesLoadRequested();
}

class EstimatesRefreshRequested extends SalesmanowrEstimatesEvent {
  const EstimatesRefreshRequested();
}

class EstimatesSearchQueryChanged extends SalesmanowrEstimatesEvent  {
  final String query;
  const EstimatesSearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class EstimatesFilterChanged extends SalesmanowrEstimatesEvent  {
  final String filterKey; // 'all' or a statusKey (e.g. 'draft', 'sent', 'new')
  const EstimatesFilterChanged(this.filterKey);
  @override
  List<Object?> get props => [filterKey];
}
