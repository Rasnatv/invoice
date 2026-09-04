/// Shared types for the Owner "Create Estimate" flow.
///
/// These used to be declared privately (with a leading underscore) inside
/// each of the two split files. In Dart, a `_`-prefixed identifier is
/// library-private — private to that one file — so the two files ended up
/// with two different types that both happened to be named `_Step`, which
/// does not compile across files. Pulling the shared enum (and the
/// `AddedItem` model, which the widgets file also needs) into their own
/// file fixes that without creating a circular import between the screen
/// and the widgets file.

enum EstimateStep { details, addItems, preview }

class AddedItem {
  final String id;
  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double quantity;
  final double boxQuantity;
  final double pieceQuantity;
  final double rate;
  final double mrp;

  const AddedItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.company,
    required this.size,
    required this.unit,
    required this.quantity,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    required this.rate,
    this.mrp = 0,
  });

  double get amount => quantity * rate;
}