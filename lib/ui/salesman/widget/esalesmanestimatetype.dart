/// Shared types for the Salesman "Create Estimate" flow.
///
/// Mirrors `ownerestimatetype.dart`: the step enum and the added-item
/// model used to be declared privately (`_Step` / `_AddedItem`) inside
/// the screen file. Pulling them out into their own file keeps the
/// pattern consistent with the owner flow and lets any future split-out
/// widget files reuse the exact same types instead of redeclaring
/// library-private lookalikes.
///
/// This is intentionally its own file (not a re-export of
/// ownerestimatetype.dart) because the salesman flow snapshots a live
/// per-item incentive preview on each added item, which the owner flow
/// has no equivalent of.
///
/// Box/piece quantity are kept on the model (the API still accepts
/// `box_quantity` / `piece_quantity` on every item) even though the
/// salesman UI no longer shows separate Box Qty / Piece Qty fields —
/// they're just no longer surfaced to the salesman and are computed
/// silently from Quantity for box-unit products.

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