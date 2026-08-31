import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/driverdespatchprovider.dart';
import 'driverdashboard_event.dart';
import 'driverdashboard_state.dart';

class DriverDashboardBloc extends Bloc<DriverDashboardEvent, DriverDashboardState> {
  final DriverDespatchProvider _provider;

  DriverDashboardBloc(this._provider) : super(const DriverDashboardState()) {
    on<FetchDriverDashboard>(_onFetch);
    on<RefreshDriverDashboard>(_onFetch);
  }

  Future<void> _onFetch(
      DriverDashboardEvent event,
      Emitter<DriverDashboardState> emit,
      ) async {
    emit(state.copyWith(status: DriverDashboardStatus.loading));
    final result = await _provider.getDashboard();
    if (result.success) {
      emit(state.copyWith(
        status: DriverDashboardStatus.success,
        dashboard: result.dashboard,
      ));
    } else {
      emit(state.copyWith(
        status: DriverDashboardStatus.failure,
        errorMessage: result.errorMessage,
      ));
    }
  }
}