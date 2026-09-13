
import 'dart:async';
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

  // Auto-refreshes the list periodically while this screen is visible, so
  // status changes made on the detail screen (in transit / delivered) show
  // up here without needing a manual pull-to-refresh.
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<DispatchListBloc>().add(const RefreshDispatchList());
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
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
      // popped (AppBar back button, system back gesture, etc). The detail
      // screen never pops with a `true` result, so relying on that left the
      // list stale until the next 5s auto-refresh tick.
      if (mounted) {
        context.read<DispatchListBloc>().add(const RefreshDispatchList());
      }
    });
  }

  Future<void> _onPullToRefresh(BuildContext context) async {
    // Mirrors the owner list screen: fire the refresh event, then wait for
    // the bloc to settle into success/failure so the RefreshIndicator spinner
    // stays visible for the full round-trip instead of dismissing instantly.
    final bloc = context.read<DispatchListBloc>();
    bloc.add(const RefreshDispatchList());
    await bloc.stream.firstWhere(
          (s) => s.status == DispatchListStatus.success || s.status == DispatchListStatus.failure,
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(child: Scaffold(
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
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    ));
  }

  Widget _buildBody(BuildContext context, DispatchListState state) {
    if (state.status == DispatchListStatus.initial ||
        (state.status == DispatchListStatus.loading && state.allDispatches.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == DispatchListStatus.failure && state.allDispatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'Failed to load dispatch bills.',
                style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            ElevatedButton(
              onPressed: () =>
                  context.read<DispatchListBloc>().add(const FetchDispatchList()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.filteredDispatches.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: Responsive.h(120)),
          Center(
            child: Text(
              state.searchQuery.isEmpty ? 'No dispatch bills found' : 'No dispatch bills match your search',
              style: AppTextStyles.subtitle(),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => _onPullToRefresh(context),
      child: ListView.separated(
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

class _DispatchCard extends StatelessWidget {
  const _DispatchCard({super.key, required this.dispatch, required this.onTap});

  final DispatchListItem dispatch;
  final VoidCallback onTap;

  // NEW: maps the raw status to a label + color for the badge below.
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
            Text('Estimate No: ${dispatch.estimateNumber}', style: AppTextStyles.caption()),
            SizedBox(height: Responsive.h(8)),
            // NEW: visible status badge so a refresh actually shows a change.
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