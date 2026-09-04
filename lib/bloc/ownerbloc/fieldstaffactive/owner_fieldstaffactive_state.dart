// import 'package:flutter/foundation.dart';
// import '../../../models/owner_reportmodel/activefieldstaffmodel.dart';
//
//
// @immutable
// abstract class FieldStaffActiveState {
//   const FieldStaffActiveState();
// }
//
// class FieldStaffActiveInitial extends FieldStaffActiveState {
//   const FieldStaffActiveInitial();
// }
//
// class FieldStaffActiveLoading extends FieldStaffActiveState {
//   const FieldStaffActiveLoading();
// }
//
// class FieldStaffActiveLoaded extends FieldStaffActiveState {
//   final List<ActiveFieldStaffModel> fieldStaff;
//   const FieldStaffActiveLoaded(this.fieldStaff);
// }
//
// class FieldStaffActiveError extends FieldStaffActiveState {
//   final String message;
//   final bool isUnauthorized;
//   const FieldStaffActiveError(this.message, {this.isUnauthorized = false});
// }
import 'package:flutter/foundation.dart';
import '../../../models/owner_reportmodel/activefieldstaffmodel.dart';


@immutable
abstract class FieldStaffActiveState {
  const FieldStaffActiveState();
}

class FieldStaffActiveInitial extends FieldStaffActiveState {
  const FieldStaffActiveInitial();
}

class FieldStaffActiveLoading extends FieldStaffActiveState {
  const FieldStaffActiveLoading();
}

class FieldStaffActiveLoaded extends FieldStaffActiveState {
  final List<ActiveFieldStaffModel> fieldStaff;
  const FieldStaffActiveLoaded(this.fieldStaff);
}

class FieldStaffActiveError extends FieldStaffActiveState {
  final String? message;
  const FieldStaffActiveError(this.message);
}