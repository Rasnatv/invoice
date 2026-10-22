enum SalesmanCancelQuotationStatus { initial, inProgress, success, failure }

class SalesmanCancelQuotationState {
  final SalesmanCancelQuotationStatus status;
  final String? message;
  final String? errorMessage;

  const SalesmanCancelQuotationState({
    this.status = SalesmanCancelQuotationStatus.initial,
    this.message,
    this.errorMessage,
  });

  SalesmanCancelQuotationState copyWith({
    SalesmanCancelQuotationStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return SalesmanCancelQuotationState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}