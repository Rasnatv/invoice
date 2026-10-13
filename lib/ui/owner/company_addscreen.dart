
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/companyprovider.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/addcompanymodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/company/company_bloc.dart';
import '../../bloc/ownerbloc/company/company_event.dart';
import '../../bloc/ownerbloc/company/company_state.dart';

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
  // ---------------- UNCHANGED: form logic ----------------
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
                  company == null ? 'Add Brand' : 'Edit Brand',
                  style: AppTextStyles.h6(),
                ),
                SizedBox(height: Responsive.h(16)),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: DValidator.brandNameText,
                  decoration: const InputDecoration(labelText: 'Brand Name'),
                  validator: DValidator.validateBrandName,
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: DValidator.brandCodeText,
                  decoration: const InputDecoration(labelText: 'Brand Code'),
                  validator: DValidator.validateBrandCode,
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: websiteCtrl,
                  keyboardType: TextInputType.url,
                  inputFormatters: DValidator.textWithLimit,
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

  // ---------------- UNCHANGED: delete logic ----------------
  Future<void> _confirmDelete(BuildContext context, CompanyModel company) async {
    final bloc = context.read<CompanyBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Brand?',
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
        child: NetworkAwareWrapper(child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text('Brand Setup', style: AppTextStyles.h6())),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openCompanyForm(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Add Brand', style: AppTextStyles.bodyBold().copyWith(color: Colors.white)),
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

                // ---------------- NEW: modern empty state ----------------
                if (state.companies.isEmpty) {
                  return const _EmptyBrands();
                }

                // ---------------- NEW: modern list ----------------
                return RefreshIndicator(
                  onRefresh: () async => context.read<CompanyBloc>().add(const LoadCompanies()),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      Responsive.w(16),
                      Responsive.h(14),
                      Responsive.w(16),
                      Responsive.h(90),
                    ),
                    // +1 => section title
                    itemCount: state.companies.length + 1,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: Responsive.h(index == 0 ? 14 : 10)),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _SectionTitle(title: 'All Brands');
                      }
                      final company = state.companies[index - 1];
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
        ));
  }
}

/// NEW: Small section label above the list.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Text(title, style: AppTextStyles.bodyBold()),
      ],
    );
  }
}

/// NEW: Clean centered empty state.
class _EmptyBrands extends StatelessWidget {
  const _EmptyBrands();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_outlined, size: 40, color: AppColors.primary),
            ),
            SizedBox(height: Responsive.h(16)),
            Text('No brands added yet', style: AppTextStyles.bodyBold()),
            SizedBox(height: Responsive.h(6)),
            Text(
              'Tap "Add Brand" to create your first brand.',
              style: AppTextStyles.caption(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// RESTYLED: Modern brand card (avatar + name + code chip + website).
class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onEdit, required this.onDelete});

  final CompanyModel company;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String get _initial {
    final name = company.name.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasWebsite = company.website != null && company.website!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _initial,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: Responsive.w(12)),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(6)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            company.code,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasWebsite) ...[
                      SizedBox(width: Responsive.w(8)),
                      Icon(Icons.language_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          company.website!,
                          style: AppTextStyles.caption(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Menu
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
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