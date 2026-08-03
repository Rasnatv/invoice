import 'package:flutter/foundation.dart';
import 'fieldstaffvisitmodel.dart';

/// TODO(backend): replace this in-memory store with real API calls once the
/// field-staff visit endpoints exist (create visit w/ image upload, list by
/// staff, incentive summary, etc.). The shape mirrors [DespatchRepository]
/// so the dashboard can be wired to a live API the same way later.
class FieldStaffRepository extends ChangeNotifier {
  FieldStaffRepository._();
  static final FieldStaffRepository instance = FieldStaffRepository._();

  final List<FieldStaffVisitModel> _visits = [];

  /// Most recently added visit first.
  List<FieldStaffVisitModel> get visits => List.unmodifiable(_visits.reversed);

  void addVisit(FieldStaffVisitModel visit) {
    _visits.add(visit);
    notifyListeners();
  }

  void updateVisit(FieldStaffVisitModel visit) {
    final i = _visits.indexWhere((v) => v.id == visit.id);
    if (i != -1) {
      _visits[i] = visit;
      notifyListeners();
    }
  }

  void deleteVisit(String id) {
    _visits.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  List<FieldStaffVisitModel> visitsFor(String staffName) =>
      visits.where((v) => v.staffName == staffName).toList();

  List<FieldStaffVisitModel> todayVisitsFor(String staffName) {
    final now = DateTime.now();
    return visitsFor(staffName).where((v) => _isSameDay(v.visitDate, now)).toList();
  }

  double totalIncentiveFor(String staffName) =>
      visitsFor(staffName).fold(0.0, (sum, v) => sum + v.incentiveAmount);

  double todayIncentiveFor(String staffName) =>
      todayVisitsFor(staffName).fold(0.0, (sum, v) => sum + v.incentiveAmount);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}