
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/network/network_bloc.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/profile/profile_event.dart';
import 'core/theme/app_theme.dart';
import 'router/approuter.dart';
import 'core/utils/responsive.dart';
import 'widgets/appsnackbar.dart';

void main() {
  runApp(const DreamsCeramicApp());
}

class DreamsCeramicApp extends StatelessWidget {
  const DreamsCeramicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NetworkBloc()..add(NetworkObserve())),
        BlocProvider(create: (_) => ProfileBloc()..add(const LoadProfile())),
      ],
      child: MaterialApp.router(
        title: 'Dreams Ceramic',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: AppSnackbar.messengerKey,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          Responsive.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
