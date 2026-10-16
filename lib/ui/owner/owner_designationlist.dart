import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/designation_provider.dart';
import '../../core/utils/delete_helper.dart';
import '../../models/owner_models/designationmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/owner_estimateshimmer.dart';
import '../../bloc/ownerbloc/designation/designationbloc.dart';
import '../../bloc/ownerbloc/designation/designationevent.dart';
import '../../bloc/ownerbloc/designation/designationstate.dart';
import 'addDesignationpage.dart';

class DesignationListPage extends StatelessWidget {
  const DesignationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DesignationBloc(
        provider: DesignationProvider(),
      )..add(FetchDesignations()),
      child: const _DesignationListView(),
    );
  }
}

class _DesignationListView extends StatelessWidget {
  const _DesignationListView();

  void _refresh(BuildContext context) =>
      context.read<DesignationBloc>().add(FetchDesignations());

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Drivers / Estimates) ----------
        appBar: AppBar(
          title: Text('Designations', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: Responsive.w(12)),
              child: TextButton.icon(
                onPressed: () => _openAddEditPage(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add',
                  style: AppTextStyles.bodyBold(color: AppColors.primary),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),

        body: SafeArea(
          child: ResponsiveCenter(
            child: BlocConsumer<DesignationBloc, DesignationState>(
              listener: (context, state) {
                if (state is DesignationActionSuccess) {
                  if (state.message != null) {
                    AppSnackbar.success(state.message!);
                  }
                } else if (state is DesignationActionFailure) {
                  if (state.message != null) AppSnackbar.error(state.message!);
                } else if (state is DesignationError) {
                  if (state.message != null) AppSnackbar.error(state.message!);
                }
              },
              builder: (context, state) {
                // ---- loading skeleton ----
                if (state is DesignationLoading ||
                    state is DesignationInitial) {
                  return ShimmerListPlaceholder(
                    itemCount: 6,
                    padding: listPadding,
                    separatorHeight: Responsive.h(10),
                    itemBuilder: (context, i) =>
                    const _DesignationCardSkeleton(),
                  );
                }

                // ---- error ----
                if (state is DesignationError) {
                  return _ErrorView(
                    message: state.message ?? 'Could not load designations.',
                    onRetry: () => _refresh(context),
                  );
                }

                List<DesignationModel> designations = [];
                if (state is DesignationLoaded) {
                  designations = state.designations;
                }
                if (state is DesignationActionSuccess) {
                  designations = state.designations;
                }

                // ---- empty (pull-to-refresh still enabled) ----
                if (designations.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(context),
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                          child: const _EmptyDesignationState(),
                        ),
                      ),
                    ),
                  );
                }

                // ---- list ----
                return RefreshIndicator(
                  onRefresh: () async => _refresh(context),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: listPadding,
                    itemCount: designations.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: Responsive.h(10)),
                    itemBuilder: (context, index) {
                      final designation = designations[index];
                      return _DesignationCard(
                        key: ValueKey(designation.id),
                        designation: designation,
                        onEdit: () =>
                            _openAddEditPage(context, designation: designation),
                        onDelete: () => _confirmDelete(context, designation),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openAddEditPage(BuildContext context, {DesignationModel? designation}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DesignationBloc>(),
          child: AddDesignationPage(designation: designation),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, DesignationModel designation) async {
    final bloc = context.read<DesignationBloc>();
    await deleteItem(
      context,
      itemName: designation.name,
      onConfirmed: () async => bloc.add(DeleteDesignation(designation.id)),
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

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

// =====================================================================
// DESIGNATION CARD
// =====================================================================

class _DesignationCard extends StatelessWidget {
  const _DesignationCard({
    super.key,
    required this.designation,
    required this.onEdit,
    required this.onDelete,
  });

  final DesignationModel designation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String get _initial => designation.name.isNotEmpty
      ? designation.name[0].toUpperCase()
      : '?';

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _initial,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.primary,
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Text(
              designation.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyBold(),
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          SizedBox(
            width: 30,
            height: 24,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.more_vert,
                  size: 20, color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: Responsive.w(8)),
                      Text('Edit', style: AppTextStyles.body()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Delete',
                          style: AppTextStyles.body(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// EMPTY / ERROR / SKELETON
// =====================================================================

/// Shown when there are no designations at all.
class _EmptyDesignationState extends StatelessWidget {
  const _EmptyDesignationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.badge_outlined,
              size: 44,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            SizedBox(height: Responsive.h(10)),
            Text(
              'Add your first designation to get started',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
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
            Icon(Icons.error_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.bodyBold()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesignationCardSkeleton extends StatelessWidget {
  const _DesignationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      child: Row(
        children: [
          const ShimmerBox(width: 42, height: 42, borderRadius: 12),
          SizedBox(width: Responsive.w(12)),
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ShimmerBox(width: 140, height: 13),
            ),
          ),
          const ShimmerBox(width: 20, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}