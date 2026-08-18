import 'package:equatable/equatable.dart';

abstract class OwnerEstimatesEvent extends Equatable {
  const OwnerEstimatesEvent();
  @override
  List<Object?> get props => [];
}

class OwnerEstimatesLoadRequested extends OwnerEstimatesEvent {
  const OwnerEstimatesLoadRequested();
}

class OwnerEstimatesRefreshRequested extends OwnerEstimatesEvent {
  const OwnerEstimatesRefreshRequested();
}

class OwnerEstimatesSearchQueryChanged extends OwnerEstimatesEvent {
  final String query;
  const OwnerEstimatesSearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class OwnerEstimatesFilterChanged extends OwnerEstimatesEvent {
  final String filterKey; // 'all' or a statusKey
  const OwnerEstimatesFilterChanged(this.filterKey);
  @override
  List<Object?> get props => [filterKey];
}