

import '../../models/owner_models/addcompanymodel.dart';

enum CompanyStatus { initial, loading, loaded, failure }

class CompanyState {
  const CompanyState({
    this.status = CompanyStatus.initial,
    this.companies = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final CompanyStatus status;
  final List<CompanyModel> companies;

  /// True while an add/update/delete call is in flight. Kept separate from
  /// [status] so the list stays visible instead of flashing a full loader
  /// every time the user adds or edits a company.
  final bool isSubmitting;

  final String? errorMessage;
  final String? successMessage;

  CompanyState copyWith({
    CompanyStatus? status,
    List<CompanyModel>? companies,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return CompanyState(
      status: status ?? this.status,
      companies: companies ?? this.companies,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
      clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}