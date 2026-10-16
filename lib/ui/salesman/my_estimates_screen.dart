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
  final _searchCtrl = TextEditingController();
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
    _searchCtrl.dispose();
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

  Future<void> _onRefresh() async {
    final bloc = context.read<EstimatesBloc>();
    bloc.add(const EstimatesRefreshRequested());
    await bloc.stream.firstWhere((s) => s.status != EstimatesStatus.loading);
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
    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as owner) ----------
        appBar: AppBar(
          title: Text('My Estimates', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    Responsive.w(20), Responsive.h(14), Responsive.w(20), 0),
                child: _SearchField(
                  controller: _searchCtrl,
                  hint: 'Search estimates...',
                  onChanged: (v) => context
                      .read<EstimatesBloc>()
                      .add(EstimatesSearchQueryChanged(v)),
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
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(20)),
                          itemCount: state.filters.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final filter = state.filters[i];
                            return _FilterChip(
                              label: '${filter.label} (${filter.count})',
                              selected: state.activeFilter == filter.key,
                              onTap: () => context
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
                child: BlocBuilder<EstimatesBloc, SalesmanownerEstimatesState>(
                  builder: (context, state) {
                    // Shimmer skeleton on first load AND on manual refresh.
                    if (state.status == EstimatesStatus.loading) {
                      return const MyEstimatesListShimmer();
                    }

                    if (state.status == EstimatesStatus.failure &&
                        state.allEstimates.isEmpty) {
                      return _ErrorView(
                        message:
                        state.errorMessage ?? 'Failed to load estimates.',
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
                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _onRefresh,
                        child: LayoutBuilder(
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
                                        Icons.description_outlined,
                                        size: 44,
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
                                        child: Text(
                                          'Failed to load more. Tap to retry',
                                          style: AppTextStyles.link(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    _scheduleAutoLoadMore(state);

                    final showFooter = state.hasMore ||
                        state.isLoadingMore ||
                        state.loadMoreFailed;

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: listPadding,
                        itemCount: list.length + (showFooter ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Responsive.h(10)),
                        itemBuilder: (context, i) {
                          // Footer: spinner or retry button.
                          if (i >= list.length) {
                            if (state.loadMoreFailed) {
                              return Center(
                                child: TextButton(
                                  onPressed: () => context
                                      .read<EstimatesBloc>()
                                      .add(const EstimatesLoadMoreRequested()),
                                  child: Text(
                                    'Failed to load more. Tap to retry',
                                    style: AppTextStyles.link(),
                                  ),
                                ),
                              );
                            }
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return EstimateCard(
                            estimate: list[i],
                            onTap: () => _openDetails(context, list[i].id),
                          );
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
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file, same as owner screen)
// =====================================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.body(),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: AppTextStyles.body(color: AppColors.textHint),
        prefixIcon: Icon(Icons.search_rounded,
            size: 20, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(13)),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(12), vertical: Responsive.h(6)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.link(
            color: selected ? Colors.white : AppColors.textPrimary,
          ).copyWith(fontSize: Responsive.sp(11.5)),
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
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.link()),
            ),
          ],
        ),
      ),
    );
  }
}