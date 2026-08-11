import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/salesman_dashboardstate.dart';
import 'package:tileshop/bloc/salemanbloc/salesmandashboard_event.dart';

import '../../Apiprovider/salesman_dashboardprovider.dart';

class DashboardHomeBloc extends Bloc<DashboardHomeEvent, DashboardHomeState> {
  final DashboardHomeApiProvider _provider;

  DashboardHomeBloc({DashboardHomeApiProvider? provider})
      : _provider = provider ?? DashboardHomeApiProvider(),
        super(DashboardHomeState.initial()) {
    on<DashboardHomeRequested>(_onFetch);
    on<DashboardHomeRefreshed>(_onFetch);
  }

  Future<void> _onFetch(
      DashboardHomeEvent event,
      Emitter<DashboardHomeState> emit,
      ) async {
    final isRefresh = event is DashboardHomeRefreshed;
    emit(state.copyWith(
      status: isRefresh ? DashboardHomeStatus.refreshing : DashboardHomeStatus.loading,
    ));

    final result = await _provider.getDashboard();

    if (result.success) {
      emit(state.copyWith(status: DashboardHomeStatus.success, data: result.data));
    } else {
      emit(state.copyWith(
        status: DashboardHomeStatus.failure,
        errorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }
}