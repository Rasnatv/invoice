import 'package:equatable/equatable.dart';

abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the drivers list from GET /drivers.
class LoadDrivers extends DriverEvent {
  const LoadDrivers();
}

/// Creates a driver via POST /drivers.
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
    this.password,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;
  final String joiningDate;
  final String? password;

  @override
  List<Object?> get props =>
      [id, name, email, mobile, licenseNumber, vehicleNumber, joiningDate, password];
}

/// Deletes a driver via POST /drivers/delete.
class DeleteDriver extends DriverEvent {
  const DeleteDriver(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

/// Clears one-off feedback (error/success message, generated password)
/// after the UI has consumed it, so it doesn't re-trigger on rebuild.
class ClearDriverFeedback extends DriverEvent {
  const ClearDriverFeedback();
}