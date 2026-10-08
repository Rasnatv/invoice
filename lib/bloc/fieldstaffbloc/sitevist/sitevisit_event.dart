

import 'package:equatable/equatable.dart';
import '../../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
import '../../../models/fieldstaffmodels/fieldstaffsitevisitmodel.dart';
import '../../../models/fieldstaffmodels/sitevisitdeletemodel.dart';
import '../../../models/fieldstaffmodels/sitevisitupdatemodel.dart';

abstract class SiteVisitEvent extends Equatable {
  const SiteVisitEvent();

  @override
  List<Object?> get props => [];
}

class FetchMySiteVisits extends SiteVisitEvent {
  const FetchMySiteVisits({this.page = 1, this.loadMore = false});

  final int page;
  final bool loadMore;

  @override
  List<Object?> get props => [page, loadMore];
}

/// POST /site-visits/show — loads a single visit for the detail screen.
class ShowSiteVisitDetail extends SiteVisitEvent {
  const ShowSiteVisitDetail(this.request);

  final SiteVisitShowRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// POST /site-visits/create
class CreateSiteVisit extends SiteVisitEvent {
  const CreateSiteVisit(this.request);

  final SiteVisitCreateRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// POST /site-visits/update
class UpdateSiteVisit extends SiteVisitEvent {
  const UpdateSiteVisit(this.request);

  final SiteVisitUpdateRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// POST /site-visits/delete
class DeleteSiteVisit extends SiteVisitEvent {
  const DeleteSiteVisit(this.request);

  final SiteVisitDeleteRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// Clears actionStatus/actionMessage back to idle once the UI has
/// consumed a create/update/delete result (snackbar shown, etc).
class ResetSiteVisitActionStatus extends SiteVisitEvent {
  const ResetSiteVisitActionStatus();
}