
enum ProductIncentiveType { none, percentage, fixed }
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
