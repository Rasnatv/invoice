import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// NOTE: adjust these two provider paths/file names to your project.
import '../../../Apiprovider/salesmanprovider.dart';
import '../../../Apiprovider/fieldstaffprovider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_models/fieldstaff_getmodel.dart';
import '../../../models/owner_models/salesmanmodel.dart';
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

  // Salesman list: GET /salesmen (all salesmen).
  final SalesmanProvider _salesmanProvider = SalesmanProvider();

  // Field staff list: GET /field-staff (all field staff).
  final FieldStaffProvider _fieldStaffProvider = FieldStaffProvider();

  late IncentiveEntityType _type;

  /// Display name (clean, without any "(2)" / "(Inactive)" suffix).
  String? _person;

  /// The id actually sent to the API.
  String? _personId;

  /// Dates always have a value (default: current month).
  late DateTime _startDate;
  late DateTime _endDate;
  late String _status;

  bool _loadingPeople = false;
  String? _peopleError;
  List<HSalesmanModel> _salesmen = [];
  List<FieldStaffModel> _fieldStaff = [];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? IncentiveEntityType.salesman;
    _person = widget.initialPerson;
    _personId = widget.initialPersonId;

    final now = DateTime.now();
    _startDate = widget.initialStart ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEnd ?? DateTime(now.year, now.month + 1, 0);

    _status = widget.initialStatus ?? _statusOptions.first;

    _loadPeople();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadPeople() async {
    setState(() {
      _loadingPeople = true;
      _peopleError = null;
    });

    if (_type == IncentiveEntityType.salesman) {
      final result = await _salesmanProvider.getSalesmen();
      if (!mounted) return;
      if (result.success) {
        setState(() {
          // Drop blank-name records so they never show as selectable rows.
          _salesmen =
              result.salesmen.where((s) => s.name.trim().isNotEmpty).toList();
          _loadingPeople = false;
          _syncSelection();
        });
      } else {
        setState(() {
          _loadingPeople = false;
          _peopleError = result.errorMessage ?? 'Failed to load salesmen.';
        });
      }
    } else {
      final result = await _fieldStaffProvider.getFieldStaff();
      if (!mounted) return;
      if (result.success) {
        setState(() {
          _fieldStaff =
              result.staff.where((f) => f.name.trim().isNotEmpty).toList();
          _loadingPeople = false;
          _syncSelection();
        });
      } else {
        setState(() {
          _loadingPeople = false;
          _peopleError = result.errorMessage ?? 'Failed to load field staff.';
        });
      }
    }
  }

  /// Makes sure the selected person exists in the freshly loaded list;
  /// otherwise clears it so the dropdown shows its hint. Call inside setState.
  void _syncSelection() {
    final index = _peopleIds.indexOf(_personId ?? '');
    if (index != -1) {
      _person = _rawNames[index];
      return;
    }
    _person = null;
    _personId = null;
  }

  // ---------------------------------------------------------------------------
  // Dropdown helpers
  // ---------------------------------------------------------------------------

  bool get _isSalesman => _type == IncentiveEntityType.salesman;

  List<String> get _rawNames => _isSalesman
      ? _salesmen.map((s) => s.name.trim()).toList()
      : _fieldStaff.map((f) => f.name.trim()).toList();

  // HSalesmanModel.id is a String; FieldStaffModel.id is an int.
  List<String> get _peopleIds => _isSalesman
      ? _salesmen.map((s) => s.id).toList()
      : _fieldStaff.map((f) => f.id.toString()).toList();

  List<bool> get _inactiveFlags => _isSalesman
      ? _salesmen.map((s) => !s.isActive).toList()
      : _fieldStaff.map((f) => !f.isActive).toList();

  /// Unique dropdown labels: "rasna", "rasna (2)", ... so two people with the
  /// same name never produce duplicate DropdownMenuItem values or resolve to
  /// the wrong id. Inactive people get an " (Inactive)" suffix.
  List<String> get _peopleNames {
    final seen = <String, int>{};
    final raw = _rawNames;
    final inactive = _inactiveFlags;

    return List.generate(raw.length, (i) {
      final n = raw[i];
      final count = (seen[n] ?? 0) + 1;
      seen[n] = count;
      var label = count == 1 ? n : '$n ($count)';
      if (inactive[i]) label += ' (Inactive)';
      return label;
    });
  }

  String? get _selectedLabel {
    final i = _peopleIds.indexOf(_personId ?? '');
    return i == -1 ? null : _peopleNames[i];
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  void _onTypeChanged(bool isSalesman) {
    final newType = isSalesman
        ? IncentiveEntityType.salesman
        : IncentiveEntityType.fieldStaff;
    if (newType == _type) return;

    setState(() {
      _type = newType;
      _person = null; // reset: the two lists don't overlap
      _personId = null;
    });
    _loadPeople();
  }

  /// Selects by index in the unique-label list, so duplicate names still
  /// resolve to the correct backend id.
  void _onPersonChanged(String label) {
    final i = _peopleNames.indexOf(label);
    if (i == -1) return;
    setState(() {
      _personId = _peopleIds[i];
      _person = _rawNames[i];
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

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final isSalesman = _isSalesman;

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

  /// Salesman list comes from GET /salesmen, field staff list from
  /// GET /field-staff (both include inactive people, marked in the label).
  Widget _buildPersonDropdown() {
    final isSalesman = _isSalesman;
    final hint = isSalesman ? 'Choose salesman' : 'Choose field staff';

    if (_loadingPeople) {
      return _DropdownField(
        options: const [],
        value: null,
        hint: isSalesman ? 'Loading salesmen…' : 'Loading field staff…',
        onChanged: (_) {},
      );
    }

    if (_peopleError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DropdownField(
            options: const [],
            value: null,
            hint: hint,
            onChanged: (_) {},
          ),
          SizedBox(height: Responsive.h(6)),
          Text(
            _peopleError!,
            style: AppTextStyles.caption(color: AppColors.error),
          ),
        ],
      );
    }

    return _DropdownField(
      options: _peopleNames,
      value: _selectedLabel,
      hint: hint,
      onChanged: _onPersonChanged,
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