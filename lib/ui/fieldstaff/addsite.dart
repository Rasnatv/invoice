
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

  // Today by default for new visits; existing visit's date when editing.
  // DateTime.now() is re-evaluated at build time of the field, not just
  // once here, so "today" is always correct when the screen opens fresh.
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Responsive.w(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.w(40),
                height: Responsive.h(4),
                margin: EdgeInsets.symmetric(vertical: Responsive.h(8)),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(Responsive.w(4)),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: Responsive.w(22)),
                title: Text('Take Photo', style: TextStyle(fontSize: Responsive.sp(14))),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: AppColors.primary, size: Responsive.w(22)),
                title: Text('Choose from Gallery', style: TextStyle(fontSize: Responsive.sp(14))),
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

  /// FIX: the backend expects a data URI ("data:<mime>;base64,<data>"),
  /// not bare base64. Sending bare base64 let the request succeed
  /// (status 1) but the server had nothing valid to decode, so no file
  /// ever landed in storage and thumbnail_url/image_url came back empty.
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

    // FIX: backend sample payload uses plain "yyyy-MM-dd" for visit_date.
    // Sending "yyyy-MM-dd HH:mm:ss" was being rejected/ignored server-side,
    // which is why the picked date wasn't sticking.
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
    // Must run before any Responsive.w/h/sp call below.
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _isEditing ? 'Edit Visit' : 'Add Visit',
            style: TextStyle(fontSize: Responsive.sp(17)),
          ),
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
              // Make sure the dashboard list (and the new thumbnail) is fresh.
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
                child: ListView(
                  padding: EdgeInsets.all(Responsive.w(20)),
                  children: [
                    _imagePicker(),
                    SizedBox(height: Responsive.h(18)),
                    _dateTile(),
                    SizedBox(height: Responsive.h(16)),
                    _field(
                      label: 'Customer Name',
                      controller: _nameCtrl,
                      icon: Icons.storefront_rounded,
                      inputFormatters: DValidator.lettersOnly,
                      validator: (v) => DValidator.validateName('Customer name', v),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    _field(
                      label: 'Site Address',
                      controller: _addressCtrl,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      inputFormatters: DValidator.textWithLimit,
                      validator: (v) => DValidator.validateEmptyText('Site address', v?.trim()),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    _field(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: DValidator.phoneNumber,
                      validator: (v) => DValidator.validatePhoneNumber(v),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    _field(
                      label: 'Email (optional)',
                      controller: _emailCtrl,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: DValidator.textWithLimit,
                      // Optional field: only validate format if something was typed.
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? null : DValidator.validateEmail(v),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    Responsive.isMobile
                        ? Column(
                      children: [
                        _field(
                          label: 'Area (sqft)',
                          controller: _areaCtrl,
                          icon: Icons.square_foot_rounded,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        _field(
                          label: 'Est. Budget',
                          controller: _budgetCtrl,
                          icon: Icons.currency_rupee_rounded,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: 'Area (sqft)',
                            controller: _areaCtrl,
                            icon: Icons.square_foot_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: Responsive.w(12)),
                        Expanded(
                          child: _field(
                            label: 'Est. Budget',
                            controller: _budgetCtrl,
                            icon: Icons.currency_rupee_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(14)),
                    _field(
                      label: 'Project Type (optional)',
                      controller: _projectTypeCtrl,
                      icon: Icons.category_outlined,
                      inputFormatters: DValidator.textWithLimit,
                    ),
                    SizedBox(height: Responsive.h(14)),
                    _field(
                      label: 'Preferred Products (optional)',
                      controller: _preferredProductsCtrl,
                      icon: Icons.grid_view_rounded,
                      maxLines: 2,
                      inputFormatters: DValidator.textWithLimit,
                    ),
                    SizedBox(height: Responsive.h(14)),
                    _field(
                      label: 'Notes (optional)',
                      controller: _notesCtrl,
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                      inputFormatters: DValidator.textWithLimit,
                    ),
                    SizedBox(height: Responsive.h(26)),
                    _submitButton(),
                    SizedBox(height: Responsive.h(12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePicker() {
    final hasAnyImage = _existingImages.isNotEmpty || _newImages.isNotEmpty;
    final thumb = Responsive.w(88);
    final railHeight = Responsive.h(96);
    final bigTile = Responsive.w(140);

    return Column(
      children: [
        if (hasAnyImage)
          SizedBox(
            height: railHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImages.map(
                      (img) => _photoThumb(
                    size: thumb,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Responsive.w(14)),
                      child: Image.network(
                        img.imageUrl,
                        width: thumb,
                        height: thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceAlt,
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.textSecondary.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    onRemove: () => _removeExistingImage(img),
                  ),
                ),
                ..._newImages.map(
                      (file) => _photoThumb(
                    size: thumb,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Responsive.w(14)),
                      child: Image.file(file, width: thumb, height: thumb, fit: BoxFit.cover),
                    ),
                    onRemove: () => _removeNewImage(file),
                  ),
                ),
                _addPhotoTile(thumb),
              ],
            ),
          )
        else
          Center(
            child: GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: bigTile,
                height: bigTile,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(Responsive.w(20)),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.4),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: Responsive.w(30)),
                    SizedBox(height: Responsive.h(6)),
                    Text(
                      'Visit Photos',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.sp(11.5),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(height: Responsive.h(6)),
        Text(
          'Attach proof-of-visit photos',
          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(11)),
        ),
      ],
    );
  }

  Widget _addPhotoTile(double size) {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.only(left: Responsive.w(4)),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(Responsive.w(14)),
          border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.2),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: Responsive.w(22)),
      ),
    );
  }

  Widget _photoThumb({required Widget child, required VoidCallback onRemove, required double size}) {
    return Padding(
      padding: EdgeInsets.only(right: Responsive.w(8)),
      child: Stack(
        children: [
          SizedBox(width: size, height: size, child: child),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(Responsive.w(3)),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, color: Colors.white, size: Responsive.w(13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTile() {
    final label = DateFormat('dd MMM yyyy').format(_visitDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(Responsive.w(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Responsive.w(14)),
        onTap: _pickDate,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Responsive.w(14)),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: Responsive.w(18), color: AppColors.primary),
              SizedBox(width: Responsive.w(10)),
              Text(
                'Visit Date',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.sp(12.5),
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                label,
                style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13.5)),
              ),
              SizedBox(width: Responsive.w(6)),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withOpacity(0.5), size: Responsive.w(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontSize: Responsive.sp(13.5)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: Responsive.sp(12.5), color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: Responsive.w(19)),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(12), horizontal: Responsive.w(12)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.w(12)),
          borderSide: BorderSide.none,
        ),
        errorStyle: TextStyle(fontSize: Responsive.sp(11)),
      ),
    );
  }

  Widget _submitButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(Responsive.w(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Responsive.w(14)),
        onTap: _saving ? null : _submit,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(15)),
          child: Center(
            child: _saving
                ? SizedBox(
              width: Responsive.w(20),
              height: Responsive.w(20),
              child: const CircularProgressIndicator(
                  strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(Colors.white)),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save_rounded, color: Colors.white, size: Responsive.w(18)),
                SizedBox(width: Responsive.w(8)),
                Text(
                  _isEditing ? 'Update Visit' : 'Save Visit',
                  style: TextStyle(
                      color: Colors.white, fontSize: Responsive.sp(14), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}