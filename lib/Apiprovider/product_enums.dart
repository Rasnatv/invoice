//
//
// /// incentive_type: 'percentage' or 'fixed'.
// enum ProductIncentiveType { percentage, fixed, }
//
// /// bonus_type: 'none', 'bulk', or 'single'.
// /// 'none' is first in the list (and the default) — when picked, bonus_type
// /// and min_quantity are left out of the request entirely rather than sent
// /// as null/0.
// enum ProductBonusType { none, bulk, single }
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
//   /// null for 'none' — callers should omit bonus_type from the request
//   /// body when this is null, rather than sending it as "null".
//   String? get apiValue {
//     switch (this) {
//       case ProductBonusType.bulk:
//         return 'bulk';
//       case ProductBonusType.single:
//         return 'single';
//       case ProductBonusType.none:
//         return null;
//     }
//   }
//
//   String get label {
//     switch (this) {
//       case ProductBonusType.bulk:
//         return 'Bulk';
//       case ProductBonusType.single:
//         return 'Single';
//       case ProductBonusType.none:
//         return 'None';
//     }
//   }
// }
/// incentive_type: 'none', 'percentage', or 'fixed'.
/// 'none' is first in the list (and the default) — when picked,
/// incentive_type, incentive_amount, and incentive_percentage are all left
/// out of the request entirely rather than sent as null.
enum ProductIncentiveType { none, percentage, fixed }

/// bonus_type: 'none', 'bulk', or 'single'.
/// 'none' is first in the list (and the default) — when picked, bonus_type
/// and min_quantity are left out of the request entirely rather than sent
/// as null/0.
enum ProductBonusType { none, bulk, single }

extension ProductIncentiveTypeX on ProductIncentiveType {
  /// null for 'none' — callers should omit incentive_type from the request
  /// body when this is null, rather than sending it as "null".
  String? get apiValue {
    switch (this) {
      case ProductIncentiveType.percentage:
        return 'percentage';
      case ProductIncentiveType.fixed:
        return 'fixed';
      case ProductIncentiveType.none:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ProductIncentiveType.percentage:
        return 'Percentage';
      case ProductIncentiveType.fixed:
        return 'Fixed';
      case ProductIncentiveType.none:
        return 'None';
    }
  }
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