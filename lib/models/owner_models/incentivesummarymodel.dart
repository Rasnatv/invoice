import 'fieldstaffincentivemodel.dart';

/// Counts block. Confirmed real shape (2026-09 API sample) — these are FLAT
/// keys directly inside `data.summary`, NOT nested under a `status_breakdown`
/// key like the previous version of this file assumed:
///   "summary": {
///     "total_incentive": "165.50",
///     "pending_count": "0",
///     "approved_count": "0",
///     "paid_count": "1"
///   }
class IncentiveStatusBreakdown {
  final int pending;
  final int approved;
  final int paid;

  const IncentiveStatusBreakdown({
    required this.pending,
    required this.approved,
    required this.paid,
  });

  factory IncentiveStatusBreakdown.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const IncentiveStatusBreakdown(pending: 0, approved: 0, paid: 0);
    }
    return IncentiveStatusBreakdown(
      pending: int.tryParse(json['pending_count']?.toString() ?? '') ?? 0,
      approved: int.tryParse(json['approved_count']?.toString() ?? '') ?? 0,
      paid: int.tryParse(json['paid_count']?.toString() ?? '') ?? 0,
    );
  }
}

/// `data.summary` of POST /field-staff-incentives/summary.
///
/// NOTE: the real API does NOT return `total_field_staff` or `top_performers`
/// — those fields existed in the old placeholder model but are not present
/// in the confirmed response, so they've been dropped. If a later API
/// version adds them back, restore the fields + fromJson keys here.
class IncentiveSummaryModel {
  final double totalIncentive;
  final IncentiveStatusBreakdown statusBreakdown;

  const IncentiveSummaryModel({
    required this.totalIncentive,
    required this.statusBreakdown,
  });

  factory IncentiveSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return IncentiveSummaryModel.empty();
    return IncentiveSummaryModel(
      totalIncentive: double.tryParse(json['total_incentive']?.toString() ?? '') ?? 0,
      // Same json object carries pending_count/approved_count/paid_count.
      statusBreakdown: IncentiveStatusBreakdown.fromJson(json),
    );
  }

  factory IncentiveSummaryModel.empty() => const IncentiveSummaryModel(
    totalIncentive: 0,
    statusBreakdown: IncentiveStatusBreakdown(pending: 0, approved: 0, paid: 0),
  );
}

/// Full `data` payload of POST /field-staff-incentives/summary.
///
/// Confirmed real shape combines the summary counts AND the (paginated,
/// via `?page=&per_page=` query params) incentive list in ONE response:
///   {
///     "data": {
///       "field_staff_id": "",
///       "summary": { ... },
///       "list": [ ...FieldStaffIncentiveModel items... ]
///     }
///   }
///
/// The response carries NO page/total/total_pages metadata, so callers must
/// infer `hasMore` themselves (e.g. `list.length >= perPageRequested`).
class FieldStaffIncentiveSummaryResponse {
  final String? fieldStaffId;
  final IncentiveSummaryModel summary;
  final List<FieldStaffIncentiveModel> list;

  const FieldStaffIncentiveSummaryResponse({
    this.fieldStaffId,
    required this.summary,
    required this.list,
  });

  factory FieldStaffIncentiveSummaryResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['list'] as List?) ?? [];
    final rawStaffId = json['field_staff_id']?.toString();
    return FieldStaffIncentiveSummaryResponse(
      fieldStaffId: (rawStaffId == null || rawStaffId.isEmpty) ? null : rawStaffId,
      summary: IncentiveSummaryModel.fromJson(json['summary'] as Map<String, dynamic>?),
      list: rawList
          .map((e) => FieldStaffIncentiveModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}