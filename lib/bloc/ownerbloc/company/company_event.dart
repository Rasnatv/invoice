abstract class CompanyEvent {
  const CompanyEvent();
}

/// Fetches the current list of companies from the API.
class LoadCompanies extends CompanyEvent {
  const LoadCompanies();
}

class AddCompanyRequested extends CompanyEvent {
  const AddCompanyRequested({
    required this.name,
    required this.code,
    this.website,
  });

  final String name;
  final String code;
  final String? website;
}

class UpdateCompanyRequested extends CompanyEvent {
  const UpdateCompanyRequested({
    required this.id,
    required this.name,
    required this.code,
    this.website,
  });

  final String id;
  final String name;
  final String code;
  final String? website;
}

class DeleteCompanyRequested extends CompanyEvent {
  const DeleteCompanyRequested(this.id);

  final String id;
}

/// Fired once the UI has shown the current error/success message, so the
/// same message doesn't re-trigger a snackbar on the next rebuild.
class CompanyMessageConsumed extends CompanyEvent {
  const CompanyMessageConsumed();
}