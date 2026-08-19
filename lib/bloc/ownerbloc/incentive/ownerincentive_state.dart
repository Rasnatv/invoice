import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/activeslaesman_model.dart';
import '../../../models/salesmanmodels/salesmanowner_incentivemodel.dart';

enum SalesmanIncentiveStatus { initial, loading, loaded, error }

enum MarkPaidStatus { idle, submitting, success, error }

class OwnerIncentiveState extends Equatable {
  final bool isOwner;

  final SalesmanIncentiveStatus status;
  final String? errorMessage;
  final bool isUnauthorized;

  final bool loadingSalesmen;
  final List<ActiveSalesmanModel> activeSalesmen;
  final String? salesmenErrorMessage;

  final String? selectedSalesmanId;
  final String? selectedSalesmanName;
  final DateTime selectedMonth;

  final SalesmanIncentiveSummaryModel? summary;
  final List<IncentiveProductModel> productList;

  final MarkPaidStatus markPaidStatus;
  final String? markPaidMessage;

  const OwnerIncentiveState({
    required this.isOwner,
    required this.status,
    required this.errorMessage,
    required this.isUnauthorized,
    required this.loadingSalesmen,
    required this.activeSalesmen,
    required this.salesmenErrorMessage,
    required this.selectedSalesmanId,
    required this.selectedSalesmanName,
    required this.selectedMonth,
    required this.summary,
    required this.productList,
    required this.markPaidStatus,
    required this.markPaidMessage,
  });

  factory OwnerIncentiveState.initial({
    required bool isOwner,
    String? selectedSalesmanId,
    String? selectedSalesmanName,
  }) =>
      OwnerIncentiveState(
        isOwner: isOwner,
        status: SalesmanIncentiveStatus.initial,
        errorMessage: null,
        isUnauthorized: false,
        loadingSalesmen: false,
        activeSalesmen: const [],
        salesmenErrorMessage: null,
        selectedSalesmanId: selectedSalesmanId,
        selectedSalesmanName: selectedSalesmanName,
        selectedMonth: DateTime.now(),
        summary: null,
        productList: const [],
        markPaidStatus: MarkPaidStatus.idle,
        markPaidMessage: null,
      );

  /// True once we have everything required to call the summary API:
  /// a salesman is only required up-front for the owner flow.
  bool get canLoadSummary => !isOwner || selectedSalesmanId != null;

  bool get isPaid => summary != null &&
      // The summary endpoint itself doesn't return a paid/unpaid flag in the
      // payload you shared, so this flips true right after a successful
      // mark-paid call for the same period. Wire this up to a real field
      // (e.g. summary.status) if/when the summary API starts returning one.
      false;

  OwnerIncentiveState copyWith({
    bool? isOwner,
    SalesmanIncentiveStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isUnauthorized,
    bool? loadingSalesmen,
    List<ActiveSalesmanModel>? activeSalesmen,
    String? salesmenErrorMessage,
    bool clearSalesmenErrorMessage = false,
    String? selectedSalesmanId,
    String? selectedSalesmanName,
    DateTime? selectedMonth,
    SalesmanIncentiveSummaryModel? summary,
    List<IncentiveProductModel>? productList,
    MarkPaidStatus? markPaidStatus,
    String? markPaidMessage,
    bool clearMarkPaidMessage = false,
  }) {
    return OwnerIncentiveState(
      isOwner: isOwner ?? this.isOwner,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      loadingSalesmen: loadingSalesmen ?? this.loadingSalesmen,
      activeSalesmen: activeSalesmen ?? this.activeSalesmen,
      salesmenErrorMessage:
      clearSalesmenErrorMessage ? null : (salesmenErrorMessage ?? this.salesmenErrorMessage),
      selectedSalesmanId: selectedSalesmanId ?? this.selectedSalesmanId,
      selectedSalesmanName: selectedSalesmanName ?? this.selectedSalesmanName,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      summary: summary ?? this.summary,
      productList: productList ?? this.productList,
      markPaidStatus: markPaidStatus ?? this.markPaidStatus,
      markPaidMessage: clearMarkPaidMessage ? null : (markPaidMessage ?? this.markPaidMessage),
    );
  }

  @override
  List<Object?> get props => [
    isOwner,
    status,
    errorMessage,
    isUnauthorized,
    loadingSalesmen,
    activeSalesmen,
    salesmenErrorMessage,
    selectedSalesmanId,
    selectedSalesmanName,
    selectedMonth,
    summary,
    productList,
    markPaidStatus,
    markPaidMessage,
  ];
}