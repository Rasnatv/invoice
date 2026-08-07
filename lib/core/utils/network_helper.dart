import 'package:connectivity_plus/connectivity_plus.dart';
import '../../bloc/network/network_bloc.dart';


class NetworkHelper {
  static void observeNetwork() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        NetworkBloc().add(NetworkNotify());
      } else {
        NetworkBloc().add(NetworkNotify(isConnected: true));
      }
    });
  }
}