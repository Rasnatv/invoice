import 'dart:io';

/// A single "visit" logged by a field staff member — the party (customer)
/// they visited, on a given date, with proof-of-visit photo and any
/// incentive earned for that visit.
class FieldStaffVisitModel {
  FieldStaffVisitModel({
    required this.id,
    required this.staffName,
    required this.partyName,
    required this.address,
    required this.phoneNo,
    required this.visitDate,
    this.imagePath,
    this.incentiveAmount = 0,
    this.notes,
  });

  final String id;

  /// Name of the field staff who made the visit.
  final String staffName;

  /// Party / customer / shop visited.
  final String partyName;
  final String address;
  final String phoneNo;

  /// Date (and time) the visit was made / logged.
  final DateTime visitDate;

  /// Local file path of the photo captured as proof of visit (camera or
  /// gallery). Null if no photo was attached.
  final String? imagePath;

  /// Incentive earned by the staff for this particular visit.
  final double incentiveAmount;

  final String? notes;

  File? get imageFile => (imagePath == null || imagePath!.isEmpty) ? null : File(imagePath!);

  bool get hasImage => imageFile != null;

  FieldStaffVisitModel copyWith({
    String? partyName,
    String? address,
    String? phoneNo,
    DateTime? visitDate,
    String? imagePath,
    double? incentiveAmount,
    String? notes,
  }) {
    return FieldStaffVisitModel(
      id: id,
      staffName: staffName,
      partyName: partyName ?? this.partyName,
      address: address ?? this.address,
      phoneNo: phoneNo ?? this.phoneNo,
      visitDate: visitDate ?? this.visitDate,
      imagePath: imagePath ?? this.imagePath,
      incentiveAmount: incentiveAmount ?? this.incentiveAmount,
      notes: notes ?? this.notes,
    );
  }
}