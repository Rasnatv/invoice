import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/salesman/salesman%20despatchdetailscreen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchstate.dart';
import '../../models/owner_models/owner_despatchmodellist.dart';


/// Salesman version of the dispatch bills listing screen.
///
/// Deliberately reuses [DispatchListBloc] / [DispatchProvider] / events /
/// states from the owner flow — same auth token, same API, same shape of
/// data. Only the screen (and navigation target) differs.
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onCardTap(DispatchListItem dispatch) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SalesmanDispatchDetailScreen(dispatchId: dispatch.id.toString()),
      ),
    ).then((didChange) {
      // Detail screen may have changed status (in transit / delivered) —
      // refresh the list so it reflects that without a full reload spinner.
      if (didChange == true && mounted) {
        context.read<DispatchListBloc>().add(const RefreshDispatchList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
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
    );
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
      return Center(child: Text('No dispatch bills found', style: AppTextStyles.subtitle()));
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<DispatchListBloc>().add(const RefreshDispatchList()),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
        itemCount: state.filteredDispatches.length,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, i) {
          final d = state.filteredDispatches[i];
          return _DispatchCard(
            key: ValueKey(d.id),
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

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}