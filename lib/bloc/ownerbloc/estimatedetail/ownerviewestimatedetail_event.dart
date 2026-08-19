import 'package:equatable/equatable.dart';
import '../../../models/owner_models/owner_estimateactionmodel.dart';


abstract class OwnerEstimateDetailEvent extends Equatable {
  const OwnerEstimateDetailEvent();
  @override
  List<Object?> get props => [];
}

class OwnerEstimateDetailLoadRequested extends OwnerEstimateDetailEvent {
  final String id;
  const OwnerEstimateDetailLoadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class OwnerEstimateApproveRequested extends OwnerEstimateDetailEvent {
  final OwnerApproveEstimateRequest request;
  const OwnerEstimateApproveRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class OwnerEstimateRejectRequested extends OwnerEstimateDetailEvent {
  final OwnerRejectEstimateRequest request;
  const OwnerEstimateRejectRequested(this.request);
  @override
  List<Object?> get props => [request];
}