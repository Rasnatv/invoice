
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/salesman/widget/salesmanestimateviewshimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistbloc.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistevent.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanownerestimatestate.dart';
import '../../widgets/estimate_card.dart';
import 'estimatedetailscreen_forsalesman.dart';

/// NOTE: EstimatesBloc is now provided by DashboardShell (above the
/// IndexedStack) so it's shared/long-lived across tab switches — this
/// screen no longer creates its own local instance. Do NOT re-add a
/// BlocProvider<EstimatesBloc> here, or you'll end up with two separate
/// instances (this one shadowing the shared one) and the
/// refresh-after-create-estimate flow (fired from DashboardHomeScreen's
/// _openCreateEstimate) will silently stop reaching this screen again.
class MyEstimatesScreen extends StatelessWidget {
  const MyEstimatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyEstimatesView();
  }
}

class _MyEstimatesView extends StatefulWidget {
  const _MyEstimatesView();

  @override
  State<_MyEstimatesView> createState() => _MyEstimatesViewState();
}

class _MyEstimatesViewState extends State<_MyEstimatesView> {
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Estimates', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<EstimatesBloc>();
            bloc.add(const EstimatesRefreshRequested());
            await bloc.stream.firstWhere((s) => s.status != EstimatesStatus.loading);
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
                child: TextField(
                  onChanged: (v) =>
                      context.read<EstimatesBloc>().add(EstimatesSearchQueryChanged(v)),
                  decoration: const InputDecoration(
                    hintText: 'Search estimates...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(12)),

              BlocBuilder<EstimatesBloc, SalesmanownerEstimatesState>(
                buildWhen: (p, c) =>
                p.filters != c.filters ||
                    p.activeFilter != c.activeFilter ||
                    p.status != c.status,
                builder: (context, state) {
                  if (state.status == EstimatesStatus.loading) {
                    return const EstimateFilterChipsShimmer();
                  }
                  if (state.filters.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                      itemCount: state.filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final filter = state.filters[i];
                        final selected = state.activeFilter == filter.key;
                        return ChoiceChip(
                          label: Text('${filter.label} (${filter.count})'),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: AppTextStyles.bodyBold(
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                          ),
                          onSelected: (_) =>
                              context.read<EstimatesBloc>().add(EstimatesFilterChanged(filter.key)),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: Responsive.h(12)),

              Expanded(
                child: BlocBuilder<EstimatesBloc, SalesmanownerEstimatesState>(
                  builder: (context, state) {
                    // Shimmer skeleton on first load AND on manual refresh —
                    // same widget both times, matching the dashboard.
                    if (state.status == EstimatesStatus.loading) {
                      return const MyEstimatesListShimmer();
                    }

                    if (state.status == EstimatesStatus.failure && state.allEstimates.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(Responsive.w(24)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.errorMessage ?? 'Something went wrong.',
                                style: AppTextStyles.subtitle(),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: Responsive.h(12)),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<EstimatesBloc>()
                                    .add(const EstimatesLoadRequested()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final list = state.filteredEstimates;
                    if (list.isEmpty) {
                      return Center(
                        child: Text('No estimates found', style: AppTextStyles.subtitle()),
                      );
                    }

                    return ListView.builder(
                      padding:
                      EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                      itemCount: list.length,
                      itemBuilder: (context, i) => EstimateCard(
                        estimate: list[i],
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SalesmanEstimateDetailsScreen(id: list[i].id),
                            ),
                          );
                          // Refresh when returning from the detail screen,
                          // in case its status changed there — replaces the
                          // RouteObserver-based auto-refresh.
                          if (context.mounted) {
                            context.read<EstimatesBloc>().add(const EstimatesRefreshRequested());
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}