import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/unitprovider.dart';
import '../../models/owner_models/uintmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/unit/unit_bloc.dart';
import '../../bloc/ownerbloc/unit/unit_event.dart';
import '../../bloc/ownerbloc/unit/unit_state.dart';

/// Shared input decoration so every field uses the app font.
InputDecoration _inputDec(String label, {String? hint}) => InputDecoration(
  labelText: label,
  hintText: hint,
  labelStyle: AppTextStyles.body(color: AppColors.textHint),
  hintStyle: AppTextStyles.body(color: AppColors.textHint),
  errorStyle: AppTextStyles.caption(color: AppColors.error),
);

class UnitSetupScreen extends StatelessWidget {
  const UnitSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UnitBloc(provider: UnitProvider())..add(const LoadUnits()),
      child: const _UnitSetupView(),
    );
  }
}

class _UnitSetupView extends StatefulWidget {
  const _UnitSetupView();

  @override
  State<_UnitSetupView> createState() => _UnitSetupViewState();
}

class _UnitSetupViewState extends State<_UnitSetupView> {
  // ---------------- form logic (unchanged) ----------------
  Future<void> _openUnitForm(BuildContext context, {UnitModel? unit}) async {
    final bloc = context.read<UnitBloc>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: unit?.name);
    final abbrCtrl = TextEditingController(text: unit?.abbreviation);

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
            bottom:
            MediaQuery.of(sheetContext).viewInsets.bottom + Responsive.h(16),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit == null ? 'Add Unit' : 'Edit Unit',
                    style: AppTextStyles.h6()),
                SizedBox(height: Responsive.h(16)),
                TextFormField(
                  controller: nameCtrl,
                  style: AppTextStyles.body(),
                  decoration: _inputDec('Unit Name'),
                  inputFormatters: DValidator.unitNameText,
                  validator: DValidator.validateUnitName,
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: abbrCtrl,
                  style: AppTextStyles.body(),
                  decoration: _inputDec('Abbreviation'),
                  inputFormatters: DValidator.unitAbbrText,
                  validator: DValidator.validateUnitAbbr,
                ),
                SizedBox(height: Responsive.h(20)),
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<UnitBloc, UnitState>(
                    bloc: bloc,
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () {
                          if (!(formKey.currentState?.validate() ??
                              false)) {
                            return;
                          }
                          if (unit == null) {
                            bloc.add(AddUnitRequested(
                              name: nameCtrl.text.trim(),
                              abbreviation: abbrCtrl.text.trim(),
                            ));
                          } else {
                            bloc.add(UpdateUnitRequested(
                              id: unit.id,
                              name: nameCtrl.text.trim(),
                              abbreviation: abbrCtrl.text.trim(),
                            ));
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                              vertical: Responsive.h(12)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                          unit == null ? 'Add' : 'Update',
                          style: AppTextStyles.bodyBold(
                              color: Colors.white),
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

  // ---------------- delete logic (unchanged) ----------------
  Future<void> _confirmDelete(BuildContext context, UnitModel unit) async {
    final bloc = context.read<UnitBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Unit?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will remove "${unit.name}". This cannot be undone.',
          style: AppTextStyles.caption(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyBold()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete',
                style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(DeleteUnitRequested(unit.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<UnitBloc, UnitState>(
      listenWhen: (previous, current) =>
      previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppSnackbar.error(state.errorMessage!);
          context.read<UnitBloc>().add(const UnitMessageConsumed());
        } else if (state.successMessage != null) {
          AppSnackbar.success(state.successMessage!);
          context.read<UnitBloc>().add(const UnitMessageConsumed());
        }
      },
      child: NetworkAwareWrapper(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Unit Setup', style: AppTextStyles.h6()),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openUnitForm(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Unit',
              style: AppTextStyles.bodyBold(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<UnitBloc, UnitState>(
              builder: (context, state) {
                if (state.status == UnitStatus.loading && state.units.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == UnitStatus.failure && state.units.isEmpty) {
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
                            onPressed: () => context
                                .read<UnitBloc>()
                                .add(const LoadUnits()),
                            child: Text('Retry',
                                style: AppTextStyles.bodyBold(
                                    color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.units.isEmpty) {
                  return const _EmptyUnits();
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      context.read<UnitBloc>().add(const LoadUnits()),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      Responsive.w(16),
                      Responsive.h(14),
                      Responsive.w(16),
                      Responsive.h(90),
                    ),
                    // +1 => section title
                    itemCount: state.units.length + 1,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: Responsive.h(index == 0 ? 14 : 10)),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _SectionTitle(title: 'All Units');
                      }
                      final unit = state.units[index - 1];
                      return _UnitCard(
                        unit: unit,
                        onEdit: () => _openUnitForm(context, unit: unit),
                        onDelete: () => _confirmDelete(context, unit),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Small section label above the list.
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

/// Clean centered empty state.
class _EmptyUnits extends StatelessWidget {
  const _EmptyUnits();

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
              child: Icon(Icons.straighten_rounded,
                  size: 40, color: AppColors.primary),
            ),
            SizedBox(height: Responsive.h(16)),
            Text('No units added yet', style: AppTextStyles.bodyBold()),
            SizedBox(height: Responsive.h(6)),
            Text(
              'Tap "Add Unit" to create your first unit.',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Unit card (icon avatar + name + abbreviation chip).
class _UnitCard extends StatelessWidget {
  const _UnitCard(
      {required this.unit, required this.onEdit, required this.onDelete});

  final UnitModel unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
          // Icon avatar
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.straighten_rounded,
                size: 22, color: AppColors.primary),
          ),
          SizedBox(width: Responsive.w(12)),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(6)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unit.abbreviation,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: AppColors.primary,
                      fontSize: Responsive.sp(10.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            color: AppColors.surface,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: Icon(Icons.more_vert,
                size: 20, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Text('Edit', style: AppTextStyles.body()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Delete',
                        style: AppTextStyles.body(color: AppColors.error)),
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