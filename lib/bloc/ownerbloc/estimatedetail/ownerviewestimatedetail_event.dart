// import 'package:equatable/equatable.dart';
// import '../../../models/owner_models/owner_estimateactionmodel.dart';
//
//
// abstract class OwnerEstimateDetailEvent extends Equatable {
//   const OwnerEstimateDetailEvent();
//   @override
//   List<Object?> get props => [];
// }
//
// class OwnerEstimateDetailLoadRequested extends OwnerEstimateDetailEvent {
//   final String id;
//   const OwnerEstimateDetailLoadRequested(this.id);
//   @override
//   List<Object?> get props => [id];
// }
//
// class OwnerEstimateApproveRequested extends OwnerEstimateDetailEvent {
//   final OwnerApproveEstimateRequest request;
//   const OwnerEstimateApproveRequested(this.request);
//   @override
//   List<Object?> get props => [request];
// }
//
// class OwnerEstimateRejectRequested extends OwnerEstimateDetailEvent {
//   final OwnerRejectEstimateRequest request;
//   const OwnerEstimateRejectRequested(this.request);
//   @override
//   List<Object?> get props => [request];
// }
import 'package:equatable/equatable.dart';
import '../../../models/owner_models/owner_estimateactionmodel.dart';
import '../../../models/owner_models/ownerestimate_updatemodel.dart';


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

/// POST /estimates/update — dispatched from the Owner Estimate Update
/// screen. Reuses [OwnerEstimateDetailState.actionStatus] /
/// [OwnerEstimateDetailState.actionMessage] to report progress, same as
/// approve/reject, so the update screen can drive a button-level spinner
/// and a BlocListener can pop back to the detail screen on success.
class OwnerEstimateUpdateRequested extends OwnerEstimateDetailEvent {
  final OwnerUpdateEstimateRequest request;
  const OwnerEstimateUpdateRequested(this.request);
  @override
  List<Object?> get props => [request];
}