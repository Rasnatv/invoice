import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/owner/data/repository/company_addrepository.dart';
import 'company_event.dart';
import 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc({required CompanyRepository repository})
      : _repository = repository,
        super(const CompanyState()) {
    on<LoadCompanies>(_onLoadCompanies);
    on<AddCompanyRequested>(_onAddCompany);
    on<UpdateCompanyRequested>(_onUpdateCompany);
    on<DeleteCompanyRequested>(_onDeleteCompany);
    on<CompanyMessageConsumed>(_onMessageConsumed);
  }

  final CompanyRepository _repository;

  Future<void> _onLoadCompanies(
      LoadCompanies event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(status: CompanyStatus.loading, clearError: true));
    try {
      final companies = await _repository.fetchCompanies();
      emit(state.copyWith(status: CompanyStatus.loaded, companies: companies));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCompany(
      AddCompanyRequested event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    try {
      final created = await _repository.addCompany(
        name: event.name,
        code: event.code,
        website: event.website,
      );
      emit(state.copyWith(
        isSubmitting: false,
        companies: [...state.companies, created],
        successMessage: 'Company added successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCompany(
      UpdateCompanyRequested event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    try {
      await _repository.updateCompany(
        id: event.id,
        name: event.name,
        code: event.code,
        website: event.website,
      );
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
        successMessage: 'Company updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCompany(
      DeleteCompanyRequested event,
      Emitter<CompanyState> emit,
      ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    try {
      await _repository.deleteCompany(event.id);
      final updated = state.companies.where((c) => c.id != event.id).toList();
      emit(state.copyWith(
        isSubmitting: false,
        companies: updated,
        successMessage: 'Company deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  void _onMessageConsumed(
      CompanyMessageConsumed event,
      Emitter<CompanyState> emit,
      ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}