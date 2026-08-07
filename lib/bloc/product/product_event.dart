import 'package:equatable/equatable.dart';
import '../../models/owner_models/addproductmodel.dart';
import '../../models/owner_models/updateproductmodel.dart';

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

class LoadProducts extends ProductEvent {
  const LoadProducts({this.page = 1, this.perPage = 10});

  final int page;
  final int perPage;

  @override
  List<Object?> get props => [page, perPage];
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
