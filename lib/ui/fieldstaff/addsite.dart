import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_bloc.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_event.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_state.dart';
import '../../core/validator/validationfile.dart';
import '../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
import '../../models/fieldstaffmodels/fieldstaffsitevisitmodel.dart';
import '../../models/fieldstaffmodels/sitevisitupdatemodel.dart';
import '../../widgets/appsnackbar.dart';

// =====================================================================
// SHARED LOOK (same as the Create Estimate screen)
// =====================================================================

/// White card, radius 16, 1px border, no shadow.
BoxDecoration _cardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
);

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, {this.color, this.size = 16});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            _IconBadge(icon!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Card with a title bar and a padded body.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
  });
  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(title: title, icon: icon, trailing: trailing),
          Padding(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(14), Responsive.h(14), Responsive.w(14), Responsive.h(6)),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Label above the field, then the filled / borderless input (same as the
/// estimate screen's LabeledField + CustomTextField look).
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption(color: AppColors.textSecondary)),
          SizedBox(height: Responsive.h(6)),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: AppTextStyles.body(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body(color: AppColors.textHint),
              prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
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
              errorStyle: TextStyle(fontSize: Responsive.sp(11)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          Responsive.w(20), Responsive.h(10), Responsive.w(20), Responsive.h(14)),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }
}

// =====================================================================
// SCREEN
// =====================================================================

class AddFieldVisitScreen extends StatefulWidget {
  const AddFieldVisitScreen({
    super.key,
    this.staffName,
    this.existing,
  });

  final String? staffName;

  /// If provided, the screen edits this visit instead of creating a new
  /// one — this doubles as your "update screen", there's no separate
  /// widget needed for updates.
  final SiteVisitDetailModel? existing;

  @override
  State<AddFieldVisitScreen> createState() => _AddFieldVisitScreenState();
}

