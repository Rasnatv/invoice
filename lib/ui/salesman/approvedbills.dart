
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/estimate/salesman_approvedbloc.dart';
import '../../bloc/salemanbloc/estimate/salesman_approvedevent.dart';
import '../../bloc/salemanbloc/estimate/salesman_approvedsate.dart';
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

  void _openEstimateDetail(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SalesmanEstimateDetailsScreen(id: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Approved Bills', style: AppTextStyles.h6()),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
              child: TextField(
                onChanged: (v) =>
                    context.read<ApprovedEstimatesBloc>().add(ApprovedEstimatesSearchChanged(v)),
                decoration: const InputDecoration(
                  hintText: 'Search estimates...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            Expanded(
              child: BlocBuilder<ApprovedEstimatesBloc, ApprovedEstimatesState>(
                builder: (context, state) {
                  if (state.isLoading && state.list.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == ApprovedEstimatesStatus.failure && state.list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 40, color: AppColors.error),
                          SizedBox(height: Responsive.h(10)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                            child: Text(
                              state.errorMessage ?? 'Failed to load approved bills.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(color: AppColors.error),
                            ),
                          ),
                          SizedBox(height: Responsive.h(10)),
                          TextButton(
                            onPressed: () => context
                                .read<ApprovedEstimatesBloc>()
                                .add(const ApprovedEstimatesRequested()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final list = state.filtered;
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No estimates found', style: AppTextStyles.subtitle()),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ApprovedEstimatesBloc>().add(const ApprovedEstimatesRefreshed());
                      await context.read<ApprovedEstimatesBloc>().stream.firstWhere(
                            (s) => s.status != ApprovedEstimatesStatus.refreshing,
                      );
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                      itemCount: list.length,
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
    );
  }
}