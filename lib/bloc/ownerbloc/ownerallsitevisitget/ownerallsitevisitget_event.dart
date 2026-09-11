abstract class OwnerGetAllSiteVisitEvent {
  const OwnerGetAllSiteVisitEvent();
}

/// Fired on page open and on pull-to-refresh.
class FetchOwnerGetAllSiteVisit extends OwnerGetAllSiteVisitEvent {
  const FetchOwnerGetAllSiteVisit();
}

/// Fired when the user taps the retry button on the error view.
class RetryOwnerGetAllSiteVisit extends OwnerGetAllSiteVisitEvent {
  const RetryOwnerGetAllSiteVisit();
}