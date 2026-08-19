import 'package:flutter/foundation.dart';
import '../../../models/owner_models/owner_despatchdetailmodel.dart';

enum DispatchDetailStatus { initial, loading, success, failure }

enum DispatchActionStatus { idle, inProgress, success, failure }

@immutable
class DispatchDetailState {
  const DispatchDetailState({
    this.status = DispatchDetailStatus.initial,
    this.dispatch,
    this.errorMessage,
    this.isUnauthorized = false,
    this.actionStatus = DispatchActionStatus.idle,
    this.actionMessage,
    this.actionType,
  });

  const DispatchDetailState.initial() : this();

  final DispatchDetailStatus status;
  final DispatchDetail? dispatch;
  final String? errorMessage;
  final bool isUnauthorized;

  /// Tracks mark-in-transit / mark-delivered calls separately from the
  /// page-load status, so a failed action doesn't blank out an already
  /// loaded detail screen.
  final DispatchActionStatus actionStatus;
  final String? actionMessage;
  final String? actionType; // 'in_transit' | 'delivered'

  DispatchDetailState copyWith({
    DispatchDetailStatus? status,
    DispatchDetail? dispatch,
    String? errorMessage,
    bool? isUnauthorized,
    DispatchActionStatus? actionStatus,
    String? actionMessage,
    String? actionType,
    bool clearErrorMessage = false,
    bool clearActionMessage = false,
  }) {
    return DispatchDetailState(
      status: status ?? this.status,
      dispatch: dispatch ?? this.dispatch,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      actionType: actionType ?? this.actionType,
    );
  }
}