// import 'package:equatable/equatable.dart';
// import '../../../models/owner_reportmodel/estimatereportmodel.dart';
//
// abstract class EstimateReportState extends Equatable {
//   const EstimateReportState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class EstimateReportInitial extends EstimateReportState {
//   const EstimateReportInitial();
// }
//
// class EstimateReportLoading extends EstimateReportState {
//   const EstimateReportLoading();
// }
//
// /// `data.summary` and `data.list` come straight from the API response —
// /// the UI just renders them, it never re-filters or re-labels rows itself.
// class EstimateReportLoaded extends EstimateReportState {
//   const EstimateReportLoaded({
//     required this.data,
//     required this.type,
//     required this.personName,
//     required this.fromDate,
//     required this.toDate,
//     required this.status,
//   });
//
//   final EstimateReportDataModel data;
//   final String type;
//   final String personName;
//   final DateTime fromDate;
//   final DateTime toDate;
//   final String status;
//
//   @override
//   List<Object?> get props => [data, type, personName, fromDate, toDate, status];
// }
//
// class EstimateReportError extends EstimateReportState {
//   const EstimateReportError(this.message);
//
//   final String message;
//
//   @override
//   List<Object?> get props => [message];
// }
//
// class EstimateReportUnauthorized extends EstimateReportState {
//   const EstimateReportUnauthorized();
// }
import 'package:equatable/equatable.dart';
import '../../../models/owner_reportmodel/estimatereportmodel.dart';

abstract class EstimateReportState extends Equatable {
  const EstimateReportState();

  @override
  List<Object?> get props => [];
}

class EstimateReportInitial extends EstimateReportState {
  const EstimateReportInitial();
}

class EstimateReportLoading extends EstimateReportState {
  const EstimateReportLoading();
}

/// `data.summary` and `data.list` come straight from the API response —
/// the UI just renders them, it never re-filters or re-labels rows itself.
class EstimateReportLoaded extends EstimateReportState {
  const EstimateReportLoaded({
    required this.data,
    required this.type,
    required this.personName,
    required this.fromDate,
    required this.toDate,
    required this.status,
  });

  final EstimateReportDataModel data;
  final String type;
  final String personName;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;

  @override
  List<Object?> get props => [data, type, personName, fromDate, toDate, status];
}

class EstimateReportError extends EstimateReportState {
  const EstimateReportError(this.message);

  final String? message;

  @override
  List<Object?> get props => [message];
}