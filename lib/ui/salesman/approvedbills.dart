//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../bloc/salemanbloc/approvedbills/salesman_approvedbloc.dart';
// import '../../bloc/salemanbloc/approvedbills/salesman_approvedevent.dart';
// import '../../bloc/salemanbloc/approvedbills/salesman_approvedsate.dart';
// import 'aprrovedestimatetile.dart';
// import 'estimatedetailscreen_forsalesman.dart';
//
//
//
// class ApprovedBills extends StatelessWidget {
//   const ApprovedBills({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => ApprovedEstimatesBloc()..add(const ApprovedEstimatesRequested()),
//       child: const _ApprovedBillsView(),
//     );
//   }
// }
//
// class _ApprovedBillsView extends StatelessWidget {
//   const _ApprovedBillsView();
//
//   Future<void> _openEstimateDetail(BuildContext context, String id) async {
//     // Grab the bloc before the await so we don't touch context afterwards.
//     final bloc = context.read<ApprovedEstimatesBloc>();
//
//     final despatched = await Navigator.of(context).push<bool>(
//       MaterialPageRoute(builder: (_) => SalesmanEstimateDetailsScreen(id: id)),
//     );
//
//     // Despatch sheet was created -> reload so the bill disappears from this list.
//     if (despatched == true) {
//       bloc.add(const ApprovedEstimatesRefreshed());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('Approved Bills', style: AppTextStyles.h6()),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
//               child: TextField(
//                 onChanged: (v) =>
//                     context.read<ApprovedEstimatesBloc>().add(ApprovedEstimatesSearchChanged(v)),
//                 decoration: const InputDecoration(
//                   hintText: 'Search estimates...',
//                   prefixIcon: Icon(Icons.search_rounded),
//                 ),
//               ),
//             ),
//             SizedBox(height: Responsive.h(12)),
//             Expanded(
//               child: BlocBuilder<ApprovedEstimatesBloc, ApprovedEstimatesState>(
//                 builder: (context, state) {
//                   if (state.isLoading && state.list.isEmpty) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (state.status == ApprovedEstimatesStatus.failure && state.list.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.error_outline, size: 40, color: AppColors.error),
//                           SizedBox(height: Responsive.h(10)),
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
//                             child: Text(
//                               state.errorMessage ?? 'Failed to load approved bills.',
//                               textAlign: TextAlign.center,
//                               style: AppTextStyles.body(color: AppColors.error),
//                             ),
//                           ),
//                           SizedBox(height: Responsive.h(10)),
//                           TextButton(
//                             onPressed: () => context
//                                 .read<ApprovedEstimatesBloc>()
//                                 .add(const ApprovedEstimatesRequested()),
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   final list = state.filtered;
//                   if (list.isEmpty) {
//                     return Column(children: [
//                          SizedBox(height: 270,),
//                         Icon(Icons.description_rounded, size: 40, color: AppColors.textSecondary.withOpacity(0.4)),
//                        SizedBox(height: Responsive.h(10)),
//                       Center(
//                       child: Text('No estimates found', style: AppTextStyles.subtitle()),
//                     )]);
//                   }
//
//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       context.read<ApprovedEstimatesBloc>().add(const ApprovedEstimatesRefreshed());
//                       await context.read<ApprovedEstimatesBloc>().stream.firstWhere(
//                             (s) => s.status != ApprovedEstimatesStatus.refreshing,
//                       );
//                     },
//                     child: ListView.builder(
//                       padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
//                       itemCount: list.length,
//                       itemBuilder: (context, i) => ApprovedEstimateTile(
//                         estimate: list[i],
//                         onTap: () => _openEstimateDetail(context, list[i].id),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
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
      create: (_) => ApprovedEstimatesBloc()..add(const ApprovedEstimatesRequested()),
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
    await bloc.stream.firstWhere((s) => s.status != ApprovedEstimatesStatus.refreshing);
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
                child: BlocBuilder<ApprovedEstimatesBloc, ApprovedEstimatesState>(
                  builder: (context, state) {
                    // ---- loading skeleton ----
                    if (state.isLoading && state.list.isEmpty) {
                      return ShimmerListPlaceholder(
                        itemCount: 6,
                        padding: listPadding,
                        separatorHeight: Responsive.h(10),
                        itemBuilder: (context, i) => const _ApprovedCardSkeleton(),
                      );
                    }

                    // ---- error ----
                    if (state.status == ApprovedEstimatesStatus.failure &&
                        state.list.isEmpty) {
                      return _ErrorView(
                        message: state.errorMessage ?? 'Failed to load approved bills.',
                        onRetry: () => context
                            .read<ApprovedEstimatesBloc>()
                            .add(const ApprovedEstimatesRequested()),
                      );
                    }

                    // ---- empty (still pull-to-refresh) ----
                    final list = state.filtered;
                    if (list.isEmpty) {
                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => _refresh(context),
                        child: LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.description_rounded,
                                      size: 44,
                                      color: AppColors.textSecondary.withOpacity(0.4),
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

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _refresh(context),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: listPadding,
                        itemCount: list.length,
                        // The tile already adds its own bottom spacing.
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (context, i) => ApprovedEstimateTile(
                          estimate: list[i],
                          onTap: () => _openEstimateDetail(context, list[i].id),
                        ),
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