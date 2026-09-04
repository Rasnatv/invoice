
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_bloc.dart';
import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_event.dart';
import '../../bloc/ownerbloc/ownerdespatchcreate/ownerdespatchsheetcreate_state.dart';

import '../../models/owner_models/ownerdespatchsheetpreparemodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/primary_button.dart';

/// Owner's despatch-sheet creation screen for an APPROVED estimate.
/// Loads quantity suggestions (POST /despatches/suggest) + active drivers
/// (GET /drivers/active), lets the owner adjust boxes/pieces/quantity per
/// item, assign a driver + vehicle, and submits via POST /despatches/create.
class OwnerDespatchSheetScreen extends StatelessWidget {
  const OwnerDespatchSheetScreen({super.key, required this.estimateId});
  final String estimateId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerDespatchSheetBloc()
        ..add(OwnerDespatchSheetLoadRequested(estimateId)),
      child: _OwnerDespatchSheetView(estimateId: estimateId),
    );
  }
}

class _OwnerDespatchSheetView extends StatelessWidget {
  const _OwnerDespatchSheetView({required this.estimateId});
  final String estimateId;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Create Despatch Sheet', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocConsumer<OwnerDespatchSheetBloc, OwnerDespatchSheetState>(
          listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
          listener: (context, state) {
            if (state.submitStatus == OwnerDespatchSubmitStatus.success) {
              AppSnackbar.success(state.submitMessage ?? 'Despatch sheet created');
              Navigator.of(context).pop(true);
            } else if (state.submitStatus == OwnerDespatchSubmitStatus.failure) {
              AppSnackbar.error(state.submitMessage ?? 'Failed to create despatch sheet');
            }
          },
          builder: (context, state) {
            if (state.status == OwnerDespatchSheetStatus.loading ||
                state.status == OwnerDespatchSheetStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == OwnerDespatchSheetStatus.failure ||
                state.suggestion == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Failed to load despatch details.'),
                    SizedBox(height: Responsive.h(10)),
                    ElevatedButton(
                      onPressed: () => context
                          .read<OwnerDespatchSheetBloc>()
                          .add(OwnerDespatchSheetLoadRequested(estimateId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return _DespatchForm(
              estimateId: estimateId,
              suggestion: state.suggestion!,
              drivers: state.drivers,
              isSubmitting: state.submitStatus == OwnerDespatchSubmitStatus.inProgress,
              driverLoadError:
              state.drivers.isEmpty ? state.errorMessage : null,
            );
          },
        ),
      ),
    ));
  }
}

class _DespatchForm extends StatefulWidget {
  const _DespatchForm({
    required this.estimateId,
    required this.suggestion,
    required this.drivers,
    required this.isSubmitting,
    this.driverLoadError,
  });

  final String estimateId;
  final DespatchSuggestionModel suggestion;
  final List<DriverModel> drivers;
  final bool isSubmitting;
  final String? driverLoadError;

  @override
  State<_DespatchForm> createState() => _DespatchFormState();
}

