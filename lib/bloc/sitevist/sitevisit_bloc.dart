import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/fieldstaff_sitevisitprovider.dart';
import '../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
import 'sitevisit_event.dart';
import 'sitevisit_state.dart';

class SiteVisitBloc extends Bloc<SiteVisitEvent, SiteVisitState> {
  SiteVisitBloc({SiteVisitProvider? provider})
      : _provider = provider ?? SiteVisitProvider(),
        super(const SiteVisitState()) {
    on<FetchMySiteVisits>(_onFetchMySiteVisits);
    on<ShowSiteVisitDetail>(_onShowSiteVisitDetail);
    on<CreateSiteVisit>(_onCreateSiteVisit);
    on<UpdateSiteVisit>(_onUpdateSiteVisit);
    on<DeleteSiteVisit>(_onDeleteSiteVisit);
    on<ResetSiteVisitActionStatus>(_onResetActionStatus);
  }

  final SiteVisitProvider _provider;

  Future<void> _onFetchMySiteVisits(
      FetchMySiteVisits event,
      Emitter<SiteVisitState> emit,
      ) async {
    emit(state.copyWith(isListLoading: true, clearListError: true));
    final result = await _provider.getMySiteVisits();
    if (result.success) {
      emit(state.copyWith(isListLoading: false, myData: result.data, clearListError: true));
    } else {
      emit(state.copyWith(isListLoading: false, listError: result.errorMessage));
    }
  }

  Future<void> _onShowSiteVisitDetail(
      ShowSiteVisitDetail event,
      Emitter<SiteVisitState> emit,
      ) async {
    emit(state.copyWith(isDetailLoading: true, clearDetailError: true));
    final result = await _provider.showSiteVisit(event.request);
    if (result.success) {
      emit(state.copyWith(isDetailLoading: false, detail: result.detail, clearDetailError: true));
    } else {
      emit(state.copyWith(isDetailLoading: false, detailError: result.errorMessage));
    }
  }

  Future<void> _onCreateSiteVisit(
      CreateSiteVisit event,
      Emitter<SiteVisitState> emit,
      ) async {
    emit(state.copyWith(actionStatus: SiteVisitActionStatus.inProgress, clearActionMessage: true));
    final result = await _provider.createSiteVisit(event.request);
    emit(_actionResultToState(result));
    if (result.success) {
      // Refresh the dashboard list in the background.
      add(const FetchMySiteVisits());
    }
  }

  Future<void> _onUpdateSiteVisit(
      UpdateSiteVisit event,
      Emitter<SiteVisitState> emit,
      ) async {
    emit(state.copyWith(actionStatus: SiteVisitActionStatus.inProgress, clearActionMessage: true));
    final result = await _provider.updateSiteVisit(event.request);
    emit(_actionResultToState(result));
    if (result.success) {
      add(const FetchMySiteVisits());
      // Keep an already-open detail screen in sync with what was just saved.
      add(ShowSiteVisitDetail(SiteVisitShowRequestModel(id: event.request.id.toString())));
    }
  }

  Future<void> _onDeleteSiteVisit(
      DeleteSiteVisit event,
      Emitter<SiteVisitState> emit,
      ) async {
    emit(state.copyWith(actionStatus: SiteVisitActionStatus.inProgress, clearActionMessage: true));
    final result = await _provider.deleteSiteVisit(event.request);
    emit(_actionResultToState(result));
    if (result.success) {
      add(const FetchMySiteVisits());
    }
  }

  void _onResetActionStatus(
      ResetSiteVisitActionStatus event,
      Emitter<SiteVisitState> emit,
      ) {
    emit(state.copyWith(
      actionStatus: SiteVisitActionStatus.idle,
      clearActionMessage: true,
      actionUnauthorized: false,
    ));
  }

  SiteVisitState _actionResultToState(SiteVisitActionResult result) {
    if (result.success) {
      return state.copyWith(
        actionStatus: SiteVisitActionStatus.success,
        actionMessage: result.message,
        actionUnauthorized: false,
      );
    }
    return state.copyWith(
      actionStatus: SiteVisitActionStatus.failure,
      actionMessage: result.errorMessage,
      actionUnauthorized: result.isUnauthorized,
    );
  }
}