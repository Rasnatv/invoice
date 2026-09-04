import 'package:equatable/equatable.dart';
import '../../models/profilemodel.dart';


abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch the current user's profile. Fire on screen init.
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Submit the Edit Profile form. [profile] should only carry the fields
/// the user actually edited — ProfileModel.toUpdateJson() drops nulls.
class UpdateProfileRequested extends ProfileEvent {
  final ProfileModel profile;

  const UpdateProfileRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Submit the Change Password form.
class ChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [
    currentPassword,
    newPassword,
    newPasswordConfirmation,
  ];
}

/// Clears updateStatus/passwordStatus back to idle — call after the UI
/// has shown a success/error snackbar so a rebuild doesn't re-trigger it.
class ResetProfileActionStatus extends ProfileEvent {
  const ResetProfileActionStatus();
}