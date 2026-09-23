//
// enum EstimateStep { details, addItems, preview }
//
// class AddedItem {
//   final String id;
//   final String productId;
//   final String name;
//   final String company;
//   final String size;
//   final String unit;
//   final String packing; // NEW — e.g. "8pcs/box", "1/2ltr/Boownerttle"
//   final double quantity;
//   final double boxQuantity;
//   final double pieceQuantity;
//   final double rate;
//   final double mrp;
//
//   const AddedItem({
//     required this.id,
//     required this.productId,
//     required this.name,
//     required this.company,
//     required this.size,
//     required this.unit,
//     this.packing = '', // NEW
//     required this.quantity,
//     this.boxQuantity = 0,
//     this.pieceQuantity = 0,
//     required this.rate,
//     this.mrp = 0,
//   });
//
//   double get amount => quantity * rate;
// }
/// Shared types for the Owner "Create Estimate" flow.
///
/// `amount`, `incentiveAmount`, `incentiveEligible`, and `incentiveReason`
/// are now stored fields set once — from the server's
/// /quotations/product-incentive response — at the moment an item is
/// added, exactly like the salesman flow's AddedItem. Previously `amount`
/// was a getter (`quantity * rate`), which silently ignored the server's
/// actual incentive-aware calculation (bulk tiers, box/piece pricing,
/// etc.) — that's what caused the amount mismatch.

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