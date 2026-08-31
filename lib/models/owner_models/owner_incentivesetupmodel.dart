/// Models for the four `salesman-incentive-setup` endpoints:
///   GET  /salesman-incentive-setup           -> SalesmanIncentiveListResponseModel
///   POST /salesman-incentive-setup/get       -> SalesmanIncentiveSetupGetResponseModel
///   POST /salesman-incentive-setup/save      -> SalesmanIncentiveActionResponseModel
///   POST /salesman-incentive-setup/delete    -> SalesmanIncentiveActionResponseModel
///
/// Drop this under lib/models/owner_models/.

/// API values are 'fixed' | 'percentage' | 'none'. The form only ever
/// lets the user pick between the first two — 'none' just means "no
/// bonus configured", which is represented by `enabled == false` /
/// `hasSetup == false` in the UI rather than as a third chip.
enum BonusType { fixed, percent }

BonusType bonusTypeFromApi(String? value) {
  switch (value) {
    case 'percentage':
      return BonusType.percent;
    case 'fixed':
    default:
      return BonusType.fixed;
  }
}

String bonusTypeToApi(BonusType type) {
  switch (type) {
    case BonusType.percent:
      return 'percentage';
    case BonusType.fixed:
      return 'fixed';
  }
}

bool _asBool(dynamic v) =>
    v?.toString() == '1' || v?.toString().toLowerCase() == 'true';

double _asDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String _asString(dynamic v) => v?.toString() ?? '';

// ---------------------------------------------------------------------
// GET /salesman-incentive-setup
// The salesman dropdown + each salesman's current-period setup status,
// in one call.
// ---------------------------------------------------------------------
class SalesmanIncentiveListItem {
  final String id;
  final String name;
  final bool hasSetup;
  final String displayText;
  final String monthYear;

  const SalesmanIncentiveListItem({
    required this.id,
    required this.name,
    required this.hasSetup,
    required this.displayText,
    required this.monthYear,
  });

  factory SalesmanIncentiveListItem.fromJson(Map<String, dynamic> json) {
    return SalesmanIncentiveListItem(
      id: _asString(json['id']),
      name: _asString(json['name']),
      hasSetup: _asBool(json['has_setup']),
      displayText: _asString(json['display_text']),
      monthYear: _asString(json['month_year']),
    );
  }
}

class SalesmanIncentiveListResponseModel {
  final String status;
  final List<SalesmanIncentiveListItem> list;
  final String message;

  const SalesmanIncentiveListResponseModel({
    required this.status,
    required this.list,
    required this.message,
  });

  factory SalesmanIncentiveListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawList = (data is Map) ? data['list'] : null;
    return SalesmanIncentiveListResponseModel(
      status: _asString(json['status']),
      message: _asString(json['message']),
      list: rawList is List
          ? rawList
          .whereType<Map>()
          .map((e) => SalesmanIncentiveListItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : const [],
    );
  }
}

// ---------------------------------------------------------------------
// POST /salesman-incentive-setup/get
// `data: {}` (empty map) means nothing has been configured for that
// salesman/year/month yet — that's NOT an error, so `data` parses to
// null in that case and the form should just start blank.
// ---------------------------------------------------------------------
class SalesmanIncentiveSetupDetail {
  final String id;
  final String salesmanId;
  final String salesmanName;
  final String year;
  final String month;
  final String monthName;
  final double targetAmount;
  final String targetAmountFormatted;
  final String bonusType; // 'fixed' | 'percentage' | 'none'
  final String bonusTypeLabel;
  final double bonusValue;
  final String bonusValueDisplay;
  final bool hasTarget;
  final String createdAt;
  final String updatedAt;

  const SalesmanIncentiveSetupDetail({
    required this.id,
    required this.salesmanId,
    required this.salesmanName,
    required this.year,
    required this.month,
    required this.monthName,
    required this.targetAmount,
    required this.targetAmountFormatted,
    required this.bonusType,
    required this.bonusTypeLabel,
    required this.bonusValue,
    required this.bonusValueDisplay,
    required this.hasTarget,
    required this.createdAt,
    required this.updatedAt,
  });

  BonusType get bonusTypeEnum => bonusTypeFromApi(bonusType);

  factory SalesmanIncentiveSetupDetail.fromJson(Map<String, dynamic> json) {
    return SalesmanIncentiveSetupDetail(
      id: _asString(json['id']),
      salesmanId: _asString(json['salesman_id']),
      salesmanName: _asString(json['salesman_name']),
      year: _asString(json['year']),
      month: _asString(json['month']),
      monthName: _asString(json['month_name']),
      targetAmount: _asDouble(json['target_amount']),
      targetAmountFormatted: _asString(json['target_amount_formatted']),
      bonusType: _asString(json['bonus_type']),
      bonusTypeLabel: _asString(json['bonus_type_label']),
      bonusValue: _asDouble(json['bonus_value']),
      bonusValueDisplay: _asString(json['bonus_value_display']),
      hasTarget: _asBool(json['has_target']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
    );
  }
}

class SalesmanIncentiveSetupGetResponseModel {
  final String status;
  final SalesmanIncentiveSetupDetail? data;
  final String message;

  const SalesmanIncentiveSetupGetResponseModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory SalesmanIncentiveSetupGetResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    SalesmanIncentiveSetupDetail? parsed;
    if (raw is Map && raw.isNotEmpty && raw['salesman_id'] != null) {
      parsed = SalesmanIncentiveSetupDetail.fromJson(Map<String, dynamic>.from(raw));
    }
    return SalesmanIncentiveSetupGetResponseModel(
      status: _asString(json['status']),
      message: _asString(json['message']),
      data: parsed,
    );
  }
}

// ---------------------------------------------------------------------
// POST /salesman-incentive-setup/save
// ---------------------------------------------------------------------
class SalesmanIncentiveSetupSaveRequest {
  final String salesmanId;
  final String year;
  final String month;
  final double targetAmount;
  final BonusType bonusType;
  final double bonusValue;
  final bool hasTarget;

  const SalesmanIncentiveSetupSaveRequest({
    required this.salesmanId,
    required this.year,
    required this.month,
    required this.targetAmount,
    required this.bonusType,
    required this.bonusValue,
    required this.hasTarget,
  });

  Map<String, dynamic> toJson() => {
    'salesman_id': salesmanId,
    'year': year,
    'month': month,
    'target_amount': hasTarget ? targetAmount.toStringAsFixed(0) : '0',
    'bonus_type': bonusTypeToApi(bonusType),
    'bonus_value': bonusValue.toStringAsFixed(2),
    'has_target': hasTarget.toString(), // API expects "true"/"false"
  };
}

// ---------------------------------------------------------------------
// Shared by /get (request body) and /delete
// ---------------------------------------------------------------------
class SalesmanIncentiveSetupQueryRequest {
  final String salesmanId;
  final String year;
  final String month;

  const SalesmanIncentiveSetupQueryRequest({
    required this.salesmanId,
    required this.year,
    required this.month,
  });

  Map<String, dynamic> toJson() => {
    'salesman_id': salesmanId,
    'year': year,
    'month': month,
  };
}

/// Generic { status, message } wrapper shared by /save and /delete.
class SalesmanIncentiveActionResponseModel {
  final String status;
  final String message;

  const SalesmanIncentiveActionResponseModel({
    required this.status,
    required this.message,
  });

  factory SalesmanIncentiveActionResponseModel.fromJson(Map<String, dynamic> json) {
    return SalesmanIncentiveActionResponseModel(
      status: _asString(json['status']),
      message: _asString(json['message']),
    );
  }
}