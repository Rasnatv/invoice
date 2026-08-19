import 'package:flutter/foundation.dart';

@immutable
abstract class DispatchDetailEvent {
  const DispatchDetailEvent();
}

class FetchDispatchDetail extends DispatchDetailEvent {
  const FetchDispatchDetail(this.id);
  final String id;
}

class RefreshDispatchDetail extends DispatchDetailEvent {
  const RefreshDispatchDetail(this.id);
  final String id;
}

class MarkInTransitRequested extends DispatchDetailEvent {
  const MarkInTransitRequested(this.id);
  final String id;
}

class MarkDeliveredRequested extends DispatchDetailEvent {
  const MarkDeliveredRequested({
    required this.id,
    required this.customerSignatureBase64,
    required this.driverSignatureBase64,
  });

  final String id;
  final String customerSignatureBase64;
  final String driverSignatureBase64;
}

/// Clears the one-shot action result (success/error banner + snackbar
/// trigger) after the UI has consumed it, so it doesn't fire again on
/// the next rebuild.
class ClearDispatchActionStatus extends DispatchDetailEvent {
  const ClearDispatchActionStatus();
}