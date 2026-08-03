import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/appsnackbar.dart';
import '../bloc/driver/driver_bloc.dart';
import '../bloc/driver/driver_event.dart';
import '../bloc/driver/driver_state.dart';
import '../data/model/get_drivermodel.dart';
import '../data/repository/driver_repository.dart';

/// Public entry point — provides the bloc and loads the drivers list.
/// Drop this into your router in place of the old dummy screen.
class OwnerDriverScreen extends StatelessWidget {
  const OwnerDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverBloc(repository: DriverRepository())..add(const LoadDrivers()),
      child: const _OwnerDriverView(),
    );
  }
}

class _OwnerDriverView extends StatefulWidget {
  const _OwnerDriverView();

  @override
  State<_OwnerDriverView> createState() => _OwnerDriverViewState();
}

class _OwnerDriverViewState extends State<_OwnerDriverView> {
  // ---- Add / Edit sheet (shared) ----
  void _openDriverSheet({DriverGetModel? existing}) {
    final bloc = context.read<DriverBloc>();
    final isEdit = existing != null;

    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final mobileController = TextEditingController(text: existing?.mobile ?? '');
    final licenseController = TextEditingController(text: existing?.licenseNumber ?? '');
    final vehicleController = TextEditingController(text: existing?.vehicleNumber ?? '');
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    DateTime joiningDate = existing?.joiningDate != null &&
        existing!.joiningDate.isNotEmpty
        ? DateTime.tryParse(existing.joiningDate) ?? DateTime.now()
        : DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
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
                child: SingleChildScrollView(
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
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('Email', Icons.mail_outline),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: _inputDecoration('Phone Number', Icons.call_outlined),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter phone number';
                            if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: licenseController,
                          textCapitalization: TextCapitalization.characters,
                          decoration:
                          _inputDecoration('License Number', Icons.badge_outlined),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter license number' : null,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: vehicleController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _inputDecoration(
                              'Vehicle Number', Icons.local_shipping_outlined),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter vehicle number' : null,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate: joiningDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setSheetState(() => joiningDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration:
                            _inputDecoration('Joining Date', Icons.event_outlined),
                            child: Text(_formatDate(joiningDate)),
                          ),
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
                                bloc.add(UpdateDriver(
                                  id: existing.id,
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  mobile: mobileController.text.trim(),
                                  licenseNumber: licenseController.text.trim(),
                                  vehicleNumber: vehicleController.text.trim(),
                                  joiningDate: _formatDate(joiningDate),
                                  password: passwordController.text.trim().isEmpty
                                      ? null
                                      : passwordController.text.trim(),
                                ));
                              } else {
                                bloc.add(AddDriver(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  mobile: mobileController.text.trim(),
                                  licenseNumber: licenseController.text.trim(),
                                  vehicleNumber: vehicleController.text.trim(),
                                  joiningDate: _formatDate(joiningDate),
                                ));
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
              ),
            );
          },
        );
      },
    );
  }

  // ---- Delete confirmation ----
  void _confirmDeleteDriver(DriverGetModel driver) {
    final bloc = context.read<DriverBloc>();
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
                bloc.add(DeleteDriver(driver.id));
                Navigator.pop(dialogContext);
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

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
        title: Text('Drivers', style: AppTextStyles.h6()),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openDriverSheet(),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text(
          'Add Driver',
          style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(13)),
        ),
      ),
      body: BlocConsumer<DriverBloc, DriverState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            AppSnackbar.success(state.successMessage!);
            context.read<DriverBloc>().add(const ClearDriverFeedback());
          } else if (state.errorMessage != null) {
            AppSnackbar.error(state.errorMessage!);
            context.read<DriverBloc>().add(const ClearDriverFeedback());
          }
        },
        builder: (context, state) {
          if (state.status == DriverStatus.loading && state.drivers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isUnauthorized) {
            // Redirect to /login is already in flight — don't flash
            // an error screen behind it.
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DriverStatus.error && state.drivers.isEmpty) {
            return _ErrorState(
              onRetry: () => context.read<DriverBloc>().add(const LoadDrivers()),
            );
          }

          if (state.drivers.isEmpty) {
            return _EmptyDriverState(onAdd: () => _openDriverSheet());
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<DriverBloc>().add(const LoadDrivers()),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(20),
                Responsive.h(16),
                Responsive.w(20),
                Responsive.h(100),
              ),
              itemCount: state.drivers.length,
              separatorBuilder: (_, __) => SizedBox(height: Responsive.h(12)),
              itemBuilder: (context, index) {
                final driver = state.drivers[index];
                return _DriverTile(
                  driver: driver,
                  onEdit: () => _openDriverSheet(existing: driver),
                  onDelete: () => _confirmDeleteDriver(driver),
                );
              },
            ),
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

  final DriverGetModel driver;
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
                SizedBox(height: Responsive.h(2)),
                Text(
                  '${driver.vehicleNumber} • ${driver.licenseNumber}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.sp(11.5),
                  ),
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
                        driver.mobile,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(12)),
            Text(
              'Could not load drivers',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
            SizedBox(height: Responsive.h(16)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}