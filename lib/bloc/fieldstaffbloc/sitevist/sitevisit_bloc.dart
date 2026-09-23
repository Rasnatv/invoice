//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../Apiprovider/fieldstaff_sitevisitprovider.dart';
//
// import '../../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
// import 'sitevisit_event.dart';
// import 'sitevisit_state.dart';
//
// class SiteVisitBloc extends Bloc<SiteVisitEvent, SiteVisitState> {
//   SiteVisitBloc({SiteVisitProvider? provider})
//       : _provider = provider ?? SiteVisitProvider(),
//         super(const SiteVisitState()) {
//     on<FetchMySiteVisits>(_onFetchMySiteVisits);
//     on<ShowSiteVisitDetail>(_onShowSiteVisitDetail);
//     on<CreateSiteVisit>(_onCreateSiteVisit);
//     on<UpdateSiteVisit>(_onUpdateSiteVisit);
//     on<DeleteSiteVisit>(_onDeleteSiteVisit);
//     on<ResetSiteVisitActionStatus>(_onResetActionStatus);
//   }
//
//   final SiteVisitProvider _provider;
//
//   Future<void> _onFetchMySiteVisits(
//       FetchMySiteVisits event,
//       Emitter<SiteVisitState> emit,
//       ) async {
//     emit(state.copyWith(isListLoading: true, clearListError: true));
//     final result = await _provider.getMySiteVisits();
//     if (result.success) {
//       emit(state.copyWith(isListLoading: false, myData: result.data, clearListError: true));
//     } else {
//       emit(state.copyWith(isListLoading: false, listError: result.errorMessage));
//     }
//   }
//
//   Future<void> _onShowSiteVisitDetail(
//       ShowSiteVisitDetail event,
//       Emitter<SiteVisitState> emit,
//       ) async {
//     emit(state.copyWith(isDetailLoading: true, clearDetailError: true));
//     final result = await _provider.showSiteVisit(event.request);
//     if (result.success) {
//       emit(state.copyWith(isDetailLoading: false, detail: result.detail, clearDetailError: true));
//     } else {
//       emit(state.copyWith(isDetailLoading: false, detailError: result.errorMessage));
//     }
//   }
//
//   Future<void> _onCreateSiteVisit(
//       CreateSiteVisit event,
//       Emitter<SiteVisitState> emit,
//       ) async {
//     emit(state.copyWith(actionStatus: SiteVisitActionStatus.inProgress, clearActionMessage: true));
//     final result = await _provider.createSiteVisit(event.request);
//     emit(_actionResultToState(result));
//     if (result.success) {
//       // Refresh the dashboard list in the background.
//       add(const FetchMySiteVisits());
//     }
//   }
//
//   Future<void> _onUpdateSiteVisit(
//       UpdateSiteVisit event,
//       Emitter<SiteVisitState> emit,
//       ) async {
//     emit(state.copyWith(actionStatus: SiteVisitActionStatus.inProgress, clearActionMessage: true));
//     final result = await _provider.updateSiteVisit(event.request);
//     emit(_actionResultToState(result));
//     if (result.success) {
//       add(const FetchMySiteVisits());
//       // Keep an already-open detail screen in sync with what was just saved.
//       add(ShowSiteVisitDetail(SiteVisitShowRequestModel(id: event.request.id.toString())));
//     }
//   }
//
//   Future<void> _onDeleteSiteVisit(
//       DeleteSiteVisit event,
//       Emitter<SiteVisitState> emit,
//       ) async {
//     emit(state.copyWith(actionStatus: SiteVisitActionStatus.inProgress, clearActionMessage: true));
//     final result = await _provider.deleteSiteVisit(event.request);
//     emit(_actionResultToState(result));
//     if (result.success) {
//       add(const FetchMySiteVisits());
//     }
//   }
//
//   void _onResetActionStatus(
//       ResetSiteVisitActionStatus event,
//       Emitter<SiteVisitState> emit,
//       ) {
//     emit(state.copyWith(
//       actionStatus: SiteVisitActionStatus.idle,
//       clearActionMessage: true,
//     ));
//   }
//
//   SiteVisitState _actionResultToState(SiteVisitActionResult result) {
//     if (result.success) {
//       return state.copyWith(
//         actionStatus: SiteVisitActionStatus.success,
//         actionMessage: result.message,
//       );
//     }
//     return state.copyWith(
//       actionStatus: SiteVisitActionStatus.failure,
//       actionMessage: result.errorMessage,
//     );
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/fieldstaff_sitevisitprovider.dart';

import '../../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
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

  static const int _perPage = 10;

  Future<void> _onFetchMySiteVisits(
      FetchMySiteVisits event,
      Emitter<SiteVisitState> emit,
      ) async {
    // "Load more" (scroll-triggered): guard against duplicate/late calls
    // and use a lightweight loading flag instead of the full shimmer.
    if (event.loadMore) {
      if (state.isLoadingMore || !state.hasMoreAll) return;
      emit(state.copyWith(isLoadingMore: true, clearListError: true));
    } else {
      // First load or pull-to-refresh — reset back to page 1.
      emit(state.copyWith(isListLoading: true, clearListError: true));
    }

    final result = await _provider.getMySiteVisits(page: event.page, perPage: _perPage);

    if (result.success) {
      final fetchedAll = result.data.all.list;

      final mergedAllList = event.loadMore
          ? [...state.allVisits, ...fetchedAll]
          : fetchedAll;

      // De-dupe defensively in case a page overlaps (e.g. a retry after
      // a new visit was added mid-scroll shifts the underlying pages).
      final dedupedAllList = {
        for (final v in mergedAllList) v.id: v,
      }.values.toList();

      final mergedData = result.data.copyWithAllList(dedupedAllList);

      emit(state.copyWith(
        isListLoading: false,
        isLoadingMore: false,
        clearListError: true,
        myData: mergedData,
        currentPage: event.page,
        // No more pages once we've loaded as many (or more, after
        // de-dupe) items than the server reports as the total.
        hasMoreAll: dedupedAllList.length < result.data.totalVisits,
      ));
    } else {
      emit(state.copyWith(
        isListLoading: false,
        isLoadingMore: false,
        listError: result.errorMessage,
      ));
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
      // Refresh the dashboard list (back to page 1) in the background.
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
    ));
  }

  SiteVisitState _actionResultToState(SiteVisitActionResult result) {
    if (result.success) {
      return state.copyWith(
        actionStatus: SiteVisitActionStatus.success,
        actionMessage: result.message,
      );
    }
    return state.copyWith(
      actionStatus: SiteVisitActionStatus.failure,
      actionMessage: result.errorMessage,
    );
  }
}