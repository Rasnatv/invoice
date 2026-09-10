/// Nested `site_visit` block returned inside /field-staff-incentives/show.
/// Confirmed against real API sample — matches exactly.
class SiteVisitInfo {
  final String id;
  final String customerName;
  final String customerPhone;
  final String siteAddress;
  final String visitDate;

  const SiteVisitInfo({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.siteAddress,
    required this.visitDate,
  });

  factory SiteVisitInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SiteVisitInfo(
        id: '',
        customerName: '',
        customerPhone: '',
        siteAddress: '',
        visitDate: '',
      );
    }
    return SiteVisitInfo(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      siteAddress: json['site_address']?.toString() ?? '',
      visitDate: json['visit_date']?.toString() ?? '',
    );
  }
}

/// Single incentive record — shape returned by:
///  - /field-staff-incentives/show            (full detail)
///  - /field-staff-incentives/mark-paid        (updated record)
///  - /field-staff-incentives/summary `list[]` (same shape; items simply
///    omit notes/approved_by/approved_at/site_visit, which default safely
///    to '' via the null-coalescing below)
///
/// Confirmed against real API samples — matches exactly, no changes needed.
class FieldStaffIncentiveModel {
  final String id;
  final String fieldStaffId;
  final String fieldStaffName;
  final String siteVisitId;
  final String estimateId;
  final String estimateNumber;
  final double incentiveAmount;
  final String incentiveAmountFormatted;
  final String status; // pending | approved | paid
  final String statusLabel;
  final String statusColor; // warning | success | info | primary ...
  final String paidAt;
  final String createdAt;
  final String notes;
  final String approvedBy;
  final String approvedAt;
  final SiteVisitInfo siteVisit;

  const FieldStaffIncentiveModel({
    required this.id,
    required this.fieldStaffId,
    required this.fieldStaffName,
    required this.siteVisitId,
    required this.estimateId,
    required this.estimateNumber,
    required this.incentiveAmount,
    required this.incentiveAmountFormatted,
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    required this.paidAt,
    required this.createdAt,
    required this.notes,
    required this.approvedBy,
    required this.approvedAt,
    required this.siteVisit,
  });

  factory FieldStaffIncentiveModel.fromJson(Map<String, dynamic> json) {
    return FieldStaffIncentiveModel(
      id: json['id']?.toString() ?? '',
      fieldStaffId: json['field_staff_id']?.toString() ?? '',
      fieldStaffName: json['field_staff_name']?.toString() ?? '',
      siteVisitId: json['site_visit_id']?.toString() ?? '',
      estimateId: json['estimate_id']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      incentiveAmount:
      double.tryParse(json['incentive_amount']?.toString() ?? '') ?? 0,
      incentiveAmountFormatted:
      json['incentive_amount_formatted']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? '',
      statusColor: json['status_color']?.toString() ?? '',
      paidAt: json['paid_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      approvedBy: json['approved_by']?.toString() ?? '',
      approvedAt: json['approved_at']?.toString() ?? '',
      siteVisit:
      SiteVisitInfo.fromJson(json['site_visit'] as Map<String, dynamic>?),
    );
  }
}