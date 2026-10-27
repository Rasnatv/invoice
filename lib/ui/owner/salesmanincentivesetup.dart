
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/addincentive/addincentive_bloc.dart';
import '../../bloc/ownerbloc/addincentive/addincentive_event.dart';
import '../../bloc/ownerbloc/addincentive/addincentive_state.dart';
import '../../core/validator/validationfile.dart';
import '../../models/owner_models/owner_incentivesetupmodel.dart';
import '../../widgets/appsnackbar.dart';


/// Input decoration that uses the app font everywhere.
InputDecoration _dec(String hint, {String? prefixText, String? suffixText}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(color: AppColors.textHint),
      errorStyle: AppTextStyles.caption(color: AppColors.error),
      prefixText: prefixText,
      prefixStyle: AppTextStyles.body(),
      suffixText: suffixText,
      suffixStyle: AppTextStyles.body(),
    );

/// "Remove incentive?" confirmation used by both screens.
Future<bool?> _showRemoveDialog(BuildContext context, String salesmanName) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Remove Incentive?', style: AppTextStyles.bodyBold()),
      content: Text(
        'This will remove the monthly target and incentive set up for $salesmanName. This cannot be undone.',
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
          child:
          Text('Remove', style: AppTextStyles.bodyBold(color: Colors.white)),
        ),
      ],
    ),
  );
}

