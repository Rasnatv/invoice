// /// Shared by add_productmodel.dart and update_productmodel.dart so both
// /// request models agree on the same incentive_type / bonus_type values.
//
// /// incentive_type: 'percentage' or 'fixed'.
// enum ProductIncentiveType { percentage, fixed }
//
// /// bonus_type: 'bulk' or 'single'.
// enum ProductBonusType { bulk, single }
//
// extension ProductIncentiveTypeX on ProductIncentiveType {
//   String get apiValue =>
//       this == ProductIncentiveType.percentage ? 'percentage' : 'fixed';
//
//   String get label =>
//       this == ProductIncentiveType.percentage ? 'Percentage' : 'Fixed';
// }
//
// extension ProductBonusTypeX on ProductBonusType {
//   String get apiValue => this == ProductBonusType.bulk ? 'bulk' : 'single';
//
//   String get label => this == ProductBonusType.bulk ? 'Bulk' : 'Single';
// }
/// Shared by add_productmodel.dart and update_productmodel.dart so both
/// request models agree on the same incentive_type / bonus_type values.

/// incentive_type: 'percentage' or 'fixed'.
enum ProductIncentiveType { percentage, fixed }

/// bonus_type: 'none', 'bulk', or 'single'.
/// 'none' is first in the list (and the default) — when picked, bonus_type
/// and min_quantity are left out of the request entirely rather than sent
/// as null/0.
enum ProductBonusType { none, bulk, single }

extension ProductIncentiveTypeX on ProductIncentiveType {
  String get apiValue =>
      this == ProductIncentiveType.percentage ? 'percentage' : 'fixed';

  String get label =>
      this == ProductIncentiveType.percentage ? 'Percentage' : 'Fixed';
}

extension ProductBonusTypeX on ProductBonusType {
  /// null for 'none' — callers should omit bonus_type from the request
  /// body when this is null, rather than sending it as "null".
  String? get apiValue {
    switch (this) {
      case ProductBonusType.bulk:
        return 'bulk';
      case ProductBonusType.single:
        return 'single';
      case ProductBonusType.none:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ProductBonusType.bulk:
        return 'Bulk';
      case ProductBonusType.single:
        return 'Single';
      case ProductBonusType.none:
        return 'None';
    }
  }
}