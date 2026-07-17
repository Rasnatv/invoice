import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivitystate.dart';
import 'network_service.dart';


class ConnectivityCubit extends Cubit<ConnectivityState> {
  final NetworkService networkService;
  StreamSubscription? _subscription;

  ConnectivityCubit({required this.networkService})
      : super(ConnectivityState.initial()) {
    _init();
  }

  void _init() {
    _checkConnection();

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      _updateStatus(offline);
    });
  }

  Future<void> checkConnection() => _checkConnection();

  Future<void> _checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    final offline = results.every((r) => r == ConnectivityResult.none);
    _updateStatus(offline);
  }

  void _updateStatus(bool offline) {
    final wasOffline = state.isOffline;

    if (wasOffline == offline) {
      // no change, but still emit if isClosed check needed
      return;
    }

    // ✅ Only trigger when coming back online
    if (wasOffline && !offline) {
      final newCount = state.reconnectCount + 1;
      emit(state.copyWith(isOffline: offline, reconnectCount: newCount));

      // ✅ Delay to stabilize internet (IMPORTANT)
      Future.delayed(const Duration(seconds: 2), () {
        networkService.onReconnected();
      });
    } else {
      emit(state.copyWith(isOffline: offline));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}