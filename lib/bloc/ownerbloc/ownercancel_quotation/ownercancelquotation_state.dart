enum OwnerCancelQuotationStatus { initial, inProgress, success, failure }

class OwnerCancelQuotationState {
  final OwnerCancelQuotationStatus status;
  final String? message;
  final String? errorMessage;

  const OwnerCancelQuotationState({
    this.status = OwnerCancelQuotationStatus.initial,
    this.message,
    this.errorMessage,
  });

  OwnerCancelQuotationState copyWith({
    OwnerCancelQuotationStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return OwnerCancelQuotationState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}