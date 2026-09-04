/// Shared profile model — used by both Owner and Salesman.
///
/// The API is loose about which fields are present per role
/// (e.g. owners may have no `mobile`, drivers may have no `email`),
/// so every field is nullable and blank strings from the API are
/// normalized to null rather than kept as ''.
class ProfileModel {
  final String? name;
  final String? email;
  final String? designation;
  final String? mobile;

  const ProfileModel({
    this.name,
    this.email,
    this.designation,
    this.mobile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String? clean(dynamic v) {
      final s = v?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }

    return ProfileModel(
      name: clean(json['name']),
      email: clean(json['email']),
      designation: clean(json['designation']),
      mobile: clean(json['mobile']),
    );
  }

  /// Body for POST/PUT profile update. Only non-null fields are sent so
  /// callers can update a subset (e.g. just name + email) without
  /// accidentally clearing fields they didn't touch.
  Map<String, dynamic> toUpdateJson() => {
    if (name != null) 'name': name,
    if (email != null) 'email': email,
    if (mobile != null) 'mobile': mobile,
  };

  ProfileModel copyWith({
    String? name,
    String? email,
    String? designation,
    String? mobile,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      mobile: mobile ?? this.mobile,
    );
  }
}

/// GET /profile response wrapper.
class ProfileGetResponseModel {
  final ProfileModel data;
  final String message;

  const ProfileGetResponseModel({required this.data, required this.message});

  factory ProfileGetResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileGetResponseModel(
      data: ProfileModel.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? const {},
      ),
      message: json['message']?.toString() ?? '',
    );
  }
}

/// Shared wrapper for the profile-update and change-password responses —
/// both return `data: {}` and only `message` is useful.
class ProfileActionResponseModel {
  final String message;

  const ProfileActionResponseModel({required this.message});

  factory ProfileActionResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileActionResponseModel(
      message: json['message']?.toString() ?? '',
    );
  }
}