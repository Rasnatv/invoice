// import 'package:equatable/equatable.dart';
//
// import '../../../models/owner_reportmodel/activecontractormodel.dart';
// import '../../../models/owner_reportmodel/contractorperformancereportmodel.dart';
// import '../../../models/owner_reportmodel/salesman_performancemodel.dart';
// import '../../../models/salesmanmodels/activeslaesman_model.dart';
//
//
// enum LoadStatus { initial, loading, success, failure }
//
// class OwnerReportsState extends Equatable {
//   const OwnerReportsState({
//     this.activeSalesmenStatus = LoadStatus.initial,
//     this.activeSalesmen = const [],
//     this.activeSalesmenError,
//     this.activeContractorsStatus = LoadStatus.initial,
//     this.activeContractors = const [],
//     this.activeContractorsError,
//     this.salesmanReportStatus = LoadStatus.initial,
//     this.salesmanReport,
//     this.salesmanReportError,
//     this.contractorReportStatus = LoadStatus.initial,
//     this.contractorReport,
//     this.contractorReportError,
//   });
//
//   factory OwnerReportsState.initial() => const OwnerReportsState();
//
//   final LoadStatus activeSalesmenStatus;
//   final List<ActiveSalesmanModel> activeSalesmen;
//   final String? activeSalesmenError;
//
//   final LoadStatus activeContractorsStatus;
//   final List<ActiveContractorModel> activeContractors;
//   final String? activeContractorsError;
//
//   final LoadStatus salesmanReportStatus;
//   final SalesmanPerformanceReportModel? salesmanReport;
//   final String? salesmanReportError;
//
//   final LoadStatus contractorReportStatus;
//   final ContractorPerformanceReportModel? contractorReport;
//   final String? contractorReportError;
//
//   OwnerReportsState copyWith({
//     LoadStatus? activeSalesmenStatus,
//     List<ActiveSalesmanModel>? activeSalesmen,
//     String? activeSalesmenError,
//     bool clearActiveSalesmenError = false,
//     LoadStatus? activeContractorsStatus,
//     List<ActiveContractorModel>? activeContractors,
//     String? activeContractorsError,
//     bool clearActiveContractorsError = false,
//     LoadStatus? salesmanReportStatus,
//     SalesmanPerformanceReportModel? salesmanReport,
//     String? salesmanReportError,
//     bool clearSalesmanReportError = false,
//     LoadStatus? contractorReportStatus,
//     ContractorPerformanceReportModel? contractorReport,
//     String? contractorReportError,
//     bool clearContractorReportError = false,
//   }) {
//     return OwnerReportsState(
//       activeSalesmenStatus: activeSalesmenStatus ?? this.activeSalesmenStatus,
//       activeSalesmen: activeSalesmen ?? this.activeSalesmen,
//       activeSalesmenError:
//       clearActiveSalesmenError ? null : (activeSalesmenError ?? this.activeSalesmenError),
//       activeContractorsStatus: activeContractorsStatus ?? this.activeContractorsStatus,
//       activeContractors: activeContractors ?? this.activeContractors,
//       activeContractorsError:
//       clearActiveContractorsError ? null : (activeContractorsError ?? this.activeContractorsError),
//       salesmanReportStatus: salesmanReportStatus ?? this.salesmanReportStatus,
//       salesmanReport: salesmanReport ?? this.salesmanReport,
//       salesmanReportError:
//       clearSalesmanReportError ? null : (salesmanReportError ?? this.salesmanReportError),
//       contractorReportStatus: contractorReportStatus ?? this.contractorReportStatus,
//       contractorReport: contractorReport ?? this.contractorReport,
//       contractorReportError:
//       clearContractorReportError ? null : (contractorReportError ?? this.contractorReportError),
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     activeSalesmenStatus,
//     activeSalesmen,
//     activeSalesmenError,
//     activeContractorsStatus,
//     activeContractors,
//     activeContractorsError,
//     salesmanReportStatus,
//     salesmanReport,
//     salesmanReportError,
//     contractorReportStatus,
//     contractorReport,
//     contractorReportError,
//   ];
// }
import 'package:equatable/equatable.dart';

import '../../../models/owner_reportmodel/activecontractormodel.dart';
import '../../../models/owner_reportmodel/contractorperformancereportmodel.dart';
import '../../../models/owner_reportmodel/reportentrymodel.dart';
import '../../../models/owner_reportmodel/salesman_performancemodel.dart';
import '../../../models/salesmanmodels/activeslaesman_model.dart';

enum LoadStatus { initial, loading, success, failure }

class OwnerReportsState extends Equatable {
  const OwnerReportsState({
    this.activeSalesmenStatus = LoadStatus.initial,
    this.activeSalesmen = const [],
    this.activeSalesmenError,
    this.activeContractorsStatus = LoadStatus.initial,
    this.activeContractors = const [],
    this.activeContractorsError,
    this.salesmanReportStatus = LoadStatus.initial,
    this.salesmanReport,
    this.salesmanReportError,
    this.salesmanQuotations = const [],
    this.salesmanEstimates = const [],
    this.salesmanPage = 1,
    this.salesmanHasMore = false,
    this.salesmanLoadingMore = false,
    this.contractorReportStatus = LoadStatus.initial,
    this.contractorReport,
    this.contractorReportError,
    this.contractorQuotations = const [],
    this.contractorEstimates = const [],
    this.contractorPage = 1,
    this.contractorHasMore = false,
    this.contractorLoadingMore = false,
  });

