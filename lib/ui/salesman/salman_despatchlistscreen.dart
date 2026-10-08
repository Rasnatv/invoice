
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/salesman/salesman%20despatchdetailscreen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchstate.dart';
import '../../models/owner_models/owner_despatchmodellist.dart';
import '../../widgets/despatchcardshimmer.dart';

class SalesmanDispatchListScreen extends StatelessWidget {
  const SalesmanDispatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DispatchListBloc(DispatchProvider())..add(const FetchDispatchList()),
      child: const _SalesmanDispatchListView(),
    );
  }
}

class _SalesmanDispatchListView extends StatefulWidget {
  const _SalesmanDispatchListView();

  @override
  State<_SalesmanDispatchListView> createState() => _SalesmanDispatchListViewState();
}

class _SalesmanDispatchListViewState extends State<_SalesmanDispatchListView> {
  final _searchCtrl = TextEditingController();

  // True while a manual refresh (pull-to-refresh OR the AppBar refresh icon)
  // is in flight.
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onCardTap(DispatchListItem dispatch) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SalesmanDispatchDetailScreen(dispatchId: dispatch.id.toString()),
      ),
    ).then((_) {
      // Always refresh on return — regardless of how the detail screen was
      // popped (AppBar back button, system back gesture, etc).
      if (mounted) {
        context.read<DispatchListBloc>().add(const RefreshDispatchList());
      }
    });
  }

  /// Shared by pull-to-refresh and the AppBar refresh icon.
  Future<void> _doRefresh(BuildContext context) async {
    if (_isRefreshing) return; // ignore taps while a refresh is running
    // Fire the refresh event, then wait for the bloc to settle into
    // success/failure so the spinner stays visible for the full round-trip.
    setState(() => _isRefreshing = true);
    try {
      final bloc = context.read<DispatchListBloc>();
      bloc.add(const RefreshDispatchList());
      await bloc.stream
          .firstWhere(
            (s) => s.status == DispatchListStatus.success || s.status == DispatchListStatus.failure,
      )
          .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Dispatch Bills', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,

        ),
        body: SafeArea(
          child: BlocBuilder<DispatchListBloc, DispatchListState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => context
                          .read<DispatchListBloc>()
                          .add(SearchDispatchQueryChanged(v)),
                      decoration: const InputDecoration(
                        hintText: 'Search DS number, party or estimate no.',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Expanded(child: _buildBody(context, state, _isRefreshing)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DispatchListState state, bool isRefreshing) {
    if (state.status == DispatchListStatus.initial ||
        (state.status == DispatchListStatus.loading &&
            state.allDispatches.isEmpty &&
            !isRefreshing)) {
      return const DispatchListShimmer();
    }

    if (state.status == DispatchListStatus.failure && state.allDispatches.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _doRefresh(context),
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: c.maxHeight,
              child: _ErrorView(
                message: state.errorMessage ?? 'Failed to load dispatch bills.',
                onRetry: () =>
                    context.read<DispatchListBloc>().add(const FetchDispatchList()),
              ),
            ),
          ),
        ),
      );
    }

    if (state.filteredDispatches.isEmpty) {
      // Wrapped in RefreshIndicator + AlwaysScrollableScrollPhysics so the
      // pull-down refresh circle works even when there is no data.
      return RefreshIndicator(
        onRefresh: () => _doRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: Responsive.h(270)),
            Icon(Icons.local_shipping_rounded,
                size: 40, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(10)),
            Center(
              child: Text(
                state.searchQuery.isEmpty
                    ? 'No dispatch bills found'
                    : 'No dispatch bills match your search',
                style: AppTextStyles.subtitle(),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _doRefresh(context),
      child: isRefreshing
          ? DispatchListShimmer(itemCount: state.filteredDispatches.length)
          : ListView.separated(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
        itemCount: state.filteredDispatches.length,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, i) {
          final d = state.filteredDispatches[i];
          return _DispatchCard(
            key: ValueKey('${d.id}_${d.status}'),
            dispatch: d,
            onTap: () => _onCardTap(d),
          );
        },
      ),
    );
  }
}

/// Error state shown when the dispatch list fails to load.
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
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(16)),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _DispatchCard extends StatelessWidget {
  const _DispatchCard({super.key, required this.dispatch, required this.onTap});

  final DispatchListItem dispatch;
  final VoidCallback onTap;

  // Maps the raw status to a label + color for the badge below.
  ({String label, Color color, IconData icon}) get _statusMeta {
    if (dispatch.isDelivered) {
      return (label: 'Delivered', color: AppColors.info, icon: Icons.check_circle_rounded);
    }
    if (dispatch.isInTransit) {
      return (label: 'In Transit', color: AppColors.warning, icon: Icons.local_shipping_rounded);
    }
    return (label: 'Pending', color: AppColors.warning, icon: Icons.local_shipping_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'DS No: ${dispatch.dsNumber}',
                    style: AppTextStyles.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
            SizedBox(height: Responsive.h(4)),
            Row(
              children: [
                const Icon(Icons.storefront_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Expanded(
                  child: Text(
                    dispatch.partyName,
                    style: AppTextStyles.caption(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(4)),
            Text('Ref: ${dispatch.estimateNumber}', style: AppTextStyles.caption()),
            SizedBox(height: Responsive.h(8)),
            // Visible status badge so a refresh actually shows a change.
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(8), vertical: Responsive.h(4)),
              decoration: BoxDecoration(
                color: meta.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(meta.icon, size: 14, color: meta.color),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    meta.label,
                    style: TextStyle(
                      color: meta.color,
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.sp(11.5),
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
}