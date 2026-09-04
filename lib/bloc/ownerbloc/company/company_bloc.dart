
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/companyprovider.dart';
import '../../../models/owner_models/addcompanymodel.dart';
import 'company_event.dart';
import 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc({required CompanyProvider provider})
      : _provider = provider,
        super(const CompanyState()) {
    on<LoadCompanies>(_onLoadCompanies);
    on<AddCompanyRequested>(_onAddCompany);
    on<UpdateCompanyRequested>(_onUpdateCompany);
    on<DeleteCompanyRequested>(_onDeleteCompany);
    on<CompanyMessageConsumed>(_onMessageConsumed);
  }

  final CompanyProvider _provider;

  Future<void> _onLoadCompanies(
      LoadCompanies event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(status: CompanyStatus.loading, clearError: true));
    final result = await _provider.getCompanies();

    if (result.success) {
      emit(state.copyWith(status: CompanyStatus.loaded, companies: result.companies));
    } else {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: result.errorMessage,
      ));
    }
  }

  /// POST /companies/create returns an empty `data: {}`, so there's no id
  /// or company object to insert into the list locally. On success this
  /// re-dispatches LoadCompanies to pick up the new row from the server.
  Future<void> _onAddCompany(
      AddCompanyRequested event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    final result = await _provider.addCompany(
      CompanyModel(id: '', name: event.name, code: event.code, website: event.website),
    );

    if (result.success) {
      emit(state.copyWith(isSubmitting: false, successMessage: result.message));
      add(const LoadCompanies());
    } else {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.errorMessage));
    }
  }

  Future<void> _onUpdateCompany(
      UpdateCompanyRequested event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    final result = await _provider.updateCompany(
      CompanyModel(id: event.id, name: event.name, code: event.code, website: event.website),
    );

    if (result.success) {
      final updated = state.companies
          .map((c) => c.id == event.id
          ? c.copyWith(
        name: event.name,
        code: event.code,
        website: event.website,
        clearWebsite: event.website == null,
      )
          : c)
          .toList();
      emit(state.copyWith(
        isSubmitting: false,
        companies: updated,
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.errorMessage));
    }
  }

  Future<void> _onDeleteCompany(
      DeleteCompanyRequested event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    final result = await _provider.deleteCompany(event.id);

    if (result.success) {
      final updated = state.companies.where((c) => c.id != event.id).toList();
      emit(state.copyWith(
        isSubmitting: false,
        companies: updated,
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.errorMessage));
    }
  }

  void _onMessageConsumed(
      CompanyMessageConsumed event,
      Emitter<CompanyState> emit,
      ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}