  factory OwnerReportsState.initial() => const OwnerReportsState();

  final LoadStatus activeSalesmenStatus;
  final List<ActiveSalesmanModel> activeSalesmen;
  final String? activeSalesmenError;

  final LoadStatus activeContractorsStatus;
  final List<ActiveContractorModel> activeContractors;
  final String? activeContractorsError;

  final LoadStatus salesmanReportStatus;
  final SalesmanPerformanceReportModel? salesmanReport;
  final String? salesmanReportError;
  final List<ReportEntryModel> salesmanQuotations;
  final List<ReportEntryModel> salesmanEstimates;
  final int salesmanPage;
  final bool salesmanHasMore;
  final bool salesmanLoadingMore;

  final LoadStatus contractorReportStatus;
  final ContractorPerformanceReportModel? contractorReport;
  final String? contractorReportError;
  final List<ReportEntryModel> contractorQuotations;
  final List<ReportEntryModel> contractorEstimates;
  final int contractorPage;
  final bool contractorHasMore;
  final bool contractorLoadingMore;

  OwnerReportsState copyWith({
    LoadStatus? activeSalesmenStatus,
    List<ActiveSalesmanModel>? activeSalesmen,
    String? activeSalesmenError,
    bool clearActiveSalesmenError = false,
    LoadStatus? activeContractorsStatus,
    List<ActiveContractorModel>? activeContractors,
    String? activeContractorsError,
    bool clearActiveContractorsError = false,
    LoadStatus? salesmanReportStatus,
    SalesmanPerformanceReportModel? salesmanReport,
    String? salesmanReportError,
    bool clearSalesmanReportError = false,
    List<ReportEntryModel>? salesmanQuotations,
    List<ReportEntryModel>? salesmanEstimates,
    int? salesmanPage,
    bool? salesmanHasMore,
    bool? salesmanLoadingMore,
    LoadStatus? contractorReportStatus,
    ContractorPerformanceReportModel? contractorReport,
    String? contractorReportError,
    bool clearContractorReportError = false,
    List<ReportEntryModel>? contractorQuotations,
    List<ReportEntryModel>? contractorEstimates,
    int? contractorPage,
    bool? contractorHasMore,
    bool? contractorLoadingMore,
  }) {
    return OwnerReportsState(
      activeSalesmenStatus: activeSalesmenStatus ?? this.activeSalesmenStatus,
      activeSalesmen: activeSalesmen ?? this.activeSalesmen,
      activeSalesmenError: clearActiveSalesmenError
          ? null
          : (activeSalesmenError ?? this.activeSalesmenError),
      activeContractorsStatus:
      activeContractorsStatus ?? this.activeContractorsStatus,
      activeContractors: activeContractors ?? this.activeContractors,
      activeContractorsError: clearActiveContractorsError
          ? null
          : (activeContractorsError ?? this.activeContractorsError),
      salesmanReportStatus: salesmanReportStatus ?? this.salesmanReportStatus,
      salesmanReport: salesmanReport ?? this.salesmanReport,
      salesmanReportError: clearSalesmanReportError
          ? null
          : (salesmanReportError ?? this.salesmanReportError),
      salesmanQuotations: salesmanQuotations ?? this.salesmanQuotations,
      salesmanEstimates: salesmanEstimates ?? this.salesmanEstimates,
      salesmanPage: salesmanPage ?? this.salesmanPage,
      salesmanHasMore: salesmanHasMore ?? this.salesmanHasMore,
      salesmanLoadingMore: salesmanLoadingMore ?? this.salesmanLoadingMore,
      contractorReportStatus:
      contractorReportStatus ?? this.contractorReportStatus,
      contractorReport: contractorReport ?? this.contractorReport,
      contractorReportError: clearContractorReportError
          ? null
          : (contractorReportError ?? this.contractorReportError),
      contractorQuotations: contractorQuotations ?? this.contractorQuotations,
      contractorEstimates: contractorEstimates ?? this.contractorEstimates,
      contractorPage: contractorPage ?? this.contractorPage,
      contractorHasMore: contractorHasMore ?? this.contractorHasMore,
      contractorLoadingMore:
      contractorLoadingMore ?? this.contractorLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    activeSalesmenStatus,
    activeSalesmen,
    activeSalesmenError,
    activeContractorsStatus,
    activeContractors,
    activeContractorsError,
    salesmanReportStatus,
    salesmanReport,
    salesmanReportError,
    salesmanQuotations,
    salesmanEstimates,
    salesmanPage,
    salesmanHasMore,
    salesmanLoadingMore,
    contractorReportStatus,
    contractorReport,
    contractorReportError,
    contractorQuotations,
    contractorEstimates,
    contractorPage,
    contractorHasMore,
    contractorLoadingMore,
  ];
}