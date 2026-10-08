
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
  final ScrollController _scrollController = ScrollController();

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
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<EstimatesBloc>().add(const EstimatesLoadMoreRequested());
    }
  }

  /// If the visible (filtered) list is too short to scroll, the scroll
  /// listener never fires - so fetch the next page ourselves until the
  /// list fills the screen or there is nothing more to load.
  void _scheduleAutoLoadMore(SalesmanownerEstimatesState state) {
    if (!state.hasMore || state.isLoadingMore || state.loadMoreFailed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        context.read<EstimatesBloc>().add(const EstimatesLoadMoreRequested());
      }
    });
  }

  void _openDetails(BuildContext context, String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SalesmanEstimateDetailsScreen(id: id),
      ),
    );
    // Refresh when returning from the detail screen,
    // in case its status changed there.
    if (context.mounted) {
      context.read<EstimatesBloc>().add(const EstimatesRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('My Estimates', style: AppTextStyles.h6()),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<EstimatesBloc>();
              bloc.add(const EstimatesRefreshRequested());
              await bloc.stream
                  .firstWhere((s) => s.status != EstimatesStatus.loading);
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
                  child: TextField(
                    onChanged: (v) => context
                        .read<EstimatesBloc>()
                        .add(EstimatesSearchQueryChanged(v)),
                    decoration: const InputDecoration(
                      hintText: 'Search estimates...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(12)),

                // Filter chips: only shown when there are estimates.
                BlocBuilder<EstimatesBloc, SalesmanownerEstimatesState>(
                  buildWhen: (p, c) =>
                  p.filters != c.filters ||
                      p.activeFilter != c.activeFilter ||
                      p.status != c.status ||
                      p.allEstimates != c.allEstimates,
                  builder: (context, state) {
                    if (state.status == EstimatesStatus.loading) {
                      return Column(
                        children: [
                          const EstimateFilterChipsShimmer(),
                          SizedBox(height: Responsive.h(12)),
                        ],
                      );
                    }

                    // No estimates at all -> hide chips (no "All (0)").
                    if (state.allEstimates.isEmpty || state.filters.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(16)),
                            itemCount: state.filters.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final filter = state.filters[i];
                              final selected = state.activeFilter == filter.key;
                              return ChoiceChip(
                                label:
                                Text('${filter.label} (${filter.count})'),
                                selected: selected,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                labelStyle: AppTextStyles.bodyBold(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.border),
                                ),
                                onSelected: (_) => context
                                    .read<EstimatesBloc>()
                                    .add(EstimatesFilterChanged(filter.key)),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                      ],
                    );
                  },
                ),

                Expanded(
                  child:
                  BlocBuilder<EstimatesBloc, SalesmanownerEstimatesState>(
                    builder: (context, state) {
                      // Shimmer skeleton on first load AND on manual refresh.
                      if (state.status == EstimatesStatus.loading) {
                        return const MyEstimatesListShimmer();
                      }

                      if (state.status == EstimatesStatus.failure &&
                          state.allEstimates.isEmpty) {
                        return _ErrorView(
                          message: state.errorMessage ??
                              'Failed to load estimates.',
                          onRetry: () => context
                              .read<EstimatesBloc>()
                              .add(const EstimatesLoadRequested()),
                        );
                      }

                      final list = state.filteredEstimates;

                      if (list.isEmpty) {
                        // The filter/search may match items on later pages.
                        _scheduleAutoLoadMore(state);

                        // Scrollable so pull-to-refresh still works.
                        return LayoutBuilder(
                          builder: (context, constraints) => ListView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (state.isLoadingMore)
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    else
                                      Icon(
                                        Icons.description_rounded,
                                        size: 40,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.4),
                                      ),
                                    SizedBox(height: Responsive.h(10)),
                                    Text(
                                      state.isLoadingMore
                                          ? 'Searching more estimates...'
                                          : 'No estimates found',
                                      style: AppTextStyles.subtitle(),
                                    ),
                                    if (state.loadMoreFailed)
                                      TextButton(
                                        onPressed: () => context
                                            .read<EstimatesBloc>()
                                            .add(const
                                        EstimatesLoadMoreRequested()),
                                        child: const Text(
                                            'Failed to load more. Tap to retry'),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      _scheduleAutoLoadMore(state);

                      final showFooter = state.hasMore ||
                          state.isLoadingMore ||
                          state.loadMoreFailed;

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(Responsive.w(16), 0,
                            Responsive.w(16), Responsive.h(20)),
                        itemCount: list.length + (showFooter ? 1 : 0),
                        itemBuilder: (context, i) {
                          // Footer: spinner or retry button.
                          if (i >= list.length) {
                            if (state.loadMoreFailed) {
                              return Center(
                                child: TextButton(
                                  onPressed: () => context
                                      .read<EstimatesBloc>()
                                      .add(const EstimatesLoadMoreRequested()),
                                  child: const Text(
                                      'Failed to load more. Tap to retry'),
                                ),
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Responsive.h(16)),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            );
                          }

                          return EstimateCard(
                            estimate: list[i],
                            onTap: () => _openDetails(context, list[i].id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error state shown when the estimates list fails to load.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: Responsive.w(40)),
            SizedBox(height: Responsive.h(12)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(16)),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}