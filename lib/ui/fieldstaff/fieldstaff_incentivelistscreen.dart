import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../ui/no%20internetconnection/no_connection.dart';
import '../../bloc/fieldstaffbloc/fieldstaffincentiveview/fieldstaffview_incentive_bloc.dart';
import '../../bloc/fieldstaffbloc/fieldstaffincentiveview/fieldstaffview_incentive_event.dart';
import '../../bloc/fieldstaffbloc/fieldstaffincentiveview/fieldstaffview_incentive_state.dart';
import '../../models/fieldstaffmodels/fieldstaffincentiveviewingmodel.dart';

// =====================================================================
// SHARED LOOK (same as dashboard / add visit / visit detail)
// =====================================================================

BoxDecoration _cardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
);

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, {this.color, this.size = 16});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// =====================================================================
// SCREEN
// =====================================================================

class IncentiveListScreen extends StatelessWidget {
  const IncentiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FieldStaffIncentivesListBloc()
        ..add(const FetchFieldStaffIncentivesEvent()),
      child: const _IncentiveListView(),
    );
  }
}

class _IncentiveListView extends StatefulWidget {
  const _IncentiveListView();

  @override
  State<_IncentiveListView> createState() => _IncentiveListViewState();
}

class _IncentiveListViewState extends State<_IncentiveListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<FieldStaffIncentivesListBloc>().add(
        const FetchMoreFieldStaffIncentivesEvent(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Incentive Earned', style: AppTextStyles.h6()),
        ),
        body: SafeArea(
          child: BlocBuilder<FieldStaffIncentivesListBloc, FieldStaffIncentivesListState>(
            builder: (context, state) {
              // Chip row stays visible once at least one status is known,
              // even while a filtered fetch is loading (no flicker).
              final showChips = state.chipOptions.length > 1;

              if (state.isInitialLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == FieldStaffIncentivesListStatus.error &&
                  state.list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Responsive.w(18)),
                      decoration: _cardDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 32, color: AppColors.textSecondary.withOpacity(0.5)),
                          SizedBox(height: Responsive.h(8)),
                          Text(
                            state.errorMessage ?? 'Something went wrong',
                            style: AppTextStyles.subtitle().copyWith(fontSize: Responsive.sp(12)),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Responsive.h(8)),
                          TextButton(
                            onPressed: () => context
                                .read<FieldStaffIncentivesListBloc>()
                                .add(const FetchFieldStaffIncentivesEvent()),
                            child: Text('Try again',
                                style: AppTextStyles.link().copyWith(fontSize: Responsive.sp(12))),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  if (showChips)
                    _StatusChipRow(
                      options: state.chipOptions,
                      selected: state.selectedStatus,
                      onSelected: (status) => context
                          .read<FieldStaffIncentivesListBloc>()
                          .add(SelectFieldStaffIncentiveStatusEvent(status)),
                    ),
                  Expanded(
                    child: state.list.isEmpty
                        ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(22)),
                          decoration: _cardDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on_outlined,
                                  size: 34,
                                  color: AppColors.textSecondary.withOpacity(0.4)),
                              SizedBox(height: Responsive.h(8)),
                              Text(
                                'No incentives added yet',
                                style: AppTextStyles.subtitle()
                                    .copyWith(fontSize: Responsive.sp(12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context
                            .read<FieldStaffIncentivesListBloc>()
                            .add(const RefreshFieldStaffIncentivesEvent());
                        await context
                            .read<FieldStaffIncentivesListBloc>()
                            .stream
                            .firstWhere((s) =>
                        s.status != FieldStaffIncentivesListStatus.loading);
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          Responsive.w(20),
                          Responsive.h(6),
                          Responsive.w(20),
                          Responsive.h(90),
                        ),
                        itemCount: state.list.length + 1,
                        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _TotalIncentiveCard(
                              value: currency.format(state.loadedTotal),
                              visitCount: state.list.length,
                              isComplete: state.hasReachedMax,
                            );
                          }

                          final i = index - 1;
                          if (i == state.list.length) {
                            if (state.status !=
                                FieldStaffIncentivesListStatus.loadingMore) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          }

                          final item = state.list[i];
                          return _IncentiveCard(item: item, currency: currency);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String statusColorKey, String statusKey) {
  final key = statusColorKey.isNotEmpty ? statusColorKey : statusKey;
  switch (key.toLowerCase()) {
    case 'success':
    case 'paid':
    case 'green':
      return const Color(0xFF2E7D32);
    case 'warning':
    case 'pending':
    case 'orange':
      return AppColors.primary;
    case 'danger':
    case 'error':
    case 'rejected':
    case 'red':
      return AppColors.error;
    default:
      return AppColors.textSecondary;
  }
}

/// Horizontally scrollable filter chips built from the statuses found in
/// the API data (state.chipOptions = ['All', ...statuses]).
class _StatusChipRow extends StatelessWidget {
  const _StatusChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.h(46),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(20), vertical: Responsive.h(8)),
        itemCount: options.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(8)),
        itemBuilder: (context, index) {
          final label = options[index];
          final isSelected = label == selected;

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onSelected(label),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: Responsive.sp(11),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Total summary card.
class _TotalIncentiveCard extends StatelessWidget {
  const _TotalIncentiveCard({
    required this.value,
    required this.visitCount,
    required this.isComplete,
  });

  final String value;
  final int visitCount;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(14)),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const _IconBadge(Icons.currency_rupee_rounded, size: 20),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Incentive',
                  style: AppTextStyles.caption(color: AppColors.textSecondary)
                      .copyWith(fontSize: Responsive.sp(10.5)),
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  value,
                  style: AppTextStyles.bodyBold(color: AppColors.primary)
                      .copyWith(fontSize: Responsive.sp(18)),
                ),
              ],
            ),
          ),
          _Pill(
            label: '$visitCount${isComplete ? '' : '+'} ${visitCount == 1 ? 'visit' : 'visits'}',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _IncentiveCard extends StatelessWidget {
  const _IncentiveCard({required this.item, required this.currency});

  final FieldStaffIncentive item;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(item.createdAt);
    final dateLabel = parsedDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate)
        : item.createdAt;
    final amount = double.tryParse(item.incentiveAmount) ?? 0;
    final displayAmount = item.incentiveAmountFormatted.isNotEmpty
        ? double.tryParse(item.incentiveAmountFormatted) ?? amount
        : amount;
    final badgeColor = _statusColor(item.statusColor, item.status);

    return Container(
      padding: EdgeInsets.all(Responsive.w(12)),
      decoration: _cardDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconBadge(Icons.receipt_long_outlined),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.estimateNumber.isEmpty
                      ? 'Estimate #${item.estimateId}'
                      : item.estimateNumber,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(12.5)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  dateLabel,
                  style: AppTextStyles.caption(color: AppColors.textSecondary)
                      .copyWith(fontSize: Responsive.sp(10.5)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(displayAmount),
                style: AppTextStyles.bodyBold(color: AppColors.success)
                    .copyWith(fontSize: Responsive.sp(12.5)),
              ),
              SizedBox(height: Responsive.h(6)),
              _Pill(
                label: item.statusLabel.isEmpty ? item.status : item.statusLabel,
                color: badgeColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}