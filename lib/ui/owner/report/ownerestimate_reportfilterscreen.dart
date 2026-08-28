// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/utils/responsive.dart';
// import 'ownerestimatereportscreen.dart';
// import 'ownerquotation_reportfilterscreen.dart';
// import 'ownerreportwidget.dart';
//
// /// Filter screen for the Estimate Report.
// /// Matches "1 · Estimate Report filter" in the mockup.
// class OwnerEstimateReportFilterScreen extends StatefulWidget {
//   const OwnerEstimateReportFilterScreen({
//     super.key,
//     this.initialType,
//     this.initialPerson,
//     this.initialStart,
//     this.initialEnd,
//     this.initialStatus,
//   });
//
//   final ReportEntityType? initialType;
//   final String? initialPerson;
//   final DateTime? initialStart;
//   final DateTime? initialEnd;
//   final String? initialStatus;
//
//   @override
//   State<OwnerEstimateReportFilterScreen> createState() => _OwnerEstimateReportFilterScreenState();
// }
//
// class _OwnerEstimateReportFilterScreenState extends State<OwnerEstimateReportFilterScreen> {
//   // TODO: replace with the real salesman/contractor lists from your bloc/API.
//   static const List<String> _salesmen = ['Rahul Kumar', 'Anjali Nair', 'Suresh Menon'];
//   static const List<String> _contractors = ['Green Valley Builders', 'Sunrise Interiors', 'Nizar Constructions'];
//   static const List<String> _statusOptions = ['All', 'Draft', 'Pending', 'Approved', 'Converted'];
//
//   late ReportEntityType _type;
//   late String _person;
//   late DateTime _startDate;
//   late DateTime _endDate;
//   late String _status;
//
//   List<String> get _people => _type == ReportEntityType.salesman ? _salesmen : _contractors;
//
//   @override
//   void initState() {
//     super.initState();
//     _type = widget.initialType ?? ReportEntityType.salesman;
//     _person = widget.initialPerson ?? _people.first;
//     final now = DateTime.now();
//     _startDate = widget.initialStart ?? DateTime(now.year, now.month, 1);
//     _endDate = widget.initialEnd ?? DateTime(now.year, now.month + 1, 0);
//     _status = widget.initialStatus ?? _statusOptions.first;
//   }
//
//   void _onTypeChanged(bool isSalesman) {
//     setState(() {
//       _type = isSalesman ? ReportEntityType.salesman : ReportEntityType.contractor;
//       _person = _people.first;
//     });
//   }
//
//   Future<void> _pickDate({required bool isStart}) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: isStart ? _startDate : _endDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//     );
//     if (picked == null) return;
//     setState(() {
//       if (isStart) {
//         _startDate = picked;
//       } else {
//         _endDate = picked;
//       }
//     });
//   }
//
//   void _generate() {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (_) => OwnerEstimateReportScreen(
//           type: _type,
//           personName: _person,
//           startDate: _startDate,
//           endDate: _endDate,
//           status: _status,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Column(
//         children: [
//           const ReportHeaderBar(title: 'Estimate Report', showBack: true),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(Responsive.w(20)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const ReportFieldLabel('SELECT TYPE'),
//                   SizedBox(height: Responsive.h(8)),
//                   ReportTypeToggle(
//                     leftLabel: 'Salesman',
//                     rightLabel: 'Contractor',
//                     isLeftSelected: _type == ReportEntityType.salesman,
//                     onChanged: _onTypeChanged,
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//                   ReportFieldLabel(_type == ReportEntityType.salesman ? 'SELECT SALESMAN' : 'SELECT CONTRACTOR'),
//                   SizedBox(height: Responsive.h(8)),
//                   ReportDropdownField(
//                     options: _people,
//                     value: _person,
//                     hint: 'Choose',
//                     onChanged: (v) => setState(() => _person = v),
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const ReportFieldLabel('START DATE'),
//                             SizedBox(height: Responsive.h(8)),
//                             ReportDateField(
//                               date: _startDate,
//                               hint: 'Select date',
//                               onTap: () => _pickDate(isStart: true),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: Responsive.w(12)),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const ReportFieldLabel('END DATE'),
//                             SizedBox(height: Responsive.h(8)),
//                             ReportDateField(
//                               date: _endDate,
//                               hint: 'Select date',
//                               onTap: () => _pickDate(isStart: false),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//                   const ReportFieldLabel('STATUS'),
//                   SizedBox(height: Responsive.h(10)),
//                   ReportStatusChips(
//                     options: _statusOptions,
//                     selected: _status,
//                     onChanged: (v) => setState(() => _status = v),
//                   ),
//                   SizedBox(height: Responsive.h(28)),
//                   GenerateReportButton(onPressed: _generate),
//                   SizedBox(height: Responsive.h(20)),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_reportmodel/activecontractormodel.dart';
import '../../../models/salesmanmodels/activeslaesman_model.dart';
import 'ownerestimatereportscreen.dart';
import 'ownerquotation_reportfilterscreen.dart'; // ReportEntityType
import 'ownerreportwidget.dart';

/// Filter screen for the Estimate Report.
/// Salesman / contractor lists are loaded from the real "active" APIs
/// (already wired up in OwnerReportsProvider) so the id sent through to
/// OwnerEstimateReportScreen is a real backend id, not a display name.
///
/// Status is NOT selected here — the result screen fetches with
/// status: 'all' first and derives the status chips from the API
/// response itself, so nothing about status is hardcoded on this screen.
class OwnerEstimateReportFilterScreen extends StatefulWidget {
  const OwnerEstimateReportFilterScreen({
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
  State<OwnerEstimateReportFilterScreen> createState() => _OwnerEstimateReportFilterScreenState();
}

class _OwnerEstimateReportFilterScreenState extends State<OwnerEstimateReportFilterScreen> {
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

  // Kept as if/else (not a `? :` across two different model types) so each
  // branch keeps its real static type and `.id` resolves correctly.
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
        builder: (_) => OwnerEstimateReportScreen(
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const ReportHeaderBar(title: 'Estimate Report', showBack: true),
          Expanded(
            child: SingleChildScrollView(
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
                      _type == ReportEntityType.salesman ? 'SELECT SALESMAN' : 'SELECT CONTRACTOR'),
                  SizedBox(height: Responsive.h(8)),
                  if (_loadingPeople)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  else if (_peopleError != null)
                    Text(_peopleError!, style: const TextStyle(fontSize: 12))
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
          ),
        ],
      ),
    );
  }
}