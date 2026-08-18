
import '../../models/owner_models/owner_despatchdetailmodel.dart';

enum DispatchDetailStatus { initial, loading, loaded, actionInProgress, failure }

class DispatchDetailState {
  final DispatchDetailStatus status;
  final DispatchDetail? dispatch;
  final String? errorMessage;
  /// 'transit' | 'delivered' — which action button is currently busy.
  final String? actionInProgressType;

  const DispatchDetailState({
    this.status = DispatchDetailStatus.initial,
    this.dispatch,
    this.errorMessage,
    this.actionInProgressType,
  });

  DispatchDetailState copyWith({
    DispatchDetailStatus? status,
    DispatchDetail? dispatch,
    String? errorMessage,
    String? actionInProgressType,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return DispatchDetailState(
      status: status ?? this.status,
      dispatch: dispatch ?? this.dispatch,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionInProgressType: clearAction ? null : (actionInProgressType ?? this.actionInProgressType),
    );
  }
}
