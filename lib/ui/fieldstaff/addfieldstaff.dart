import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import 'fieldstaff repository.dart';
import 'fieldstaffvisitmodel.dart';

/// Screen the field staff uses to log a daily visit: which party they
/// visited, the address, a contact number, a photo taken on-site as proof
/// of visit, and the incentive earned for that visit.
class AddFieldVisitScreen extends StatefulWidget {
  const AddFieldVisitScreen({
    super.key,
    required this.staffName,
    this.existing,
  });

  final String staffName;

  /// If provided, the screen edits this visit instead of creating a new one.
  final FieldStaffVisitModel? existing;

  @override
  State<AddFieldVisitScreen> createState() => _AddFieldVisitScreenState();
}

class _AddFieldVisitScreenState extends State<AddFieldVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _partyCtrl = TextEditingController(text: widget.existing?.partyName);
  late final _addressCtrl = TextEditingController(text: widget.existing?.address);
  late final _phoneCtrl = TextEditingController(text: widget.existing?.phoneNo);
  late final _incentiveCtrl = TextEditingController(
    text: widget.existing == null ? '' : widget.existing!.incentiveAmount.toStringAsFixed(0),
  );
  late final _notesCtrl = TextEditingController(text: widget.existing?.notes);

  late DateTime _visitDate = widget.existing?.visitDate ?? DateTime.now();
  File? _image;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final path = widget.existing?.imagePath;
    if (path != null && path.isNotEmpty) _image = File(path);
  }

  @override
  void dispose() {
    _partyCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _incentiveCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 75, maxWidth: 1280);
      if (picked != null) setState(() => _image = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access camera/gallery')),
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_image != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _image = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    // TODO(backend): upload `_image` and POST the visit instead of a delay.
    await Future.delayed(const Duration(milliseconds: 500));

    final visit = FieldStaffVisitModel(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      staffName: widget.staffName,
      partyName: _partyCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phoneNo: _phoneCtrl.text.trim(),
      visitDate: _visitDate,
      imagePath: _image?.path,
      incentiveAmount: double.tryParse(_incentiveCtrl.text.trim()) ?? 0,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (_isEditing) {
      FieldStaffRepository.instance.updateVisit(visit);
    } else {
      FieldStaffRepository.instance.addVisit(visit);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(_isEditing ? 'Visit updated' : 'Visit to ${visit.partyName} added')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEditing ? 'Edit Visit' : 'Add Visit'),
      ),
      body: SafeArea(
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
                label: 'Party Name',
                controller: _partyCtrl,
                icon: Icons.storefront_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter party name' : null,
              ),
              SizedBox(height: Responsive.h(14)),
              _field(
                label: 'Address',
                controller: _addressCtrl,
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter address' : null,
              ),
              SizedBox(height: Responsive.h(14)),
              _field(
                label: 'Phone Number',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter phone number';
                  if (v.trim().length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              SizedBox(height: Responsive.h(14)),
              _field(
                label: 'Notes (optional)',
                controller: _notesCtrl,
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              SizedBox(height: Responsive.h(26)),
              _submitButton(),
              SizedBox(height: Responsive.h(12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.4),
                image: _image != null
                    ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: _image == null
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 30),
                  SizedBox(height: Responsive.h(6)),
                  Text(
                    'Visit Photo',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(11.5), fontWeight: FontWeight.w600),
                  ),
                ],
              )
                  : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 15),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(6)),
          Text(
            'Tap to attach proof-of-visit photo',
            style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(11)),
          ),
        ],
      ),
    );
  }

  Widget _dateTile() {
    final label = DateFormat('dd MMM yyyy').format(_visitDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _pickDate,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: Responsive.w(10)),
              Text(
                'Visit Date',
                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12.5), fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                label,
                style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13.5)),
              ),
              SizedBox(width: Responsive.w(6)),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.5)),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: Responsive.sp(13.5)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: Responsive.sp(12.5), color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 19),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: TextStyle(fontSize: Responsive.sp(11)),
      ),
    );
  }

  Widget _submitButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _saving ? null : _submit,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(15)),
          child: Center(
            child: _saving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(Colors.white)),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                SizedBox(width: Responsive.w(8)),
                Text(
                  _isEditing ? 'Update Visit' : 'Save Visit',
                  style: TextStyle(color: Colors.white, fontSize: Responsive.sp(14), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}