
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_bloc.dart';
import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_event.dart';
import '../../bloc/ownerbloc/fieldstaffincentive/fieldstaff_incentive_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/owner_models/fieldstaffincentivemodel.dart';
import '../../widgets/appsnackbar.dart';
import 'fieldstaff_incentivedetailscreen.dart';


/// Public entry point — provides the bloc, loads current-month data.
class FieldStaffIncentiveScreen extends StatelessWidget {
  const FieldStaffIncentiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final lastOfMonth = DateTime(now.year, now.month + 1, 0);

    return BlocProvider(
      create: (_) => FieldStaffIncentiveBloc(provider: IncentiveProvider())
        ..add(LoadFieldStaffIncentives(
          dateFrom: _fmt(firstOfMonth),
          dateTo: _fmt(lastOfMonth),
        )),
      child: const _FieldStaffIncentiveView(),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _FieldStaffIncentiveView extends StatefulWidget {
  const _FieldStaffIncentiveView();

  @override
  State<_FieldStaffIncentiveView> createState() => _FieldStaffIncentiveViewState();
}

class _FieldStaffIncentiveViewState extends State<_FieldStaffIncentiveView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<FieldStaffIncentiveBloc>().add(const LoadMoreIncentives());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _pickFieldStaff(BuildContext context, FieldStaffIncentiveState state) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
            children: [
              ListTile(
                leading: Icon(Icons.groups_outlined, color: AppColors.primary),
                title: const Text('All Field Staff'),
                selected: state.selectedFieldStaffId == null,
                onTap: () => Navigator.pop(sheetContext, ''),
              ),
              const Divider(height: 1),
              ...state.fieldStaffOptions.map(
                    (staff) => ListTile(
                  leading: Icon(Icons.person_outline, color: AppColors.primary),
                  title: Text(staff.name),
                  selected: state.selectedFieldStaffId == staff.id,
                  onTap: () => Navigator.pop(sheetContext, staff.id),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;
    context
        .read<FieldStaffIncentiveBloc>()
        .add(FilterByFieldStaff(selected.isEmpty ? null : selected));
  }

  void _pickDateRange(BuildContext context, FieldStaffIncentiveState state) async {
    final initialRange = DateTimeRange(
      start: DateTime.tryParse(state.dateFrom) ?? DateTime.now(),
      end: DateTime.tryParse(state.dateTo) ?? DateTime.now(),
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
    );

    if (picked == null || !context.mounted) return;
    context.read<FieldStaffIncentiveBloc>().add(FilterByDateRange(
      dateFrom: _fmtDate(picked.start),
      dateTo: _fmtDate(picked.end),
    ));
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<FieldStaffIncentiveBloc, FieldStaffIncentiveState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppSnackbar.error(state.errorMessage!);
            context.read<FieldStaffIncentiveBloc>().add(const ClearIncentiveListFeedback());
          }
        },
        builder: (context, state) {
          if (state.status == FieldStaffIncentiveStatus.loading && state.incentives.isEmpty) {
            return Column(
              children: [
                _Header(
                  state: state,
                  onPickStaff: () => _pickFieldStaff(context, state),
                  onPickDateRange: () => _pickDateRange(context, state),
                ),
                const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<FieldStaffIncentiveBloc>().add(const RefreshFieldStaffIncentives()),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    state: state,
                    onPickStaff: () => _pickFieldStaff(context, state),
                    onPickDateRange: () => _pickDateRange(context, state),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _StatusTabs(state: state),
                ),
                if (state.incentives.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyIncentiveState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      Responsive.w(20),
                      Responsive.h(4),
                      Responsive.w(20),
                      Responsive.h(24),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index == state.incentives.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final incentive = state.incentives[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: Responsive.h(12)),
                            child: _IncentiveCard(
                              incentive: incentive,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IncentiveDetailScreen(id: incentive.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount:
                        state.incentives.length + (state.status == FieldStaffIncentiveStatus.loadingMore ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Maroon header: back + title, staff dropdown, date range picker, overlapping stats card.
class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onPickStaff, required this.onPickDateRange});

  final FieldStaffIncentiveState state;
  final VoidCallback onPickStaff;
  final VoidCallback onPickDateRange;

  String get _dateRangeLabel {
    if (state.dateFrom.isEmpty || state.dateTo.isEmpty) return 'Select Date Range';
    return '${state.dateFrom}  to  ${state.dateTo}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Responsive.w(16),
            Responsive.h(8),
            Responsive.w(16),
            Responsive.h(40),
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Responsive.w(28)),
              bottomRight: Radius.circular(Responsive.w(28)),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Field Staff Incentives',
                        style: AppTextStyles.h6().copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(8)),
                InkWell(
                  onTap: onPickStaff,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(14),
                      vertical: Responsive.h(12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.groups_outlined, color: Colors.white, size: 18),
                        SizedBox(width: Responsive.w(8)),
                        Expanded(
                          child: Text(
                            state.selectedFieldStaffName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(13.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(10)),
                InkWell(
                  onTap: onPickDateRange,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(14),
                      vertical: Responsive.h(12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range_outlined, color: Colors.white, size: 18),
                        SizedBox(width: Responsive.w(8)),
                        Expanded(
                          child: Text(
                            _dateRangeLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(13.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -Responsive.h(26)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            child: _SummaryCard(state: state),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final FieldStaffIncentiveState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(16),
        vertical: Responsive.h(16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              value: '₹${summary.totalIncentive.toStringAsFixed(0)}',
              label: 'Total Incentive',
              valueColor: AppColors.black,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatColumn(
              value: '${summary.statusBreakdown.pending}',
              label: 'Pending',
              valueColor: const Color(0xFFC9862B),
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatColumn(
              value: '${summary.statusBreakdown.paid}',
              label: 'Paid',
              valueColor: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: Responsive.h(36),
      color: AppColors.textSecondary.withOpacity(0.15),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label, required this.valueColor});

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(17),
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(11),
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.state});

  final FieldStaffIncentiveState state;

  /// Reads the label straight off an already-loaded record's `status_label`
  /// (comes from the API, e.g. "Paid") instead of hardcoding it here.
  /// Only falls back to a plain word if no loaded record currently has
  /// this status — there's no dedicated "list of statuses" endpoint to
  /// source a label from in that case.
  static String? _apiLabelFor(List<FieldStaffIncentiveModel> incentives, String status) {
    for (final incentive in incentives) {
      if (incentive.status == status && incentive.statusLabel.isNotEmpty) {
        return incentive.statusLabel;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = state.summary.statusBreakdown;
    final incentives = state.incentives;
    final tabs = <_StatusTab>[
      _StatusTab('all', 'All', breakdown.pending + breakdown.approved + breakdown.paid),
      if (breakdown.pending > 0)
        _StatusTab('pending', _apiLabelFor(incentives, 'pending') ?? 'Pending', breakdown.pending),
      if (breakdown.approved > 0)
        _StatusTab('approved', _apiLabelFor(incentives, 'approved') ?? 'Approved', breakdown.approved),
      if (breakdown.paid > 0)
        _StatusTab('paid', _apiLabelFor(incentives, 'paid') ?? 'Paid', breakdown.paid),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(20),
        Responsive.h(10),
        Responsive.w(20),
        Responsive.h(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = tab.value == state.selectedStatus;
            return Padding(
              padding: EdgeInsets.only(right: Responsive.w(8)),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context
                    .read<FieldStaffIncentiveBloc>()
                    .add(FilterByStatus(tab.value)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(14),
                    vertical: Responsive.h(8),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '${tab.label} (${tab.count})',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: Responsive.sp(12.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusTab {
  const _StatusTab(this.value, this.label, this.count);
  final String value;
  final String label;
  final int count;
}

class _IncentiveCard extends StatelessWidget {
  const _IncentiveCard({required this.incentive, required this.onTap});

  final FieldStaffIncentiveModel incentive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          incentive.fieldStaffName,
                          style: AppTextStyles.bodyBold(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: Responsive.w(6)),
                      _StatusPill(status: incentive.status, label: incentive.statusLabel),
                    ],
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    'Visited: ${incentive.siteVisit.customerName}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.sp(11.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Est: ${incentive.estimateNumber}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.sp(11),
                        ),
                      ),
                      Text(
                        '₹${incentive.incentiveAmountFormatted}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.sp(14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.label});

  final String status;
  final String label;

  Color get _color {
    switch (status) {
      case 'paid':
        return Colors.green.shade700;
      case 'approved':
        return Colors.blue.shade700;
      case 'pending':
      default:
        return const Color(0xFFC9862B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(9), vertical: Responsive.h(3)),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _color,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyIncentiveState extends StatelessWidget {
  const _EmptyIncentiveState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payments_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(12)),
            Text(
              'No incentives found',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
          ],
        ),
      ),
    );
  }
}