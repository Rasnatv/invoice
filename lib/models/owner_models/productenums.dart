/// Shared by add_productmodel.dart and update_productmodel.dart so both
/// request models agree on the same incentive_type / bonus_type values.

/// incentive_type: 'percentage' or 'fixed'.
enum ProductIncentiveType { percentage, fixed }

/// bonus_type: 'bulk' or 'single'.
enum ProductBonusType { bulk, single }

extension ProductIncentiveTypeX on ProductIncentiveType {
  String get apiValue =>
      this == ProductIncentiveType.percentage ? 'percentage' : 'fixed';

  String get label =>
      this == ProductIncentiveType.percentage ? 'Percentage' : 'Fixed';
}

extension ProductBonusTypeX on ProductBonusType {
  String get apiValue => this == ProductBonusType.bulk ? 'bulk' : 'single';

  String get label => this == ProductBonusType.bulk ? 'Bulk' : 'Single';
}
