import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/estimate/salesman_approvedevent.dart';
import 'package:tileshop/bloc/salemanbloc/estimate/salesman_approvedsate.dart';
import '../../../Apiprovider/salesman_approvedestimateprovider.dart';


class ApprovedEstimatesBloc extends Bloc<ApprovedEstimatesEvent, ApprovedEstimatesState> {
  final ApprovedEstimateProvider _provider;

  ApprovedEstimatesBloc({ApprovedEstimateProvider? provider})
      : _provider = provider ?? ApprovedEstimateProvider(),
        super(const ApprovedEstimatesState()) {
    on<ApprovedEstimatesRequested>(_onFetch);
    on<ApprovedEstimatesRefreshed>(_onFetch);
    on<ApprovedEstimatesSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetch(
      ApprovedEstimatesEvent event, Emitter<ApprovedEstimatesState> emit) async {
    final isRefresh = event is ApprovedEstimatesRefreshed;
    emit(state.copyWith(
      status: isRefresh ? ApprovedEstimatesStatus.refreshing : ApprovedEstimatesStatus.loading,
    ));

    final result = await _provider.getMyApprovedEstimates();

    if (result.success) {
      emit(state.copyWith(status: ApprovedEstimatesStatus.success, list: result.list));
    } else {
      emit(state.copyWith(
        status: ApprovedEstimatesStatus.failure,
        errorMessage: result.errorMessage ?? 'Failed to load approved estimates.',
      ));
    }
  }

  void _onSearchChanged(
      ApprovedEstimatesSearchChanged event, Emitter<ApprovedEstimatesState> emit) {
    emit(state.copyWith(query: event.query));
  }
}