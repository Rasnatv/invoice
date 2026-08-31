import 'package:equatable/equatable.dart';
import '../../../models/owner_models/owner_incentivesetupmodel.dart';


enum SalesmanIncentiveListStatus { initial, loading, success, failure }

enum SalesmanIncentiveDetailStatus { initial, loading, success, failure }

enum SalesmanIncentiveActionStatus { initial, submitting, success, failure }

class SalesmanIncentiveState extends Equatable {
  // GET /salesman-incentive-setup (list)
  final SalesmanIncentiveListStatus listStatus;
  final List<SalesmanIncentiveListItem> list;
  final String? listError;

  // POST /salesman-incentive-setup/get (single salesman/period detail)
  final SalesmanIncentiveDetailStatus detailStatus;
  final SalesmanIncentiveSetupDetail? detail; // null + success == nothing set up yet
  final String? detailError;

  // POST /salesman-incentive-setup/save and /delete
  final SalesmanIncentiveActionStatus actionStatus;
  final String? actionMessage;
  final String? actionError;

  final bool isUnauthorized;

  const SalesmanIncentiveState({
    this.listStatus = SalesmanIncentiveListStatus.initial,
    this.list = const [],
    this.listError,
    this.detailStatus = SalesmanIncentiveDetailStatus.initial,
    this.detail,
    this.detailError,
    this.actionStatus = SalesmanIncentiveActionStatus.initial,
    this.actionMessage,
    this.actionError,
    this.isUnauthorized = false,
  });

  SalesmanIncentiveState copyWith({
    SalesmanIncentiveListStatus? listStatus,
    List<SalesmanIncentiveListItem>? list,
    String? listError,
    bool clearListError = false,
    SalesmanIncentiveDetailStatus? detailStatus,
    SalesmanIncentiveSetupDetail? detail,
    bool clearDetail = false,
    String? detailError,
    bool clearDetailError = false,
    SalesmanIncentiveActionStatus? actionStatus,
    String? actionMessage,
    bool clearActionMessage = false,
    String? actionError,
    bool clearActionError = false,
    bool? isUnauthorized,
  }) {
    return SalesmanIncentiveState(
      listStatus: listStatus ?? this.listStatus,
      list: list ?? this.list,
      listError: clearListError ? null : (listError ?? this.listError),
      detailStatus: detailStatus ?? this.detailStatus,
      detail: clearDetail ? null : (detail ?? this.detail),
      detailError: clearDetailError ? null : (detailError ?? this.detailError),
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    list,
    listError,
    detailStatus,
    detail,
    detailError,
    actionStatus,
    actionMessage,
    actionError,
    isUnauthorized,
  ];
}