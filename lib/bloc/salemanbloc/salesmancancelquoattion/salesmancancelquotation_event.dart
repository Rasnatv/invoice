abstract class SalesmanCancelQuotationEvent {
  const SalesmanCancelQuotationEvent();
}

class SalesmanCancelQuotationRequested extends SalesmanCancelQuotationEvent {
  const SalesmanCancelQuotationRequested(this.id);
  final String id;
}

class SalesmanCancelQuotationResultConsumed
    extends SalesmanCancelQuotationEvent {
  const SalesmanCancelQuotationResultConsumed();
}