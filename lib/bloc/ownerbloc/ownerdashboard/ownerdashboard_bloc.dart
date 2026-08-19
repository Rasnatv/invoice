import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerdashboard_apiprovider.dart';
import 'ownerdashboard_event.dart';
import 'ownerdashboard_state.dart';


class OwnerDashboardBloc extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  final OwnerDashboardApiProvider _provider;

  OwnerDashboardBloc({OwnerDashboardApiProvider? provider})
      : _provider = provider ?? OwnerDashboardApiProvider(),
        super(OwnerDashboardState.initial()) {
    on<OwnerDashboardRequested>(_onFetch);
    on<OwnerDashboardRefreshed>(_onFetch);
  }

  Future<void> _onFetch(
      OwnerDashboardEvent event,
      Emitter<OwnerDashboardState> emit,
      ) async {
    final isRefresh = event is OwnerDashboardRefreshed;
    emit(state.copyWith(
      status: isRefresh ? OwnerDashboardStatus.refreshing : OwnerDashboardStatus.loading,
    ));

    final result = await _provider.getDashboard();

    if (result.success) {
      emit(state.copyWith(status: OwnerDashboardStatus.success, data: result.data));
    } else {
      emit(state.copyWith(
        status: OwnerDashboardStatus.failure,
        errorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }
}