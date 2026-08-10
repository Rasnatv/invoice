import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart'; // exposes Responsive and ResponsiveCenter
import '../../../core/validator/validationfile.dart';
import '../../Apiprovider/fieldstaffprovider.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/fieldstaff_cretaemodel.dart';
import '../../models/owner_models/fieldstaff_deletemodel.dart';
import '../../models/owner_models/fieldstaff_getmodel.dart';
import '../../models/owner_models/fieldstaff_updatemodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../bloc/ownerbloc/fieldstaff_bloc.dart';
import '../../bloc/ownerbloc/fieldstaff_event.dart';
import '../../bloc/ownerbloc/fieldstaffstate.dart';


class OwnerAddFieldStaffScreen extends StatelessWidget {
  const OwnerAddFieldStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FieldStaffBloc(provider: FieldStaffProvider())
        ..add(const FetchFieldStaffListEvent()),
      child: const _OwnerAddFieldStaffView(),
    );
  }
}

class _OwnerAddFieldStaffView extends StatelessWidget {
  const _OwnerAddFieldStaffView();

  // ---------------- ADD / EDIT SHEET ----------------

  void _openStaffSheet(BuildContext context, {FieldStaffModel? existing}) {
    final bloc = context.read<FieldStaffBloc>();
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final mobileController = TextEditingController(text: existing?.mobile ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    final ValueNotifier<DateTime?> joiningDate = ValueNotifier<DateTime?>(
      existing != null && existing.joiningDate.isNotEmpty
          ? DateTime.tryParse(existing.joiningDate)
          : DateTime.now(),
    );
    // Only relevant on edit — the create API doesn't accept is_active.
    final ValueNotifier<bool> isActive = ValueNotifier<bool>(existing?.isActive ?? true);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: BlocListener<FieldStaffBloc, FieldStaffState>(
            listener: (listenerContext, state) {
              if (state.status == FieldStaffStatus.submitSuccess) {
                Navigator.pop(sheetContext);
                AppSnackbar.success(state.message ?? 'Success');
              } else if (state.status == FieldStaffStatus.submitError) {
                AppSnackbar.error(state.message ?? 'Something went wrong');
              }
            },
            child: Padding(
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
                  child: SingleChildScrollView(
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
                          isEdit ? 'Edit Field Staff' : 'Add Field Staff',
                          style: AppTextStyles.bodyBold(color: AppColors.black)
                              .copyWith(fontSize: Responsive.sp(17)),
                        ),
                        SizedBox(height: Responsive.h(18)),
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: DValidator.lettersOnly,
                          decoration: _inputDecoration('Full Name', Icons.person_outline),
                          validator: (v) => DValidator.validateName('Name', v),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: DValidator.textWithLimit,
                          decoration: _inputDecoration('Email', Icons.email_outlined),
                          validator: DValidator.validateEmail,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: DValidator.defaultPhoneLength,
                          inputFormatters: DValidator.phoneNumber,
                          decoration: _inputDecoration('Mobile Number', Icons.call_outlined),
                          validator: (v) => DValidator.validatePhoneNumber(v),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          inputFormatters: DValidator.textWithLimit,
                          decoration: _inputDecoration('Address', Icons.home_outlined),
                          validator: (v) => DValidator.validateRequired(
                            v,
                            message: 'Address is required',
                          ),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: joiningDate,
                          builder: (context, date, _) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: sheetContext,
                                  initialDate: date ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) joiningDate.value = picked;
                              },
                              child: InputDecorator(
                                decoration: _inputDecoration(
                                    'Joining Date', Icons.calendar_today_outlined),
                                child: Text(
                                  date != null ? _formatDate(date) : 'Select date',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(14),
                                    color: date != null
                                        ? AppColors.black
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (isEdit) ...[
                          SizedBox(height: Responsive.h(14)),
                          ValueListenableBuilder<bool>(
                            valueListenable: isActive,
                            builder: (context, active, _) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.w(14),
                                  vertical: Responsive.h(4),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: active,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) => isActive.value = v,
                                  title: Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(14),
                                      color: AppColors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    active
                                        ? 'Staff can be assigned work'
                                        : 'Staff is marked inactive',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(11.5),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        SizedBox(height: Responsive.h(18)),
                        BlocBuilder<FieldStaffBloc, FieldStaffState>(
                          builder: (context, state) {
                            final isSaving = state.isSubmitting;
                            return SizedBox(
                              width: double.infinity,
                              height: Responsive.h(48),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () {
                                  if (!formKey.currentState!.validate()) return;
                                  if (joiningDate.value == null) {
                                    AppSnackbar.warning('Please select a joining date');
                                    return;
                                  }

                                  final joiningDateStr = _formatDate(joiningDate.value!);

                                  if (isEdit) {
                                    bloc.add(UpdateFieldStaffEvent(
                                      FieldStaffUpdateModel(
                                        id: existing.id,
                                        name: nameController.text.trim(),
                                        email: emailController.text.trim(),
                                        mobile: mobileController.text.trim(),
                                        address: addressController.text.trim(),
                                        joiningDate: joiningDateStr,
                                        isActive: isActive.value,
                                      ),
                                    ));
                                  } else {
                                    bloc.add(AddFieldStaffEvent(
                                      FieldStaffCreateModel(
                                        name: nameController.text.trim(),
                                        email: emailController.text.trim(),
                                        mobile: mobileController.text.trim(),
                                        address: addressController.text.trim(),
                                        joiningDate: joiningDateStr,
                                      ),
                                    ));
                                  }
                                },
                                child: isSaving
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : Text(
                                  isEdit ? 'Save Changes' : 'Add Field Staff',
                                  style: AppTextStyles.bodyBold(color: Colors.white)
                                      .copyWith(fontSize: Responsive.sp(14)),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// ---------------- DELETE CONFIRM ----------------

  Future<void> _confirmDeleteStaff(BuildContext context, FieldStaffModel staff) async {
    final bloc = context.read<FieldStaffBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Field Staff',
      message: 'Are you sure you want to remove ${staff.name} from your field staff list?',
      confirmText: 'Remove',
    );
    if (confirmed) {
      bloc.add(DeleteFieldStaffEvent(FieldStaffDeleteModel(id: staff.id)));
    }
  }
  // ---------------- HELPERS ----------------

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      counterText: '',
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

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text('Field Staff', style: AppTextStyles.h6()),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openStaffSheet(context),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text(
          'Add Staff',
          style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(13)),
        ),
      ),
      body: ResponsiveCenter(
        child: BlocConsumer<FieldStaffBloc, FieldStaffState>(
          listener: (context, state) {
            if (state.status == FieldStaffStatus.deleteSuccess) {
              AppSnackbar.success(state.message ?? 'Removed');
            } else if (state.status == FieldStaffStatus.deleteError) {
              AppSnackbar.error(state.message ?? 'Failed to remove');
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              // This is the only other place a fetch is triggered — an
              // explicit pull-to-refresh. The bloc itself never refetches
              // after add/update/delete; it patches staffList locally.
              onRefresh: () async {
                context.read<FieldStaffBloc>().add(const FetchFieldStaffListEvent());
              },
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    ));
  }

  Widget _buildBody(BuildContext context, FieldStaffState state) {
    if (!state.hasLoadedOnce &&
        (state.isLoading || state.status == FieldStaffStatus.initial)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!state.hasLoadedOnce && state.status == FieldStaffStatus.loadError) {
      return _ErrorState(
        message: state.message ?? 'Failed to load field staff',
        onRetry: () =>
            context.read<FieldStaffBloc>().add(const FetchFieldStaffListEvent()),
      );
    }
    if (state.staffList.isEmpty) {
      return _EmptyStaffState(onAdd: () => _openStaffSheet(context));
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(20),
        Responsive.h(16),
        Responsive.w(20),
        Responsive.h(100),
      ),
      itemCount: state.staffList.length,
      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(12)),
      itemBuilder: (context, index) {
        final staff = state.staffList[index];
        return _FieldStaffTile(
          staff: staff,
          onEdit: () => _openStaffSheet(context, existing: staff),
          onDelete: () => _confirmDeleteStaff(context, staff),
        );
      },
    );
  }
}

class _FieldStaffTile extends StatelessWidget {
  const _FieldStaffTile({
    required this.staff,
    required this.onEdit,
    required this.onDelete,
  });

  final FieldStaffModel staff;
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
              staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
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
                        staff.name,
                        style: AppTextStyles.bodyBold(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (staff.employeeCode.isNotEmpty) ...[
                      SizedBox(width: Responsive.w(6)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(8),
                          vertical: Responsive.h(3),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          staff.employeeCode,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: Responsive.sp(10.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (!staff.isActive) ...[
                      SizedBox(width: Responsive.w(6)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(8),
                          vertical: Responsive.h(3),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Inactive',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: Responsive.sp(10.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: Responsive.h(4)),
                Row(
                  children: [
                    Icon(Icons.call_outlined, size: 15, color: AppColors.primary),
                    SizedBox(width: Responsive.w(4)),
                    Text(
                      staff.mobile,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: Responsive.sp(12.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(4)),
                Text(
                  staff.email,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(4)),
                Text(
                  staff.address,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(4)),
                Text(
                  'Joined: ${staff.joiningDate}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(11.5)),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(12)),
            Text(
              'No field staff added yet',
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
                'Add Field Staff',
                style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.withOpacity(0.5)),
            SizedBox(height: Responsive.h(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
            SizedBox(height: Responsive.h(16)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}