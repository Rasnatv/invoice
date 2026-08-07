
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/salesmanprovider.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/salesmanmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/salesman_bloc.dart';
import '../../bloc/ownerbloc/salesman_event.dart';
import '../../bloc/ownerbloc/salesman_state.dart';
import 'owneraddsalesmanscreen.dart';


class OwnerSalesmenScreen extends StatelessWidget {
  const OwnerSalesmenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      SalesmanBloc(
        provider: SalesmanProvider(),
      )
        ..add(FetchSalesmen()),
      child: const _OwnerSalesmenView(),
    );
  }
}

class _OwnerSalesmenView extends StatefulWidget {
  const _OwnerSalesmenView();

  @override
  State<_OwnerSalesmenView> createState() => _OwnerSalesmenViewState();
}

class _OwnerSalesmenViewState extends State<_OwnerSalesmenView> {
  final _searchCtrl = TextEditingController();

  // Keeps the last successfully loaded list around so that a transient
  // state — e.g. SalesmanActionLoading while a delete request is in
  // flight — doesn't fall through to an empty list and flash
  // "No salesmen found" before the real result comes back.
  List<HSalesmanModel> _lastKnownSalesmen = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HSalesmanModel> _apply(List<HSalesmanModel> all) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.mobile.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.designationName.toLowerCase().contains(q) ||
          s.id.toString().contains(q);
    }).toList();
  }

  Future<void> _openAddSalesman() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SalesmanBloc>(),
          child: const OwnerAddSalesmanScreen(),
        ),
      ),
    );
  }

  Future<void> _openEditSalesman(HSalesmanModel salesman) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SalesmanBloc>(),
          child: OwnerAddSalesmanScreen(salesman: salesman),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSalesman(HSalesmanModel salesman) async {
    final bloc = context.read<SalesmanBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Salesman?',
      message: 'This will remove "${salesman.name}" from your salesman list. This cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed) {
      bloc.add(DeleteSalesman(salesman.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Salesmen', style: AppTextStyles.h6()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _openAddSalesman,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text(
          'Add Salesman',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search salesman by name, phone or email',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            Expanded(
              child: BlocConsumer<SalesmanBloc, SalesmanState>(
                listener: (context, state) {
                  // AppSnackbar uses a global ScaffoldMessengerKey, so this
                  // fires correctly even while an Add/Edit screen is pushed
                  // on top of this one.
                  if (state is SalesmanActionSuccess) {
                    AppSnackbar.success(state.message);
                  } else if (state is SalesmanActionFailure) {
                    AppSnackbar.error(state.message);
                  } else if (state is SalesmanError) {
                    AppSnackbar.error(state.message);
                  }
                },
                builder: (context, state) {
                  if (state is SalesmanLoading || state is SalesmanInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SalesmanError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text(state.message, textAlign: TextAlign.center, style: AppTextStyles.caption()),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<SalesmanBloc>().add(FetchSalesmen()),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Default to whatever we last had (e.g. while a delete
                  // is in flight as SalesmanActionLoading), only replacing
                  // it once a fresh list actually arrives.
                  List<HSalesmanModel> all = _lastKnownSalesmen;
                  if (state is SalesmanLoaded) all = state.salesmen;
                  if (state is SalesmanActionSuccess) all = state.salesmen;
                  _lastKnownSalesmen = all;

                  final items = _apply(all);



                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<SalesmanBloc>().add(FetchSalesmen());
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                      itemBuilder: (context, i) => _OwnerSalesmanCard(
                        salesman: items[i],
                        onEdit: () => _openEditSalesman(items[i]),
                        onDelete: () => _confirmDeleteSalesman(items[i]),
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

// class _OwnerSalesmanCard extends StatelessWidget {
//   const _OwnerSalesmanCard({required this.salesman, required this.onEdit, required this.onDelete});
//   final HSalesmanModel salesman;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   Color get _accentColor {
//     const palette = [
//       Color(0xFF1565C0),
//       Color(0xFFAD1457),
//       Color(0xFF00838F),
//       Color(0xFF6D4C41),
//       Color(0xFF558B2F),
//     ];
//     final index = salesman.id.hashCode.abs() % palette.length;
//     return palette[index];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(salesman.name, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
//               ),
//               SizedBox(width: Responsive.w(4)),
//               PopupMenuButton<String>(
//                 padding: EdgeInsets.zero,
//                 icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
//                 onSelected: (value) {
//                   if (value == 'edit') onEdit();
//                   if (value == 'delete') onDelete();
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'edit',
//                     child: Row(
//                       children: [
//                         Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
//                         SizedBox(width: 8),
//                         Text('Edit'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(Icons.delete_outline, size: 18, color: AppColors.error),
//                         SizedBox(width: 8),
//                         Text('Delete', style: TextStyle(color: AppColors.error)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(6)),
//           Wrap(
//             spacing: 6,
//             runSpacing: 4,
//             children: [
//
//               if (salesman.designationName.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     salesman.designationName,
//                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(4)),
//           Row(
//             children: [
//               const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
//               SizedBox(width: Responsive.w(4)),
//               Expanded(
//                 child: Text(salesman.mobile, style: AppTextStyles.caption(), overflow: TextOverflow.ellipsis),
//               ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(2)),
//           Row(
//             children: [
//               const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
//               SizedBox(width: Responsive.w(4)),
//               Expanded(
//                 child: Text(salesman.email, style: AppTextStyles.caption(), overflow: TextOverflow.ellipsis),
//               ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(8)),
//           const Divider(height: 1, color: AppColors.border),
//           SizedBox(height: Responsive.h(8)),
//           Text(
//             salesman.joiningDate != null
//                 ? 'Joined ${DateFormat('dd-MM-yyyy').format(salesman.joiningDate!)}'
//                 : 'Joining date unavailable',
//             style: AppTextStyles.caption(),
//           ),
//         ],
//       ),
//     );
//   }
// }
class _OwnerSalesmanCard extends StatelessWidget {
  const _OwnerSalesmanCard({required this.salesman, required this.onEdit, required this.onDelete});
  final HSalesmanModel salesman;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _accentColor {
    const palette = [
      Color(0xFF1565C0),
      Color(0xFFAD1457),
      Color(0xFF00838F),
      Color(0xFF6D4C41),
      Color(0xFF558B2F),
    ];
    final index = salesman.id.hashCode.abs() % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    // Format salary with Indian Rupee symbol
    final formattedSalary = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    ).format(salesman.salary);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  salesman.name,
                  style: AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Add salary badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  formattedSalary,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(4)),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.h(6)),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (salesman.designationName.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    salesman.designationName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              // Add Active/Inactive status badge
              // In the _OwnerSalesmanCard build method, update the status badge

// Replace the status badge section with this:
    Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
    color: salesman.isActive
    ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: salesman.isActive ? Colors.green : Colors.red,
    ),
    ),
    const SizedBox(width: 4),
    Text(
    salesman.isActive ? 'Active' : 'Inactive',
    style: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: salesman.isActive ? Colors.green : Colors.red,
    ),
    ),
    ],
    ),
    ),

            ],
          ),
          SizedBox(height: Responsive.h(4)),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(4)),
              Expanded(
                child: Text(salesman.mobile, style: AppTextStyles.caption(), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(2)),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(4)),
              Expanded(
                child: Text(salesman.email, style: AppTextStyles.caption(), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    salesman.joiningDate != null
                        ? 'Joined ${DateFormat('dd-MM-yyyy').format(salesman.joiningDate!)}'
                        : 'Joining date unavailable',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
              // Employee Code if available
              if (salesman.employeeCode.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ID: ${salesman.employeeCode}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}