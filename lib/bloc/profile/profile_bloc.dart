import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/profileprovider.dart';
import '../../models/profilemodel.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileProvider _provider;

  ProfileBloc({ProfileProvider? provider})
      : _provider = provider ?? ProfileProvider(),
        super(ProfileState.initial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<ChangePasswordRequested>(_onChangePassword);
    on<ResetProfileActionStatus>(_onResetStatus);
  }

  Future<void> _onLoadProfile(
      LoadProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _provider.getProfile();

    if (result.success) {
      emit(state.copyWith(isLoading: false, profile: result.profile, clearError: true));
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: result.errorMessage));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileRequested event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(updateStatus: ProfileActionStatus.loading));

    final result = await _provider.updateProfile(event.profile);

    if (result.success) {
      // API returns empty data: {} on success, so merge what was submitted
      // into local state instead of trying to parse a profile back.
      final current = state.profile ?? const ProfileModel();
      final merged = current.copyWith(
        name: event.profile.name,
        email: event.profile.email,
        mobile: event.profile.mobile,
      );
      emit(state.copyWith(
        updateStatus: ProfileActionStatus.success,
        updateMessage: result.message ?? 'Profile updated successfully',
        profile: merged,
      ));
    } else {
      emit(state.copyWith(
        updateStatus: ProfileActionStatus.failure,
        updateMessage: result.errorMessage,
      ));
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordRequested event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(passwordStatus: ProfileActionStatus.loading));

    final result = await _provider.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      newPasswordConfirmation: event.newPasswordConfirmation,
    );

    if (result.success) {
      emit(state.copyWith(
        passwordStatus: ProfileActionStatus.success,
        passwordMessage: result.message ?? 'Password changed successfully',
      ));
    } else {
      emit(state.copyWith(
        passwordStatus: ProfileActionStatus.failure,
        passwordMessage: result.errorMessage,
      ));
    }
  }

  void _onResetStatus(
      ResetProfileActionStatus event,
      Emitter<ProfileState> emit,
      ) {
    emit(state.copyWith(
      updateStatus: ProfileActionStatus.idle,
      passwordStatus: ProfileActionStatus.idle,
    ));
  }
}