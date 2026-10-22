
abstract class DispatchListEvent {
  const DispatchListEvent();
}

/// Initial load, shows the full-screen loader.
class FetchDispatchList extends DispatchListEvent {
  const FetchDispatchList();
}

/// Pull-to-refresh / re-fetch after returning from the detail screen.
class RefreshDispatchList extends DispatchListEvent {
  const RefreshDispatchList();
}

/// Load the next page when the user scrolls near the bottom.
class LoadMoreDispatchList extends DispatchListEvent {
  const LoadMoreDispatchList();
}

class SearchDispatchQueryChanged extends DispatchListEvent {
  final String query;
  const SearchDispatchQueryChanged(this.query);
}