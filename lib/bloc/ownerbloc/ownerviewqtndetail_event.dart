import 'package:equatable/equatable.dart';
import '../../models/owner_models/owner_quotationapprovemodel.dart';

abstract class OwnerQuotationDetailEvent extends Equatable {
  const OwnerQuotationDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches full detail for a single quotation from POST /quotations/show.
class OwnerQuotationDetailRequested extends OwnerQuotationDetailEvent {
  final String id;
  const OwnerQuotationDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clears whatever detail is currently loaded — call when leaving the
/// details screen so a stale detail doesn't flash the next time it opens.
class OwnerQuotationDetailCleared extends OwnerQuotationDetailEvent {
  const OwnerQuotationDetailCleared();
}

/// Approves a quotation via POST /quotations/approve. On success the bloc
/// re-fetches the detail so the screen immediately reflects the new
/// status ("approved") without a manual refresh.
class OwnerQuotationApproveRequested extends OwnerQuotationDetailEvent {
  final QuotationApproveRequest request;
  const OwnerQuotationApproveRequested(this.request);

  @override
  List<Object?> get props => [request];
}

/// Resets the approve status back to idle after the UI has shown the
/// success/error snackbar for it, so re-opening the screen doesn't replay it.
class OwnerQuotationApproveResultConsumed extends OwnerQuotationDetailEvent {
  const OwnerQuotationApproveResultConsumed();
}