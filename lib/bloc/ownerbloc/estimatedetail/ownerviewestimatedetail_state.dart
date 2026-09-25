//
// import 'package:equatable/equatable.dart';
// import '../../../models/salesmanmodels/estimatedetail.model.dart';
//
// enum OwnerEstimateDetailStatus { initial, loading, success, failure }
//
// enum OwnerEstimateActionStatus { idle, inProgress, success, failure }
//
// class OwnerEstimateDetailState extends Equatable {
//   final OwnerEstimateDetailStatus status;
//   final EstimateDetailModel? detail;
//   final String? errorMessage;
//
//   // Tracks the approve/reject/update call separately so the screen can
//   // show a button-level spinner without re-rendering the whole detail
//   // as loading.
//   final OwnerEstimateActionStatus actionStatus;
//   final String? actionMessage;
//
//   // Tracks POST /estimates/remove-item separately from actionStatus, so
//   // deleting a single item row shows a spinner on just that row rather
//   // than disabling the whole Save Changes button. `removedEstimateItemId`
//   // tells the listener which row's server call just succeeded, so it can
//   // be dropped from the in-progress edit list.
//   final OwnerEstimateActionStatus itemRemoveStatus;
//   final String? itemRemoveMessage;
//   final String? removedEstimateItemId;
//
//   const OwnerEstimateDetailState({
//     this.status = OwnerEstimateDetailStatus.initial,
//     this.detail,
//     this.errorMessage,
//     this.actionStatus = OwnerEstimateActionStatus.idle,
//     this.actionMessage,
//     this.itemRemoveStatus = OwnerEstimateActionStatus.idle,
//     this.itemRemoveMessage,
//     this.removedEstimateItemId,
//   });
//
//   OwnerEstimateDetailState copyWith({
//     OwnerEstimateDetailStatus? status,
//     EstimateDetailModel? detail,
//     String? errorMessage,
//     OwnerEstimateActionStatus? actionStatus,
//     String? actionMessage,
//     OwnerEstimateActionStatus? itemRemoveStatus,
//     String? itemRemoveMessage,
//     String? removedEstimateItemId,
//   }) {
//     return OwnerEstimateDetailState(
//       status: status ?? this.status,
//       detail: detail ?? this.detail,
//       errorMessage: errorMessage,
//       actionStatus: actionStatus ?? this.actionStatus,
//       actionMessage: actionMessage,
//       itemRemoveStatus: itemRemoveStatus ?? this.itemRemoveStatus,
//       itemRemoveMessage: itemRemoveMessage,
//       removedEstimateItemId: removedEstimateItemId,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     status,
//     detail,
//     errorMessage,
//     actionStatus,
//     actionMessage,
//     itemRemoveStatus,
//     itemRemoveMessage,
//     removedEstimateItemId,
//   ];
//
// }
import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';

enum OwnerEstimateDetailStatus { initial, loading, success, failure }

enum OwnerEstimateActionStatus { idle, inProgress, success, failure }

class OwnerEstimateDetailState extends Equatable {
  final OwnerEstimateDetailStatus status;
  final EstimateDetailModel? detail;
  final String? errorMessage;

  // Tracks the approve/reject/update call separately so the screen can
  // show a button-level spinner without re-rendering the whole detail
  // as loading.
  final OwnerEstimateActionStatus actionStatus;
  final String? actionMessage;

  // Tracks POST /estimates/remove-item separately from actionStatus, so
  // deleting a single item row shows a spinner on just that row rather
  // than disabling the whole Save Changes button. `removedEstimateItemId`
  // tells the listener which row's server call just succeeded, so it can
  // be dropped from the in-progress edit list.
  final OwnerEstimateActionStatus itemRemoveStatus;
  final String? itemRemoveMessage;
  final String? removedEstimateItemId;

  // Tracks POST /estimates/update-item separately from actionStatus and
  // itemRemoveStatus, so updating a single item row (pencil icon) shows a
  // spinner on just that row. `updatedEstimateItemId` tells the listener
  // which row's server call just succeeded, so it can refresh that row's
  // display values.
  final OwnerEstimateActionStatus itemUpdateStatus;
  final String? itemUpdateMessage;
  final String? updatedEstimateItemId;

  const OwnerEstimateDetailState({
    this.status = OwnerEstimateDetailStatus.initial,
    this.detail,
    this.errorMessage,
    this.actionStatus = OwnerEstimateActionStatus.idle,
    this.actionMessage,
    this.itemRemoveStatus = OwnerEstimateActionStatus.idle,
    this.itemRemoveMessage,
    this.removedEstimateItemId,
    this.itemUpdateStatus = OwnerEstimateActionStatus.idle,
    this.itemUpdateMessage,
    this.updatedEstimateItemId,
  });

  OwnerEstimateDetailState copyWith({
    OwnerEstimateDetailStatus? status,
    EstimateDetailModel? detail,
    String? errorMessage,
    OwnerEstimateActionStatus? actionStatus,
    String? actionMessage,
    OwnerEstimateActionStatus? itemRemoveStatus,
    String? itemRemoveMessage,
    String? removedEstimateItemId,
    OwnerEstimateActionStatus? itemUpdateStatus,
    String? itemUpdateMessage,
    String? updatedEstimateItemId,
  }) {
    return OwnerEstimateDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
      itemRemoveStatus: itemRemoveStatus ?? this.itemRemoveStatus,
      itemRemoveMessage: itemRemoveMessage,
      removedEstimateItemId: removedEstimateItemId,
      itemUpdateStatus: itemUpdateStatus ?? this.itemUpdateStatus,
      itemUpdateMessage: itemUpdateMessage,
      updatedEstimateItemId: updatedEstimateItemId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    detail,
    errorMessage,
    actionStatus,
    actionMessage,
    itemRemoveStatus,
    itemRemoveMessage,
    removedEstimateItemId,
    itemUpdateStatus,
    itemUpdateMessage,
    updatedEstimateItemId,
  ];
}