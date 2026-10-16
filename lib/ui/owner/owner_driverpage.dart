import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/driverprovider.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/get_drivermodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/owner_estimateshimmer.dart';
import '../../bloc/ownerbloc/driver/driver_bloc.dart';
import '../../bloc/ownerbloc/driver/driver_event.dart';
import '../../bloc/ownerbloc/driver/driver_state.dart';

/// Active / inactive colours (same palette as Estimates).
const Color _inactiveColor = Color(0xFFDC2626);

class OwnerDriverScreen extends StatelessWidget {
  const OwnerDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      DriverBloc(provider: DriverProvider())..add(const LoadDrivers()),
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
  // The listener clears the bloc's errorMessage right after showing the
  // snackbar (ClearDriverFeedback), so we remember the last error here to
  // keep showing the real message inside the full-screen error view.
  String? _lastErrorMessage;

  void _refresh() => context.read<DriverBloc>().add(const LoadDrivers());

  // ---- Add / Edit sheet (shared) ----
  void _openDriverSheet({DriverGetModel? existing}) {
    final bloc = context.read<DriverBloc>();
    final isEdit = existing != null;

    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final mobileController =
    TextEditingController(text: existing?.mobile ?? '');
    final licenseController =
    TextEditingController(text: existing?.licenseNumber ?? '');
    final vehicleController =
    TextEditingController(text: existing?.vehicleNumber ?? '');
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Empty by default when adding; pre-filled only when editing.
    // The API returns joining_date as dd-MM-yyyy (e.g. "01-10-2026"),
    // which DateTime.tryParse can't read - so parse it explicitly.
    DateTime? joiningDate;
    if (existing != null) {
      joiningDate = _parseApiDate(existing.joiningDate);
    }
    bool showDateError = false;

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
                              style: AppTextStyles.h6(),
                            ),
                            if (isEdit)
                              _StatusSwitch(
                                isActive: isActive,
                                onChanged: (val) =>
                                    setSheetState(() => isActive = val),
                              ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(18)),
                        TextFormField(
                          controller: nameController,
                          style: AppTextStyles.body(),
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: DValidator.lettersOnly,
                          decoration: _inputDecoration(
                              'Driver Name', Icons.person_outline),
                          validator: (v) =>
                              DValidator.validateName('Driver name', v),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: emailController,
                          style: AppTextStyles.body(),
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: DValidator.textWithLimit,
                          decoration:
                          _inputDecoration('Email', Icons.mail_outline),
                          validator: DValidator.validateEmail,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: mobileController,
                          style: AppTextStyles.body(),
                          keyboardType: TextInputType.phone,
                          inputFormatters: DValidator.phoneNumber,
                          decoration: _inputDecoration(
                              'Phone Number', Icons.call_outlined),
                          validator: DValidator.validatePhoneNumber,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: licenseController,
                          style: AppTextStyles.body(),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: DValidator.licenseNumber,
                          decoration: _inputDecoration(
                              'License Number', Icons.badge_outlined),
                          validator: DValidator.validateLicenseNumber,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: vehicleController,
                          style: AppTextStyles.body(),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: DValidator.vehicleNumber,
                          decoration: _inputDecoration(
                              'Vehicle Number', Icons.local_shipping_outlined),
                          validator: DValidator.validateVehicleNumber,
                        ),
                        SizedBox(height: Responsive.h(14)),

                        // ---- Joining Date (pre-filled when editing) ----
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final now = DateTime.now();
                            final today =
                            DateTime(now.year, now.month, now.day);

