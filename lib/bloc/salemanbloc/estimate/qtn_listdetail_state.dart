import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../../models/salesmanmodels/quotationlistmodel.dart';

enum QuotationLoadStatus { initial, loading, success, failure }

enum QuotationActionStatus { idle, inProgress, success, failure }

/// Sentinel used by [SalesmanQuotationState.copyWith] so nullable fields
/// (errors, the loaded detail, etc.) can be explicitly reset to null
/// instead of always falling back to "keep the old value".
class _NoUpdate {
  const _NoUpdate();
}

const Object _noUpdate = _NoUpdate();

class SalesmanQuotationState extends Equatable {
  // ---- list (GET /quotations/my) ----
  final QuotationLoadStatus listStatus;
  final List<QuotationListItem> list;
  final String? listError;

  // ---- detail (POST /quotations/show) ----
  final QuotationLoadStatus detailStatus;
  final QuotationDetailModel? detail;
  final String? detailError;

  // ---- delete (POST /quotations/delete) ----
  final QuotationActionStatus deleteStatus;
  final String? deletingId;
  final String? deleteError;

  // ---- submit for approval (POST /quotations/submit) / update (POST /quotations/update) ----
  final QuotationActionStatus submitStatus;
  final String? submittingId;
  final String? submitError;
  final String? submitMessage;

  const SalesmanQuotationState({
    this.listStatus = QuotationLoadStatus.initial,
    this.list = const [],
    this.listError,
    this.detailStatus = QuotationLoadStatus.initial,
    this.detail,
    this.detailError,
    this.deleteStatus = QuotationActionStatus.idle,
    this.deletingId,
    this.deleteError,
    this.submitStatus = QuotationActionStatus.idle,
    this.submittingId,
    this.submitError,
    this.submitMessage,
  });

  SalesmanQuotationState copyWith({
    QuotationLoadStatus? listStatus,
    List<QuotationListItem>? list,
    Object? listError = _noUpdate,
    QuotationLoadStatus? detailStatus,
    Object? detail = _noUpdate,
    Object? detailError = _noUpdate,
    QuotationActionStatus? deleteStatus,
    Object? deletingId = _noUpdate,
    Object? deleteError = _noUpdate,
    QuotationActionStatus? submitStatus,
    Object? submittingId = _noUpdate,
    Object? submitError = _noUpdate,
    Object? submitMessage = _noUpdate,
  }) {
    return SalesmanQuotationState(
      listStatus: listStatus ?? this.listStatus,
      list: list ?? this.list,
      listError: identical(listError, _noUpdate) ? this.listError : listError as String?,
      detailStatus: detailStatus ?? this.detailStatus,
      detail: identical(detail, _noUpdate) ? this.detail : detail as QuotationDetailModel?,
      detailError: identical(detailError, _noUpdate) ? this.detailError : detailError as String?,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deletingId: identical(deletingId, _noUpdate) ? this.deletingId : deletingId as String?,
      deleteError: identical(deleteError, _noUpdate) ? this.deleteError : deleteError as String?,
      submitStatus: submitStatus ?? this.submitStatus,
      submittingId: identical(submittingId, _noUpdate) ? this.submittingId : submittingId as String?,
      submitError: identical(submitError, _noUpdate) ? this.submitError : submitError as String?,
      submitMessage: identical(submitMessage, _noUpdate) ? this.submitMessage : submitMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    list,
    listError,
    detailStatus,
    detail,
    detailError,
    deleteStatus,
    deletingId,
    deleteError,
    submitStatus,
    submittingId,
    submitError,
    submitMessage,
  ];
}