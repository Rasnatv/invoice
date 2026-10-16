
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/despatchcardshimmer.dart';
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
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    final bloc = context.read<DispatchListBloc>();
    bloc.add(const RefreshDispatchList());
    await bloc.stream.firstWhere(
          (s) =>
      s.status == DispatchListStatus.success ||
          s.status == DispatchListStatus.failure,
    );
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _openDetail(dynamic dispatch) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerDispatchDetailScreen(dispatchId: dispatch.id),
      ),
    );
    if (changed == true && mounted) {
      context.read<DispatchListBloc>().add(const RefreshDispatchList());
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (unchanged) ----------
        appBar:
        AppBar(title: Text('My Dispatch Bills', style: AppTextStyles.h6())),

        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(Responsive.w(20),
                    Responsive.h(14), Responsive.w(20), Responsive.h(12)),
                child: _SearchField(
                  controller: _searchCtrl,
                  hint: 'Search dispatch bills...',
                  onChanged: (value) => context
                      .read<DispatchListBloc>()
                      .add(SearchDispatchQueryChanged(value)),
                ),
              ),
              Expanded(
                child: BlocBuilder<DispatchListBloc, DispatchListState>(
                  builder: (context, state) {
                    final listPadding = EdgeInsets.fromLTRB(Responsive.w(20),
                        0, Responsive.w(20), Responsive.h(24));

                    // Initial load OR manual refresh -> shimmer
                    if (state.status == DispatchListStatus.initial ||
                        state.status == DispatchListStatus.loading ||
                        _isRefreshing) {
                      return ShimmerListPlaceholder(
                        itemCount: 6,
                        padding: listPadding,
                        separatorHeight: Responsive.h(10),
                        itemBuilder: (_, __) => const DispatchCardShimmer(),
                      );
                    }

                    if (state.status == DispatchListStatus.failure &&
                        state.allDispatches.isEmpty) {
                      return _ErrorView(
                        message: state.errorMessage ??
                            'Failed to load dispatch bills',
                        onRetry: () => context
                            .read<DispatchListBloc>()
                            .add(const FetchDispatchList()),
                      );
                    }

                    final list = state.filteredDispatches;

                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: list.isEmpty
                          ? LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_shipping_rounded,
                                        size: 44,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.4),
                                      ),
                                      SizedBox(height: Responsive.h(10)),
                                      Text(
                                        state.searchQuery.isEmpty
                                            ? 'No dispatch bills yet'
                                            : 'No dispatch bills match your search',
                                        style: AppTextStyles.subtitle(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      )
                          : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: listPadding,
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Responsive.h(10)),
                        itemBuilder: (context, i) {
                          final dispatch = list[i];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _openDetail(dispatch),
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

// ---------------- SEARCH FIELD ----------------

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

// ---------------- ERROR ----------------

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
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
