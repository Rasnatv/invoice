import 'package:equatable/equatable.dart';

enum QuotationItemRemoveStatus { initial, inProgress, success, failure }

class QuotationItemRemoveState extends Equatable {
  final QuotationItemRemoveStatus status;

  /// The `quotation_item_id` the current/most-recent remove operation is
  /// (or was) for. Lets the UI show a per-tile spinner and, on success,
  /// know exactly which item to drop from its local list.
  final String? removedItemId;
  final String? message;
  final String? errorMessage;

  const QuotationItemRemoveState({
    this.status = QuotationItemRemoveStatus.initial,
    this.removedItemId,
    this.message,
    this.errorMessage,
  });

  QuotationItemRemoveState copyWith({
    QuotationItemRemoveStatus? status,
    String? removedItemId,
    String? message,
    String? errorMessage,
  }) {
    return QuotationItemRemoveState(
      status: status ?? this.status,
      removedItemId: removedItemId ?? this.removedItemId,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, removedItemId, message, errorMessage];
}