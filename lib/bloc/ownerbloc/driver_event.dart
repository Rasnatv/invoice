import 'package:equatable/equatable.dart';

abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

class LoadDrivers extends DriverEvent {
  const LoadDrivers();
}

class AddDriver extends DriverEvent {
  const AddDriver({
    required this.name,
    required this.email,
    required this.mobile,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.joiningDate,
  });

  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;
  final String joiningDate;

  @override
  List<Object?> get props =>
      [name, email, mobile, licenseNumber, vehicleNumber, joiningDate];
}

/// Updates a driver via POST /drivers/update. [password] is optional —
/// only pass it when the owner wants to reset the driver's password.
class UpdateDriver extends DriverEvent {
  const UpdateDriver({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.joiningDate,
    required this.isActive,
    this.password,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;
  final String joiningDate;
  final bool isActive;
  final String? password;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    mobile,
    licenseNumber,
    vehicleNumber,
    joiningDate,
    isActive,
    password,
  ];
}

class DeleteDriver extends DriverEvent {
  const DeleteDriver(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class ClearDriverFeedback extends DriverEvent {
  const ClearDriverFeedback();
}