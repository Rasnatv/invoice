import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_cubit.dart';
import 'connectivitystate.dart';

import 'nointernet_connectionpage.dart';

class NetworkAwareWrapper extends StatelessWidget {
  final Widget child;
  const NetworkAwareWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        // ✅ Show full screen when offline
        if (state.isOffline) {
          return NoInternetPage(
            onRetry: () => context.read<ConnectivityCubit>().checkConnection(),
          );
        }

        // ✅ Normal app (NO red snackbar / NO banner)
        return KeyedSubtree(
          key: ValueKey(state.reconnectCount), // refresh after reconnect
          child: child,
        );
      },
    );
  }
}