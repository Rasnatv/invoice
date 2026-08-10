// /// A product master entry as configured by the owner/admin: pricing plus
// /// its incentive structure. `tier1`/`tier2` represent annual sales targets
// /// (e.g. ₹1,00,000 and ₹2,00,000) that, once a salesman crosses them for
// /// this product, unlock an extra bonus % on top of the base incentive %.
// class ProductIncentiveModel {
//   final String id;
//   final String name;
//   final String company;
//   final double mrp;
//   final double rate;
//
//   /// Base incentive %, always applies.
//   final double incentivePercent;
//
//   /// Tier 1 annual sales target (₹) and the extra bonus % unlocked once
//   /// crossed (added on top of [incentivePercent]).
//   final double tier1AnnualTarget;
//   final double tier1BonusPercent;
//
//   /// Tier 2 annual sales target (₹, higher than tier 1) and its extra
//   /// bonus % (replaces the tier 1 bonus once crossed, on top of base %).
//   final double tier2AnnualTarget;
//   final double tier2BonusPercent;
//
//   const ProductIncentiveModel({
//     required this.id,
//     required this.name,
//     required this.company,
//     required this.mrp,
//     required this.rate,
//     required this.incentivePercent,
//     this.tier1AnnualTarget = 100000,
//     this.tier1BonusPercent = 1,
//     this.tier2AnnualTarget = 200000,
//     this.tier2BonusPercent = 2,
//   });
//
//   ProductIncentiveModel copyWith({
//     String? name,
//     String? company,
//     double? mrp,
//     double? rate,
//     double? incentivePercent,
//     double? tier1AnnualTarget,
//     double? tier1BonusPercent,
//     double? tier2AnnualTarget,
//     double? tier2BonusPercent,
//   }) {
//     return ProductIncentiveModel(
//       id: id,
//       name: name ?? this.name,
//       company: company ?? this.company,
//       mrp: mrp ?? this.mrp,
//       rate: rate ?? this.rate,
//       incentivePercent: incentivePercent ?? this.incentivePercent,
//       tier1AnnualTarget: tier1AnnualTarget ?? this.tier1AnnualTarget,
//       tier1BonusPercent: tier1BonusPercent ?? this.tier1BonusPercent,
//       tier2AnnualTarget: tier2AnnualTarget ?? this.tier2AnnualTarget,
//       tier2BonusPercent: tier2BonusPercent ?? this.tier2BonusPercent,
//     );
//   }
//
//   /// Effective incentive % for a given achieved annual sales figure of
//   /// this product, applying whichever bonus tier has been crossed.
//   double effectiveIncentivePercentFor(double achievedAnnualSales) {
//     if (achievedAnnualSales >= tier2AnnualTarget) {
//       return incentivePercent + tier2BonusPercent;
//     }
//     if (achievedAnnualSales >= tier1AnnualTarget) {
//       return incentivePercent + tier1BonusPercent;
//     }
//     return incentivePercent;
//   }
// }
class LProductIncentiveModel {
  const LProductIncentiveModel({
    required this.id,
    required this.name,
    required this.company,
    required this.mrp,
    required this.rate,
    required this.incentivePercent,
    this.size,
    this.unit,
  });

  final String id;
  final String name;
  final String company;
  final double mrp;
  final double rate;
  final double incentivePercent;

  /// e.g. "600x600", "4\"", "25"
  final String? size;

  /// e.g. "sq.ft", "box", "piece", "kg", "meter", "liter", "bag"
  final String? unit;

  LProductIncentiveModel copyWith({
    String? id,
    String? name,
    String? company,
    double? mrp,
    double? rate,
    double? incentivePercent,
    String? size,
    String? unit,
  }) {
    return LProductIncentiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      mrp: mrp ?? this.mrp,
      rate: rate ?? this.rate,
      incentivePercent: incentivePercent ?? this.incentivePercent,
      size: size ?? this.size,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'mrp': mrp,
      'rate': rate,
      'incentivePercent': incentivePercent,
      'size': size,
      'unit': unit,
    };
  }

  factory LProductIncentiveModel.fromJson(Map<String, dynamic> json) {
    return LProductIncentiveModel(
      id: json['id'] as String,
      name: json['name'] as String,
      company: json['company'] as String,
      mrp: (json['mrp'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      incentivePercent: (json['incentivePercent'] as num).toDouble(),
      size: json['size'] as String?,
      unit: json['unit'] as String?,
    );
  }
}