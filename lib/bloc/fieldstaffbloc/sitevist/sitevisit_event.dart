// import 'package:equatable/equatable.dart';
// import '../../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
// import '../../../models/fieldstaffmodels/fieldstaffsitevisitmodel.dart';
// import '../../../models/fieldstaffmodels/sitevisitdeletemodel.dart';
// import '../../../models/fieldstaffmodels/sitevisitupdatemodel.dart';
//
// abstract class SiteVisitEvent extends Equatable {
//   const SiteVisitEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// /// GET /site-visits/my — feeds both the "Today" and "All" tabs on the
// /// dashboard.
// class FetchMySiteVisits extends SiteVisitEvent {
//   const FetchMySiteVisits();
// }
//
// /// POST /site-visits/show — loads a single visit for the detail screen.
// class ShowSiteVisitDetail extends SiteVisitEvent {
//   const ShowSiteVisitDetail(this.request);
//
//   final SiteVisitShowRequestModel request;
//
//   @override
//   List<Object?> get props => [request];
// }
//
// /// POST /site-visits/create
// class CreateSiteVisit extends SiteVisitEvent {
//   const CreateSiteVisit(this.request);
//
//   final SiteVisitCreateRequestModel request;
//
//   @override
//   List<Object?> get props => [request];
// }
//
// /// POST /site-visits/update
// class UpdateSiteVisit extends SiteVisitEvent {
//   const UpdateSiteVisit(this.request);
//
//   final SiteVisitUpdateRequestModel request;
//
//   @override
//   List<Object?> get props => [request];
// }
//
// /// POST /site-visits/delete
// class DeleteSiteVisit extends SiteVisitEvent {
//   const DeleteSiteVisit(this.request);
//
//   final SiteVisitDeleteRequestModel request;
//
//   @override
//   List<Object?> get props => [request];
// }
//
// /// Clears actionStatus/actionMessage back to idle once the UI has
// /// consumed a create/update/delete result (snackbar shown, etc).
// class ResetSiteVisitActionStatus extends SiteVisitEvent {
//   const ResetSiteVisitActionStatus();
// }
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

/// GET /site-visits/my — feeds both the "Today" and "All" tabs on the
/// dashboard.
///
/// - [page]: which page of the "all" list to fetch. Defaults to 1 (first
///   load / pull-to-refresh).
/// - [loadMore]: true when this fetch was triggered by scrolling to the
///   bottom of the "All" tab — the bloc appends the results onto the
///   existing list instead of replacing it, and uses the
///   isLoadingMore/hasMoreAll state instead of the full-screen shimmer.
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