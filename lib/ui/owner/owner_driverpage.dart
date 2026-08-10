
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/driverprovider.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/get_drivermodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/driver_bloc.dart';
import '../../bloc/ownerbloc/driver_event.dart';
import '../../bloc/ownerbloc/driver_state.dart';


/// Public entry point — provides the bloc and loads the drivers list.
class OwnerDriverScreen extends StatelessWidget {
  const OwnerDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverBloc(provider: DriverProvider())..add(const LoadDrivers()),
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

    bool isActive = existing?.isActive ?? true;

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEdit ? 'Edit Driver' : 'Add Driver',
                              style: AppTextStyles.bodyBold(color: AppColors.black)
                                  .copyWith(fontSize: Responsive.sp(17)),
                            ),
                            if (isEdit)
                              _StatusSwitch(
                                isActive: isActive,
                                onChanged: (val) => setSheetState(() => isActive = val),
                              ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(18)),
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: DValidator.lettersOnly,
                          decoration: _inputDecoration('Driver Name', Icons.person_outline),
                          validator: (v) => DValidator.validateName('Driver name', v),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: DValidator.textWithLimit,
                          decoration: _inputDecoration('Email', Icons.mail_outline),
                          validator: DValidator.validateEmail,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: DValidator.phoneNumber,
                          decoration: _inputDecoration('Phone Number', Icons.call_outlined),
                          validator: DValidator.validatePhoneNumber,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: licenseController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: DValidator.textWithLimit,
                          decoration:
                          _inputDecoration('License Number', Icons.badge_outlined),
                          validator: (v) =>
                              DValidator.validateRequired(v, message: 'Enter license number'),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: vehicleController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: DValidator.textWithLimit,
                          decoration: _inputDecoration(
                              'Vehicle Number', Icons.local_shipping_outlined),
                          validator: (v) =>
                              DValidator.validateRequired(v, message: 'Enter vehicle number'),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        // if (isEdit) ...[
                        //   TextFormField(
                        //     controller: passwordController,
                        //     obscureText: true,
                        //     decoration: _inputDecoration(
                        //         'New Password (optional)', Icons.lock_outline),
                        //   ),
                        //   SizedBox(height: Responsive.h(14)),
                        // ],
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
                                  isActive: isActive,
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
  Future<void> _confirmDeleteDriver(DriverGetModel driver) async {
    final bloc = context.read<DriverBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Driver',
      message: 'Are you sure you want to remove ${driver.name} from your drivers list?',
      confirmText: 'Remove',
    );
    if (confirmed) {
      bloc.add(DeleteDriver(driver.id));
    }
  }
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }


  static String _displayDate(String raw) {
    if (raw.isEmpty) return '—';
    return raw;
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
    return NetworkAwareWrapper(child: Scaffold(
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
    ));
  }
}

/// Small on/off switch used inside the edit sheet to toggle a driver's
/// active status before saving.
class _StatusSwitch extends StatelessWidget {
  const _StatusSwitch({required this.isActive, required this.onChanged});

  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(!isActive),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10),
          vertical: Responsive.h(6),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.green : Colors.red.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              size: 14,
              color: isActive ? Colors.green.shade700 : Colors.red.shade400,
            ),
            SizedBox(width: Responsive.w(4)),
            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: Responsive.sp(11.5),
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.green.shade700 : Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small read-only status badge shown on each driver tile.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(9),
        vertical: Responsive.h(3),
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.red.shade400,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        driver.name,
                        style: AppTextStyles.bodyBold(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: Responsive.w(6)),
                    _StatusBadge(isActive: driver.isActive),
                  ],
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
                SizedBox(height: Responsive.h(2)),
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 13, color: AppColors.textSecondary),
                    SizedBox(width: Responsive.w(4)),
                    Text(
                      _OwnerDriverViewState._displayDate(driver.joiningDate),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.sp(11),
                      ),
                    ),
                  ],
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