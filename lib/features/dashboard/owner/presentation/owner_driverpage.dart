
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class DriverModel {
  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;

  DriverModel copyWith({String? name, String? phone}) {
    return DriverModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

class OwnerDriverScreen extends StatefulWidget {
  const OwnerDriverScreen({super.key});

  @override
  State<OwnerDriverScreen> createState() => _OwnerDriverScreenState();
}

class _OwnerDriverScreenState extends State<OwnerDriverScreen> {
  // ---- Dummy data (replace with real cubit/repo later) ----
  final List<DriverModel> _drivers = [
    DriverModel(id: 'DRV001', name: 'Ramesh Kumar', phone: '9876543210'),
    DriverModel(id: 'DRV002', name: 'Suresh Nair', phone: '9845123456'),
    DriverModel(id: 'DRV003', name: 'Anil Varma', phone: '9998887771'),
  ];

  // ---- Add / Edit sheet (shared) ----
  void _openDriverSheet({DriverModel? existing}) {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(20),
              Responsive.h(20),
              Responsive.w(20),
              Responsive.h(24),
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  Text(
                    isEdit ? 'Edit Driver' : 'Add Driver',
                    style: AppTextStyles.bodyBold(color: AppColors.black)
                        .copyWith(fontSize: Responsive.sp(17)),
                  ),
                  SizedBox(height: Responsive.h(18)),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Driver Name', Icons.person_outline),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter driver name' : null,
                  ),
                  SizedBox(height: Responsive.h(14)),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: _inputDecoration('Phone Number', Icons.call_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter phone number';
                      if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(10)),
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.h(48),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        if (isEdit) {
                          final updatedDriver = existing.copyWith(
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                          );
                          final index =
                          _drivers.indexWhere((d) => d.id == existing.id);
                          if (index != -1) {
                            setState(() => _drivers[index] = updatedDriver);
                          }
                        } else {
                          final newDriver = DriverModel(
                            id: 'DRV${(_drivers.length + 1).toString().padLeft(3, '0')}',
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                          );
                          setState(() => _drivers.insert(0, newDriver));
                        }

                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        isEdit ? 'Save Changes' : 'Add Driver',
                        style: AppTextStyles.bodyBold(color: Colors.white)
                            .copyWith(fontSize: Responsive.sp(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---- Delete confirmation ----
  void _confirmDeleteDriver(DriverModel driver) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Remove Driver',
            style: AppTextStyles.bodyBold(color: AppColors.black)
                .copyWith(fontSize: Responsive.sp(16)),
          ),
          content: Text(
            'Are you sure you want to remove ${driver.name} from your drivers list?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: Responsive.sp(13),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _drivers.removeWhere((d) => d.id == driver.id));
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${driver.name} removed')),
                );
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.w(14),
        vertical: Responsive.h(14),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
            'Drivers',
            style: AppTextStyles.h6()
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openDriverSheet(),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text(
          'Add Driver',
          style: AppTextStyles.bodyBold(color: Colors.white)
              .copyWith(fontSize: Responsive.sp(13)),
        ),
      ),
      body: _drivers.isEmpty
          ? _EmptyDriverState(onAdd: () => _openDriverSheet())
          : ListView.separated(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(20),
          Responsive.h(16),
          Responsive.w(20),
          Responsive.h(100),
        ),
        itemCount: _drivers.length,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(12)),
        itemBuilder: (context, index) {
          final driver = _drivers[index];
          return _DriverTile(
            driver: driver,
            onEdit: () => _openDriverSheet(existing: driver),
            onDelete: () => _confirmDeleteDriver(driver),
          );
        },
      ),
    );
  }
}

class _DriverTile extends StatelessWidget {
  const _DriverTile({
    required this.driver,
    required this.onEdit,
    required this.onDelete,
  });

  final DriverModel driver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              driver.name.isNotEmpty ? driver.name[0].toUpperCase() : '?',
              style: AppTextStyles.bodyBold(color: AppColors.primary)
                  .copyWith(fontSize: Responsive.sp(16)),
            ),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(4)),
                InkWell(
                  onTap: () {
                    // TODO: launch dialer or copy number
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_outlined, size: 15, color: AppColors.primary),
                      SizedBox(width: Responsive.w(4)),
                      Text(
                        driver.phone,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: Responsive.sp(12.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
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
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: Responsive.w(8)),
                    const Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDriverState extends StatelessWidget {
  const _EmptyDriverState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(12)),
            Text(
              'No drivers added yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
            SizedBox(height: Responsive.h(16)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onAdd,
              child: Text(
                'Add Driver',
                style: AppTextStyles.bodyBold(color: Colors.white)
                    .copyWith(fontSize: Responsive.sp(13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}