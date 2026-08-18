import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/ownerdespatchcreateprovider.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import 'ownerdespatchsheetcreate_event.dart';
import 'ownerdespatchsheetcreate_state.dart';

class OwnerDespatchSheetBloc
    extends Bloc<OwnerDespatchSheetEvent, OwnerDespatchSheetState> {
  final OwnerDespatchProvider _provider;

  OwnerDespatchSheetBloc({OwnerDespatchProvider? provider})
      : _provider = provider ?? OwnerDespatchProvider(),
        super(const OwnerDespatchSheetState()) {
    on<OwnerDespatchSheetLoadRequested>(_onLoadRequested);
    on<OwnerDespatchCreateRequested>(_onCreateRequested);
  }

  Future<void> _onLoadRequested(OwnerDespatchSheetLoadRequested event,
      Emitter<OwnerDespatchSheetState> emit) async {
    emit(state.copyWith(status: OwnerDespatchSheetStatus.loading, errorMessage: null));

    final results = await Future.wait([
      _provider.getSuggestion(event.estimateId),
      _provider.getActiveDrivers(),
    ]);
    final suggestionResult = results[0] as DespatchSuggestionResult;
    final driverResult = results[1] as DriverListResult;

    if (!suggestionResult.success || suggestionResult.data == null) {
      emit(state.copyWith(
        status: OwnerDespatchSheetStatus.failure,
        errorMessage:
        suggestionResult.errorMessage ?? 'Failed to load despatch suggestions.',
      ));
      return;
    }

    // Driver list failing isn't fatal to viewing the sheet — surface it as
    // an empty list plus the load-time error message so the picker just
    // shows "No drivers available" instead of blocking the whole screen.
    emit(state.copyWith(
      status: OwnerDespatchSheetStatus.success,
      suggestion: suggestionResult.data,
      drivers: driverResult.drivers,
      errorMessage: driverResult.success ? null : driverResult.errorMessage,
    ));
  }

  Future<void> _onCreateRequested(OwnerDespatchCreateRequested event,
      Emitter<OwnerDespatchSheetState> emit) async {
    emit(state.copyWith(
        submitStatus: OwnerDespatchSubmitStatus.inProgress, submitMessage: null));
    final result = await _provider.createDespatch(event.request);
    if (!result.success) {
      emit(state.copyWith(
        submitStatus: OwnerDespatchSubmitStatus.failure,
        submitMessage: result.message,
      ));
      return;
    }
    emit(state.copyWith(
      submitStatus: OwnerDespatchSubmitStatus.success,
      submitMessage: result.message,
    ));
  }
}