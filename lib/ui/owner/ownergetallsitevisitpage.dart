import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/ownerallsitevisitget/ownerallsitevisitget_bloc.dart';
import '../../bloc/ownerbloc/ownerallsitevisitget/ownerallsitevisitget_event.dart';
import '../../bloc/ownerbloc/ownerallsitevisitget/ownerallsitevisitget_state.dart';
import '../../models/owner_models/ownergetallsitevisitmodel.dart';


class OwnerGetAllSiteVisitPage extends StatelessWidget {
  const OwnerGetAllSiteVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerGetAllSiteVisitBloc()..add(const FetchOwnerGetAllSiteVisit()),
      child: const _OwnerGetAllSiteVisitView(),
    );
  }
}

class _OwnerGetAllSiteVisitView extends StatelessWidget {
  const _OwnerGetAllSiteVisitView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM, yyyy');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Site Visits', style: AppTextStyles.h6())),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<OwnerGetAllSiteVisitBloc>().add(const FetchOwnerGetAllSiteVisit());
              await context.read<OwnerGetAllSiteVisitBloc>().stream.firstWhere(
                    (s) => s is OwnerGetAllSiteVisitLoaded || s is OwnerGetAllSiteVisitError,
              );
            },
            child: BlocBuilder<OwnerGetAllSiteVisitBloc, OwnerGetAllSiteVisitState>(
              builder: (context, state) {
                if (state is OwnerGetAllSiteVisitInitial ||
                    state is OwnerGetAllSiteVisitLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OwnerGetAllSiteVisitError) {
                  return ListView(
                    children: [
                      SizedBox(height: Responsive.h(100)),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                          child: Column(
                            children: [
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption(color: AppColors.textSecondary),
                              ),
                              SizedBox(height: Responsive.h(14)),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<OwnerGetAllSiteVisitBloc>()
                                    .add(const RetryOwnerGetAllSiteVisit()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final summary = (state as OwnerGetAllSiteVisitLoaded).summary;
                final visits = summary.all.list;

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(16),
                    Responsive.h(14),
                    Responsive.w(16),
                    Responsive.h(24),
                  ),
                  children: [
                    _SummaryCard(summary: summary, currency: currency),
                    SizedBox(height: Responsive.h(20)),
                    Text('All Visits',
                        style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
                    SizedBox(height: Responsive.h(10)),
                    if (visits.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
                        child: Center(
                          child: Text(
                            'No site visits found.',
                            style: AppTextStyles.caption(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      for (final visit in visits)
                        _SiteVisitTile(visit: visit, currency: currency, dateFmt: dateFmt),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.currency});

  final SiteVisitsSummaryModel summary;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Site Visits Overview', style: AppTextStyles.bodyBold()),
                    Text('Today: ${summary.todayVisits}', style: AppTextStyles.caption()),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(14)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Visits', style: AppTextStyles.caption()),
                    Text('${summary.totalVisits}',
                        style: AppTextStyles.bodyBold().copyWith(fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Visits', style: AppTextStyles.caption()),
                    Text('${summary.todayVisits}',
                        style: AppTextStyles.bodyBold().copyWith(fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Incentive', style: AppTextStyles.caption()),
                    Text(
                      currency.format(summary.totalIncentiveValue),
                      style: AppTextStyles.bodyBold(color: AppColors.success).copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SiteVisitTile extends StatelessWidget {
  const _SiteVisitTile({
    required this.visit,
    required this.currency,
    required this.dateFmt,
  });

  final SiteVisitItemModel visit;
  final NumberFormat currency;
  final DateFormat dateFmt;

  Color _statusColor() {
    if (visit.isConverted) return AppColors.success;
    if (visit.isPending) return Colors.orange;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final date = visit.visitDateValue;
    final statusColor = _statusColor();

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (visit.hasThumbnail)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    visit.thumbnailUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: AppColors.border,
                      child: const Icon(Icons.image_not_supported_outlined, size: 18),
                    ),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.customerName, style: AppTextStyles.bodyBold().copyWith(fontSize: 13)),
                    Text(visit.customerPhone, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(3)),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  visit.statusLabel,
                  style: AppTextStyles.bodyBold(color: statusColor).copyWith(fontSize: 11.5),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text('Site', style: AppTextStyles.caption()),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  visit.siteAddress,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(6)),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text('Visit Date', style: AppTextStyles.caption()),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  date != null ? dateFmt.format(date) : visit.visitDate,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: Responsive.w(6)),
                  Text(visit.fieldStaffName, style: AppTextStyles.caption()),
                ],
              ),
              Row(
                children: [
                  Text('Incentive: ', style: AppTextStyles.caption()),
                  Text(
                    currency.format(visit.incentiveEarnedValue),
                    style: AppTextStyles.bodyBold(color: AppColors.success).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