class _AddFieldVisitScreenState extends State<AddFieldVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameCtrl = TextEditingController(text: widget.existing?.customerName);
  late final _phoneCtrl = TextEditingController(text: widget.existing?.customerPhone);
  late final _emailCtrl = TextEditingController(text: widget.existing?.customerEmail);
  late final _addressCtrl = TextEditingController(text: widget.existing?.siteAddress);
  late final _areaCtrl = TextEditingController();
  late final _projectTypeCtrl = TextEditingController();
  late final _budgetCtrl = TextEditingController();
  late final _preferredProductsCtrl = TextEditingController();
  late final _notesCtrl = TextEditingController(text: widget.existing?.notes);

  late DateTime _visitDate = _parseExistingDate() ?? DateTime.now();

  late final List<SiteVisitImageModel> _existingImages =
  List.of(widget.existing?.images ?? const []);
  final Set<String> _removedExistingImageIds = {};
  final List<File> _newImages = [];

  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  DateTime? _parseExistingDate() => DateTime.tryParse(widget.existing?.visitDate ?? '');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _areaCtrl.dispose();
    _projectTypeCtrl.dispose();
    _budgetCtrl.dispose();
    _preferredProductsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 75, maxWidth: 1280);
      if (picked != null) setState(() => _newImages.add(File(picked.path)));
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error('Could not access camera/gallery');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: EdgeInsets.all(Responsive.w(12)),
          padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
          decoration: _cardDecoration(radius: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.w(40),
                height: Responsive.h(4),
                margin: EdgeInsets.symmetric(vertical: Responsive.h(8)),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: const _IconBadge(Icons.camera_alt_rounded),
                title: Text('Take Photo', style: AppTextStyles.bodyBold()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                leading: const _IconBadge(Icons.photo_library_rounded),
                title: Text('Choose from Gallery', style: AppTextStyles.bodyBold()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeExistingImage(SiteVisitImageModel image) {
    setState(() {
      _existingImages.remove(image);
      _removedExistingImageIds.add(image.imageId);
    });
  }

  void _removeNewImage(File file) {
    setState(() => _newImages.remove(file));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _visitDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _visitDate.hour,
        _visitDate.minute,
      ));
    }
  }

  /// Backend expects a data URI ("data:<mime>;base64,<data>").
  Future<List<String>> _encodeNewImages() async {
    final encoded = <String>[];
    for (final file in _newImages) {
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last.toLowerCase();
      final mime = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      encoded.add('data:$mime;base64,${base64Encode(bytes)}');
    }
    return encoded;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final images = await _encodeNewImages();
    if (!mounted) return;

    // Backend expects plain "yyyy-MM-dd" for visit_date.
    final visitDateStr = DateFormat('yyyy-MM-dd').format(_visitDate);

    if (_isEditing) {
      final request = SiteVisitUpdateRequestModel(
        id: int.parse(widget.existing!.id),
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        customerEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        siteAddress: _addressCtrl.text.trim(),
        areaSqft: double.tryParse(_areaCtrl.text.trim()),
        projectType: _projectTypeCtrl.text.trim().isEmpty ? null : _projectTypeCtrl.text.trim(),
        estimatedBudget: double.tryParse(_budgetCtrl.text.trim()),
        preferredProducts:
        _preferredProductsCtrl.text.trim().isEmpty ? null : _preferredProductsCtrl.text.trim(),
        visitDate: visitDateStr,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        removeImageIds: _removedExistingImageIds.isEmpty
            ? null
            : _removedExistingImageIds.map(int.parse).toList(),
        images: images.isEmpty ? null : images,
      );
      context.read<SiteVisitBloc>().add(UpdateSiteVisit(request));
    } else {
      final request = SiteVisitCreateRequestModel(
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        customerEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        siteAddress: _addressCtrl.text.trim(),
        areaSqft: double.tryParse(_areaCtrl.text.trim()),
        projectType: _projectTypeCtrl.text.trim().isEmpty ? null : _projectTypeCtrl.text.trim(),
        estimatedBudget: double.tryParse(_budgetCtrl.text.trim()),
        preferredProducts:
        _preferredProductsCtrl.text.trim().isEmpty ? null : _preferredProductsCtrl.text.trim(),
        visitDate: visitDateStr,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        images: images.isEmpty ? null : images,
      );
      context.read<SiteVisitBloc>().add(CreateSiteVisit(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final sectionGap = SizedBox(height: Responsive.h(14));
    final gap = SizedBox(width: Responsive.w(10));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(_isEditing ? 'Edit Visit' : 'Add Visit', style: AppTextStyles.h6()),
        ),
        body: BlocListener<SiteVisitBloc, SiteVisitState>(
          listenWhen: (prev, curr) =>
          curr.actionStatus != prev.actionStatus &&
              (curr.actionStatus == SiteVisitActionStatus.success ||
                  curr.actionStatus == SiteVisitActionStatus.failure),
          listener: (context, state) {
            if (!mounted) return;
            setState(() => _saving = false);

            if (state.actionStatus == SiteVisitActionStatus.success) {
              Navigator.of(context).pop();
              AppSnackbar.success(
                state.actionMessage ?? (_isEditing ? 'Visit updated' : 'Visit added'),
              );
              context.read<SiteVisitBloc>().add(const FetchMySiteVisits());
            } else {
              AppSnackbar.error(state.actionMessage ?? 'Something went wrong');
            }
            context.read<SiteVisitBloc>().add(const ResetSiteVisitActionStatus());
          },
          child: SafeArea(
            child: ResponsiveCenter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          Responsive.w(20),
                          Responsive.h(14),
                          Responsive.w(20),
                          Responsive.h(24),
                        ),
                        children: [
                          // ---- Header (title + date) ----
                          _headerCard(),
                          sectionGap,

                          // ---- Photos ----
                          _SectionCard(
                            title: 'Visit Photos',
                            icon: Icons.add_a_photo_outlined,
                            trailing: Text(
                              '${_existingImages.length + _newImages.length} added',
                              style: AppTextStyles.caption(color: AppColors.textSecondary),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: Responsive.h(8)),
                              child: _imagePicker(),
                            ),
                          ),
                          sectionGap,

                          // ---- Customer ----
                          _SectionCard(
                            title: 'Customer Details',
                            icon: Icons.groups_2_outlined,
                            child: Column(
                              children: [
                                _LabeledField(
                                  label: 'Customer Name',
                                  hint: 'Enter customer name',
                                  controller: _nameCtrl,
                                  icon: Icons.storefront_rounded,
                                  inputFormatters: DValidator.lettersOnly,
                                  validator: (v) => DValidator.validateName('Customer name', v),
                                ),
                                _LabeledField(
                                  label: 'Phone Number',
                                  hint: 'Enter phone number',
                                  controller: _phoneCtrl,
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: DValidator.phoneNumber,
                                  validator: (v) => DValidator.validatePhoneNumber(v),
                                ),
                                _LabeledField(
                                  label: 'Email (optional)',
                                  hint: 'Enter customer email',
                                  controller: _emailCtrl,
                                  icon: Icons.alternate_email,
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: DValidator.textWithLimit,
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? null
                                      : DValidator.validateEmail(v),
                                ),
                              ],
                            ),
                          ),
                          sectionGap,

                          // ---- Site ----
                          _SectionCard(
                            title: 'Site Details',
                            icon: Icons.location_on_outlined,
                            child: Column(
                              children: [
                                _LabeledField(
                                  label: 'Site Address',
                                  hint: 'Enter site address',
                                  controller: _addressCtrl,
                                  icon: Icons.location_on_outlined,
                                  maxLines: 2,
                                  inputFormatters: DValidator.textWithLimit,
                                  validator: (v) =>
                                      DValidator.validateEmptyText('Site address', v?.trim()),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _LabeledField(
                                        label: 'Area (sqft)',
                                        hint: 'Area',
                                        controller: _areaCtrl,
                                        icon: Icons.square_foot_rounded,
                                        keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true),
                                        inputFormatters: DValidator.decimalNumber,
                                        validator: (v) =>
                                            DValidator.validateOptionalNumber('Area', v),
                                      ),
                                    ),
                                    gap,
                                    Expanded(
                                      child: _LabeledField(
                                        label: 'Est. Budget',
                                        hint: 'Budget',
                                        controller: _budgetCtrl,
                                        icon: Icons.currency_rupee_rounded,
                                        keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true),
                                        inputFormatters: DValidator.decimalNumber,
                                        validator: (v) => DValidator.validateOptionalNumber(
                                            'Estimated budget', v),
                                      ),
                                    ),
                                  ],
                                ),
                                _LabeledField(
                                  label: 'Preferred Products (optional)',
                                  hint: 'e.g. Vitrified tiles, 2x2',
                                  controller: _preferredProductsCtrl,
                                  icon: Icons.grid_view_rounded,
                                  maxLines: 2,
                                  inputFormatters: DValidator.textWithLimit,
                                ),
                              ],
                            ),
                          ),
                          sectionGap,

                          // ---- Notes ----
                          _SectionCard(
                            title: 'Other Details',
                            icon: Icons.tune_rounded,
                            child: _LabeledField(
                              label: 'Notes (optional)',
                              hint: 'Add any notes about this visit',
                              controller: _notesCtrl,
                              icon: Icons.notes_rounded,
                              maxLines: 3,
                              inputFormatters: DValidator.textWithLimit,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _BottomActionBar(child: _submitButton()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const _IconBadge(Icons.assignment_ind_outlined),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Text(_isEditing ? 'Edit Visit' : 'New Visit', style: AppTextStyles.bodyBold()),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _pickDate,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(10), vertical: Responsive.h(6)),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: Responsive.w(6)),
                  Text(DateFormat('dd-MM-yyyy').format(_visitDate), style: AppTextStyles.body()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePicker() {
    final hasAnyImage = _existingImages.isNotEmpty || _newImages.isNotEmpty;
    final thumb = Responsive.w(80);

    if (!hasAnyImage) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _showImageSourceSheet,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: Responsive.h(22)),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              const _IconBadge(Icons.add_a_photo_rounded, size: 22),
              SizedBox(height: Responsive.h(8)),
              Text('Add Visit Photos', style: AppTextStyles.bodyBold()),
              SizedBox(height: Responsive.h(2)),
              Text('Attach proof-of-visit photos',
                  style: AppTextStyles.caption(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: thumb + 8,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          ..._existingImages.map(
                (img) => _photoThumb(
              size: thumb,
              child: Image.network(
                img.imageUrl,
                width: thumb,
                height: thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.background,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined,
                      color: AppColors.textSecondary.withOpacity(0.5)),
                ),
              ),
              onRemove: () => _removeExistingImage(img),
            ),
          ),
          ..._newImages.map(
                (file) => _photoThumb(
              size: thumb,
              child: Image.file(file, width: thumb, height: thumb, fit: BoxFit.cover),
              onRemove: () => _removeNewImage(file),
            ),
          ),
          _addPhotoTile(thumb),
        ],
      ),
    );
  }

  Widget _addPhotoTile(double size) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _showImageSourceSheet,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 22),
      ),
    );
  }

  Widget _photoThumb({required Widget child, required VoidCallback onRemove, required double size}) {
    return Padding(
      padding: EdgeInsets.only(right: Responsive.w(10)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: child,
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: Responsive.h(48),
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _submit,
        icon: _saving
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.save_rounded, color: Colors.white, size: 18),
        label: Text(
          _saving ? 'Saving…' : (_isEditing ? 'Update Visit' : 'Save Visit'),
          style: AppTextStyles.bodyBold(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}