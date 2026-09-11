import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownergetallsitevisitprovider.dart';
import 'ownerallsitevisitget_event.dart';
import 'ownerallsitevisitget_state.dart';

class OwnerGetAllSiteVisitBloc
    extends Bloc<OwnerGetAllSiteVisitEvent, OwnerGetAllSiteVisitState> {
  final OwnerGetAllSiteVisitProvider _provider;

  OwnerGetAllSiteVisitBloc({OwnerGetAllSiteVisitProvider? provider})
      : _provider = provider ?? OwnerGetAllSiteVisitProvider(),
        super(const OwnerGetAllSiteVisitInitial()) {
    on<FetchOwnerGetAllSiteVisit>(_onFetch);
    on<RetryOwnerGetAllSiteVisit>(_onFetch);
  }

  Future<void> _onFetch(
      OwnerGetAllSiteVisitEvent event,
      Emitter<OwnerGetAllSiteVisitState> emit,
      ) async {
    emit(const OwnerGetAllSiteVisitLoading());

    final result = await _provider.getAllSiteVisits();

    if (result.success && result.data != null) {
      emit(OwnerGetAllSiteVisitLoaded(result.data!));
    } else {
      emit(OwnerGetAllSiteVisitError(result.errorMessage ?? 'Failed to load site visits.'));
    }
  }
}