/// Green banner used when an incentive has already been paid.
class _PaidBanner extends StatelessWidget {
  const _PaidBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(12)),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 18),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(text,
                style: AppTextStyles.caption(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// White rounded block used for grouped content.
class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Pill chip used for Fixed / Percentage choice (same look as the
/// filter chips on Estimates). A null [onTap] means disabled.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(onTap == null ? 0.5 : 1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: Responsive.sp(12),
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.bodyBold()),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ADD INCENTIVE (salesman picker)
// =====================================================================

class AddIncentiveScreen extends StatelessWidget {
  const AddIncentiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      SalesmanIncentiveBloc()..add(const LoadSalesmanIncentiveList()),
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

  // Guards against a second push/dialog firing while one route
  // transition is still animating (e.g. fast double-tap on
  // "Setup Incentive" or "Remove Incentive"). Without this guard, two
  // overlapping transitions can crash with:
  //   Failed assertion: 'manifest.fromHero == newManifest.toHero'
  bool _isNavigating = false;

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
    if (_isNavigating) return; // block re-entry while already navigating
    _isNavigating = true;
    final bloc = context.read<SalesmanIncentiveBloc>();

    bloc.add(const ClearSalesmanIncentiveSetupDetail());

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
    _isNavigating = false;
    if (changed == true && mounted) {
      bloc.add(const LoadSalesmanIncentiveList());
    }
  }

  Future<void> _confirmRemove(SalesmanIncentiveListItem salesman) async {
    if (_isNavigating) return; // block re-entry while already navigating
    _isNavigating = true;
    final confirmed = await _showRemoveDialog(context, salesman.name);
    _isNavigating = false;
    if (confirmed == true && mounted) {
      context.read<SalesmanIncentiveBloc>().add(
        DeleteSalesmanIncentiveSetup(
          SalesmanIncentiveSetupQueryRequest(
              salesmanId: salesman.id, year: _year, month: _month),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Add Incentive', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: BlocConsumer<SalesmanIncentiveBloc, SalesmanIncentiveState>(
            listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus &&
                current.actionStatus != SalesmanIncentiveActionStatus.submitting,
            listener: (context, state) {
              if (state.actionStatus == SalesmanIncentiveActionStatus.success) {
                AppSnackbar.success(state.actionMessage ?? 'Done');
                context
                    .read<SalesmanIncentiveBloc>()
                    .add(const LoadSalesmanIncentiveList());
              } else if (state.actionStatus ==
                  SalesmanIncentiveActionStatus.failure) {
                AppSnackbar.error(state.actionError ??
                    'Something went wrong. Please try again.');
              }
            },
            builder: (context, state) {
              if (state.listStatus == SalesmanIncentiveListStatus.loading ||
                  state.listStatus == SalesmanIncentiveListStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.listStatus == SalesmanIncentiveListStatus.failure) {
                return _ErrorView(
                  message: state.listError ?? 'Failed to load salesmen.',
                  onRetry: () => context
                      .read<SalesmanIncentiveBloc>()
                      .add(const LoadSalesmanIncentiveList()),
                );
              }

              final list = state.list;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 44,
                        color: AppColors.textSecondary.withOpacity(0.4),
                      ),
                      SizedBox(height: Responsive.h(10)),
                      Text('No salesmen found', style: AppTextStyles.subtitle()),
                    ],
                  ),
                );
              }

              _ensureSelection(list);
              final selected = list.firstWhere((s) => s.id == _selectedId,
                  orElse: () => list.first);
              final isSubmitting =
                  state.actionStatus == SalesmanIncentiveActionStatus.submitting;

              return ListView(
                padding: EdgeInsets.all(Responsive.w(20)),
                children: [
                  Text(
                    'Select a salesman to add or update their monthly target and incentive.',
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  Text('Salesman', style: AppTextStyles.bodyBold()),
                  SizedBox(height: Responsive.h(6)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selected.id,
                        isExpanded: true,
                        style: AppTextStyles.body(),
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary),
                        items: [
                          for (final s in list)
                            DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name, style: AppTextStyles.body()),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(12),
                        vertical: Responsive.h(10)),
                    decoration: BoxDecoration(
                      color: selected.hasSetup
                          ? AppColors.primary.withOpacity(0.08)
                          : AppColors.textSecondary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected.hasSetup
                              ? Icons.check_circle_outline
                              : Icons.info_outline,
                          size: 16,
                          color: selected.hasSetup
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: Responsive.w(8)),
                        Expanded(
                          child: Text(
                            selected.hasSetup
                                ? 'Current: ${selected.displayText} · ${selected.monthYear}'
                                : 'No incentive added yet for ${selected.name}.',
                            style: AppTextStyles.caption(
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(20)),

                  // PAID -> no Edit / Remove buttons, only a banner.
                  if (selected.isPaid)
                    const _PaidBanner(
                        text:
                        'Incentive already paid for this month. Editing is disabled.')
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                              vertical: Responsive.h(14)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed:
                        isSubmitting ? null : () => _openSetup(selected),
                        child: Text(
                          selected.hasSetup
                              ? 'Edit Incentive Setup'
                              : 'Setup Incentive',
                          style: AppTextStyles.bodyBold(color: Colors.white),
                        ),
                      ),
                    ),
                    if (selected.hasSetup) ...[
                      SizedBox(height: Responsive.h(10)),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () => _confirmRemove(selected),
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.error),
                          label: Text(
                            'Remove Incentive',
                            style:
                            AppTextStyles.bodyBold(color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// SALESMAN MONTHLY INCENTIVE SETUP
// =====================================================================

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
  State<SalesmanIncentiveSetupScreen> createState() =>
      _SalesmanIncentiveSetupScreenState();
}

class _SalesmanIncentiveSetupScreenState
    extends State<SalesmanIncentiveSetupScreen> {
  late int _month = int.parse(widget.initialMonth);
  late int _year = int.parse(widget.initialYear);

  BonusType _bonusType = BonusType.fixed;
  final _targetCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hadExistingSetup = false;
  bool _isPaid = false; // true => read-only, no save/remove

  // Guards against a second dialog/pop firing while one action is
  // already in flight (e.g. fast double-tap on "Remove Incentive").
  bool _isNavigating = false;

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
    _isPaid = detail?.isPaid ?? false;
    if (detail == null) {
      _bonusType = BonusType.fixed;
      _targetCtrl.text = '';
      _bonusCtrl.text = '';
      return;
    }
    _bonusType = detail.bonusTypeEnum;
    _targetCtrl.text =
    detail.targetAmount > 0 ? detail.targetAmount.toStringAsFixed(0) : '';
    _bonusCtrl.text =
    detail.bonusValue == 0 ? '' : _trimZeros(detail.bonusValue);
  }

  // Called the instant the user switches month/year, BEFORE the new
  // /get response arrives, so stale values from the previous period
  // never stay visible on screen while the new period loads.
  void _resetFormForNewPeriod() {
    setState(() => _applyDetail(null));
  }

  String _trimZeros(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  /// Calendar picker for the month/year. Only last year and this year
  /// are selectable (no future years like 2028). Opens in year view;
  /// only the month and year of the tapped date are used.
  Future<void> _pickPeriod() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, 1, 1);
    final lastDate = DateTime(now.year, 12, 31);

    DateTime initial = DateTime(_year, _month, 1);
    if (initial.isAfter(lastDate)) initial = lastDate;
    if (initial.isBefore(firstDate)) initial = firstDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select month & year',
    );
    if (picked == null) return;

    if (picked.month != _month || picked.year != _year) {
      _month = picked.month;
      _year = picked.year;
      // Clear stale fields immediately, THEN refetch.
      _resetFormForNewPeriod();
      _fetchForPeriod();
    }
  }

  void _save() {
    if (_isPaid) return;
    if (!_formKey.currentState!.validate()) return;
    context.read<SalesmanIncentiveBloc>().add(
      SaveSalesmanIncentiveSetup(
        SalesmanIncentiveSetupSaveRequest(
          salesmanId: widget.salesmanId,
          year: _year.toString(),
          month: _month.toString(),
          targetAmount: double.parse(_targetCtrl.text.trim()),
          bonusType: _bonusType,
          bonusValue: double.parse(_bonusCtrl.text.trim()),
          hasTarget: true, // target is always required now
        ),
      ),
    );
  }

  Future<void> _remove() async {
    if (_isPaid) return;
    if (_isNavigating) return; // block re-entry while already navigating
    _isNavigating = true;
    final confirmed = await _showRemoveDialog(context, widget.salesmanName);
    _isNavigating = false;
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

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Salesman Monthly Incentive Setup',
            style: AppTextStyles.h6(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<SalesmanIncentiveBloc, SalesmanIncentiveState>(
                listenWhen: (previous, current) =>
                previous.detailStatus != current.detailStatus &&
                    current.detailStatus ==
                        SalesmanIncentiveDetailStatus.success,
                listener: (context, state) {
                  setState(() => _applyDetail(state.detail));
                },
              ),
              BlocListener<SalesmanIncentiveBloc, SalesmanIncentiveState>(
                listenWhen: (previous, current) =>
                previous.actionStatus != current.actionStatus &&
                    current.actionStatus !=
                        SalesmanIncentiveActionStatus.submitting,
                listener: (context, state) {
                  if (state.actionStatus ==
                      SalesmanIncentiveActionStatus.success) {
                    AppSnackbar.success(state.actionMessage ?? 'Done');
                    // Deferred to the next frame so the pop doesn't race
                    // the snackbar's own overlay animation.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) Navigator.of(context).pop(true);
                    });
                  } else if (state.actionStatus ==
                      SalesmanIncentiveActionStatus.failure) {
                    AppSnackbar.error(state.actionError ??
                        'Something went wrong. Please try again.');
                  }
                },
              ),
            ],
            child: BlocBuilder<SalesmanIncentiveBloc, SalesmanIncentiveState>(
              builder: (context, state) {
                final isLoadingDetail =
                    state.detailStatus == SalesmanIncentiveDetailStatus.loading;
                final isSubmitting = state.actionStatus ==
                    SalesmanIncentiveActionStatus.submitting;

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.w(20)),
                    children: [
                      Text('Assigned Salesman', style: AppTextStyles.bodyBold()),
                      SizedBox(height: Responsive.h(6)),
                      Container(
                        padding: EdgeInsets.all(Responsive.w(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.salesmanName.isNotEmpty
                                    ? widget.salesmanName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  color: AppColors.primary,
                                  fontSize: Responsive.sp(16),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: Responsive.w(12)),
                            Expanded(
                              child: Text(
                                widget.salesmanName,
                                style: AppTextStyles.bodyBold(),
                              ),
                            ),
                            if (isLoadingDetail)
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),

                      if (_isPaid) ...[
                        SizedBox(height: Responsive.h(12)),
                        const _PaidBanner(
                            text: 'Incentive already paid. Editing is disabled.'),
                      ],
                      SizedBox(height: Responsive.h(18)),

                      // ---- Month & year: calendar picker ----
                      Text('Applies to', style: AppTextStyles.bodyBold()),
                      SizedBox(height: Responsive.h(6)),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: isLoadingDetail ? null : _pickPeriod,
                        child: InputDecorator(
                          decoration: const InputDecoration(),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined,
                                  size: 20, color: AppColors.textSecondary),
                              SizedBox(width: Responsive.w(10)),
                              Expanded(
                                child: Text(
                                  DateFormat('MMMM yyyy')
                                      .format(DateTime(_year, _month)),
                                  style: AppTextStyles.body(),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(16)),

                      _Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---- Monthly target amount ----
                            Text('Monthly Target Amount (₹)',
                                style: AppTextStyles.bodyBold()),
                            SizedBox(height: Responsive.h(6)),
                            TextFormField(
                              controller: _targetCtrl,
                              enabled: !_isPaid,
                              style: AppTextStyles.body(),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: DValidator.targetNumber,
                              decoration: _dec('e.g. 300000'),
                              validator: DValidator.validateTargetAmount,
                            ),
                            SizedBox(height: Responsive.h(16)),

                            // ---- Incentive type ----
                            Text('Incentive Type',
                                style: AppTextStyles.bodyBold()),
                            SizedBox(height: Responsive.h(8)),
                            Row(
                              children: [
                                Expanded(
                                  child: _OptionChip(
                                    label: 'Fixed Amount',
                                    selected: _bonusType == BonusType.fixed,
                                    // Clear the old value on switch so a fixed amount
                                    // never carries over as a (wrong) percentage.
                                    onTap: _isPaid
                                        ? null
                                        : () => setState(() {
                                      _bonusType = BonusType.fixed;
                                      _bonusCtrl.clear();
                                    }),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(10)),
                                Expanded(
                                  child: _OptionChip(
                                    label: 'Percentage',
                                    selected: _bonusType == BonusType.percent,
                                    onTap: _isPaid
                                        ? null
                                        : () => setState(() {
                                      _bonusType = BonusType.percent;
                                      _bonusCtrl.clear();
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.h(16)),

                            Text(
                              _bonusType == BonusType.fixed
                                  ? 'Incentive Amount (₹) if Target Reached'
                                  : 'Incentive % if Target Reached',
                              style: AppTextStyles.bodyBold(),
                            ),
                            SizedBox(height: Responsive.h(6)),
                            TextFormField(
                              controller: _bonusCtrl,
                              enabled: !_isPaid,
                              style: AppTextStyles.body(),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: _bonusType == BonusType.percent
                                  ? DValidator.percentNumber
                                  : DValidator.fixedBonusNumber,
                              decoration: _dec(
                                _bonusType == BonusType.fixed
                                    ? 'e.g. 5000'
                                    : 'e.g. 2',
                                prefixText: _bonusType == BonusType.fixed
                                    ? '₹ '
                                    : null,
                                suffixText: _bonusType == BonusType.percent
                                    ? '%'
                                    : null,
                              ),
                              validator: (v) => DValidator.validateBonusValue(
                                v,
                                isPercent: _bonusType == BonusType.percent,
                                targetText: _targetCtrl.text,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remove is hidden once paid.
                      if (_hadExistingSetup && !_isPaid) ...[
                        SizedBox(height: Responsive.h(16)),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: isSubmitting ? null : _remove,
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.error),
                            label: Text(
                              'Remove Incentive',
                              style: AppTextStyles.bodyBold(
                                  color: AppColors.error),
                            ),
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
        ),

        // Save button is shown whenever the incentive is not paid.
        bottomNavigationBar: !_isPaid
            ? SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(20),
              Responsive.h(10),
              Responsive.w(20),
              Responsive.h(14),
            ),
            child: BlocBuilder<SalesmanIncentiveBloc,
                SalesmanIncentiveState>(
              builder: (context, state) {
                final isSubmitting = state.actionStatus ==
                    SalesmanIncentiveActionStatus.submitting;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding:
                      EdgeInsets.symmetric(vertical: Responsive.h(14)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: isSubmitting ? null : _save,
                    child: isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Save',
                      style: AppTextStyles.bodyBold(
                          color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        )
            : null,
      ),
    );
  }
}
