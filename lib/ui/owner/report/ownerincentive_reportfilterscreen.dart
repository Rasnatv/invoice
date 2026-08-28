
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ownerbloc/fieldstaffactive/owner_fieldstaffactive_bloc.dart';
import '../../../bloc/ownerbloc/fieldstaffactive/owner_fieldstaffactive_event.dart';
import '../../../bloc/ownerbloc/fieldstaffactive/owner_fieldstaffactive_state.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_bloc.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_event.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'owner_incentivereportscreen.dart';
import 'ownerreportwidget.dart';

enum IncentiveEntityType { salesman, fieldStaff }

/// Filter screen for the Incentive Report.
/// Matches "2b · Filter form (Incentive)" in the mockup.
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

  DateTime? _startDate;
  DateTime? _endDate;
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
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
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
      _person = null; // reset — the two lists don't overlap
      _personId = null;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
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

  bool get _canGenerate =>
      _person != null &&
          _personId != null &&
          _startDate != null &&
          _endDate != null;

  void _generate() {
    if (!_canGenerate) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OwnerIncentiveReportScreen(
          type: _type,
          personId: _personId!,
          personName: _person!,
          startDate: _startDate!,
          endDate: _endDate!,
          status: _status,
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
          const ReportHeaderBar(title: 'Incentive Report', showBack: true),
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
                    rightLabel: 'Field Staff',
                    isLeftSelected: _type == IncentiveEntityType.salesman,
                    onChanged: _onTypeChanged,
                  ),
                  SizedBox(height: Responsive.h(20)),
                  ReportFieldLabel(_type == IncentiveEntityType.salesman
                      ? 'SELECT SALESMAN'
                      : 'SELECT FIELD STAFF'),
                  SizedBox(height: Responsive.h(8)),
                  _buildPersonDropdown(),
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
                  SizedBox(height: Responsive.h(20)),
                  const ReportFieldLabel('STATUS'),
                  SizedBox(height: Responsive.h(10)),
                  ReportStatusChips(
                    options: _statusOptions,
                    selected: _status,
                    onChanged: (v) => setState(() => _status = v),
                  ),
                  SizedBox(height: Responsive.h(28)),
                  GenerateReportButton(
                      onPressed: _canGenerate ? _generate : null),
                  SizedBox(height: Responsive.h(20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Salesman pulls live data from [_ownerReportsBloc] via GET
  /// /salesmen/active. Field Staff pulls live data from [_fieldStaffBloc]
  /// via GET /field-staff/active. Neither list is hardcoded anymore.
  Widget _buildPersonDropdown() {
    if (_type == IncentiveEntityType.salesman) {
      return BlocBuilder<OwnerReportsBloc, OwnerReportsState>(
        bloc: _ownerReportsBloc,
        builder: (context, state) {
          if (state.activeSalesmenStatus == LoadStatus.loading ||
              state.activeSalesmenStatus == LoadStatus.initial) {
            return ReportDropdownField(
              options: const [],
              value: null,
              hint: 'Loading salesmen…',
              // ReportDropdownField.onChanged is non-nullable — pass a
              // no-op instead of null; there are no options yet anyway.
              onChanged: (_) {},
            );
          }

          if (state.activeSalesmenStatus == LoadStatus.failure) {
            return ReportDropdownField(
              options: const [],
              value: null,
              hint: state.activeSalesmenError ?? 'Failed to load salesmen',
              onChanged: (_) {},
            );
          }

          final salesmen = state.activeSalesmen;
          // NOTE: adjust `.name` / `.id` below if ActiveSalesmanModel uses
          // different field names.
          final names = salesmen.map((s) => s.name).toList();
          final nameToId = {
            for (final s in salesmen) s.name: s.id,
          };

          return ReportDropdownField(
            options: names,
            value: _person,
            hint: 'Choose salesman',
            onChanged: (v) => setState(() {
              _person = v;
              _personId = v == null ? null : nameToId[v];
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
          return ReportDropdownField(
            options: const [],
            value: null,
            hint: 'Loading field staff…',
            onChanged: (_) {},
          );
        }

        if (state is FieldStaffActiveError) {
          return ReportDropdownField(
            options: const [],
            value: null,
            hint: state.message,
            onChanged: (_) {},
          );
        }

        final loaded = state as FieldStaffActiveLoaded;
        final names = loaded.fieldStaff.map((f) => f.name).toList();
        final nameToId = {
          for (final f in loaded.fieldStaff) f.name: f.id,
        };

        return ReportDropdownField(
          options: names,
          value: _person,
          hint: 'Choose field staff',
          onChanged: (v) => setState(() {
            _person = v;
            _personId = v == null ? null : nameToId[v];
          }),
        );
      },
    );
  }
}