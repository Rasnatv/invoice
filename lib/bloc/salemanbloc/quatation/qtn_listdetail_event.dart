import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/quotationupdatemodel.dart';

abstract class SalesmanQuotationEvent extends Equatable {
  const SalesmanQuotationEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches (or refreshes) the logged-in salesman's quotation list from
/// GET /quotations/my.
class QuotationListRequested extends SalesmanQuotationEvent {
  const QuotationListRequested();
}

/// Fetches full detail for a single quotation from POST /quotations/show.
class QuotationDetailRequested extends SalesmanQuotationEvent {
  final String id;
  const QuotationDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clears whatever detail is currently loaded — call when leaving the
/// preview screen so a stale detail doesn't flash the next time it opens.
class QuotationDetailCleared extends SalesmanQuotationEvent {
  const QuotationDetailCleared();
}

/// Deletes a quotation via POST /quotations/delete. On success the item is
/// removed from the in-memory list immediately (no extra round trip).
class QuotationDeleteRequested extends SalesmanQuotationEvent {
  final String id;
  const QuotationDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Sends a saved (draft) quotation for admin/owner approval via
/// POST /quotations/submit.
class QuotationSubmitForApprovalRequested extends SalesmanQuotationEvent {
  final String id;
  const QuotationSubmitForApprovalRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Updates an existing (draft) quotation via POST /quotations/update, then
/// re-fetches its detail so the preview reflects the saved changes.
class QuotationUpdateSubmitted extends SalesmanQuotationEvent {
  final QuotationUpdateRequest request;
  const QuotationUpdateSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

/// Resets delete/submit status back to idle after the UI has shown the
/// success/error snackbar for it, so re-opening a screen doesn't replay it.
class QuotationActionResultConsumed extends SalesmanQuotationEvent {
  const QuotationActionResultConsumed();
}