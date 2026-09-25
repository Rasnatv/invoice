
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

/// POST /estimates/remove-item — dispatched when deleting a *previously
/// saved* item row from the Owner Estimate Update screen. Items added in
/// the current form session (no server-side item id yet) are removed
/// locally without this event; see OwnerEstimateUpdateScreen._removeItem.
/// Tracked via [OwnerEstimateDetailState.itemRemoveStatus] separately
/// from [OwnerEstimateDetailState.actionStatus], so removing one row
/// doesn't put the whole "Save Changes" button into a busy state.
class OwnerEstimateItemRemoveRequested extends OwnerEstimateDetailEvent {
  final String estimateId;
  final String estimateItemId;
  const OwnerEstimateItemRemoveRequested({
    required this.estimateId,
    required this.estimateItemId,
  });
  @override
  List<Object?> get props => [estimateId, estimateItemId];
}

/// POST /estimates/update-item — dispatched when editing a *previously
/// saved* item row from the Owner Estimate Update screen (pencil icon),
/// updating just that one line item on the server immediately, without
/// touching the rest of the estimate. Mirrors
/// OwnerEstimateItemRemoveRequested. Items added in the current form
/// session with no server-side item id yet should NOT use this event —
/// they're just updated locally in _items until Save Changes is tapped
/// (which goes through OwnerEstimateUpdateRequested instead).
/// Tracked via [OwnerEstimateDetailState.itemUpdateStatus] separately
/// from both actionStatus and itemRemoveStatus, so updating one row
/// shows a spinner on just that row.
class OwnerEstimateItemUpdateRequested extends OwnerEstimateDetailEvent {
  final String estimateId;
  final String estimateItemId;
  final double quantity;
  final double rate;
  final double boxQuantity;
  final double pieceQuantity;

  const OwnerEstimateItemUpdateRequested({
    required this.estimateId,
    required this.estimateItemId,
    required this.quantity,
    required this.rate,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
  });

  @override
  List<Object?> get props =>
      [estimateId, estimateItemId, quantity, rate, boxQuantity, pieceQuantity];
}