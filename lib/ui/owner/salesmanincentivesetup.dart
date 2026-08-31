
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/addincentive/addincentive_bloc.dart';
import '../../bloc/ownerbloc/addincentive/addincentive_event.dart';
import '../../bloc/ownerbloc/addincentive/addincentive_state.dart';
import '../../models/owner_models/owner_incentivesetupmodel.dart';

/// SCREEN 1 — "Add Incentive"
///
/// Loads the salesman list from GET /salesman-incentive-setup, which
/// already carries each salesman's current-month setup status
/// (has_setup / display_text / month_year) — that IS the "active
/// salesman" list, no separate endpoint needed.
class AddIncentiveScreen extends StatelessWidget {
  const AddIncentiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesmanIncentiveBloc()..add(const LoadSalesmanIncentiveList()),
      child: const _AddIncentiveView(),
    );
  }
}

class _AddIncentiveView extends StatefulWidget {
  const _AddIncentiveView();

  @override
  State<_AddIncentiveView> createState() => _AddIncentiveViewState();
}

class _AddIncentiveViewState extends State<_AddIncentiveView> {
  String? _selectedId;

  // The list endpoint reports each salesman's status for the CURRENT
  // month, so remove/edit here act on today's year/month.
  final DateTime _period = DateTime.now();
  String get _year => _period.year.toString();
  String get _month => _period.month.toString();

  void _ensureSelection(List<SalesmanIncentiveListItem> list) {
    if (list.isEmpty) {
      _selectedId = null;
      return;
    }
    if (_selectedId == null || !list.any((s) => s.id == _selectedId)) {
      _selectedId = list.first.id;
    }
  }

