

enum EstimateStep { details, addItems, preview }

class AddedItem {
  final String id;
  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;
  final String packing;

  final double quantity;
  final double boxQuantity;
  final double pieceQuantity;
  final double rate;

  /// Product's reference MRP at the time this item was added — display
  /// only, not used in any calculation.
  final double mrp;

  /// Amount as returned by the server (product-incentive API's `amount`
  /// field at the moment this item was added) — NOT quantity * rate.
  final double amount;

  /// Snapshot of the live incentive at the moment this item was added.
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
    required this.amount,
    this.incentiveAmount = 0,
    this.incentiveEligible = false,
    this.incentiveReason,
  });
}