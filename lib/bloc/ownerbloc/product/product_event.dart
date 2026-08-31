
import 'package:equatable/equatable.dart';

import '../../../models/owner_models/addproductmodel.dart';
import '../../../models/owner_models/updateproductmodel.dart';


abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches company + unit active lists together — call this once when the
/// add/edit product screen opens, before the dropdowns are usable.
class LoadProductDropdowns extends ProductEvent {
  const LoadProductDropdowns();
}

/// Resets and (re)loads from page 1 — used for the initial load and for
/// pull-to-refresh. For subsequent pages, use [LoadMoreProducts] instead;
/// this event always replaces the list rather than appending to it.
class LoadProducts extends ProductEvent {
  const LoadProducts({this.page = 1, this.perPage = 10});

  final int page;
  final int perPage;

  @override
  List<Object?> get props => [page, perPage];
}

/// Fetches the next page after the currently loaded one and appends it to
/// the existing product list. The bloc ignores this if a load is already
/// in progress or a previous page came back short (i.e. no more pages).
class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts({this.perPage = 10});

  final int perPage;

  @override
  List<Object?> get props => [perPage];
}

class CreateProduct extends ProductEvent {
  const CreateProduct(this.request);

  final ProductAddRequestModel request;

  @override
  List<Object?> get props => [request];
}

class UpdateProduct extends ProductEvent {
  const UpdateProduct(this.request);

  final ProductUpdateRequestModel request;

  @override
  List<Object?> get props => [request];
}

class DeleteProduct extends ProductEvent {
  const DeleteProduct(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}