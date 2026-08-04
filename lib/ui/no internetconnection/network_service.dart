
class NetworkService {
  final List<Future<void> Function()> _callbacks = [];

  void register(Future<void> Function() callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  void unregister(Future<void> Function() callback) {
    _callbacks.remove(callback);
  }

  void onReconnected() {
    for (final cb in List.of(_callbacks)) {
      cb();
    }
  }
}