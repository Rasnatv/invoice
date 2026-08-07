import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/companyprovider.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/addcompanymodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/company_bloc.dart';
import '../../bloc/ownerbloc/company_event.dart';
import '../../bloc/ownerbloc/company_state.dart';

/// Lists all companies and lets the owner add / edit / delete them.
/// Wrapped in its own BlocProvider so it can be pushed from anywhere
/// without the caller needing to know about CompanyBloc.
class CompanySetupScreen extends StatelessWidget {
  const CompanySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      CompanyBloc(provider: CompanyProvider())..add(const LoadCompanies()),
      child: const _CompanySetupView(),
    );
  }
}

class _CompanySetupView extends StatefulWidget {
  const _CompanySetupView();

  @override
  State<_CompanySetupView> createState() => _CompanySetupViewState();
}

class _CompanySetupViewState extends State<_CompanySetupView> {
  Future<void> _openCompanyForm(BuildContext context, {CompanyModel? company}) async {
    final bloc = context.read<CompanyBloc>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: company?.name);
    final codeCtrl = TextEditingController(text: company?.code);
    final websiteCtrl = TextEditingController(text: company?.website);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: Responsive.w(16),
            right: Responsive.w(16),
            top: Responsive.h(16),
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + Responsive.h(16),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company == null ? 'Add Company' : 'Edit Company',
                  style: AppTextStyles.h6(),
                ),
                SizedBox(height: Responsive.h(16)),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: (v) =>
                      DValidator.validateRequired(v, message: 'Company name is required'),
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Company Code'),
                  validator: (v) =>
                      DValidator.validateRequired(v, message: 'Company code is required'),
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: websiteCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Website (optional)',
                    hintText: 'https://example.com',
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return null;
                    final uri = Uri.tryParse(value);
                    if (uri == null || !(uri.isScheme('HTTP') || uri.isScheme('HTTPS'))) {
                      return 'Enter a valid URL starting with http:// or https://';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.h(20)),
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<CompanyBloc, CompanyState>(
                    bloc: bloc,
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          final website = websiteCtrl.text.trim();
                          if (company == null) {
                            bloc.add(AddCompanyRequested(
                              name: nameCtrl.text.trim(),
                              code: codeCtrl.text.trim(),
                              website: website.isEmpty ? null : website,
                            ));
                          } else {
                            bloc.add(UpdateCompanyRequested(
                              id: company.id,
                              name: nameCtrl.text.trim(),
                              code: codeCtrl.text.trim(),
                              website: website.isEmpty ? null : website,
                            ));
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          company == null ? 'Add' : 'Update',
                          style: AppTextStyles.bodyBold().copyWith(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _confirmDelete(BuildContext context, CompanyModel company) async {
    final bloc = context.read<CompanyBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Company?',
      message: 'This will remove "${company.name}". This cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed) {
      bloc.add(DeleteCompanyRequested(company.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<CompanyBloc, CompanyState>(
      listenWhen: (previous, current) =>
      previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppSnackbar.error(state.errorMessage!);
          context.read<CompanyBloc>().add(const CompanyMessageConsumed());
        } else if (state.successMessage != null) {
          AppSnackbar.success(state.successMessage!);
          context.read<CompanyBloc>().add(const CompanyMessageConsumed());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Company Setup', style: AppTextStyles.h6())),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openCompanyForm(context),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('Add Company', style: AppTextStyles.bodyBold().copyWith(color: Colors.white)),
        ),
        body: SafeArea(
          child: BlocBuilder<CompanyBloc, CompanyState>(
            builder: (context, state) {
              if (state.status == CompanyStatus.loading && state.companies.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == CompanyStatus.failure && state.companies.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage ?? 'Something went wrong',
                          style: AppTextStyles.subtitle(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: Responsive.h(12)),
                        OutlinedButton(
                          onPressed: () => context.read<CompanyBloc>().add(const LoadCompanies()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.companies.isEmpty) {
                return Center(
                  child: Text('No companies added yet', style: AppTextStyles.subtitle()),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => context.read<CompanyBloc>().add(const LoadCompanies()),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(16),
                    Responsive.h(14),
                    Responsive.w(16),
                    Responsive.h(90),
                  ),
                  itemCount: state.companies.length,
                  separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                  itemBuilder: (context, index) {
                    final company = state.companies[index];
                    return _CompanyCard(
                      company: company,
                      onEdit: () => _openCompanyForm(context, company: company),
                      onDelete: () => _confirmDelete(context, company),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onEdit, required this.onDelete});

  final CompanyModel company;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        company.name,
                        style: AppTextStyles.bodyBold(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        company.code,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (company.website != null) ...[
                  SizedBox(height: Responsive.h(3)),
                  Text(
                    company.website!,
                    style: AppTextStyles.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}