import 'package:equatable/equatable.dart';

abstract class QuotationItemRemoveEvent extends Equatable {
  const QuotationItemRemoveEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user confirms deleting an existing (already-saved) item
/// from a quotation/estimate. Not used for items that were only just added
/// locally and never saved to the server — those are removed from the UI
/// list directly, with no API call.
class QuotationItemRemoveRequested extends QuotationItemRemoveEvent {
  final String quotationId;
  final String quotationItemId;

  const QuotationItemRemoveRequested({
    required this.quotationId,
    required this.quotationItemId,
  });

  @override
  List<Object?> get props => [quotationId, quotationItemId];
}

/// Fired by the UI after it has read a terminal status (success/failure)
/// off the state, so a rebuild doesn't re-trigger the same snackbar or
/// list update a second time.
class QuotationItemRemoveResultConsumed extends QuotationItemRemoveEvent {
  const QuotationItemRemoveResultConsumed();
}