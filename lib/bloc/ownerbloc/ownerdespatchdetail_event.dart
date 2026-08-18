abstract class DispatchDetailEvent {
  const DispatchDetailEvent();
}

class FetchDispatchDetail extends DispatchDetailEvent {
  final String dispatchId;
  const FetchDispatchDetail(this.dispatchId);
}

/// Step 1 of the delivery flow: pending -> in_transit.
class MarkInTransitRequested extends DispatchDetailEvent {
  final String dispatchId;
  const MarkInTransitRequested(this.dispatchId);
}

/// Step 2 of the delivery flow: in_transit -> delivered. Only valid once
/// the dispatch has already been marked in transit.
class MarkDeliveredRequested extends DispatchDetailEvent {
  final String dispatchId;
  final String customerSignatureBase64;
  final String driverSignatureBase64;

  const MarkDeliveredRequested({
    required this.dispatchId,
    required this.customerSignatureBase64,
    required this.driverSignatureBase64,
  });
}
