// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import 'package:tileshop/ui/salesman/salesman%20despatchdetailscreen.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../Apiprovider/ownerdespatchprovider.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchstate.dart';
// import '../../models/owner_models/owner_despatchmodellist.dart';
// import '../../widgets/despatchcardshimmer.dart';
// import '../owner/widget/despatchcardshimmer.dart';
//
// class SalesmanDispatchListScreen extends StatelessWidget {
//   const SalesmanDispatchListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) =>
//       DispatchListBloc(DispatchProvider())..add(const FetchDispatchList()),
//       child: const _SalesmanDispatchListView(),
//     );
//   }
// }
//
// class _SalesmanDispatchListView extends StatefulWidget {
//   const _SalesmanDispatchListView();
//
//   @override
//   State<_SalesmanDispatchListView> createState() =>
//       _SalesmanDispatchListViewState();
// }
//
// class _SalesmanDispatchListViewState extends State<_SalesmanDispatchListView> {
//   final _searchCtrl = TextEditingController();
//
//   // True while a manual refresh (pull-to-refresh) is in flight.
//   bool _isRefreshing = false;
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   void _onCardTap(DispatchListItem dispatch) {
//     Navigator.of(context)
//         .push(
//       MaterialPageRoute(
//         builder: (_) =>
//             SalesmanDispatchDetailScreen(dispatchId: dispatch.id.toString()),
//       ),
//     )
//         .then((_) {
//       // Always refresh on return, however the detail screen was popped.
//       if (mounted) {
//         context.read<DispatchListBloc>().add(const RefreshDispatchList());
//       }
//     });
//   }
//
//   /// Pull-to-refresh. Waits for the bloc to settle so the spinner stays
//   /// visible for the full round-trip.
//   Future<void> _doRefresh(BuildContext context) async {
//     if (_isRefreshing) return;
//     setState(() => _isRefreshing = true);
//     try {
//       final bloc = context.read<DispatchListBloc>();
//       bloc.add(const RefreshDispatchList());
//       await bloc.stream
//           .firstWhere(
//             (s) =>
//         s.status == DispatchListStatus.success ||
//             s.status == DispatchListStatus.failure,
//       )
//           .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
//     } finally {
//       if (mounted) setState(() => _isRefreshing = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return NetworkAwareWrapper(
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//
//         // ---------- APPBAR (same as owner) ----------
//         appBar: AppBar(
//           title: Text('Dispatch Bills', style: AppTextStyles.h6()),
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//         ),
//
//         body: SafeArea(
//           child: BlocBuilder<DispatchListBloc, DispatchListState>(
//             builder: (context, state) {
//               return Column(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(Responsive.w(20),
//                         Responsive.h(14), Responsive.w(20), 0),
//                     child: _SearchField(
//                       controller: _searchCtrl,
//                       hint: 'Search DS number, party or estimate no.',
//                       onChanged: (v) => context
//                           .read<DispatchListBloc>()
//                           .add(SearchDispatchQueryChanged(v)),
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(12)),
//                   Expanded(child: _buildBody(context, state, _isRefreshing)),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody(
//       BuildContext context, DispatchListState state, bool isRefreshing) {
//     final listPadding = EdgeInsets.fromLTRB(
//         Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));
//
//     if (state.status == DispatchListStatus.initial ||
//         (state.status == DispatchListStatus.loading &&
//             state.allDispatches.isEmpty &&
//             !isRefreshing)) {
//       return const DispatchListShimmer();
//     }
//
//     if (state.status == DispatchListStatus.failure &&
//         state.allDispatches.isEmpty) {
//       return RefreshIndicator(
//         color: AppColors.primary,
//         onRefresh: () => _doRefresh(context),
//         child: LayoutBuilder(
//           builder: (context, c) => SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: SizedBox(
//               height: c.maxHeight,
//               child: _ErrorView(
//                 message: state.errorMessage ?? 'Failed to load dispatch bills.',
//                 onRetry: () => context
//                     .read<DispatchListBloc>()
//                     .add(const FetchDispatchList()),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     if (state.filteredDispatches.isEmpty) {
//       // Scrollable so pull-down refresh works even with no data.
//       return RefreshIndicator(
//         color: AppColors.primary,
//         onRefresh: () => _doRefresh(context),
//         child: LayoutBuilder(
//           builder: (context, constraints) => SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.local_shipping_outlined,
//                       size: 44,
//                       color: AppColors.textSecondary.withOpacity(0.4),
//                     ),
//                     SizedBox(height: Responsive.h(10)),
//                     Text(
//                       state.searchQuery.isEmpty
//                           ? 'No dispatch bills found'
//                           : 'No dispatch bills match your search',
//                       style: AppTextStyles.subtitle(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       color: AppColors.primary,
//       onRefresh: () => _doRefresh(context),
//       child: isRefreshing
//           ? DispatchListShimmer(itemCount: state.filteredDispatches.length)
//           : ListView.separated(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: listPadding,
//         itemCount: state.filteredDispatches.length,
//         separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
//         itemBuilder: (context, i) {
//           final d = state.filteredDispatches[i];
//           return _DispatchCard(
//             key: ValueKey('${d.id}_${d.status}'),
//             dispatch: d,
//             onTap: () => _onCardTap(d),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // =====================================================================
// // SMALL REUSABLE PIECES (private to this file, same as owner screen)
// // =====================================================================
//
// class _SearchField extends StatelessWidget {
//   const _SearchField({
//     required this.controller,
//     required this.hint,
//     required this.onChanged,
//   });
//   final TextEditingController controller;
//   final String hint;
//   final ValueChanged<String> onChanged;
//
//   OutlineInputBorder _border(Color c) => OutlineInputBorder(
//     borderRadius: BorderRadius.circular(14),
//     borderSide: BorderSide(color: c),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       onChanged: onChanged,
//       style: AppTextStyles.body(),
//       decoration: InputDecoration(
//         isDense: true,
//         filled: true,
//         fillColor: Colors.white,
//         hintText: hint,
//         hintStyle: AppTextStyles.body(color: AppColors.textHint),
//         prefixIcon: Icon(Icons.search_rounded,
//             size: 20, color: AppColors.textSecondary),
//         contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(13)),
//         border: _border(AppColors.border),
//         enabledBorder: _border(AppColors.border),
//         focusedBorder: _border(AppColors.primary),
//       ),
//     );
//   }
// }
//
// class _ListCard extends StatelessWidget {
//   const _ListCard({required this.child, this.onTap});
//   final Widget child;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(Responsive.w(14)),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppColors.border),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// class _IconTile extends StatelessWidget {
//   const _IconTile({required this.icon});
//   final IconData icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 42,
//       height: 42,
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(icon, color: AppColors.primary, size: 20),
//     );
//   }
// }
//
// class _InfoRow extends StatelessWidget {
//   const _InfoRow({
//     required this.icon,
//     required this.text,
//     this.color = AppColors.textSecondary,
//   });
//   final IconData icon;
//   final String text;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 14, color: color),
//         SizedBox(width: Responsive.w(6)),
//         Expanded(
//           child: Text(
//             text,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: AppTextStyles.captionnew(color: color)
//                 .copyWith(fontSize: Responsive.sp(11)),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _StatusPill extends StatelessWidget {
//   const _StatusPill({required this.label, required this.color});
//   final String label;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: AppTextStyles.link(color: color)
//             .copyWith(fontSize: Responsive.sp(10.5)),
//       ),
//     );
//   }
// }
//
// // =====================================================================
// // ERROR
// // =====================================================================
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
//             Icon(Icons.error_outline_rounded,
//                 color: AppColors.textSecondary.withOpacity(0.5), size: 38),
//             SizedBox(height: Responsive.h(10)),
//             Text(message,
//                 textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
//             SizedBox(height: Responsive.h(10)),
//             TextButton(
//               onPressed: onRetry,
//               child: Text('Try again', style: AppTextStyles.link()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // =====================================================================
// // DISPATCH CARD
// // =====================================================================
//
// class _DispatchCard extends StatelessWidget {
//   const _DispatchCard({super.key, required this.dispatch, required this.onTap});
//
//   final DispatchListItem dispatch;
//   final VoidCallback onTap;
//
//   // Maps the raw status to a label + colour for the pill.
//   ({String label, Color color}) get _statusMeta {
//     if (dispatch.isDelivered) {
//       return (label: 'Delivered', color: AppColors.info);
//     }
//     if (dispatch.isInTransit) {
//       return (label: 'In Transit', color: AppColors.warning);
//     }
//     return (label: 'Pending', color: AppColors.warning);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final meta = _statusMeta;
//
//     return _ListCard(
//       onTap: onTap,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ---- top: icon, DS number + party, status ----
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const _IconTile(icon: Icons.local_shipping_outlined),
//               SizedBox(width: Responsive.w(12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'DS No: ${dispatch.dsNumber}',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTextStyles.bodyBold(),
//                     ),
//                     SizedBox(height: Responsive.h(2)),
//                     Text(
//                       dispatch.partyName,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style:
//                       AppTextStyles.caption(color: AppColors.textSecondary),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: Responsive.w(8)),
//               _StatusPill(label: meta.label, color: meta.color),
//             ],
//           ),
//
//           SizedBox(height: Responsive.h(12)),
//           const Divider(height: 1, color: AppColors.border),
//           SizedBox(height: Responsive.h(10)),
//
//           // ---- bottom: estimate reference + chevron ----
//           Row(
//             children: [
//               Expanded(
//                 child: _InfoRow(
//                   icon: Icons.description_outlined,
//                   text: 'Ref: ${dispatch.estimateNumber}',
//                 ),
//               ),
//               Icon(Icons.chevron_right_rounded,
//                   size: 20, color: AppColors.textSecondary),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
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
import '../owner/widget/despatchcardshimmer.dart';

