import 'package:equatable/equatable.dart';

abstract class ProductBillsEvent extends Equatable {
  const ProductBillsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads page 1 (or reloads from scratch, e.g. pull-to-refresh).
class LoadProductBills extends ProductBillsEvent {
  const LoadProductBills();
}

/// Loads the next page and appends to the existing list.
class LoadMoreProductBills extends ProductBillsEvent {
  const LoadMoreProductBills();
}