/// Simplified product incentive model — no tier system.
/// Just a flat incentive % applied to whatever sales value is achieved
/// for that product.
class ProductIncentiveModel {
  final String id;
  final String name;
  final String company;
  final double mrp;
  final double rate;
  final double incentivePercent;

  const ProductIncentiveModel({
    required this.id,
    required this.name,
    required this.company,
    required this.mrp,
    required this.rate,
    required this.incentivePercent,
  });

  ProductIncentiveModel copyWith({
    String? id,
    String? name,
    String? company,
    double? mrp,
    double? rate,
    double? incentivePercent,
  }) {
    return ProductIncentiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      mrp: mrp ?? this.mrp,
      rate: rate ?? this.rate,
      incentivePercent: incentivePercent ?? this.incentivePercent,
    );
  }
}