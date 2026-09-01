import 'package:equatable/equatable.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load — fetches page 1.
class LoadProductList extends ProductListEvent {
  const LoadProductList();
}

/// Pull-to-refresh — resets to page 1 and reloads.
class RefreshProductList extends ProductListEvent {
  const RefreshProductList();
}

/// Fetches the next page and appends to the existing list.
class LoadMoreProductList extends ProductListEvent {
  const LoadMoreProductList();
}