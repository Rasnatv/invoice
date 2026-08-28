import 'package:flutter/foundation.dart';

@immutable
abstract class FieldStaffActiveEvent {
  const FieldStaffActiveEvent();
}

/// Triggers GET /field-staff/active.
class FetchActiveFieldStaff extends FieldStaffActiveEvent {
  const FetchActiveFieldStaff();
}