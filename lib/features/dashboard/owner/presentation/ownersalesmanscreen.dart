import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/salesmanmodel.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/owner_widgets.dart';
import 'owneraddsalesmanscreen.dart';

class OwnerSalesmenScreen extends StatefulWidget {
  const OwnerSalesmenScreen({super.key});

  @override
  State<OwnerSalesmenScreen> createState() => _OwnerSalesmenScreenState();
}

class _OwnerSalesmenScreenState extends State<OwnerSalesmenScreen> {
  String _filter = 'All';
  final _searchCtrl = TextEditingController();

  static const _filters = ['All'];

  // Available posts / designations. Owner can add new ones via the
  // "Add Post" icon; this list then flows into the badges, the filter
  // chips and the Add/Edit Salesman screen's designation dropdown.
  final List<String> _posts = [
    'Senior Sales Executive',
    'Sales Executive',
    'Junior Sales Executive',
    'Team Lead',
  ];

  final List<SalesmanModel> _salesmen = [
    SalesmanModel(
      id: 'SM-1001',
      name: 'Rahul Kumar',
      mobile: '9123456780',
      email: 'rahul.kumar@example.com',
      joinedDate: DateTime.now().subtract(const Duration(days: 240)),
      status: 'Active',
      designation: 'Senior Sales Executive',
    ),
    SalesmanModel(
      id: 'SM-1002',
      name: 'Anoop Menon',
      mobile: '9123456781',
      email: 'anoop.menon@example.com',
      joinedDate: DateTime.now().subtract(const Duration(days: 120)),
      status: 'Active',
      designation: 'Sales Executive',
    ),
    SalesmanModel(
      id: 'SM-1003',
      name: 'Divya Prasad',
      mobile: '9123456782',
      email: 'divya.prasad@example.com',
      joinedDate: DateTime.now().subtract(const Duration(days: 60)),
      status: 'Inactive',
      designation: 'Junior Sales Executive',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SalesmanModel> _apply(List<SalesmanModel> all) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return all.where((s) {
      final matchesFilter = _filter == 'All' || s.status == _filter;
      final matchesSearch = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.mobile.contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.id.toLowerCase().contains(q) ||
          s.designation.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> _openAddSalesman() async {
    final created = await Navigator.of(context).push<SalesmanModel>(
      MaterialPageRoute(
        builder: (_) => const OwnerAddSalesmanScreen(),
      ),
    );
    if (created != null) {
      setState(() => _salesmen.add(created));
    }
  }

  Future<void> _openEditSalesman(SalesmanModel salesman) async {
    final updated = await Navigator.of(context).push<SalesmanModel>(
      MaterialPageRoute(
        builder: (_) => OwnerAddSalesmanScreen(salesman: salesman),
      ),
    );
    if (updated != null) {
      setState(() {
        final i = _salesmen.indexWhere((s) => s.id == updated.id);
        if (i != -1) _salesmen[i] = updated;
      });
    }
  }

  Future<void> _confirmDeleteSalesman(SalesmanModel salesman) async {
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
      setState(() => _salesmen.removeWhere((s) => s.id == salesman.id));
    }
  }

  // Returns how many salesmen currently hold this post, so deletion
  // can be blocked/warned instead of silently orphaning their data.
  int _postUsageCount(String post) =>
      _salesmen.where((s) => s.designation == post).length;

  void _addPost(String rawValue, StateSetter dialogSetState) {
    final value = rawValue.trim();
    if (value.isEmpty) return;
    final alreadyExists =
    _posts.any((p) => p.toLowerCase() == value.toLowerCase());
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$value" already exists')),
      );
      return;
    }
    setState(() => _posts.add(value));
    dialogSetState(() {});
  }

  void _deletePost(String post, StateSetter dialogSetState) {
    final usage = _postUsageCount(post);
    if (usage > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"$post" is assigned to $usage salesman${usage == 1 ? '' : 'men'} and can\'t be deleted',
          ),
        ),
      );
      return;
    }
    setState(() => _posts.remove(post));
    dialogSetState(() {});
  }

  // Opens the Manage Posts view: add new posts and delete existing
  // ones (blocked if a salesman is still assigned to that post).
  // Both actions update the badges, filters, and the Add/Edit
  // Salesman screen's designation dropdown right away.
  Future<void> _openManagePostsDialog() async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: Text('Manage Posts', style: AppTextStyles.bodyBold()),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Area Manager',
                            labelText: 'Post / Designation',
                          ),
                          onSubmitted: (v) {
                            _addPost(v, dialogSetState);
                            ctrl.clear();
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.primary),
                        onPressed: () {
                          _addPost(ctrl.text, dialogSetState);
                          ctrl.clear();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('No posts yet', style: AppTextStyles.caption()),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _posts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, i) {
                          final post = _posts[i];
                          final usage = _postUsageCount(post);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(post, style: AppTextStyles.bodyBold()),
                            subtitle: usage > 0
                                ? Text('$usage assigned', style: AppTextStyles.caption())
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              tooltip: 'Delete',
                              onPressed: () => _deletePost(post, dialogSetState),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final items = _apply(_salesmen);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Salesmen', style: AppTextStyles.h6()),
        actions: [
          IconButton(
            tooltip: 'Manage Posts',
            icon: const Icon(Icons.add_moderator_outlined),
            onPressed: _openManagePostsDialog,
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
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final selected = f == _filter;
                  return ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.bodyBold(color: selected ? Colors.white : AppColors.textPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    onSelected: (_) => setState(() => _filter = f),
                  );
                },
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            Expanded(
              child: items.isEmpty
                  ? Center(
                child: Text('No salesmen found', style: AppTextStyles.subtitle()),
              )
                  : ListView.separated(
                padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                itemBuilder: (context, i) => _OwnerSalesmanCard(
                  salesman: items[i],
                  onEdit: () => _openEditSalesman(items[i]),
                  onDelete: () => _confirmDeleteSalesman(items[i]),
                ),
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
  final SalesmanModel salesman;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // Distinct accent per post so the level is scannable at a glance.
  // Falls back to a deterministic color for any newly added post so
  // custom posts still look intentional instead of all defaulting
  // to the same gray.
  Color get _designationColor {
    switch (salesman.designation) {
      case 'Senior Sales Executive':
        return const Color(0xFF2E7D32);
      case 'Team Lead':
        return const Color(0xFF6A1B9A);
      case 'Junior Sales Executive':
        return const Color(0xFFEF6C00);
      case 'Sales Executive':
        return AppColors.info;
      default:
        const palette = [
          Color(0xFF1565C0),
          Color(0xFFAD1457),
          Color(0xFF00838F),
          Color(0xFF6D4C41),
          Color(0xFF558B2F),
        ];
        final index = salesman.designation.hashCode.abs() % palette.length;
        return palette[index];
    }
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
              color: _designationColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              salesman.designation,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _designationColor),
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
          Text('Joined ${DateFormat('dd-MM-yyyy').format(salesman.joinedDate)}', style: AppTextStyles.caption()),
        ],
      ),
    );
  }
}