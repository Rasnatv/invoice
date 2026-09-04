// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../Apiprovider/ownerreportprovider.dart';
// import 'ownerreport_event.dart';
// import 'ownerreport_state.dart';
//
//
// class OwnerReportsBloc extends Bloc<OwnerReportsEvent, OwnerReportsState> {
//   OwnerReportsBloc({OwnerReportsProvider? provider})
//       : _provider = provider ?? OwnerReportsProvider(),
//         super(OwnerReportsState.initial()) {
//     on<newLoadActiveSalesmen>(_onLoadActiveSalesmen);
//     on<LoadActiveContractors>(_onLoadActiveContractors);
//     on<LoadSalesmanReport>(_onLoadSalesmanReport);
//     on<LoadContractorReport>(_onLoadContractorReport);
//   }
//
//   final OwnerReportsProvider _provider;
//
//   Future<void> _onLoadActiveSalesmen(
//       newLoadActiveSalesmen event,
//       Emitter<OwnerReportsState> emit,
//       ) async {
//     emit(state.copyWith(
//       activeSalesmenStatus: LoadStatus.loading,
//       clearActiveSalesmenError: true,
//     ));
//     final result = await _provider.getActiveSalesmen();
//     if (result.success) {
//       emit(state.copyWith(
//         activeSalesmenStatus: LoadStatus.success,
//         activeSalesmen: result.salesmen,
//       ));
//     } else {
//       emit(state.copyWith(
//         activeSalesmenStatus: LoadStatus.failure,
//         activeSalesmenError: result.errorMessage ?? 'Failed to load salesmen.',
//       ));
//     }
//   }
//
//   Future<void> _onLoadActiveContractors(
//       LoadActiveContractors event,
//       Emitter<OwnerReportsState> emit,
//       ) async {
//     emit(state.copyWith(
//       activeContractorsStatus: LoadStatus.loading,
//       clearActiveContractorsError: true,
//     ));
//     final result = await _provider.getActiveContractors();
//     if (result.success) {
//       emit(state.copyWith(
//         activeContractorsStatus: LoadStatus.success,
//         activeContractors: result.contractors,
//       ));
//     } else {
//       emit(state.copyWith(
//         activeContractorsStatus: LoadStatus.failure,
//         activeContractorsError: result.errorMessage ?? 'Failed to load contractors.',
//       ));
//     }
//   }
//
//   Future<void> _onLoadSalesmanReport(
//       LoadSalesmanReport event,
//       Emitter<OwnerReportsState> emit,
//       ) async {
//     emit(state.copyWith(
//       salesmanReportStatus: LoadStatus.loading,
//       clearSalesmanReportError: true,
//     ));
//     final result = await _provider.getSalesmanPerformanceReport(
//       salesmanId: event.salesmanId,
//       fromDate: event.fromDate,
//       toDate: event.toDate,
//     );
//     if (result.success) {
//       emit(state.copyWith(
//         salesmanReportStatus: LoadStatus.success,
//         salesmanReport: result.report,
//       ));
//     } else {
//       emit(state.copyWith(
//         salesmanReportStatus: LoadStatus.failure,
//         salesmanReportError: result.errorMessage ?? 'Failed to load salesman report.',
//       ));
//     }
//   }
//
//   Future<void> _onLoadContractorReport(
//       LoadContractorReport event,
//       Emitter<OwnerReportsState> emit,
//       ) async {
//     emit(state.copyWith(
//       contractorReportStatus: LoadStatus.loading,
//       clearContractorReportError: true,
//     ));
//     final result = await _provider.getContractorPerformanceReport(
//       contractorId: event.contractorId,
//       fromDate: event.fromDate,
//       toDate: event.toDate,
//     );
//     if (result.success) {
//       emit(state.copyWith(
//         contractorReportStatus: LoadStatus.success,
//         contractorReport: result.report,
//       ));
//     } else {
//       emit(state.copyWith(
//         contractorReportStatus: LoadStatus.failure,
//         contractorReportError: result.errorMessage ?? 'Failed to load contractor report.',
//       ));
//     }
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/ownerreportprovider.dart';
import 'ownerreport_event.dart';
import 'ownerreport_state.dart';


class OwnerReportsBloc extends Bloc<OwnerReportsEvent, OwnerReportsState> {
  OwnerReportsBloc({OwnerReportsProvider? provider})
      : _provider = provider ?? OwnerReportsProvider(),
        super(OwnerReportsState.initial()) {
    on<newLoadActiveSalesmen>(_onLoadActiveSalesmen);
    on<LoadActiveContractors>(_onLoadActiveContractors);
    on<LoadSalesmanReport>(_onLoadSalesmanReport);
    on<LoadContractorReport>(_onLoadContractorReport);
  }

  final OwnerReportsProvider _provider;

  Future<void> _onLoadActiveSalesmen(
      newLoadActiveSalesmen event,
      Emitter<OwnerReportsState> emit,
      ) async {
    emit(state.copyWith(
      activeSalesmenStatus: LoadStatus.loading,
      clearActiveSalesmenError: true,
    ));
    final result = await _provider.getActiveSalesmen();
    if (result.success) {
      emit(state.copyWith(
        activeSalesmenStatus: LoadStatus.success,
        activeSalesmen: result.salesmen,
      ));
    } else {
      emit(state.copyWith(
        activeSalesmenStatus: LoadStatus.failure,
        activeSalesmenError: result.errorMessage,
      ));
    }
  }

  Future<void> _onLoadActiveContractors(
      LoadActiveContractors event,
      Emitter<OwnerReportsState> emit,
      ) async {
    emit(state.copyWith(
      activeContractorsStatus: LoadStatus.loading,
      clearActiveContractorsError: true,
    ));
    final result = await _provider.getActiveContractors();
    if (result.success) {
      emit(state.copyWith(
        activeContractorsStatus: LoadStatus.success,
        activeContractors: result.contractors,
      ));
    } else {
      emit(state.copyWith(
        activeContractorsStatus: LoadStatus.failure,
        activeContractorsError: result.errorMessage,
      ));
    }
  }

  Future<void> _onLoadSalesmanReport(
      LoadSalesmanReport event,
      Emitter<OwnerReportsState> emit,
      ) async {
    emit(state.copyWith(
      salesmanReportStatus: LoadStatus.loading,
      clearSalesmanReportError: true,
    ));
    final result = await _provider.getSalesmanPerformanceReport(
      salesmanId: event.salesmanId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    if (result.success) {
      emit(state.copyWith(
        salesmanReportStatus: LoadStatus.success,
        salesmanReport: result.report,
      ));
    } else {
      emit(state.copyWith(
        salesmanReportStatus: LoadStatus.failure,
        salesmanReportError: result.errorMessage,
      ));
    }
  }

  Future<void> _onLoadContractorReport(
      LoadContractorReport event,
      Emitter<OwnerReportsState> emit,
      ) async {
    emit(state.copyWith(
      contractorReportStatus: LoadStatus.loading,
      clearContractorReportError: true,
    ));
    final result = await _provider.getContractorPerformanceReport(
      contractorId: event.contractorId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    if (result.success) {
      emit(state.copyWith(
        contractorReportStatus: LoadStatus.success,
        contractorReport: result.report,
      ));
    } else {
      emit(state.copyWith(
        contractorReportStatus: LoadStatus.failure,
        contractorReportError: result.errorMessage,
      ));
    }
  }
}