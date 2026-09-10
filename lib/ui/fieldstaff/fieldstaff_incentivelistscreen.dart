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
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Incentive Earned', style: AppTextStyles.h6()),
        ),
        body: SafeArea(
          child: BlocBuilder<FieldStaffIncentivesListBloc,
              FieldStaffIncentivesListState>(
            builder: (context, state) {
              // Chip row is shown as soon as we know about at least one
              // status (i.e. after the first successful fetch), even while
              // a filtered fetch is loading — so it doesn't flicker away
              // every time you tap a chip.
              final showChips = state.chipOptions.length > 1;

              if (state.isInitialLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == FieldStaffIncentivesListStatus.error &&
                  state.list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage ?? 'Something went wrong',
                          style: AppTextStyles.subtitle(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: Responsive.h(12)),
                        OutlinedButton(
                          onPressed: () => context
                              .read<FieldStaffIncentivesListBloc>()
                              .add(const FetchFieldStaffIncentivesEvent()),
                          child: const Text('Retry'),
                        ),
                      ],
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
                      child: Text('No incentives added yet',
                          style: AppTextStyles.subtitle()),
                    )
                        : RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<FieldStaffIncentivesListBloc>()
                            .add(const RefreshFieldStaffIncentivesEvent());
                        await context
                            .read<FieldStaffIncentivesListBloc>()
                            .stream
                            .firstWhere((s) =>
                        s.status !=
                            FieldStaffIncentivesListStatus.loading);
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          Responsive.w(16),
                          Responsive.h(14),
                          Responsive.w(16),
                          Responsive.h(90),
                        ),
                        itemCount: state.list.length + 1,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Responsive.h(10)),
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
                                FieldStaffIncentivesListStatus
                                    .loadingMore) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Responsive.h(16)),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.4),
                                ),
                              ),
                            );
                          }

                          final item = state.list[i];
                          return _IncentiveCard(
                              item: item, currency: currency);
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

/// Horizontally scrollable row of filter chips, built from whatever
/// statuses have actually shown up in the API data so far (state.chipOptions
/// = ['All', ...discovered statuses]). Selected chip is filled with
/// AppColors.primary; others sit outlined on AppColors.surface.
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
      height: Responsive.h(44),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
        itemCount: options.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(8)),
        itemBuilder: (context, index) {
          final label = options[index];
          final isSelected = label == selected;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(label),
            showCheckmark: false,
            labelStyle: AppTextStyles.caption().copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(12),
              vertical: Responsive.h(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}

/// Total summary card, restyled to sit on the same surface/border
/// language as the rest of the app instead of a custom gradient.
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
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.currency_rupee_rounded,
                size: 20, color: AppColors.primary),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Incentive', style: AppTextStyles.caption()),
                SizedBox(height: Responsive.h(2)),
                Text(value, style: AppTextStyles.h3()),
                SizedBox(height: Responsive.h(2)),

              ],
            ),
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
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
                        item.estimateNumber.isEmpty
                            ? 'Estimate #${item.estimateId}'
                            : item.estimateNumber,
                        style: AppTextStyles.bodyBold(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.statusLabel.isEmpty ? item.status : item.statusLabel,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(3)),
                Text(
                  dateLabel,
                  style: AppTextStyles.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Text(
            currency.format(displayAmount),
            style: AppTextStyles.bodyBold().copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }
}