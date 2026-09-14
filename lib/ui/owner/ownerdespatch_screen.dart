
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchstate.dart';
import '../../widgets/despatchcard.dart';
import '../../widgets/despatchcardshimmer.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'owner_despatchdetailscreen.dart';

class OwnerdespatchScreen extends StatelessWidget {
  const OwnerdespatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OwnerdespatchView();
  }
}

class _OwnerdespatchView extends StatefulWidget {
  const _OwnerdespatchView();

  @override
  State<_OwnerdespatchView> createState() => _OwnerdespatchViewState();
}

class _OwnerdespatchViewState extends State<_OwnerdespatchView> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    final bloc = context.read<DispatchListBloc>();
    bloc.add(const RefreshDispatchList());
    await bloc.stream.firstWhere(
          (s) => s.status == DispatchListStatus.success || s.status == DispatchListStatus.failure,
    );
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('My Dispatch Bills', style: AppTextStyles.h6())),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(12)),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search dispatch bills...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => context.read<DispatchListBloc>().add(SearchDispatchQueryChanged(value)),
                ),
              ),
              Expanded(
                child: BlocBuilder<DispatchListBloc, DispatchListState>(
                  builder: (context, state) {
                    // Initial load OR manual refresh -> shimmer
                    if (state.status == DispatchListStatus.initial ||
                        state.status == DispatchListStatus.loading ||
                        _isRefreshing) {
                      return ShimmerListPlaceholder(
                        itemCount: 6,
                        padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                        separatorHeight: Responsive.h(12),
                        itemBuilder: (_, __) => const DispatchCardShimmer(),
                      );
                    }

                    if (state.status == DispatchListStatus.failure && state.allDispatches.isEmpty) {
                      return _ErrorView(
                        message: state.errorMessage ?? 'Failed to load dispatch bills',
                        onRetry: () => context.read<DispatchListBloc>().add(const FetchDispatchList()),
                      );
                    }

                    final list = state.filteredDispatches;

                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: list.isEmpty
                          ? ListView(
                        children: [
                          SizedBox(height: Responsive.h(120)),
                          Center(
                            child: Text(
                              state.searchQuery.isEmpty
                                  ? 'No dispatch bills yet'
                                  : 'No dispatch bills match your search',
                              style: AppTextStyles.body(),
                            ),
                          ),
                        ],
                      )
                          : ListView.builder(
                        padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final dispatch = list[i];
                          return GestureDetector(
                            onTap: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OwnerDispatchDetailScreen(dispatchId: dispatch.id),
                                ),
                              );
                              if (changed == true && context.mounted) {
                                context.read<DispatchListBloc>().add(const RefreshDispatchList());
                              }
                            },
                            child: DispatchCard(dispatch: dispatch),
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
            const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
            SizedBox(height: Responsive.h(10)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(14)),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}