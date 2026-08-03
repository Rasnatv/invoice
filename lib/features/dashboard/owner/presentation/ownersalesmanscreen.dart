//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/model/salesmanmodel.dart';
// import '../../../../core/utils/responsive.dart';
// import '../widgets/owner_widgets.dart';
// import 'owneraddsalesmanscreen.dart';
//
// class OwnerSalesmenScreen extends StatefulWidget {
//   const OwnerSalesmenScreen({super.key});
//
//   @override
//   State<OwnerSalesmenScreen> createState() => _OwnerSalesmenScreenState();
// }
//
// class _OwnerSalesmenScreenState extends State<OwnerSalesmenScreen> {
//   String _filter = 'All';
//   final _searchCtrl = TextEditingController();
//
//   static const _filters = ['All'];
//
//   final List<String> _posts = [
//     'Senior Sales Executive',
//     'Sales Executive',
//     'Junior Sales Executive',
//     'Team Lead',
//   ];
//
//   final List<SalesmanModel> _salesmen = [
//     SalesmanModel(
//       id: 'SM-1001',
//       name: 'Rahul Kumar',
//       mobile: '9123456780',
//       email: 'rahul.kumar@example.com',
//       joinedDate: DateTime.now().subtract(const Duration(days: 240)),
//       status: 'Active',
//       designation: 'Senior Sales Executive',
//     ),
//     SalesmanModel(
//       id: 'SM-1002',
//       name: 'Anoop Menon',
//       mobile: '9123456781',
//       email: 'anoop.menon@example.com',
//       joinedDate: DateTime.now().subtract(const Duration(days: 120)),
//       status: 'Active',
//       designation: 'Sales Executive',
//     ),
//     SalesmanModel(
//       id: 'SM-1003',
//       name: 'Divya Prasad',
//       mobile: '9123456782',
//       email: 'divya.prasad@example.com',
//       joinedDate: DateTime.now().subtract(const Duration(days: 60)),
//       status: 'Inactive',
//       designation: 'Junior Sales Executive',
//     ),
//   ];
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   List<SalesmanModel> _apply(List<SalesmanModel> all) {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     return all.where((s) {
//       final matchesFilter = _filter == 'All' || s.status == _filter;
//       final matchesSearch = q.isEmpty ||
//           s.name.toLowerCase().contains(q) ||
//           s.mobile.contains(q) ||
//           s.email.toLowerCase().contains(q) ||
//           s.id.toLowerCase().contains(q) ||
//           s.designation.toLowerCase().contains(q);
//       return matchesFilter && matchesSearch;
//     }).toList();
//   }
//
//   Future<void> _openAddSalesman() async {
//     final created = await Navigator.of(context).push<SalesmanModel>(
//       MaterialPageRoute(
//         builder: (_) => const OwnerAddSalesmanScreen(),
//       ),
//     );
//     if (created != null) {
//       setState(() => _salesmen.add(created));
//     }
//   }
//
//   Future<void> _openEditSalesman(SalesmanModel salesman) async {
//     final updated = await Navigator.of(context).push<SalesmanModel>(
//       MaterialPageRoute(
//         builder: (_) => OwnerAddSalesmanScreen(salesman: salesman),
//       ),
//     );
//     if (updated != null) {
//       setState(() {
//         final i = _salesmen.indexWhere((s) => s.id == updated.id);
//         if (i != -1) _salesmen[i] = updated;
//       });
//     }
//   }
//
//   Future<void> _confirmDeleteSalesman(SalesmanModel salesman) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: Text('Delete Salesman?', style: AppTextStyles.bodyBold()),
//         content: Text(
//           'This will remove "${salesman.name}" from your salesman list. This cannot be undone.',
//           style: AppTextStyles.caption(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//             onPressed: () => Navigator.of(dialogContext).pop(true),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) {
//       setState(() => _salesmen.removeWhere((s) => s.id == salesman.id));
//     }
//   }
//
//   // Returns how many salesmen currently hold this post, so deletion
//   // can be blocked/warned instead of silently orphaning their data.
//   int _postUsageCount(String post) =>
//       _salesmen.where((s) => s.designation == post).length;
//
//   // Same accent logic used on the salesman cards, reused here so each
//   // row in "Manage Posts" carries a matching color dot — makes the
//   // list scannable and ties the two screens together visually.
//   Color _postColor(String post) {
//     switch (post) {
//       case 'Senior Sales Executive':
//         return const Color(0xFF2E7D32);
//       case 'Team Lead':
//         return const Color(0xFF6A1B9A);
//       case 'Junior Sales Executive':
//         return const Color(0xFFEF6C00);
//       case 'Sales Executive':
//         return AppColors.info;
//       default:
//         const palette = [
//           Color(0xFF1565C0),
//           Color(0xFFAD1457),
//           Color(0xFF00838F),
//           Color(0xFF6D4C41),
//           Color(0xFF558B2F),
//         ];
//         final index = post.hashCode.abs() % palette.length;
//         return palette[index];
//     }
//   }
//
//   void _addPost(String rawValue, StateSetter dialogSetState) {
//     final value = rawValue.trim();
//     if (value.isEmpty) return;
//     final alreadyExists =
//     _posts.any((p) => p.toLowerCase() == value.toLowerCase());
//     if (alreadyExists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('"$value" already exists')),
//       );
//       return;
//     }
//     setState(() => _posts.add(value));
//     dialogSetState(() {});
//   }
//
//   // Renames a post in place and cascades the new name to every
//   // salesman currently holding it, so badges/filters/dropdown all
//   // stay consistent immediately.
//   void _editPost(String oldValue, StateSetter dialogSetState) {
//     final ctrl = TextEditingController(text: oldValue);
//     showDialog<void>(
//       context: context,
//       builder: (editContext) => AlertDialog(
//         title: Text('Rename Post', style: AppTextStyles.bodyBold()),
//         content: TextField(
//           controller: ctrl,
//           autofocus: true,
//           textCapitalization: TextCapitalization.words,
//           decoration: const InputDecoration(
//             labelText: 'Post / Designation',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(editContext).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//             onPressed: () {
//               final newValue = ctrl.text.trim();
//               if (newValue.isEmpty) return;
//
//               final collision = _posts.any((p) =>
//               p.toLowerCase() == newValue.toLowerCase() &&
//                   p.toLowerCase() != oldValue.toLowerCase());
//               if (collision) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('"$newValue" already exists')),
//                 );
//                 return;
//               }
//
//               setState(() {
//                 final i = _posts.indexOf(oldValue);
//                 if (i != -1) _posts[i] = newValue;
//                 for (var j = 0; j < _salesmen.length; j++) {
//                   final s = _salesmen[j];
//                   if (s.designation == oldValue) {
//                     _salesmen[j] = SalesmanModel(
//                       id: s.id,
//                       name: s.name,
//                       mobile: s.mobile,
//                       email: s.email,
//                       joinedDate: s.joinedDate,
//                       status: s.status,
//                       designation: newValue,
//                     );
//                   }
//                 }
//               });
//               dialogSetState(() {});
//               Navigator.of(editContext).pop();
//             },
//             child: const Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _deletePost(String post, StateSetter dialogSetState) {
//     final usage = _postUsageCount(post);
//     if (usage > 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             '"$post" is assigned to $usage salesman${usage == 1 ? '' : 'men'} and can\'t be deleted',
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() => _posts.remove(post));
//     dialogSetState(() {});
//   }
//
//   // Opens the Manage Posts view: add, rename, and delete posts
//   // (rename cascades to salesmen; delete is blocked if a salesman is
//   // still assigned to that post). All actions update the badges,
//   // filters, and the Add/Edit Salesman screen's designation dropdown
//   // right away.
//   Future<void> _openManagePostsDialog() async {
//     final ctrl = TextEditingController();
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, dialogSetState) => Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: 420,
//               // Cap against the actual visible viewport so the dialog
//               // shrinks (and its content scrolls) instead of
//               // overflowing once the keyboard is open.
//               maxHeight: MediaQuery.of(context).size.height -
//                   MediaQuery.of(context).viewInsets.bottom -
//                   48,
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Icon(Icons.badge_outlined, color: AppColors.primary),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Manage Posts', style: AppTextStyles.bodyBold()),
//                               Text(
//                                 'Add, rename or remove designations',
//                                 style: AppTextStyles.caption(),
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close, size: 20),
//                           onPressed: () => Navigator.of(dialogContext).pop(),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: ctrl,
//                             autofocus: true,
//                             textCapitalization: TextCapitalization.words,
//                             decoration: const InputDecoration(
//                               hintText: 'e.g. Area Manager',
//                               labelText: 'New post / designation',
//                             ),
//                             onSubmitted: (v) {
//                               _addPost(v, dialogSetState);
//                               ctrl.clear();
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Material(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(10),
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(10),
//                             onTap: () {
//                               _addPost(ctrl.text, dialogSetState);
//                               ctrl.clear();
//                             },
//                             child: const Padding(
//                               padding: EdgeInsets.all(12),
//                               child: Icon(Icons.add, color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     if (_posts.isEmpty)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 20),
//                         child: Center(
//                           child: Text('No posts yet', style: AppTextStyles.caption()),
//                         ),
//                       )
//                     else
//                       Column(
//                         children: [
//                           for (var i = 0; i < _posts.length; i++) ...[
//                             if (i > 0) const SizedBox(height: 8),
//                             Builder(builder: (context) {
//                               final post = _posts[i];
//                               final usage = _postUsageCount(post);
//                               final color = _postColor(post);
//                               return Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.background,
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(color: AppColors.border),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       width: 10,
//                                       height: 10,
//                                       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             post,
//                                             style: AppTextStyles.bodyBold(),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//
//                                         ],
//                                       ),
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
//                                       tooltip: 'Rename',
//                                       onPressed: () => _editPost(post, dialogSetState),
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
//                                       tooltip: 'Delete',
//                                       onPressed: () => _deletePost(post, dialogSetState),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ],
//                         ],
//                       ),
//                     const SizedBox(height: 12),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () => Navigator.of(dialogContext).pop(),
//                         child: const Text('Done'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final items = _apply(_salesmen);
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('Salesmen', style: AppTextStyles.h6()),
//         actions: [
//           IconButton(
//             tooltip: 'Manage Posts',
//             icon: const Icon(Icons.add_moderator_outlined),
//             onPressed: _openManagePostsDialog,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primary,
//         onPressed: _openAddSalesman,
//         child: const Icon(Icons.person_add_alt_1, color: Colors.white),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
//               child: TextField(
//                 controller: _searchCtrl,
//                 onChanged: (_) => setState(() {}),
//                 decoration: const InputDecoration(
//                   hintText: 'Search salesman by name, phone or email',
//                   prefixIcon: Icon(Icons.search_rounded),
//                 ),
//               ),
//             ),
//             SizedBox(height: Responsive.h(12)),
//             SizedBox(
//               height: 42,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
//                 itemCount: _filters.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (context, i) {
//                   final f = _filters[i];
//                   final selected = f == _filter;
//                   return ChoiceChip(
//                     label: Text(f),
//                     selected: selected,
//                     selectedColor: AppColors.primary,
//                     backgroundColor: AppColors.surface,
//                     labelStyle: AppTextStyles.bodyBold(color: selected ? Colors.white : AppColors.textPrimary),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                       side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
//                     ),
//                     onSelected: (_) => setState(() => _filter = f),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: Responsive.h(12)),
//             Expanded(
//               child: items.isEmpty
//                   ? Center(
//                 child: Text('No salesmen found', style: AppTextStyles.subtitle()),
//               )
//                   : ListView.separated(
//                 padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
//                 itemCount: items.length,
//                 separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
//                 itemBuilder: (context, i) => _OwnerSalesmanCard(
//                   salesman: items[i],
//                   onEdit: () => _openEditSalesman(items[i]),
//                   onDelete: () => _confirmDeleteSalesman(items[i]),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _OwnerSalesmanCard extends StatelessWidget {
//   const _OwnerSalesmanCard({required this.salesman, required this.onEdit, required this.onDelete});
//   final SalesmanModel salesman;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   Color get _designationColor {
//     switch (salesman.designation) {
//       case 'Senior Sales Executive':
//         return const Color(0xFF2E7D32);
//       case 'Team Lead':
//         return const Color(0xFF6A1B9A);
//       case 'Junior Sales Executive':
//         return const Color(0xFFEF6C00);
//       case 'Sales Executive':
//         return AppColors.info;
//       default:
//         const palette = [
//           Color(0xFF1565C0),
//           Color(0xFFAD1457),
//           Color(0xFF00838F),
//           Color(0xFF6D4C41),
//           Color(0xFF558B2F),
//         ];
//         final index = salesman.designation.hashCode.abs() % palette.length;
//         return palette[index];
//     }
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
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: _designationColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               salesman.designation,
//               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _designationColor),
//             ),
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
//           Text('Joined ${DateFormat('dd-MM-yyyy').format(salesman.joinedDate)}', style: AppTextStyles.caption()),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/saleman/salesman_bloc.dart';
import '../bloc/saleman/salesman_event.dart';
import '../bloc/saleman/salesman_state.dart';
import '../data/model/salesman_getmodel.dart';
import '../data/repository/salesman_repository.dart';
import 'owner_designationlist.dart';
import 'owneraddsalesmanscreen.dart';


class OwnerSalesmenScreen extends StatelessWidget {
  const OwnerSalesmenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesmanBloc(
        repository: SalesmanRepository(),
      )..add(FetchSalesmen()),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Salesman?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will remove "${salesman.name}" from your salesman list. This cannot be undone.',
          style: AppTextStyles.caption(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(DeleteSalesman(salesman.id));
    }
  }

  void _openDesignations() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DesignationListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Salesmen', style: AppTextStyles.h6()),
        actions: [
          TextButton.icon(
            onPressed: _openDesignations,
            icon: const Icon(Icons.badge_outlined, size: 18),
            label: const Text('Add Designation'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddSalesman,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
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
                  if (state is SalesmanActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (state is SalesmanActionFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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

                  List<HSalesmanModel> all = [];
                  if (state is SalesmanLoaded) all = state.salesmen;
                  if (state is SalesmanActionSuccess) all = state.salesmen;

                  final items = _apply(all);

                  if (items.isEmpty) {
                    return Center(
                      child: Text('No salesmen found', style: AppTextStyles.subtitle()),
                    );
                  }

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
                child: Text(salesman.name, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ID: ${salesman.id}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _accentColor),
            ),
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
          Text(
            salesman.joiningDate != null
                ? 'Joined ${DateFormat('dd-MM-yyyy').format(salesman.joiningDate!)}'
                : 'Joining date unavailable',
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}