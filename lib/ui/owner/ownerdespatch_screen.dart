import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchstate.dart';
import '../../widgets/despatchcard.dart';
import 'owner_despatchdetailscreen.dart';


class OwnerdespatchScreen extends StatelessWidget {
  const OwnerdespatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DispatchListBloc(DispatchProvider())..add(const FetchDispatchList()),
      child: const _OwnerdespatchView(),
    );
  }
}

class _OwnerdespatchView extends StatelessWidget {
  const _OwnerdespatchView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
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
                  if (state.status == DispatchListStatus.initial || state.status == DispatchListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
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
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OwnerDispatchDetailScreen(dispatchId: dispatch.id),
                            ),
                          ),
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
