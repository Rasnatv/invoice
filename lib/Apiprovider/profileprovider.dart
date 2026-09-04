import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/profilemodel.dart'; // adjust path to match your project layout

class ProfileResult {
  final bool success;
  final ProfileModel? profile;
  final String? errorMessage;

  const ProfileResult.success(this.profile)
      : success = true,
        errorMessage = null;

  const ProfileResult.failure(this.errorMessage)
      : success = false,
        profile = null;
}

class ProfileActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const ProfileActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const ProfileActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class ProfileProvider {
  final ApiClient _apiClient;

  ProfileProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /profile — works for both owner and salesman; the response shape
  /// is identical, only which fields come back populated differs.
  Future<ProfileResult> getProfile() async {
    try {
      final response = await _apiClient.getProfile();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ProfileGetResponseModel.fromJson(response.data);
        return ProfileResult.success(parsed.data);
      }
      return ProfileResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ProfileResult.failure(message);
    }
  }

  /// POST/PUT /profile update.
  ///
  /// The confirmed real response returns an empty `data: {}` on success —
  /// no updated profile object comes back. Callers should merge the
  /// submitted [profile] fields into local state themselves (the bloc
  /// below does this) rather than trying to build a ProfileModel out of
  /// this result.
  Future<ProfileActionResult> updateProfile(ProfileModel profile) async {
    try {
      final response = await _apiClient.updateProfile(profile.toUpdateJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ProfileActionResponseModel.fromJson(response.data);
        return ProfileActionResult.success(parsed.message);
      }
      return ProfileActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ProfileActionResult.failure(message);
    }
  }

  /// POST /change-password
  Future<ProfileActionResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiClient.changePassword({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ProfileActionResponseModel.fromJson(response.data);
        return ProfileActionResult.success(parsed.message);
      }
      return ProfileActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ProfileActionResult.failure(message);
    }
  }
}