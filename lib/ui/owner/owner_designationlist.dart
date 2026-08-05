
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../Apiprovider/designation_provider.dart';
import '../../models/owner_models/designationmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/designationbloc.dart';
import '../../bloc/ownerbloc/designationevent.dart';
import '../../bloc/ownerbloc/designationstate.dart';
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

  static const Color _primary = Color(0xFF2F5D50);
  static const Color _accent = Color(0xFFE8A33D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Designations',
          style: AppTextStyles.h6(),
        ),
      ),
      body: BlocConsumer<DesignationBloc, DesignationState>(
        listener: (context, state) {
          if (state is DesignationActionSuccess) {
            AppSnackbar.success(state.message);
          } else if (state is DesignationActionFailure) {
            AppSnackbar.error(state.message);
          } else if (state is DesignationError) {
            AppSnackbar.error(state.message);
          }
        },
        builder: (context, state) {
          if (state is DesignationLoading || state is DesignationInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: _primary,
              ),
            );
          }

          if (state is DesignationError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<DesignationBloc>().add(FetchDesignations()),
            );
          }

          List<DesignationModel> designations = [];
          if (state is DesignationLoaded) designations = state.designations;
          if (state is DesignationActionSuccess) designations = state.designations;


          return RefreshIndicator(
            color: _primary,
            onRefresh: () async {
              context.read<DesignationBloc>().add(FetchDesignations());
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: designations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final designation = designations[index];
                return _DesignationCard(
                  designation: designation,
                  primary: _primary,
                  accent: _accent,
                  onEdit: () => _openAddEditPage(context, designation: designation),
                  onDelete: () => _confirmDelete(context, designation),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openAddEditPage(context),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Designation',
          style: TextStyle(fontWeight: FontWeight.w600),
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

  void _confirmDelete(BuildContext context, DesignationModel designation) {
    final bloc = context.read<DesignationBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete designation?'),
        content: Text('This will permanently delete "${designation.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(DeleteDesignation(designation.id));
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignationCard extends StatelessWidget {
  final DesignationModel designation;
  final Color primary;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DesignationCard({
    required this.designation,
    required this.primary,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E5E0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                designation.name.isNotEmpty ? designation.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                designation.name,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: primary,
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red.shade400,
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}


class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}