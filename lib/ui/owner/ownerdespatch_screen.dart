// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../Apiprovider/ownerdespatchprovider.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchstate.dart';
// import '../../widgets/despatchcard.dart';
// import 'owner_despatchdetailscreen.dart';
//
// class OwnerdespatchScreen extends StatelessWidget {
//   const OwnerdespatchScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const _OwnerdespatchView(); // bloc now provided by Ownerdashboardshell
//   }
// }
//
// class _OwnerdespatchView extends StatelessWidget {
//   const _OwnerdespatchView();
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return NetworkAwareWrapper(child: Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('My Dispatch Bills', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(12)),
//               child: TextField(
//                 decoration: const InputDecoration(
//                   hintText: 'Search dispatch bills...',
//                   prefixIcon: Icon(Icons.search_rounded),
//                 ),
//                 onChanged: (value) => context.read<DispatchListBloc>().add(SearchDispatchQueryChanged(value)),
//               ),
//             ),
//             Expanded(
//               child: BlocBuilder<DispatchListBloc, DispatchListState>(
//                 builder: (context, state) {
//                   if (state.status == DispatchListStatus.initial || state.status == DispatchListStatus.loading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (state.status == DispatchListStatus.failure && state.allDispatches.isEmpty) {
//                     return _ErrorView(
//                       message: state.errorMessage ?? 'Failed to load dispatch bills',
//                       onRetry: () => context.read<DispatchListBloc>().add(const FetchDispatchList()),
//                     );
//                   }
//
//                   final list = state.filteredDispatches;
//
//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       final bloc = context.read<DispatchListBloc>();
//                       bloc.add(const RefreshDispatchList());
//                       await bloc.stream.firstWhere(
//                             (s) => s.status == DispatchListStatus.success || s.status == DispatchListStatus.failure,
//                       );
//                     },
//                     child: list.isEmpty
//                         ? ListView(
//                       children: [
//                         SizedBox(height: Responsive.h(120)),
//                         Center(
//                           child: Text(
//                             state.searchQuery.isEmpty ? 'No dispatch bills yet' : 'No dispatch bills match your search',
//                             style: AppTextStyles.body(),
//                           ),
//                         ),
//                       ],
//                     )
//                         : ListView.builder(
//                       padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
//                       itemCount: list.length,
//                       itemBuilder: (context, i) {
//                         final dispatch = list[i];
//                         return
//                           GestureDetector(
//                             onTap: () async {
//                               final changed = await Navigator.push<bool>(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => OwnerDispatchDetailScreen(dispatchId: dispatch.id),
//                                 ),
//                               );
//                               if (changed == true && context.mounted) {
//                                 context.read<DispatchListBloc>().add(const RefreshDispatchList());
//                               }
//                             },
//                           child: DispatchCard(dispatch: dispatch),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   const _ErrorView({required this.message, required this.onRetry});
//   final String message;
//   final VoidCallback onRetry;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(Responsive.w(24)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
//             SizedBox(height: Responsive.h(10)),
//             Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
//             SizedBox(height: Responsive.h(14)),
//             ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchstate.dart';
import '../../widgets/despatchcard.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'owner_despatchdetailscreen.dart';

class OwnerdespatchScreen extends StatelessWidget {
  const OwnerdespatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OwnerdespatchView(); // bloc now provided by Ownerdashboardshell
  }
}

class _OwnerdespatchView extends StatelessWidget {
  const _OwnerdespatchView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(child: Scaffold(
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
                  // Covers both the very first load AND a pull-to-refresh
                  // (RefreshDispatchList puts the bloc back into `loading`),
                  // so the shimmer shows in both cases. We size the skeleton
                  // to whatever was already on screen so a refresh doesn't
                  // visibly jump; a first load falls back to a default count.
                  if (state.status == DispatchListStatus.initial ||
                      state.status == DispatchListStatus.loading) {
                    final int skeletonCount = state.filteredDispatches.isNotEmpty
                        ? state.filteredDispatches.length
                        : 6;

                    return ShimmerListPlaceholder(
                      itemCount: skeletonCount,
                      padding: EdgeInsets.fromLTRB(
                          Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                      separatorHeight: Responsive.h(10),
                      itemBuilder: (context, i) => const _DispatchCardSkeleton(),
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
                    onRefresh: () async {
                      final bloc = context.read<DispatchListBloc>();
                      bloc.add(const RefreshDispatchList());
                      await bloc.stream.firstWhere(
                            (s) => s.status == DispatchListStatus.success || s.status == DispatchListStatus.failure,
                      );
                    },
                    child: list.isEmpty
                        ? ListView(
                      children: [
                        SizedBox(height: Responsive.h(120)),
                        Center(
                          child: Text(
                            state.searchQuery.isEmpty ? 'No dispatch bills yet' : 'No dispatch bills match your search',
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
                        return
                          GestureDetector(
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
    ));
  }
}

/// Skeleton placeholder shaped roughly like [DispatchCard], shown (inside a
/// [ShimmerLoading] ancestor via [ShimmerListPlaceholder]) while dispatch
/// bills are loading or refreshing.
///
/// NOTE: this approximates a typical bill-card layout (title/number row,
/// a status chip, a couple of detail lines, and a date/amount footer).
/// Tweak the rows below to line up with your actual `DispatchCard` widget
/// if its real layout differs.
class _DispatchCardSkeleton extends StatelessWidget {
  const _DispatchCardSkeleton();

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
          // Bill number + status chip row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerBox(width: 150, height: 14),
              const ShimmerBox(width: 70, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          // Customer / party name
          const ShimmerBox(width: 180, height: 14),
          SizedBox(height: Responsive.h(8)),
          // Secondary detail line (e.g. contractor / salesman)
          const ShimmerBox(width: 130, height: 12),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          // Date + amount footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 80, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
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