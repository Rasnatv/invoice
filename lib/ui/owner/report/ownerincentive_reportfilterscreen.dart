import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../bloc/ownerbloc/fieldstaffactive/owner_fieldstaffactive_bloc.dart';
import '../../../bloc/ownerbloc/fieldstaffactive/owner_fieldstaffactive_event.dart';
import '../../../bloc/ownerbloc/fieldstaffactive/owner_fieldstaffactive_state.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_bloc.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_event.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import 'owner_incentivereportscreen.dart';

enum IncentiveEntityType { salesman, fieldStaff }

/// Filter screen for the Incentive Report.
class OwnerIncentiveReportFilterScreen extends StatefulWidget {
  const OwnerIncentiveReportFilterScreen({
    super.key,
    this.initialType,
    this.initialPersonId,
    this.initialPerson,
    this.initialStart,
    this.initialEnd,
    this.initialStatus,
  });

  final IncentiveEntityType? initialType;
  final String? initialPersonId;
  final String? initialPerson;
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final String? initialStatus;

  @override
  State<OwnerIncentiveReportFilterScreen> createState() =>
      _OwnerIncentiveReportFilterScreenState();
}

class _OwnerIncentiveReportFilterScreenState
    extends State<OwnerIncentiveReportFilterScreen> {
  static const List<String> _statusOptions = ['All', 'Paid', 'Pending'];

  // Salesman list: GET /salesmen/active via OwnerReportsBloc.
  late final OwnerReportsBloc _ownerReportsBloc;

  // Field staff list: GET /field-staff/active via FieldStaffActiveBloc.
  late final FieldStaffActiveBloc _fieldStaffBloc;

  late IncentiveEntityType _type;

  /// Display name shown in the dropdown.
  String? _person;

  /// The id actually sent to the API.
  String? _personId;

  /// Dates always have a value (default: current month).
  late DateTime _startDate;
  late DateTime _endDate;
  late String _status;

  @override
  void initState() {
    super.initState();
    _ownerReportsBloc = OwnerReportsBloc()..add(const newLoadActiveSalesmen());
    _fieldStaffBloc = FieldStaffActiveBloc()
      ..add(const FetchActiveFieldStaff());
    _type = widget.initialType ?? IncentiveEntityType.salesman;
    _person = widget.initialPerson;
    _personId = widget.initialPersonId;

    final now = DateTime.now();
    _startDate = widget.initialStart ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEnd ?? DateTime(now.year, now.month + 1, 0);

    _status = widget.initialStatus ?? _statusOptions.first;
  }

  @override
  void dispose() {
    _ownerReportsBloc.close();
    _fieldStaffBloc.close();
    super.dispose();
  }

  void _onTypeChanged(bool isSalesman) {
    setState(() {
      _type = isSalesman
          ? IncentiveEntityType.salesman
          : IncentiveEntityType.fieldStaff;
      _person = null; // reset: the two lists don't overlap
      _personId = null;
    });
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

  bool get _canGenerate => _person != null && _personId != null;

  void _generate() {
    if (!_canGenerate) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OwnerIncentiveReportScreen(
          type: _type,
          personId: _personId!,
          personName: _person!,
          startDate: _startDate,
          endDate: _endDate,
          status: _status,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final isSalesman = _type == IncentiveEntityType.salesman;

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates / Drivers) ----------
        appBar: AppBar(
          title: Text('Incentive Report', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(Responsive.w(20),
                      Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                  child: _FilterCard(
                    title: 'Filters',
                    icon: Icons.tune_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Select Type'),
                        SizedBox(height: Responsive.h(8)),
                        Wrap(
                          spacing: Responsive.w(8),
                          children: [
                            _OptionChip(
                              label: 'Salesman',
                              selected: isSalesman,
                              onTap: () => _onTypeChanged(true),
                            ),
                            _OptionChip(
                              label: 'Field Staff',
                              selected: !isSalesman,
                              onTap: () => _onTypeChanged(false),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(16)),
                        _FieldLabel(
                            isSalesman ? 'Select Salesman' : 'Select Field Staff'),
                        SizedBox(height: Responsive.h(8)),
                        _buildPersonDropdown(),
                        SizedBox(height: Responsive.h(16)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('Start Date'),
                                  SizedBox(height: Responsive.h(8)),
                                  _DateField(
                                    date: _startDate,
                                    onTap: () => _pickDate(isStart: true),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: Responsive.w(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('End Date'),
                                  SizedBox(height: Responsive.h(8)),
                                  _DateField(
                                    date: _endDate,
                                    onTap: () => _pickDate(isStart: false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(16)),
                        const _FieldLabel('Status'),
                        SizedBox(height: Responsive.h(8)),
                        Wrap(
                          spacing: Responsive.w(8),
                          runSpacing: Responsive.h(8),
                          children: [
                            for (final o in _statusOptions)
                              _OptionChip(
                                label: o,
                                selected: o == _status,
                                onTap: () => setState(() => _status = o),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- BOTTOM BAR (same as Estimate Details) ----------
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: EdgeInsets.fromLTRB(Responsive.w(20),
                    Responsive.h(10), Responsive.w(20), Responsive.h(14)),
                child: SizedBox(
                  width: double.infinity,
                  height: Responsive.h(48),
                  child: ElevatedButton(
                    onPressed: _canGenerate ? _generate : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Generate Report',
                        style: AppTextStyles.bodyBold(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Salesman pulls live data from [_ownerReportsBloc] via GET
  /// /salesmen/active. Field Staff pulls live data from [_fieldStaffBloc]
  /// via GET /field-staff/active.
  Widget _buildPersonDropdown() {
    if (_type == IncentiveEntityType.salesman) {
      return BlocBuilder<OwnerReportsBloc, OwnerReportsState>(
        bloc: _ownerReportsBloc,
        builder: (context, state) {
          if (state.activeSalesmenStatus == LoadStatus.loading ||
              state.activeSalesmenStatus == LoadStatus.initial) {
            return _DropdownField(
              options: const [],
              value: null,
              hint: 'Loading salesmen…',
              onChanged: (_) {},
            );
          }

          if (state.activeSalesmenStatus == LoadStatus.failure) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DropdownField(
                  options: const [],
                  value: null,
                  hint: 'Choose salesman',
                  onChanged: (_) {},
                ),
                SizedBox(height: Responsive.h(6)),
                Text(
                  state.activeSalesmenError ?? 'Failed to load salesmen.',
                  style: AppTextStyles.caption(color: AppColors.error),
                ),
              ],
            );
          }

          final salesmen = state.activeSalesmen;
          // NOTE: adjust `.name` / `.id` if ActiveSalesmanModel differs.
          final names = salesmen.map((s) => s.name).toList();
          final nameToId = {for (final s in salesmen) s.name: s.id};

          return _DropdownField(
            options: names,
            value: _person,
            hint: 'Choose salesman',
            onChanged: (v) => setState(() {
              _person = v;
              _personId = nameToId[v];
            }),
          );
        },
      );
    }

    return BlocBuilder<FieldStaffActiveBloc, FieldStaffActiveState>(
      bloc: _fieldStaffBloc,
      builder: (context, state) {
        if (state is FieldStaffActiveLoading ||
            state is FieldStaffActiveInitial) {
          return _DropdownField(
            options: const [],
            value: null,
            hint: 'Loading field staff…',
            onChanged: (_) {},
          );
        }

        if (state is FieldStaffActiveError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DropdownField(
                options: const [],
                value: null,
                hint: 'Choose field staff',
                onChanged: (_) {},
              ),
              SizedBox(height: Responsive.h(6)),
              Text(
                state.message ?? 'Failed to load field staff.',
                style: AppTextStyles.caption(color: AppColors.error),
              ),
            ],
          );
        }

        final loaded = state as FieldStaffActiveLoaded;
        final names = loaded.fieldStaff.map((f) => f.name).toList();
        final nameToId = {for (final f in loaded.fieldStaff) f.name: f.id};

        return _DropdownField(
          options: names,
          value: _person,
          hint: 'Choose field staff',
          onChanged: (v) => setState(() {
            _person = v;
            _personId = nameToId[v];
          }),
        );
      },
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

/// White card (radius 16, 1px border, no shadow) with an icon badge + title
/// bar, same as the section cards on the Estimate Details screen.
class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.title, required this.child, this.icon});
  final String title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: AppColors.primary),
                  ),
                  SizedBox(width: Responsive.w(10)),
                ],
                Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption(color: AppColors.textSecondary),
    );
  }
}

/// Same pill look as the filter chips on the Estimates list.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(16), vertical: Responsive.h(8)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: Responsive.sp(11.5),
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Field look from the dialogs: filled, no border, radius 14.
BoxDecoration _fieldDecoration() => BoxDecoration(
  color: AppColors.background,
  borderRadius: BorderRadius.circular(14),
);

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.options,
    required this.value,
    required this.hint,
    required this.onChanged,
  });
  final List<String> options;
  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Avoid a Dropdown assertion if the saved value isn't in the list yet.
    final safeValue = options.contains(value) ? value : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          hint: Text(hint,
              style: AppTextStyles.body(color: AppColors.textHint)),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          style: AppTextStyles.body(),
          items: options
              .map((o) => DropdownMenuItem(
            value: o,
            child: Text(o, style: AppTextStyles.body()),
          ))
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
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(12), vertical: Responsive.h(14)),
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(),
              ),
            ),
            SizedBox(width: Responsive.w(6)),
            Icon(Icons.calendar_today_rounded,
                size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}