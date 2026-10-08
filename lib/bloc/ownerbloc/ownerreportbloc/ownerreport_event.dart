// import 'package:equatable/equatable.dart';
//
// abstract class OwnerReportsEvent extends Equatable {
//   const OwnerReportsEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// /// Loads the salesman dropdown list (GET /salesmen/active).
// class newLoadActiveSalesmen extends OwnerReportsEvent {
//   const newLoadActiveSalesmen();
// }
//
// /// Loads the contractor dropdown list (GET /reports/contractors/active).
// class LoadActiveContractors extends OwnerReportsEvent {
//   const LoadActiveContractors();
// }
//
// /// Loads a single salesman's performance report.
// class LoadSalesmanReport extends OwnerReportsEvent {
//   const LoadSalesmanReport({
//     required this.salesmanId,
//     required this.fromDate,
//     required this.toDate,
//   });
//
//   final String salesmanId;
//   final String fromDate; // yyyy-MM-dd
//   final String toDate; // yyyy-MM-dd
//
//   @override
//   List<Object?> get props => [salesmanId, fromDate, toDate];
// }
//
// /// Loads a single contractor's performance report.
// class LoadContractorReport extends OwnerReportsEvent {
//   const LoadContractorReport({
//     required this.contractorId,
//     required this.fromDate,
//     required this.toDate,
//   });
//
//   final String contractorId;
//   final String fromDate; // yyyy-MM-dd
//   final String toDate; // yyyy-MM-dd
//
//   @override
//   List<Object?> get props => [contractorId, fromDate, toDate];
// }
import 'package:equatable/equatable.dart';

abstract class OwnerReportsEvent extends Equatable {
  const OwnerReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the salesman dropdown list (GET /salesmen/active).
class newLoadActiveSalesmen extends OwnerReportsEvent {
  const newLoadActiveSalesmen();
}

/// Loads the contractor dropdown list (GET /reports/contractors/active).
class LoadActiveContractors extends OwnerReportsEvent {
  const LoadActiveContractors();
}

/// Loads a single salesman's performance report (page 1).
class LoadSalesmanReport extends OwnerReportsEvent {
  const LoadSalesmanReport({
    required this.salesmanId,
    required this.fromDate,
    required this.toDate,
  });

  final String salesmanId;
  final String fromDate; // yyyy-MM-dd
  final String toDate; // yyyy-MM-dd

  @override
  List<Object?> get props => [salesmanId, fromDate, toDate];
}

/// Loads the next page of the current salesman report.
class LoadMoreSalesmanReport extends OwnerReportsEvent {
  const LoadMoreSalesmanReport();
}

/// Loads a single contractor's performance report (page 1).
class LoadContractorReport extends OwnerReportsEvent {
  const LoadContractorReport({
    required this.contractorId,
    required this.fromDate,
    required this.toDate,
  });

  final String contractorId;
  final String fromDate; // yyyy-MM-dd
  final String toDate; // yyyy-MM-dd

  @override
  List<Object?> get props => [contractorId, fromDate, toDate];
}

/// Loads the next page of the current contractor report.
class LoadMoreContractorReport extends OwnerReportsEvent {
  const LoadMoreContractorReport();
}