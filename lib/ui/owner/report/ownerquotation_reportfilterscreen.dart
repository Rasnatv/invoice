
import 'package:flutter/material.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_reportmodel/activecontractormodel.dart';
import '../../../models/salesmanmodels/activeslaesman_model.dart';
import 'owner_quoatationreportscreen.dart';
import 'ownerreportwidget.dart';

enum ReportEntityType { salesman, contractor }

class OwnerQuotationReportFilterScreen extends StatefulWidget {
  const OwnerQuotationReportFilterScreen({
    super.key,
    this.initialType,
    this.initialPersonId,
    this.initialPerson,
    this.initialStart,
    this.initialEnd,
  });

  final ReportEntityType? initialType;
  final String? initialPersonId;
  final String? initialPerson;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<OwnerQuotationReportFilterScreen> createState() => _OwnerQuotationReportFilterScreenState();
}

class _OwnerQuotationReportFilterScreenState extends State<OwnerQuotationReportFilterScreen> {
  final OwnerReportsProvider _reportsProvider = OwnerReportsProvider();

  late ReportEntityType _type;
  late DateTime _startDate;
  late DateTime _endDate;

  bool _loadingPeople = true;
  String? _peopleError;
  List<ActiveSalesmanModel> _salesmen = [];
  List<ActiveContractorModel> _contractors = [];

  String? _selectedPersonId;
  String? _selectedPersonName;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? ReportEntityType.salesman;
    final now = DateTime.now();
    _startDate = widget.initialStart ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEnd ?? DateTime(now.year, now.month + 1, 0);
    _selectedPersonId = widget.initialPersonId;
    _selectedPersonName = widget.initialPerson;
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

    if (_type == ReportEntityType.salesman) {
      final result = await _reportsProvider.getActiveSalesmen();
      if (!mounted) return;
      if (result.success) {
        setState(() {
          // Drop any salesman with a blank/whitespace-only name — a
          // nameless record should never appear as a selectable row.
          _salesmen = result.salesmen.where((s) => s.name.trim().isNotEmpty).toList();
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
      final result = await _reportsProvider.getActiveContractors();
      if (!mounted) return;
      if (result.success) {
        setState(() {
          // Same guard for contractors — no blank-name rows in the dropdown.
          _contractors = result.contractors.where((c) => c.name.trim().isNotEmpty).toList();
          _loadingPeople = false;
          _syncSelection();
        });
      } else {
        setState(() {
          _loadingPeople = false;
          _peopleError = result.errorMessage ?? 'Failed to load contractors.';
        });
      }
    }
  }

  /// Makes sure the selected person actually exists in the freshly loaded
  /// list. If the preselected id is missing (inactive, wrong type, blank
  /// name that got filtered out, etc.) — or nothing was preselected at all
  /// — the selection is cleared so the dropdown falls back to showing its
  /// "Select Salesman" / "Select Contractor" hint rather than silently
  /// defaulting to the first person. Call inside setState.
  void _syncSelection() {
    final ids = _peopleIds;
    final names = _rawNames;

    final index = ids.indexOf(_selectedPersonId ?? '');
    if (index != -1) {
      // Keep the name in sync with the real record.
      _selectedPersonName = names[index];
      return;
    }

    // No match (or nothing was preselected) — leave unselected.
    _selectedPersonId = null;
    _selectedPersonName = null;
  }

  // ---------------------------------------------------------------------------
  // Dropdown helpers
  // ---------------------------------------------------------------------------

  // _salesmen / _contractors are already filtered to exclude blank names
  // in _loadPeople, so these stay simple and always in sync by index.
  List<String> get _rawNames => _type == ReportEntityType.salesman
      ? _salesmen.map((s) => s.name.trim()).toList()
      : _contractors.map((c) => c.name.trim()).toList();

  List<String> get _peopleIds => _type == ReportEntityType.salesman
      ? _salesmen.map((s) => s.id.toString()).toList()
      : _contractors.map((c) => c.id.toString()).toList();

  /// Unique dropdown labels: "rasna", "rasna (2)", ... so two people with the
  /// same name never produce duplicate DropdownMenuItem values.
  List<String> get _peopleNames {
    final seen = <String, int>{};
    return _rawNames.map((n) {
      final count = (seen[n] ?? 0) + 1;
      seen[n] = count;
      return count == 1 ? n : '$n ($count)';
    }).toList();
  }

  /// Label for the currently selected id, or null if nothing is selected
  /// or the id isn't in the list. Feeds ReportDropdownField's nullable
  /// [value] directly — null shows the placeholder hint.
  String? get _selectedLabel {
    final i = _peopleIds.indexOf(_selectedPersonId ?? '');
    return i == -1 ? null : _peopleNames[i];
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  void _onTypeChanged(bool isSalesman) {
    setState(() {
      _type = isSalesman ? ReportEntityType.salesman : ReportEntityType.contractor;
      _selectedPersonId = null;
      _selectedPersonName = null;
    });
    _loadPeople();
  }

  /// Selects by index in the unique-label list, so duplicate names still
  /// resolve to the correct backend id.
  void _onPersonChanged(String label) {
    final i = _peopleNames.indexOf(label);
    if (i == -1) return;
    setState(() {
      _selectedPersonId = _peopleIds[i];
      _selectedPersonName = _rawNames[i];
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

  bool get _canGenerate => _selectedPersonId != null && _selectedPersonName != null;

  void _generate() {
    if (!_canGenerate) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OwnerQuotationReportScreen(
          type: _type,
          personId: _selectedPersonId!,
          personName: _selectedPersonName!,
          startDate: _startDate,
          endDate: _endDate,
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

    final names = _peopleNames;

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Quotation Report', style: AppTextStyles.h6())),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportFieldLabel('SELECT TYPE'),
              SizedBox(height: Responsive.h(8)),
              ReportTypeToggle(
                leftLabel: 'Salesman',
                rightLabel: 'Contractor',
                isLeftSelected: _type == ReportEntityType.salesman,
                onChanged: _onTypeChanged,
              ),
              SizedBox(height: Responsive.h(20)),
              ReportFieldLabel(
                _type == ReportEntityType.salesman ? 'SELECT SALESMAN' : 'SELECT CONTRACTOR',
              ),
              SizedBox(height: Responsive.h(8)),
              if (_loadingPeople)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                )
              else if (_peopleError != null)
                Text(_peopleError!, style: AppTextStyles.caption())
              else if (names.isEmpty)
                  Text(
                    _type == ReportEntityType.salesman
                        ? 'No active salesmen found.'
                        : 'No active contractors found.',
                    style: AppTextStyles.caption(),
                  )
                else
                  ReportDropdownField(
                    options: names,
                    // null until the user actually picks someone — shows
                    // the "Select Salesman" / "Select Contractor" hint.
                    value: _selectedLabel,
                    hint: _type == ReportEntityType.salesman
                        ? 'Select Salesman'
                        : 'Select Contractor',
                    onChanged: _onPersonChanged,
                  ),
              SizedBox(height: Responsive.h(20)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ReportFieldLabel('START DATE'),
                        SizedBox(height: Responsive.h(8)),
                        ReportDateField(
                          date: _startDate,
                          hint: 'Select date',
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
                        const ReportFieldLabel('END DATE'),
                        SizedBox(height: Responsive.h(8)),
                        ReportDateField(
                          date: _endDate,
                          hint: 'Select date',
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(28)),
              GenerateReportButton(
                onPressed: _canGenerate ? _generate : null,
              ),
              SizedBox(height: Responsive.h(20)),
            ],
          ),
        ),
      ),
    );
  }
}