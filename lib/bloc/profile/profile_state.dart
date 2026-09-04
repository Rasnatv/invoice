import 'package:equatable/equatable.dart';
import '../../models/profilemodel.dart';


enum ProfileActionStatus { idle, loading, success, failure }

class ProfileState extends Equatable {
  // Profile load
  final bool isLoading;
  final ProfileModel? profile;
  final String? errorMessage;

  // Edit Profile submit
  final ProfileActionStatus updateStatus;
  final String? updateMessage;

  // Change Password submit
  final ProfileActionStatus passwordStatus;
  final String? passwordMessage;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.updateStatus = ProfileActionStatus.idle,
    this.updateMessage,
    this.passwordStatus = ProfileActionStatus.idle,
    this.passwordMessage,
  });

  factory ProfileState.initial() => const ProfileState(isLoading: true);

  ProfileState copyWith({
    bool? isLoading,
    ProfileModel? profile,
    String? errorMessage,
    bool clearError = false,
    ProfileActionStatus? updateStatus,
    String? updateMessage,
    ProfileActionStatus? passwordStatus,
    String? passwordMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      updateStatus: updateStatus ?? this.updateStatus,
      updateMessage: updateMessage ?? this.updateMessage,
      passwordStatus: passwordStatus ?? this.passwordStatus,
      passwordMessage: passwordMessage ?? this.passwordMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    profile,
    errorMessage,
    updateStatus,
    updateMessage,
    passwordStatus,
    passwordMessage,
  ];
}