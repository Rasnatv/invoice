
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

/// Filter screen for the Quotation Report.
/// Salesman / contractor lists are loaded from the real "active" APIs
/// (already wired up in OwnerReportsProvider) so the ids sent to
/// /reports/quotations are real backend ids, not display names.
///
/// Status is NOT selected here. The result screen (OwnerQuotationReportScreen)
/// fetches with status: 'all' first, reads the distinct statuses straight
/// off the returned rows, and shows the status chips there — nothing about
/// status is hardcoded or chosen on this screen.
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
          _salesmen = result.salesmen;
          _loadingPeople = false;
          if (_selectedPersonId == null && _salesmen.isNotEmpty) {
            _selectedPersonId = _salesmen.first.id;
            _selectedPersonName = _salesmen.first.name;
          }
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
          _contractors = result.contractors;
          _loadingPeople = false;
          if (_selectedPersonId == null && _contractors.isNotEmpty) {
            _selectedPersonId = _contractors.first.id;
            _selectedPersonName = _contractors.first.name;
          }
        });
      } else {
        setState(() {
          _loadingPeople = false;
          _peopleError = result.errorMessage ?? 'Failed to load contractors.';
        });
      }
    }
  }

  List<String> get _peopleNames => _type == ReportEntityType.salesman
      ? _salesmen.map((s) => s.name).toList()
      : _contractors.map((c) => c.name).toList();

  void _onTypeChanged(bool isSalesman) {
    setState(() {
      _type = isSalesman ? ReportEntityType.salesman : ReportEntityType.contractor;
      _selectedPersonId = null;
      _selectedPersonName = null;
    });
    _loadPeople();
  }

  // Fixed: previously this used a `? :` ternary across two different
  // firstWhere() calls (ActiveSalesmanModel vs ActiveContractorModel).
  // Dart inferred the shared type as Object, so `match.id` failed to
  // resolve. Splitting into if/else keeps each branch's real type,
  // so `.id` resolves correctly on both.
  void _onPersonChanged(String name) {
    setState(() {
      _selectedPersonName = name;
      if (_type == ReportEntityType.salesman) {
        _selectedPersonId = _salesmen.firstWhere((s) => s.name == name).id;
      } else {
        _selectedPersonId = _contractors.firstWhere((c) => c.name == name).id;
      }
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

  void _generate() {
    if (_selectedPersonId == null || _selectedPersonName == null) return;
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

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(child: Scaffold(
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
            ReportFieldLabel(_type == ReportEntityType.salesman ? 'SELECT SALESMAN' : 'SELECT CONTRACTOR'),
            SizedBox(height: Responsive.h(8)),
            if (_loadingPeople)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              )
            else if (_peopleError != null)
              Text(_peopleError!, style: AppTextStyles.caption())
            else
              ReportDropdownField(
                options: _peopleNames,
                value: _selectedPersonName ?? '',
                hint: 'Choose',
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
            GenerateReportButton(onPressed: _generate),
            SizedBox(height: Responsive.h(20)),
          ],
        ),
      ),
    ));
  }
}