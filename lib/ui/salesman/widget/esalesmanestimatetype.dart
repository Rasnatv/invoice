
enum EstimateStep { details, addItems, preview }

class AddedItem {
  final String id;
  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;

  /// Human-readable packing description, e.g. "8pcs/box", "1/2ltr/Bottle".
  final String packing;

  final double quantity;
  final double boxQuantity;
  final double pieceQuantity;
  final double rate;

  /// Product's reference MRP at the time this item was added — display
  /// only, not used in any calculation and not required to be non-zero.
  final double mrp;

  /// Snapshot of the live incentive preview (POST
  /// /quotations/product-incentive) at the moment this item was added,
  /// so a later product/rate change elsewhere doesn't retroactively
  /// change what an already-added item shows.
  final double incentiveAmount;
  final bool incentiveEligible;
  final String? incentiveReason;

  const AddedItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.company,
    required this.size,
    required this.unit,
    this.packing = '',
    required this.quantity,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    required this.rate,
    this.mrp = 0,
    this.incentiveAmount = 0,
    this.incentiveEligible = false,
    this.incentiveReason,
  });

  double get amount => quantity * rate;
}