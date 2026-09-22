
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_bloc.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_event.dart' hide LoadActiveSalesmen;
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import 'ownercontractorreportscreen.dart';
import 'ownersalesmanreportscreen.dart';

enum ReportPersonType { salesman, contractor }

/// Filter screen shown before generating a Salesman/Contractor report.
/// Matches mockup frame 2. Options are now loaded from the real
/// GET /salesmen/active and GET /reports/contractors/active endpoints.
class OwnerReportFilterScreen extends StatelessWidget {
  const OwnerReportFilterScreen({
    super.key,
    required this.type,
    this.initialPersonId,
    this.initialStart,
    this.initialEnd,
  });

  final ReportPersonType type;
  final String? initialPersonId;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  Widget build(BuildContext context) {
    // If OwnerReportsBloc is already provided higher up your widget tree,
    // swap this for BlocProvider.value(value: context.read<OwnerReportsBloc>(), ...)
    return BlocProvider(
      create: (_) => OwnerReportsBloc()
        ..add(newLoadActiveSalesmen())
        ..add(const LoadActiveContractors()),
      child: _OwnerReportFilterView(
        type: type,
        initialPersonId: initialPersonId,
        initialStart: initialStart,
        initialEnd: initialEnd,
      ),
    );
  }
}

class _DropdownEntry {
  const _DropdownEntry(this.id, this.label);
  final String id;
  final String label;
}

class _OwnerReportFilterView extends StatefulWidget {
  const _OwnerReportFilterView({
    required this.type,
    this.initialPersonId,
    this.initialStart,
    this.initialEnd,
  });

  final ReportPersonType type;
  final String? initialPersonId;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<_OwnerReportFilterView> createState() => _OwnerReportFilterViewState();
}

class _OwnerReportFilterViewState extends State<_OwnerReportFilterView> {
  String? _selectedId;
  late DateTime _startDate;
  late DateTime _endDate;

  bool get _isSalesman => widget.type == ReportPersonType.salesman;
  String get _label => _isSalesman ? 'SELECT SALESMAN' : 'SELECT CONTRACTOR';
  String get _hint => _isSalesman ? 'Select Salesman' : 'Select Contractor';

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialPersonId;
    final now = DateTime.now();
    _startDate = widget.initialStart ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEnd ?? DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _generate(OwnerReportsState state) {
    final id = _selectedId;
    if (id == null) return;

    if (_isSalesman) {
      final match = state.activeSalesmen.where((s) => s.id == id);
      final name = match.isNotEmpty ? match.first.name : '';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OwnerSalesmanReportScreen(
            salesmanId: id,
            salesmanName: name,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    } else {
      final match = state.activeContractors.where((c) => c.id == id);
      final name = match.isNotEmpty ? match.first.name : '';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OwnerContractorReportScreen(
            contractorId: id,
            contractorName: name,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    }
  }

  /// Safely clears a selection that's no longer valid, AFTER the current
  /// build finishes. Mutating state directly inside build() can leave the
  /// UI stuck, so this defers it to a post-frame callback.
  void _clearInvalidSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedId != null) {
        setState(() => _selectedId = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final dateFmt = DateFormat('dd MMM yyyy');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Reports', style: AppTextStyles.h6())),
        body: Column(
          children: [
            // ReportHeaderBar(title: _title, showBack: true),
            Expanded(
              child: BlocBuilder<OwnerReportsBloc, OwnerReportsState>(
                builder: (context, state) {
                  final loading = _isSalesman
                      ? state.activeSalesmenStatus == LoadStatus.loading
                      : state.activeContractorsStatus == LoadStatus.loading;
                  final error = _isSalesman
                      ? state.activeSalesmenError
                      : state.activeContractorsError;

                  // Skip entries with a null/blank name entirely — only
                  // show salesmen/contractors that actually have a real
                  // name, never a placeholder or blank row.
                  final options = _isSalesman
                      ? state.activeSalesmen
                      .where((s) => (s.name.trim()).isNotEmpty)
                      .map((s) => _DropdownEntry(s.id, s.name.trim()))
                      .toList()
                      : state.activeContractors
                      .where((c) => (c.name.trim()).isNotEmpty)
                      .map((c) => _DropdownEntry(c.id, c.name.trim()))
                      .toList();

                  final isEmpty = !loading && error == null && options.isEmpty;

                  // If a previously-selected id no longer exists in the
                  // freshly-loaded list, clear it safely (post-frame),
                  // never mutate state directly during build.
                  if (_selectedId != null &&
                      options.isNotEmpty &&
                      options.every((o) => o.id != _selectedId)) {
                    _clearInvalidSelection();
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(Responsive.w(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _label,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: Responsive.sp(11),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(height: Responsive.h(8)),
                        if (loading)
                          Container(
                            height: Responsive.h(52),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (error != null)
                          Text(
                            error,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: Responsive.sp(12.5),
                            ),
                          )
                        else if (isEmpty)
                          // Never render DropdownButton with an empty items
                          // list — that throws RangeError(length: 0) as soon
                          // as it's tapped/measured.
                            Container(
                              height: Responsive.h(52),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                _isSalesman
                                    ? 'No active salesmen found'
                                    : 'No active contractors found',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: Responsive.sp(13),
                                ),
                              ),
                            )
                          else
                            _DropdownField(
                              value: _selectedId,
                              hint: _hint,
                              options: options,
                              onChanged: (v) => setState(() => _selectedId = v),
                            ),
                        SizedBox(height: Responsive.h(20)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _DateField(
                                label: 'START DATE',
                                dateLabel: dateFmt.format(_startDate),
                                onTap: () => _pickDate(isStart: true),
                              ),
                            ),
                            SizedBox(width: Responsive.w(12)),
                            Expanded(
                              child: _DateField(
                                label: 'END DATE',
                                dateLabel: dateFmt.format(_endDate),
                                onTap: () => _pickDate(isStart: false),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(28)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            _selectedId == null ? null : () => _generate(state),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.4),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(15)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Generate Report',
                              style: AppTextStyles.bodyBold(color: Colors.white)
                                  .copyWith(fontSize: Responsive.sp(15)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });

  final String? value;
  final String? hint;
  final List<_DropdownEntry> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Extra safety net: if somehow called with empty options, never let
    // DropdownButton render — that's the direct cause of RangeError.
    if (options.isEmpty) {
      return Container(
        height: Responsive.h(52),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No options available',
          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
        ),
      );
    }

    // Guard: if value is set but doesn't match any item, DropdownButton
    // will assert/throw. Fall back to null (shows hint) instead of crashing.
    final safeValue = options.any((o) => o.id == value) ? value : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          hint: hint != null
              ? Text(
            hint!,
            style: AppTextStyles.bodyBold(color: AppColors.textSecondary)
                .copyWith(fontSize: Responsive.sp(14)),
          )
              : null,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          style: AppTextStyles.bodyBold(color: AppColors.black)
              .copyWith(fontSize: Responsive.sp(14)),
          items: options
              .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.dateLabel,
    required this.onTap,
  });

  final String label;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: Responsive.sp(11),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: Responsive.h(8)),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(14)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    dateLabel,
                    style: TextStyle(fontSize: Responsive.sp(13), color: AppColors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}