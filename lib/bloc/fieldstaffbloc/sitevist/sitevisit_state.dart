import 'package:equatable/equatable.dart';
import '../../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
import '../../../models/fieldstaffmodels/fieldstaffsitevisitmodel.dart';


enum SiteVisitActionStatus { idle, inProgress, success, failure }

class SiteVisitState extends Equatable {
  const SiteVisitState({
    this.isListLoading = false,
    this.listError,
    this.myData = SiteVisitMyDataModel.empty,
    this.isDetailLoading = false,
    this.detail,
    this.detailError,
    this.actionStatus = SiteVisitActionStatus.idle,
    this.actionMessage,
    this.actionUnauthorized = false,
  });

  // ---- GET /site-visits/my ----
  final bool isListLoading;
  final String? listError;
  final SiteVisitMyDataModel myData;

  // ---- POST /site-visits/show ----
  final bool isDetailLoading;
  final SiteVisitDetailModel? detail;
  final String? detailError;

  // ---- create / update / delete ----
  final SiteVisitActionStatus actionStatus;
  final String? actionMessage;
  final bool actionUnauthorized;

  List<SiteVisitListItemModel> get todayVisits => myData.today.list;
  List<SiteVisitListItemModel> get allVisits => myData.all.list;
  int get totalVisitsCount => myData.totalVisits;
  int get todayVisitsCount => myData.todayVisits;
  double get totalIncentive => myData.totalIncentive;

  SiteVisitState copyWith({
    bool? isListLoading,
    String? listError,
    bool clearListError = false,
    SiteVisitMyDataModel? myData,
    bool? isDetailLoading,
    SiteVisitDetailModel? detail,
    String? detailError,
    bool clearDetailError = false,
    SiteVisitActionStatus? actionStatus,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? actionUnauthorized,
  }) {
    return SiteVisitState(
      isListLoading: isListLoading ?? this.isListLoading,
      listError: clearListError ? null : (listError ?? this.listError),
      myData: myData ?? this.myData,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      detail: detail ?? this.detail,
      detailError: clearDetailError ? null : (detailError ?? this.detailError),
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      actionUnauthorized: actionUnauthorized ?? this.actionUnauthorized,
    );
  }

  @override
  List<Object?> get props => [
    isListLoading,
    listError,
    myData,
    isDetailLoading,
    detail,
    detailError,
    actionStatus,
    actionMessage,
    actionUnauthorized,
  ];
}