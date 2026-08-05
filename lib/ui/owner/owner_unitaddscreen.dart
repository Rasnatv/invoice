import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/unitprovider.dart';
import '../../models/owner_models/uintmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/unit_bloc.dart';
import '../../bloc/ownerbloc/unit_event.dart';
import '../../bloc/ownerbloc/unit_state.dart';

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
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + Responsive.h(16),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit == null ? 'Add Unit' : 'Edit Unit', style: AppTextStyles.h6()),
                SizedBox(height: Responsive.h(16)),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Unit Name'),
                  validator: (v) =>
                      DValidator.validateRequired(v, message: 'Unit name is required'),
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: abbrCtrl,
                  decoration: const InputDecoration(labelText: 'Abbreviation'),
                  validator: (v) =>
                      DValidator.validateRequired(v, message: 'Abbreviation is required'),
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
                          if (!(formKey.currentState?.validate() ?? false)) return;
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
                          unit == null ? 'Add' : 'Update',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Unit Setup', style: AppTextStyles.h6())),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openUnitForm(context),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('Add Unit', style: AppTextStyles.bodyBold().copyWith(color: Colors.white)),
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
                          onPressed: () => context.read<UnitBloc>().add(const LoadUnits()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.units.isEmpty) {
                return Center(child: Text('No units added yet', style: AppTextStyles.subtitle()));
              }

              return RefreshIndicator(
                onRefresh: () async => context.read<UnitBloc>().add(const LoadUnits()),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(16),
                    Responsive.h(14),
                    Responsive.w(16),
                    Responsive.h(90),
                  ),
                  itemCount: state.units.length,
                  separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                  itemBuilder: (context, index) {
                    final unit = state.units[index];
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
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit, required this.onEdit, required this.onDelete});

  final UnitModel unit;
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit.name, style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(3)),
                Text(unit.abbreviation, style: AppTextStyles.caption()),
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