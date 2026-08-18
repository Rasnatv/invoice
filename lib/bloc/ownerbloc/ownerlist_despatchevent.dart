abstract class DispatchListEvent {
  const DispatchListEvent();
}

/// Initial load, shows the full-screen loader.
class FetchDispatchList extends DispatchListEvent {
  const FetchDispatchList();
}

/// Pull-to-refresh / re-fetch after returning from the detail screen.
/// Keeps the current list on screen while the new one loads.
class RefreshDispatchList extends DispatchListEvent {
  const RefreshDispatchList();
}

class SearchDispatchQueryChanged extends DispatchListEvent {
  final String query;
  const SearchDispatchQueryChanged(this.query);
}