class _DespatchFormState extends State<_DespatchForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _refNoCtrl;
  late final TextEditingController _partyNameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _vehicleCtrl;
  final _notesCtrl = TextEditingController();

  String? _selectedDriverId;
  String? _selectedDriverName;
  DateTime _despatchDate = DateTime.now();

  // Per-item controllers keyed by estimate_item_id, pre-filled from the
  // suggestion so the owner can tweak boxes/pieces/quantity before submit.
  late final Map<String, TextEditingController> _boxesCtrls;
  late final Map<String, TextEditingController> _piecesCtrls;
  late final Map<String, TextEditingController> _qtyCtrls;

  // Shared input decoration style so every field in this form looks the
  // same (icon + filled surface + rounded border), matching the look of
  // the old static despatch-sheet draft.
  InputDecoration _decor(String label, {IconData? icon, String? hint, String? error}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      errorText: error,
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.w(14),
        vertical: Responsive.h(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final s = widget.suggestion;
    _refNoCtrl = TextEditingController(text: s.previewDsNumber);
    _partyNameCtrl = TextEditingController(text: s.partyName);
    _contactCtrl = TextEditingController(text: s.contactNumber);
    _addressCtrl = TextEditingController(text: s.deliveryAddress);
    _vehicleCtrl = TextEditingController();

    _boxesCtrls = {
      for (final item in s.items)
        item.estimateItemId: TextEditingController(text: item.suggestedBoxes.toString()),
    };
    _piecesCtrls = {
      for (final item in s.items)
        item.estimateItemId: TextEditingController(text: item.suggestedPieces.toString()),
    };
    _qtyCtrls = {
      for (final item in s.items)
        item.estimateItemId:
        TextEditingController(text: item.suggestedQuantity.toStringAsFixed(0)),
    };
  }

  @override
  void dispose() {
    _refNoCtrl.dispose();
    _partyNameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _vehicleCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _boxesCtrls.values) c.dispose();
    for (final c in _piecesCtrls.values) c.dispose();
    for (final c in _qtyCtrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;

    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(Responsive.w(18)),
              children: [
                // ---- Estimate / DS header ----
                Container(
                  padding: EdgeInsets.all(Responsive.w(14)),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimate No.', style: AppTextStyles.caption()),
                          Text(s.estimateNumber, style: AppTextStyles.h3()),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('DS No. (preview)', style: AppTextStyles.caption()),
                          Text(s.previewDsNumber, style: AppTextStyles.h3()),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(18)),

                // ---- Delivery details ----
                Text('Delivery Details', style: AppTextStyles.h3()),
                SizedBox(height: Responsive.h(10)),
                TextFormField(
                  controller: _refNoCtrl,
                  decoration: _decor('Reference No.', icon: Icons.confirmation_number_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: _partyNameCtrl,
                  decoration: _decor('Party Name', icon: Icons.groups_2_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: _contactCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _decor('Contact Number', icon: Icons.call_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: _addressCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: _decor('Delivery Address', icon: Icons.location_on_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: Responsive.h(20)),

                // ---- Driver & vehicle ----
                Text('Driver & Vehicle', style: AppTextStyles.h3()),
                SizedBox(height: Responsive.h(10)),
                if (widget.drivers.isEmpty)
                  Container(
                    padding: EdgeInsets.all(Responsive.w(12)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.textHint),
                        SizedBox(width: Responsive.w(8)),
                        Expanded(
                          child: Text(
                            widget.driverLoadError ?? 'No active drivers available.',
                            style: AppTextStyles.caption(),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedDriverId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    decoration: _decor('Assign Driver', icon: Icons.person_outline),
                    items: widget.drivers
                        .map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(d.name, style: AppTextStyles.body()),
                    ))
                        .toList(),
                    onChanged: (v) {
                      final driver = widget.drivers.firstWhere((d) => d.id == v);
                      setState(() {
                        _selectedDriverId = driver.id;
                        _selectedDriverName = driver.name;
                      });
                    },
                    validator: (v) => v == null ? 'Select a driver' : null,
                  ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: _vehicleCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _decor(
                    'Vehicle Number',
                    icon: Icons.local_shipping_outlined,
                    hint: 'KA01AB1234',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: Responsive.h(12)),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _despatchDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _despatchDate = picked);
                  },
                  child: InputDecorator(
                    decoration: _decor('Despatch Date', icon: Icons.event_outlined),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_despatchDate),
                      style: AppTextStyles.body(),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                TextFormField(
                  controller: _notesCtrl,
                  minLines: 1,
                  maxLines: 3,
                  decoration: _decor('Delivery Notes (optional)', icon: Icons.notes_outlined),
                ),
                SizedBox(height: Responsive.h(20)),

                // ---- Items table ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items', style: AppTextStyles.h3()),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Total: ${s.items.length}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary)),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                _DespatchItemsTable(
                  items: s.items,
                  boxesCtrls: _boxesCtrls,
                  piecesCtrls: _piecesCtrls,
                  qtyCtrls: _qtyCtrls,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(18)),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: PrimaryButton(
            label: widget.isSubmitting ? 'Please wait...' : 'Create Despatch Sheet',
            height: 48,
            onPressed: widget.isSubmitting ? null : _submit,
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDriverId == null || _selectedDriverName == null) {
      AppSnackbar.error('Please assign a driver');
      return;
    }

    final items = widget.suggestion.items.map((item) {
      final id = item.estimateItemId;
      return OwnerDespatchItemRequest(
        estimateItemId: id,
        boxes: int.tryParse(_boxesCtrls[id]!.text.trim()) ?? 0,
        pieces: int.tryParse(_piecesCtrls[id]!.text.trim()) ?? 0,
        quantity: double.tryParse(_qtyCtrls[id]!.text.trim()) ?? 0,
      );
    }).toList();

    final request = OwnerDespatchCreateRequest(
      estimateId: widget.estimateId,
      refNo: _refNoCtrl.text.trim(),
      partyName: _partyNameCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      deliveryAddress: _addressCtrl.text.trim(),
      driverId: _selectedDriverId!,
      driverName: _selectedDriverName!,
      vehicleNumber: _vehicleCtrl.text.trim(),
      items: items,
      despatchDate: DateFormat('yyyy-MM-dd').format(_despatchDate),
      deliveryNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    context.read<OwnerDespatchSheetBloc>().add(OwnerDespatchCreateRequested(request));
  }
}

/// Table-style item list (header row + one row per item, each with inline
/// editable Boxes / Pieces / Quantity cells) — matches the compact sheet
/// layout from the old draft, but driven by the real suggestion data and
/// wired to the same controllers used for submit.
class _DespatchItemsTable extends StatelessWidget {
  const _DespatchItemsTable({
    required this.items,
    required this.boxesCtrls,
    required this.piecesCtrls,
    required this.qtyCtrls,
  });

  final List<DespatchSuggestionItem> items;
  final Map<String, TextEditingController> boxesCtrls;
  final Map<String, TextEditingController> piecesCtrls;
  final Map<String, TextEditingController> qtyCtrls;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('No items to despatch.', style: AppTextStyles.caption()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            color: AppColors.surfaceAlt,
            padding:
            EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(10)),
            child: Row(
              children: [
                SizedBox(width: 24, child: Text('#', style: AppTextStyles.caption())),
                Expanded(flex: 3, child: Text('Item', style: AppTextStyles.caption())),
                SizedBox(width: 70, child: Text('Boxes', style: AppTextStyles.caption())),
                SizedBox(width: 70, child: Text('Pieces', style: AppTextStyles.caption())),
                SizedBox(width: 78, child: Text('Qty', style: AppTextStyles.caption())),
              ],
            ),
          ),
          // Item rows
          for (var i = 0; i < items.length; i++)
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(10)),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Padding(
                      padding: EdgeInsets.only(top: Responsive.h(14)),
                      child: Text('${i + 1}', style: AppTextStyles.body()),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(top: Responsive.h(14), right: Responsive.w(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].productName,
                            style: AppTextStyles.bodyBold(),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(
                            'Unit: ${items[i].unit} · Remaining: ${items[i].remainingQuantity.toStringAsFixed(0)}',
                            style: AppTextStyles.caption(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: boxesCtrls[items[i].estimateItemId],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTextStyles.body(),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.w(6)),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: piecesCtrls[items[i].estimateItemId],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTextStyles.body(),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.w(6)),
                  SizedBox(
                    width: 78,
                    child: TextFormField(
                      controller: qtyCtrls[items[i].estimateItemId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: AppTextStyles.body(),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}