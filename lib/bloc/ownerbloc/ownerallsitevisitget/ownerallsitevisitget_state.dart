import '../../../models/owner_models/ownergetallsitevisitmodel.dart';

abstract class OwnerGetAllSiteVisitState {
  const OwnerGetAllSiteVisitState();
}

class OwnerGetAllSiteVisitInitial extends OwnerGetAllSiteVisitState {
  const OwnerGetAllSiteVisitInitial();
}

class OwnerGetAllSiteVisitLoading extends OwnerGetAllSiteVisitState {
  const OwnerGetAllSiteVisitLoading();
}

class OwnerGetAllSiteVisitLoaded extends OwnerGetAllSiteVisitState {
  final SiteVisitsSummaryModel summary;

  const OwnerGetAllSiteVisitLoaded(this.summary);
}

class OwnerGetAllSiteVisitError extends OwnerGetAllSiteVisitState {
  final String message;

  const OwnerGetAllSiteVisitError(this.message);
}