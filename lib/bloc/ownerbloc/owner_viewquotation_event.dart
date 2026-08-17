enum QuotationFilterType { mine, salesman }

abstract class QuotationEvent {
  const QuotationEvent();
}

/// Initial fetch of quotations (page 1).
class FetchQuotationsEvent extends QuotationEvent {
  final int page;
  final int perPage;

  const FetchQuotationsEvent({this.page = 1, this.perPage = 10});
}

/// Loads the next page and appends to the existing list.
class LoadMoreQuotationsEvent extends QuotationEvent {
  const LoadMoreQuotationsEvent();
}

/// Pull-to-refresh style reload, keeps current filter/search, resets to page 1.
class RefreshQuotationsEvent extends QuotationEvent {
  const RefreshQuotationsEvent();
}

/// Fired as the user types in the search box.
class SearchQuotationsEvent extends QuotationEvent {
  final String query;

  const SearchQuotationsEvent(this.query);
}

/// Toggle between "My Quotations" and "Salesman Quotations".
class FilterQuotationsEvent extends QuotationEvent {
  final QuotationFilterType filter;

  const FilterQuotationsEvent(this.filter);
}