  Future<void> _openSetup(SalesmanIncentiveListItem salesman) async {
    final bloc = context.read<SalesmanIncentiveBloc>();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SalesmanIncentiveSetupScreen(
            salesmanId: salesman.id,
            salesmanName: salesman.name,
            initialYear: _year,
            initialMonth: _month,
          ),
        ),
      ),
    );
    if (changed == true && mounted) {
      bloc.add(const LoadSalesmanIncentiveList());
    }
  }

  Future<void> _confirmRemove(SalesmanIncentiveListItem salesman) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove Incentive?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will remove the monthly target and incentive set up for ${salesman.name}. This cannot be undone.',
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
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<SalesmanIncentiveBloc>().add(
        DeleteSalesmanIncentiveSetup(
          SalesmanIncentiveSetupQueryRequest(salesmanId: salesman.id, year: _year, month: _month),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Add Incentive', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocConsumer<SalesmanIncentiveBloc, SalesmanIncentiveState>(
          listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus &&
              current.actionStatus != SalesmanIncentiveActionStatus.submitting,
          listener: (context, state) {
            if (state.actionStatus == SalesmanIncentiveActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage ?? 'Done')),
              );
              context.read<SalesmanIncentiveBloc>().add(const LoadSalesmanIncentiveList());
            } else if (state.actionStatus == SalesmanIncentiveActionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionError ?? 'Something went wrong. Please try again.')),
              );
            }
          },
          builder: (context, state) {
            if (state.listStatus == SalesmanIncentiveListStatus.loading ||
                state.listStatus == SalesmanIncentiveListStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.listStatus == SalesmanIncentiveListStatus.failure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.w(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.listError ?? 'Failed to load salesmen.',
                        style: AppTextStyles.caption(),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.h(12)),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<SalesmanIncentiveBloc>().add(const LoadSalesmanIncentiveList()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final list = state.list;
            if (list.isEmpty) {
              return Center(child: Text('No salesmen found.', style: AppTextStyles.caption()));
            }

            _ensureSelection(list);
            final selected = list.firstWhere((s) => s.id == _selectedId, orElse: () => list.first);
            final isSubmitting = state.actionStatus == SalesmanIncentiveActionStatus.submitting;

            return ListView(
              padding: EdgeInsets.all(Responsive.w(16)),
              children: [
                Text(
                  'Select a salesman to add or update their monthly target and incentive.',
                  style: AppTextStyles.caption(),
                ),
                SizedBox(height: Responsive.h(16)),

                Text('Salesman', style: AppTextStyles.caption()),
                SizedBox(height: Responsive.h(6)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selected.id,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: [
                        for (final s in list)
                          DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name,
                                style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13.5))),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedId = v);
                      },
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(14)),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(10)),
                  decoration: BoxDecoration(
                    color: selected.hasSetup
                        ? AppColors.primary.withOpacity(0.08)
                        : AppColors.textSecondary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected.hasSetup ? Icons.check_circle_outline : Icons.info_outline,
                        size: 16,
                        color: selected.hasSetup ? AppColors.primary : AppColors.textSecondary,
                      ),
                      SizedBox(width: Responsive.w(8)),
                      Expanded(
                        child: Text(
                          selected.hasSetup
                              ? 'Current: ${selected.displayText} · ${selected.monthYear}'
                              : 'No incentive added yet for ${selected.name}.',
                          style: AppTextStyles.caption(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(20)),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSubmitting ? null : () => _openSetup(selected),
                    child: Text(
                      selected.hasSetup ? 'Edit Incentive Setup' : 'Setup Incentive',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                if (selected.hasSetup) ...[
                  SizedBox(height: Responsive.h(10)),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: isSubmitting ? null : () => _confirmRemove(selected),
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      label: const Text('Remove Incentive', style: TextStyle(color: AppColors.error)),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// SCREEN 2 — "Salesman Monthly Incentive Setup"
///
/// Opened only after a salesman is picked on AddIncentiveScreen. Loads
/// the existing setup (if any) for the chosen year/month via
/// POST /salesman-incentive-setup/get, and saves via
/// POST /salesman-incentive-setup/save. Shares the same
/// SalesmanIncentiveBloc instance as screen 1 (passed via
/// BlocProvider.value).
class SalesmanIncentiveSetupScreen extends StatefulWidget {
  const SalesmanIncentiveSetupScreen({
    super.key,
    required this.salesmanId,
    required this.salesmanName,
    required this.initialYear,
    required this.initialMonth,
  });

  final String salesmanId;
  final String salesmanName;
  final String initialYear;
  final String initialMonth;

  @override
  State<SalesmanIncentiveSetupScreen> createState() => _SalesmanIncentiveSetupScreenState();
}

class _SalesmanIncentiveSetupScreenState extends State<SalesmanIncentiveSetupScreen> {
  late int _month = int.parse(widget.initialMonth);
  late int _year = int.parse(widget.initialYear);

  bool _enabled = false;
  bool _useTarget = false;
  BonusType _bonusType = BonusType.fixed;
  final _targetCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hadExistingSetup = false;

  @override
  void initState() {
    super.initState();
    _fetchForPeriod();
  }

  void _fetchForPeriod() {
    context.read<SalesmanIncentiveBloc>().add(
      LoadSalesmanIncentiveSetup(
        salesmanId: widget.salesmanId,
        year: _year.toString(),
        month: _month.toString(),
      ),
    );
  }

  void _applyDetail(SalesmanIncentiveSetupDetail? detail) {
    _hadExistingSetup = detail != null;
    if (detail == null) {
      _enabled = false;
      _useTarget = false;
      _bonusType = BonusType.fixed;
      _targetCtrl.text = '';
      _bonusCtrl.text = '';
      return;
    }
    _enabled = true;
    _useTarget = detail.hasTarget;
    _bonusType = detail.bonusTypeEnum;
    _targetCtrl.text = detail.hasTarget ? detail.targetAmount.toStringAsFixed(0) : '';
    _bonusCtrl.text = detail.bonusValue == 0 ? '' : _trimZeros(detail.bonusValue);
  }

  String _trimZeros(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  void _save() {
    if (_enabled && !_formKey.currentState!.validate()) return;
    context.read<SalesmanIncentiveBloc>().add(
      SaveSalesmanIncentiveSetup(
        SalesmanIncentiveSetupSaveRequest(
          salesmanId: widget.salesmanId,
          year: _year.toString(),
          month: _month.toString(),
          targetAmount: _useTarget ? double.parse(_targetCtrl.text.trim()) : 0,
          bonusType: _bonusType,
          bonusValue: _enabled ? double.parse(_bonusCtrl.text.trim()) : 0,
          hasTarget: _enabled && _useTarget,
        ),
      ),
    );
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove Incentive?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will remove the monthly target and incentive set up for ${widget.salesmanName}. This cannot be undone.',
          style: AppTextStyles.caption(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<SalesmanIncentiveBloc>().add(
        DeleteSalesmanIncentiveSetup(
          SalesmanIncentiveSetupQueryRequest(
            salesmanId: widget.salesmanId,
            year: _year.toString(),
            month: _month.toString(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _bonusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currentYear = DateTime.now().year;
    final years = [for (int y = currentYear - 1; y <= currentYear + 2; y++) y];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Salesman Monthly Incentive Setup', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocConsumer<SalesmanIncentiveBloc, SalesmanIncentiveState>(
          listenWhen: (previous, current) =>
          (previous.detailStatus != current.detailStatus &&
              current.detailStatus == SalesmanIncentiveDetailStatus.success) ||
              (previous.actionStatus != current.actionStatus &&
                  current.actionStatus != SalesmanIncentiveActionStatus.submitting),
          listener: (context, state) {
            if (state.detailStatus == SalesmanIncentiveDetailStatus.success) {
              setState(() => _applyDetail(state.detail));
            }
            if (state.actionStatus == SalesmanIncentiveActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage ?? 'Done')),
              );
              Navigator.of(context).pop(true);
            } else if (state.actionStatus == SalesmanIncentiveActionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionError ?? 'Something went wrong. Please try again.')),
              );
            }
          },
          builder: (context, state) {
            final isLoadingDetail = state.detailStatus == SalesmanIncentiveDetailStatus.loading;
            final isSubmitting = state.actionStatus == SalesmanIncentiveActionStatus.submitting;

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(16)),
                children: [
                  Text('Assigned Salesman', style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(6)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withOpacity(0.18),
                          child: Text(
                            widget.salesmanName.isNotEmpty ? widget.salesmanName[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: Responsive.w(10)),
                        Expanded(
                          child: Text(
                            widget.salesmanName,
                            style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16)),
                          ),
                        ),
                        if (isLoadingDetail)
                          const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(18)),

                  Text('Applies to', style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(6)),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<int>(
                          value: _month,
                          isExpanded: true,
                          decoration: const InputDecoration(hintText: 'Month'),
                          items: [
                            for (int m = 1; m <= 12; m++)
                              DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(0, m)))),
                          ],
                          onChanged: isLoadingDetail
                              ? null
                              : (v) {
                            if (v != null && v != _month) {
                              setState(() => _month = v);
                              _fetchForPeriod();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int>(
                          value: _year,
                          isExpanded: true,
                          decoration: const InputDecoration(hintText: 'Year'),
                          items: [for (final y in years) DropdownMenuItem(value: y, child: Text('$y'))],
                          onChanged: isLoadingDetail
                              ? null
                              : (v) {
                            if (v != null && v != _year) {
                              setState(() => _year = v);
                              _fetchForPeriod();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),

                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _enabled,
                    onChanged: isLoadingDetail ? null : (v) => setState(() => _enabled = v),
                    title: Text('Bonus for this month?', style: AppTextStyles.bodyBold()),
                    subtitle: Text(
                      _enabled ? 'Yes — fill in the details below.' : 'No bonus set up. Nothing else to fill in.',
                      style: AppTextStyles.caption(),
                    ),
                  ),

                  if (_enabled) ...[
                    const Divider(height: 24, color: AppColors.border),

                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _useTarget,
                      onChanged: (v) => setState(() => _useTarget = v),
                      title: Text('Set a sales target', style: AppTextStyles.bodyBold()),
                      subtitle: Text(
                        _useTarget
                            ? 'Bonus is paid only after ${widget.salesmanName} crosses this target.'
                            : 'Off: bonus applies to total monthly sales, no target needed.',
                        style: AppTextStyles.caption(),
                      ),
                    ),
                    if (_useTarget) ...[
                      SizedBox(height: Responsive.h(10)),
                      Text('Monthly Target Amount (₹)', style: AppTextStyles.caption()),
                      SizedBox(height: Responsive.h(6)),
                      TextFormField(
                        controller: _targetCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: 'e.g. 300000'),
                        validator: (v) {
                          if (!_enabled || !_useTarget) return null;
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.h(16)),
                    ],

                    Text('Incentive Type', style: AppTextStyles.caption()),
                    SizedBox(height: Responsive.h(6)),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Fixed Amount'),
                            selected: _bonusType == BonusType.fixed,
                            selectedColor: AppColors.primary.withOpacity(0.18),
                            onSelected: (_) => setState(() => _bonusType = BonusType.fixed),
                          ),
                        ),
                        SizedBox(width: Responsive.w(10)),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Percentage'),
                            selected: _bonusType == BonusType.percent,
                            selectedColor: AppColors.primary.withOpacity(0.18),
                            onSelected: (_) => setState(() => _bonusType = BonusType.percent),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(16)),

                    Text(
                      _bonusType == BonusType.fixed
                          ? (_useTarget ? 'Incentive Amount (₹) if Target Reached' : 'Incentive Amount (₹) on Total Sales')
                          : (_useTarget ? 'Incentive % if Target Reached' : 'Incentive % on Total Sales'),
                      style: AppTextStyles.caption(),
                    ),
                    SizedBox(height: Responsive.h(6)),
                    TextFormField(
                      controller: _bonusCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: _bonusType == BonusType.fixed ? 'e.g. 5000' : 'e.g. 2',
                        prefixText: _bonusType == BonusType.fixed ? '₹ ' : null,
                        suffixText: _bonusType == BonusType.percent ? '%' : null,
                      ),
                      validator: (v) {
                        if (!_enabled) return null;
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ],

                  if (_hadExistingSetup) ...[
                    SizedBox(height: Responsive.h(16)),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: isSubmitting ? null : _remove,
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        label: const Text('Remove Incentive', style: TextStyle(color: AppColors.error)),
                      ),
                    ),
                  ],
                  SizedBox(height: Responsive.h(28)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(10), Responsive.w(16), Responsive.h(14)),
          child: BlocBuilder<SalesmanIncentiveBloc, SalesmanIncentiveState>(
            builder: (context, state) {
              final isSubmitting = state.actionStatus == SalesmanIncentiveActionStatus.submitting;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                  ),
                  onPressed: isSubmitting ? null : _save,
                  child: isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}