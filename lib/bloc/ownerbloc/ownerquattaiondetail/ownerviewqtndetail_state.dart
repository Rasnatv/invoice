import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';

enum OwnerQuotationDetailStatus { initial, loading, success, failure }

enum OwnerQuotationApproveStatus { idle, inProgress, success, failure }

/// Sentinel used by [OwnerQuotationDetailState.copyWith] so nullable
/// fields (errors, the loaded detail, etc.) can be explicitly reset to
/// null instead of always falling back to "keep the old value".
class _NoUpdate {
  const _NoUpdate();
}

const Object _noUpdate = _NoUpdate();

class OwnerQuotationDetailState extends Equatable {
  // ---- detail (POST /quotations/show) ----
  final OwnerQuotationDetailStatus detailStatus;
  final QuotationDetailModel? detail;
  final String? detailError;

  // ---- approve (POST /quotations/approve) ----
  final OwnerQuotationApproveStatus approveStatus;
  final String? approveError;
  final String? approveMessage;

  const OwnerQuotationDetailState({
    this.detailStatus = OwnerQuotationDetailStatus.initial,
    this.detail,
    this.detailError,
    this.approveStatus = OwnerQuotationApproveStatus.idle,
    this.approveError,
    this.approveMessage,
  });

  bool get isApproved => (detail?.status.toLowerCase() ?? '') == 'approved';

  OwnerQuotationDetailState copyWith({
    OwnerQuotationDetailStatus? detailStatus,
    Object? detail = _noUpdate,
    Object? detailError = _noUpdate,
    OwnerQuotationApproveStatus? approveStatus,
    Object? approveError = _noUpdate,
    Object? approveMessage = _noUpdate,
  }) {
    return OwnerQuotationDetailState(
      detailStatus: detailStatus ?? this.detailStatus,
      detail: identical(detail, _noUpdate) ? this.detail : detail as QuotationDetailModel?,
      detailError: identical(detailError, _noUpdate) ? this.detailError : detailError as String?,
      approveStatus: approveStatus ?? this.approveStatus,
      approveError: identical(approveError, _noUpdate) ? this.approveError : approveError as String?,
      approveMessage:
      identical(approveMessage, _noUpdate) ? this.approveMessage : approveMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    detailStatus,
    detail,
    detailError,
    approveStatus,
    approveError,
    approveMessage,
  ];
}