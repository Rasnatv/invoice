abstract class OwnerCancelQuotationEvent {
  const OwnerCancelQuotationEvent();
}

class OwnerCancelQuotationRequested extends OwnerCancelQuotationEvent {
  const OwnerCancelQuotationRequested(this.id);
  final String id;
}

class OwnerCancelQuotationResultConsumed extends OwnerCancelQuotationEvent {
  const OwnerCancelQuotationResultConsumed();
}