import '../../models/owner_models/owner_viewquotationmodel.dart';
import 'owner_viewquotation_event.dart';

abstract class QuotationState {
  const QuotationState();
}

class QuotationInitial extends QuotationState {
  const QuotationInitial();
}

class QuotationLoading extends QuotationState {
  const QuotationLoading();
}

class QuotationLoaded extends QuotationState {
  final List<OwnerviewQuotationModel> myQuotations;
  final List<OwnerviewQuotationModel> salesmanQuotations;
  final QuotationFilterType filter;
  final String searchQuery;
  final int currentPage;
  final int perPage;
  final bool hasMore;
  final bool isLoadingMore;

  const QuotationLoaded({
    required this.myQuotations,
    required this.salesmanQuotations,
    this.filter = QuotationFilterType.mine,
    this.searchQuery = '',
    this.currentPage = 1,
    this.perPage = 10,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  /// The list the UI should actually render, after filter + search.
  List<OwnerviewQuotationModel> get visibleQuotations {
    final source = filter == QuotationFilterType.mine ? myQuotations : salesmanQuotations;
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((q) {
      return q.customerName.toLowerCase().contains(query) ||
          q.quotationNumber.toLowerCase().contains(query) ||
          q.estimateNumber.toLowerCase().contains(query) ||
          q.customerPhone.contains(query) ||
          q.salesmanName.toLowerCase().contains(query);
    }).toList();
  }

  QuotationLoaded copyWith({
    List<OwnerviewQuotationModel>? myQuotations,
    List<OwnerviewQuotationModel>? salesmanQuotations,
    QuotationFilterType? filter,
    String? searchQuery,
    int? currentPage,
    int? perPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return QuotationLoaded(
      myQuotations: myQuotations ?? this.myQuotations,
      salesmanQuotations: salesmanQuotations ?? this.salesmanQuotations,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class QuotationError extends QuotationState {
  final String? message;
  final bool isUnauthorized;

  const QuotationError(this.message, {this.isUnauthorized = false});
}