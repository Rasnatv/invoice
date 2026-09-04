// import 'package:flutter/foundation.dart';
// import '../../../models/owner_reportmodel/incentivereportmodel.dart';
//
//
// @immutable
// abstract class IncentiveReportState {
//   const IncentiveReportState();
// }
//
// class IncentiveReportInitial extends IncentiveReportState {
//   const IncentiveReportInitial();
// }
//
// class IncentiveReportLoading extends IncentiveReportState {
//   /// true only while loading page 1 with nothing on screen yet.
//   final bool isFirstLoad;
//   const IncentiveReportLoading({this.isFirstLoad = true});
// }
//
// class IncentiveReportLoaded extends IncentiveReportState {
//   final IncentiveSummaryModel summary;
//   final List<IncentiveListItemModel> items;
//   final int currentPage;
//   final bool hasReachedMax;
//   final bool isLoadingMore;
//
//   const IncentiveReportLoaded({
//     required this.summary,
//     required this.items,
//     required this.currentPage,
//     this.hasReachedMax = false,
//     this.isLoadingMore = false,
//   });
//
//   IncentiveReportLoaded copyWith({
//     IncentiveSummaryModel? summary,
//     List<IncentiveListItemModel>? items,
//     int? currentPage,
//     bool? hasReachedMax,
//     bool? isLoadingMore,
//   }) {
//     return IncentiveReportLoaded(
//       summary: summary ?? this.summary,
//       items: items ?? this.items,
//       currentPage: currentPage ?? this.currentPage,
//       hasReachedMax: hasReachedMax ?? this.hasReachedMax,
//       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
//     );
//   }
// }
//
// class IncentiveReportError extends IncentiveReportState {
//   final String message;
//   final bool isUnauthorized;
//   const IncentiveReportError(this.message, {this.isUnauthorized = false});
// }
import 'package:flutter/foundation.dart';
import '../../../models/owner_reportmodel/incentivereportmodel.dart';


@immutable
abstract class IncentiveReportState {
  const IncentiveReportState();
}

class IncentiveReportInitial extends IncentiveReportState {
  const IncentiveReportInitial();
}

class IncentiveReportLoading extends IncentiveReportState {
  /// true only while loading page 1 with nothing on screen yet.
  final bool isFirstLoad;
  const IncentiveReportLoading({this.isFirstLoad = true});
}

class IncentiveReportLoaded extends IncentiveReportState {
  final IncentiveSummaryModel summary;
  final List<IncentiveListItemModel> items;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const IncentiveReportLoaded({
    required this.summary,
    required this.items,
    required this.currentPage,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  IncentiveReportLoaded copyWith({
    IncentiveSummaryModel? summary,
    List<IncentiveListItemModel>? items,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return IncentiveReportLoaded(
      summary: summary ?? this.summary,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class IncentiveReportError extends IncentiveReportState {
  final String? message;
  const IncentiveReportError(this.message);
}