class SalesmanDispatchListScreen extends StatelessWidget {
  const SalesmanDispatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      DispatchListBloc(DispatchProvider())..add(const FetchDispatchList()),
      child: const _SalesmanDispatchListView(),
    );
  }
}

class _SalesmanDispatchListView extends StatefulWidget {
  const _SalesmanDispatchListView();

  @override
  State<_SalesmanDispatchListView> createState() =>
      _SalesmanDispatchListViewState();
}

class _SalesmanDispatchListViewState extends State<_SalesmanDispatchListView> {
  final _searchCtrl = TextEditingController();

  // True while a manual refresh (pull-to-refresh) is in flight.
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onCardTap(DispatchListItem dispatch) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) =>
            SalesmanDispatchDetailScreen(dispatchId: dispatch.id.toString()),
      ),
    )
        .then((_) {
      // Always refresh on return, however the detail screen was popped.
      if (mounted) {
        context.read<DispatchListBloc>().add(const RefreshDispatchList());
      }
    });
  }

  /// Pull-to-refresh. Waits for the bloc to settle so the spinner stays
  /// visible for the full round-trip.
  Future<void> _doRefresh(BuildContext context) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final bloc = context.read<DispatchListBloc>();
      bloc.add(const RefreshDispatchList());
      await bloc.stream
          .firstWhere(
            (s) =>
        s.status == DispatchListStatus.success ||
            s.status == DispatchListStatus.failure,
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

        // ---------- APPBAR (same as owner) ----------
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
                    padding: EdgeInsets.fromLTRB(Responsive.w(20),
                        Responsive.h(14), Responsive.w(20), 0),
                    child: _SearchField(
                      controller: _searchCtrl,
                      hint: 'Search DS number, party or estimate no.',
                      onChanged: (v) => context
                          .read<DispatchListBloc>()
                          .add(SearchDispatchQueryChanged(v)),
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

  Widget _buildBody(
      BuildContext context, DispatchListState state, bool isRefreshing) {
    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));

    // Initial load -> shimmer list
    if (state.status == DispatchListStatus.initial ||
        (state.status == DispatchListStatus.loading &&
            state.allDispatches.isEmpty &&
            !isRefreshing)) {
      return DispatchListShimmer(
        itemCount: 6,
        padding: listPadding,
        separatorHeight: Responsive.h(10),
      );
    }

    if (state.status == DispatchListStatus.failure &&
        state.allDispatches.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _doRefresh(context),
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: c.maxHeight,
              child: _ErrorView(
                message: state.errorMessage ?? 'Failed to load dispatch bills.',
                onRetry: () => context
                    .read<DispatchListBloc>()
                    .add(const FetchDispatchList()),
              ),
            ),
          ),
        ),
      );
    }

    if (state.filteredDispatches.isEmpty) {
      // Scrollable so pull-down refresh works even with no data.
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _doRefresh(context),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 44,
                      color: AppColors.textSecondary.withOpacity(0.4),
                    ),
                    SizedBox(height: Responsive.h(10)),
                    Text(
                      state.searchQuery.isEmpty
                          ? 'No dispatch bills found'
                          : 'No dispatch bills match your search',
                      style: AppTextStyles.subtitle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Manual refresh -> shimmer (capped so a long list doesn't build
    // dozens of placeholder cards).
    final shimmerCount =
    state.filteredDispatches.length > 8 ? 8 : state.filteredDispatches.length;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _doRefresh(context),
      child: isRefreshing
          ? DispatchListShimmer(
        itemCount: shimmerCount,
        padding: listPadding,
        separatorHeight: Responsive.h(10),
      )
          : ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: listPadding,
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

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: Responsive.w(6)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionnew(color: color)
                .copyWith(fontSize: Responsive.sp(11)),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.link(color: color)
            .copyWith(fontSize: Responsive.sp(10.5)),
      ),
    );
  }
}

// =====================================================================
// ERROR
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

// =====================================================================
// DISPATCH CARD
// =====================================================================

class _DispatchCard extends StatelessWidget {
  const _DispatchCard({super.key, required this.dispatch, required this.onTap});

  final DispatchListItem dispatch;
  final VoidCallback onTap;

  // Maps the raw status to a label + colour for the pill.
  ({String label, Color color}) get _statusMeta {
    if (dispatch.isDelivered) {
      return (label: 'Delivered', color: AppColors.info);
    }
    if (dispatch.isInTransit) {
      return (label: 'In Transit', color: AppColors.warning);
    }
    return (label: 'Pending', color: AppColors.warning);
  }

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta;

    return _ListCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: icon, DS number + party, status ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(icon: Icons.local_shipping_outlined),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DS No: ${dispatch.dsNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      dispatch.partyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _StatusPill(label: meta.label, color: meta.color),
            ],
          ),

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: estimate reference + chevron ----
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.description_outlined,
                  text: 'Ref: ${dispatch.estimateNumber}',
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}