import 'package:equatable/equatable.dart';

import '../../../models/owner_reportmodel/activecontractormodel.dart';
import '../../../models/owner_reportmodel/contractorperformancereportmodel.dart';
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
    this.contractorReportStatus = LoadStatus.initial,
    this.contractorReport,
    this.contractorReportError,
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

  final LoadStatus contractorReportStatus;
  final ContractorPerformanceReportModel? contractorReport;
  final String? contractorReportError;

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
    LoadStatus? contractorReportStatus,
    ContractorPerformanceReportModel? contractorReport,
    String? contractorReportError,
    bool clearContractorReportError = false,
  }) {
    return OwnerReportsState(
      activeSalesmenStatus: activeSalesmenStatus ?? this.activeSalesmenStatus,
      activeSalesmen: activeSalesmen ?? this.activeSalesmen,
      activeSalesmenError:
      clearActiveSalesmenError ? null : (activeSalesmenError ?? this.activeSalesmenError),
      activeContractorsStatus: activeContractorsStatus ?? this.activeContractorsStatus,
      activeContractors: activeContractors ?? this.activeContractors,
      activeContractorsError:
      clearActiveContractorsError ? null : (activeContractorsError ?? this.activeContractorsError),
      salesmanReportStatus: salesmanReportStatus ?? this.salesmanReportStatus,
      salesmanReport: salesmanReport ?? this.salesmanReport,
      salesmanReportError:
      clearSalesmanReportError ? null : (salesmanReportError ?? this.salesmanReportError),
      contractorReportStatus: contractorReportStatus ?? this.contractorReportStatus,
      contractorReport: contractorReport ?? this.contractorReport,
      contractorReportError:
      clearContractorReportError ? null : (contractorReportError ?? this.contractorReportError),
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
    contractorReportStatus,
    contractorReport,
    contractorReportError,
  ];
}