                            // initialDate must never be after lastDate, otherwise
                            // showDatePicker throws an assertion error (edit mode
                            // with a saved future date).
                            DateTime initial = joiningDate ?? today;
                            if (initial.isAfter(today)) initial = today;

                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate: initial,
                              firstDate: DateTime(2000),
                              lastDate: today, // future dates are disabled
                            );
                            if (picked != null) {
                              setSheetState(() {
                                joiningDate = picked;
                                showDateError = false;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,
                              prefixIcon: Icon(Icons.event_outlined,
                                  color: AppColors.textSecondary, size: 20),
                              errorText: showDateError
                                  ? (joiningDate == null
                                  ? 'Please select joining date'
                                  : 'Joining date cannot be in the future')
                                  : null,
                              errorStyle: AppTextStyles.caption(
                                  color: AppColors.error),
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
                            ),
                            child: Text(
                              joiningDate == null
                                  ? 'Select Joining Date'
                                  : _pickerDate(joiningDate!),
                              style: joiningDate == null
                                  ? AppTextStyles.body(
                                  color: AppColors.textHint)
                                  : AppTextStyles.body(),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(16)),
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
                              final formValid =
                              formKey.currentState!.validate();

                              if (joiningDate == null) {
                                setSheetState(() => showDateError = true);
                                return;
                              }

                              // Block a saved future date from being re-saved.
                              final now = DateTime.now();
                              final today =
                              DateTime(now.year, now.month, now.day);
                              if (joiningDate!.isAfter(today)) {
                                setSheetState(() => showDateError = true);
                                return;
                              }

                              if (!formValid) return;

                              if (isEdit) {
                                bloc.add(UpdateDriver(
                                  id: existing.id,
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  mobile: mobileController.text.trim(),
                                  licenseNumber: licenseController.text.trim(),
                                  vehicleNumber: vehicleController.text.trim(),
                                  // Update API body uses dd-MM-yyyy
                                  // (e.g. "25-01-2025").
                                  joiningDate: _pickerDate(joiningDate!),
                                  isActive: isActive,
                                  password:
                                  passwordController.text.trim().isEmpty
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
                                  // Add flow unchanged: yyyy-MM-dd
                                  joiningDate: _formatDate(joiningDate!),
                                ));
                              }

                              Navigator.pop(sheetContext);
                            },
                            child: Text(
                              isEdit ? 'Save Changes' : 'Add Driver',
                              style:
                              AppTextStyles.bodyBold(color: Colors.white),
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
      message:
      'Are you sure you want to remove ${driver.name} from your drivers list?',
      confirmText: 'Remove',
    );
    if (confirmed) {
      bloc.add(DeleteDriver(driver.id));
    }
  }

  /// yyyy-MM-dd - used when adding a driver.
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// dd-MM-yyyy - shown in the date field and sent on update.
  static String _pickerDate(DateTime date) =>
      DateFormat('dd-MM-yyyy').format(date);

  /// API returns dd-MM-yyyy (e.g. "01-10-2026"); also accepts yyyy-MM-dd.
  /// Returns null if empty or unparseable.
  static DateTime? _parseApiDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(s);
    } catch (_) {
      return DateTime.tryParse(s);
    }
  }

  static String _displayDate(String raw) {
    if (raw.isEmpty) return '—';
    return raw;
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(color: AppColors.textHint),
      errorStyle: AppTextStyles.caption(color: AppColors.error),
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

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates) ----------
        appBar: AppBar(
          title: Text('Drivers', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: Responsive.w(12)),
              child: TextButton.icon(
                onPressed: () => _openDriverSheet(),
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
          child: BlocConsumer<DriverBloc, DriverState>(
            listener: (context, state) {
              if (state.successMessage != null) {
                AppSnackbar.success(state.successMessage!);
                context.read<DriverBloc>().add(const ClearDriverFeedback());
              } else if (state.errorMessage != null) {
                _lastErrorMessage = state.errorMessage;
                AppSnackbar.error(state.errorMessage!);
                context.read<DriverBloc>().add(const ClearDriverFeedback());
              }
            },
            builder: (context, state) {
              // ---- loading skeleton ----
              if (state.status == DriverStatus.loading &&
                  state.drivers.isEmpty) {
                return ShimmerListPlaceholder(
                  itemCount: 6,
                  padding: listPadding,
                  separatorHeight: Responsive.h(10),
                  itemBuilder: (context, i) => const _DriverCardSkeleton(),
                );
              }

              if (state.isUnauthorized) {
                // Redirect to /login is already in flight - don't flash
                // an error screen behind it.
                return const Center(child: CircularProgressIndicator());
              }

              // ---- error ----
              if (state.status == DriverStatus.error && state.drivers.isEmpty) {
                return _ErrorView(
                  message: state.errorMessage ??
                      _lastErrorMessage ??
                      'Could not load drivers.',
                  onRetry: _refresh,
                );
              }

              // ---- empty ----
              if (state.drivers.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 44,
                                color:
                                AppColors.textSecondary.withOpacity(0.4),
                              ),
                              SizedBox(height: Responsive.h(10)),
                              Text('No drivers added yet',
                                  style: AppTextStyles.subtitle()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // ---- list ----
              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: listPadding,
                  itemCount: state.drivers.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: Responsive.h(10)),
                  itemBuilder: (context, index) {
                    final driver = state.drivers[index];
                    return _DriverCard(
                      key: ValueKey(driver.id),
                      driver: driver,
                      joiningDate: _displayDate(driver.joiningDate),
                      onEdit: () => _openDriverSheet(existing: driver),
                      onDelete: () => _confirmDeleteDriver(driver),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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
    final color = isActive ? AppColors.success : _inactiveColor;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(!isActive),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10),
          vertical: Responsive.h(6),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              size: 14,
              color: color,
            ),
            SizedBox(width: Responsive.w(4)),
            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: Responsive.sp(11.5),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ERROR / SKELETON
// =====================================================================

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

class _DriverCardSkeleton extends StatelessWidget {
  const _DriverCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: Responsive.w(12)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 13),
                    SizedBox(height: 8),
                    ShimmerBox(width: 160, height: 11),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 80, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// DRIVER CARD
// =====================================================================

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    super.key,
    required this.driver,
    required this.joiningDate,
    required this.onEdit,
    required this.onDelete,
  });

  final DriverGetModel driver;
  final String joiningDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String get _initial =>
      driver.name.isNotEmpty ? driver.name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: avatar, name + vehicle/licence, status, menu ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      '${driver.vehicleNumber} • ${driver.licenseNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _StatusPill(
                label: driver.isActive ? 'Active' : 'Inactive',
                color: driver.isActive ? AppColors.success : _inactiveColor,
              ),
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
                              style:
                              AppTextStyles.body(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: joining date, phone ----
          Row(
            children: [
              Icon(Icons.event_outlined,
                  size: 13, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  joiningDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: launch dialer or copy number
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_outlined,
                          size: 15, color: AppColors.primary),
                      SizedBox(width: Responsive.w(4)),
                      Text(
                        driver.mobile,
                        style: AppTextStyles.bodyBold(color: AppColors.primary),
                      ),
                    ],
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