import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/approvedbills/salesman_approvedbloc.dart';
import '../../bloc/salemanbloc/approvedbills/salesman_approvedevent.dart';
import '../../bloc/salemanbloc/approvedbills/salesman_approvedsate.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'aprrovedestimatetile.dart';
import 'estimatedetailscreen_forsalesman.dart';

class ApprovedBills extends StatelessWidget {
  const ApprovedBills({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ApprovedEstimatesBloc()..add(const ApprovedEstimatesRequested()),
      child: const _ApprovedBillsView(),
    );
  }
}

class _ApprovedBillsView extends StatelessWidget {
  const _ApprovedBillsView();

  Future<void> _openEstimateDetail(BuildContext context, String id) async {
    // Grab the bloc before the await so we don't touch context afterwards.
    final bloc = context.read<ApprovedEstimatesBloc>();

    final despatched = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SalesmanEstimateDetailsScreen(id: id)),
    );

    // Despatch sheet was created -> reload so the bill disappears from this list.
    if (despatched == true) {
      bloc.add(const ApprovedEstimatesRefreshed());
    }
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<ApprovedEstimatesBloc>();
    bloc.add(const ApprovedEstimatesRefreshed());
    await bloc.stream
        .firstWhere((s) => s.status != ApprovedEstimatesStatus.refreshing);
  }

  /// Dispatches LoadMore after the current frame (never inside build()).
  /// The bloc ignores it if a page is already loading or nothing is left.
  void _requestNextPage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<ApprovedEstimatesBloc>().add(const ApprovedEstimatesLoadMore());
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Approved Bills', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    Responsive.w(20), Responsive.h(14), Responsive.w(20), 0),
                child: TextField(
                  onChanged: (v) => context
                      .read<ApprovedEstimatesBloc>()
                      .add(ApprovedEstimatesSearchChanged(v)),
                  decoration: const InputDecoration(
                    hintText: 'Search estimates...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Expanded(
                child:
                BlocBuilder<ApprovedEstimatesBloc, ApprovedEstimatesState>(
                  builder: (context, state) {
                    // ---- loading skeleton ----
                    if (state.isLoading && state.list.isEmpty) {
                      return ShimmerListPlaceholder(
                        itemCount: 6,
                        padding: listPadding,
                        separatorHeight: Responsive.h(10),
                        itemBuilder: (context, i) =>
                        const _ApprovedCardSkeleton(),
                      );
                    }

                    // ---- error ----
                    if (state.status == ApprovedEstimatesStatus.failure &&
                        state.list.isEmpty) {
                      return _ErrorView(
                        message: state.errorMessage ??
                            'Failed to load approved bills.',
                        onRetry: () => context
                            .read<ApprovedEstimatesBloc>()
                            .add(const ApprovedEstimatesRequested()),
                      );
                    }

                    final list = state.filtered;

                    // Search is client-side, so while a search is active keep
                    // pulling pages until everything has been searched.
                    final searching = state.query.trim().isNotEmpty;
                    final canLoadMore = state.hasMore &&
                        !state.loadMoreFailed &&
                        state.status == ApprovedEstimatesStatus.success;

                    // ---- empty (still pull-to-refresh) ----
                    if (list.isEmpty) {
                      if (searching && canLoadMore) {
                        _requestNextPage(context);
                      }
                      final stillSearching = searching &&
                          state.hasMore &&
                          !state.loadMoreFailed;

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => _refresh(context),
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight),
                                  child: Center(
                                    child: stillSearching
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    )
                                        : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.description_rounded,
                                          size: 44,
                                          color: AppColors.textSecondary
                                              .withOpacity(0.4),
                                        ),
                                        SizedBox(height: Responsive.h(10)),
                                        Text('No estimates found',
                                            style: AppTextStyles.subtitle()),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      );
                    }

                    // ---- list + pagination footer ----
                    final showFooter = state.hasMore;

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _refresh(context),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: listPadding,
                        itemCount: list.length + (showFooter ? 1 : 0),
                        itemBuilder: (context, i) {
                          // Footer row (last item)
                          if (i == list.length) {
                            return _PaginationFooter(
                              failed: state.loadMoreFailed,
                              onRetry: () => context
                                  .read<ApprovedEstimatesBloc>()
                                  .add(const ApprovedEstimatesLoadMore()),
                              // Built only when the user scrolls to the end
                              // (or the list is too short to scroll).
                              onVisible: () => _requestNextPage(context),
                            );
                          }

                          // The tile already adds its own bottom spacing.
                          return ApprovedEstimateTile(
                            estimate: list[i],
                            onTap: () =>
                                _openEstimateDetail(context, list[i].id),
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
// PAGINATION FOOTER
// =====================================================================

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.failed,
    required this.onRetry,
    required this.onVisible,
  });

  final bool failed;
  final VoidCallback onRetry;
  final VoidCallback onVisible;

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text('Failed to load more. Tap to retry',
                style: AppTextStyles.link()),
          ),
        ),
      );
    }

    // Footer got built => user reached the end => ask for the next page.
    onVisible();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

// =====================================================================
// ERROR / SKELETON
// =====================================================================

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

class _ApprovedCardSkeleton extends StatelessWidget {
  const _ApprovedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: Responsive.w(12)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 13),
                    SizedBox(height: 8),
                    ShimmerBox(width: 160, height: 11),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 100, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}