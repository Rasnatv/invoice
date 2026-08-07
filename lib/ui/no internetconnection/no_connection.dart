import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/network/network_bloc.dart';
import 'nointernet_connectionpage.dart'; // adjust to your actual path

class NetworkAwareWrapper extends StatelessWidget {
  final Widget child;
  const NetworkAwareWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      builder: (context, state) {
        if (state is NetworkFailure) {
          return NoInternetPage(
            onRetry: () => context.read<NetworkBloc>().add(NetworkObserve()),
          );
        }
        return child;
      },
    );
  }
}