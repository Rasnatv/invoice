import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/salesman/widget/esalesmanestimatetype.dart';
import 'package:flutter/material.dart';
import '../../../bloc/salemanbloc/estimate/salesman_estimate_bloc.dart';
import '../../../bloc/salemanbloc/estimate/salesmanestimate_event.dart';
import '../../../bloc/salemanbloc/estimate/salesmanestimate_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';

class _UnitFieldVisibility {
  final bool showSize;
  final bool showPacking;

  const _UnitFieldVisibility({
    required this.showSize,
    required this.showPacking,
  });

  factory _UnitFieldVisibility.forProduct(ActiveProductModel? product) {
    if (product == null) {
      return const _UnitFieldVisibility(showSize: false, showPacking: false);
    }
    return _UnitFieldVisibility(
      showSize: product.size.trim().isNotEmpty,
      showPacking: product.packing.trim().isNotEmpty,
    );
  }
}

// =====================================================================
// SHARED LOOK (same as the Owner create-estimate screen)
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Text(title, style: AppTextStyles.bodyBold()),
      ],
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

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.body(color: AppColors.textSecondary)),
        SizedBox(width: Responsive.w(12)),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value, maxLines: 1, style: AppTextStyles.bodyBold()),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// STEP INDICATOR
// =====================================================================

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.step});
  final EstimateStep step;

  static const _labels = ['Details', 'Items', 'Preview'];

  @override
  Widget build(BuildContext context) {
    final index = EstimateStep.values.indexOf(step);
    final count = EstimateStep.values.length;

    Widget dot(int dotIndex) {
      final active = dotIndex == index;
      final done = dotIndex < index;
      return Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (active || done) ? AppColors.primary : AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: (active || done) ? AppColors.primary : AppColors.border),
        ),
        child: done
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
          '${dotIndex + 1}',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            color: active ? Colors.white : AppColors.textHint,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20), vertical: Responsive.h(12)),
      child: Row(
        children: List.generate(count * 2 - 1, (i) {
          if (i.isOdd) {
            final segmentDone = (i ~/ 2) < index;
            return Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
                decoration: BoxDecoration(
                  color: segmentDone ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final dotIndex = i ~/ 2;
          final label = dotIndex < _labels.length ? _labels[dotIndex] : '';
          final reached = dotIndex <= index;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              dot(dotIndex),
              SizedBox(width: Responsive.w(6)),
              Text(
                label,
                style: AppTextStyles.caption(
                  color: reached ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// =====================================================================
// STEP 1 — DETAILS
// =====================================================================

class DetailsStep extends StatelessWidget {
  const DetailsStep({
    super.key,
    required this.date,
    required this.onDateChanged,
    required this.partyNameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.customerEmailCtrl,
    required this.contractorNameCtrl,
    required this.contractorPhoneCtrl,
    required this.contractorEmailCtrl,
    required this.contractorAddressCtrl,
    required this.onSelectSiteVisit,
    required this.onNext,
  });

  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController partyNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController customerEmailCtrl;
  final TextEditingController contractorNameCtrl;
  final TextEditingController contractorPhoneCtrl;
  final TextEditingController contractorEmailCtrl;
  final TextEditingController contractorAddressCtrl;
  final ValueChanged<SiteVisitDropdownItem> onSelectSiteVisit;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final sectionGap = SizedBox(height: Responsive.h(14));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24)),
            children: [
              // ---- Estimate header (title + date) ----
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(14), vertical: Responsive.h(12)),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    const _IconBadge(Icons.description_outlined),
                    SizedBox(width: Responsive.w(10)),
                    Expanded(child: Text('New Estimate', style: AppTextStyles.bodyBold())),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) onDateChanged(picked);
                      },
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
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: AppColors.textSecondary),
                            SizedBox(width: Responsive.w(6)),
                            Text(DateFormat('dd-MM-yyyy').format(date),
                                style: AppTextStyles.body()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              sectionGap,

              // ---- Customer ----
              _SectionCard(
                title: 'Customer Details',
                icon: Icons.groups_2_outlined,
                child: Column(
                  children: [
                    _PhoneSiteVisitField(
                      phoneCtrl: phoneCtrl,
                      onSelectSiteVisit: onSelectSiteVisit,
                    ),
                    LabeledField(
                      label: 'Party Name',
                      field: CustomTextField(
                        hint: 'Enter party name',
                        icon: Icons.groups_2_outlined,
                        controller: partyNameCtrl,
                        inputFormatters: DValidator.lettersOnly,
                      ),
                    ),
                    LabeledField(
                      label: 'Address',
                      field: CustomTextField(
                        hint: 'Enter site address',
                        icon: Icons.location_on_outlined,
                        controller: addressCtrl,
                        inputFormatters: DValidator.textWithLimit,
                      ),
                    ),
                    LabeledField(
                      label: 'Email (optional)',
                      field: CustomTextField(
                        hint: 'Enter customer email',
                        icon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        controller: customerEmailCtrl,
                        inputFormatters: DValidator.textWithLimit,
                      ),
                    ),
                  ],
                ),
              ),
              sectionGap,

              // ---- Contractor ----
              _SectionCard(
                title: 'Contractor Details',
                icon: Icons.engineering_outlined,
                child: Column(
                  children: [
                    LabeledField(
                      label: 'Contractor Name',
                      field: CustomTextField(
                        hint: 'Enter contractor name',
                        icon: Icons.engineering_outlined,
                        controller: contractorNameCtrl,
                        inputFormatters: DValidator.lettersOnly,
                      ),
                    ),
                    LabeledField(
                      label: 'Contact No.',
                      field: CustomTextField(
                        hint: 'Enter contractor phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: contractorPhoneCtrl,
                        inputFormatters: DValidator.phoneNumber,
                      ),
                    ),
                    LabeledField(
                      label: 'Email (optional)',
                      field: CustomTextField(
                        hint: 'Enter contractor email',
                        icon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        controller: contractorEmailCtrl,
                        inputFormatters: DValidator.textWithLimit,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        BottomActionBar(
          right: PrimaryButton(label: 'Add Items', height: 48, onPressed: onNext),
        ),
      ],
    );
  }
}

// =====================================================================
// PHONE FIELD WITH LIVE SITE-VISIT SUGGESTIONS (from the bloc)
// =====================================================================

class _PhoneSiteVisitField extends StatelessWidget {
  const _PhoneSiteVisitField({
    required this.phoneCtrl,
    required this.onSelectSiteVisit,
  });

  final TextEditingController phoneCtrl;
  final ValueChanged<SiteVisitDropdownItem> onSelectSiteVisit;

  static const int _minDigitsToSearch = 2;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: phoneCtrl,
      builder: (context, value, _) {
        final query = value.text.trim();

        return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
          buildWhen: (prev, curr) =>
          prev.siteVisits != curr.siteVisits ||
              prev.siteVisitsStatus != curr.siteVisitsStatus ||
              prev.selectedSiteVisit != curr.selectedSiteVisit,
          builder: (context, state) {
            List<SiteVisitDropdownItem> matches = [];
            if (query.length >= _minDigitsToSearch) {
              matches = state.siteVisits.where((v) => v.customerPhone.contains(query)).toList();
            }
            // Hide the list once a visit has been picked and the phone
            // still equals it; it reappears as soon as the number is edited.
            final selected = state.selectedSiteVisit;
            final alreadySelected = selected != null && selected.customerPhone == query;
            final showSuggestions = matches.isNotEmpty && !alreadySelected;
            final loading = state.siteVisitsStatus == LoadStatus.loading;
            final failed = state.siteVisitsStatus == LoadStatus.failure;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledField(
                  label: 'Contact No.',
                  field: CustomTextField(
                    hint: 'Enter phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: phoneCtrl,
                    inputFormatters: DValidator.phoneNumber,
                  ),
                ),
                if (query.length >= _minDigitsToSearch && loading) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: Responsive.h(12)),
                    child: Text('Searching pending site visits…',
                        style: AppTextStyles.caption(color: AppColors.textSecondary)),
                  ),
                ] else if (query.length >= _minDigitsToSearch && failed) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: Responsive.h(12)),
                    child: InkWell(
                      onTap: () => context
                          .read<SalesmanEstimateBloc>()
                          .add(const PendingSiteVisitsRequested()),
                      child: Text(
                        'Couldn\'t load site visits — tap to retry',
                        style: AppTextStyles.caption(color: AppColors.error),
                      ),
                    ),
                  ),
                ] else if (showSuggestions) ...[
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: Responsive.h(220)),
                    decoration: _cardDecoration(radius: 14),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: matches.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, i) {
                        final v = matches[i];
                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              v.customerName.isNotEmpty ? v.customerName[0].toUpperCase() : '?',
                              style: AppTextStyles.caption(color: AppColors.primary),
                            ),
                          ),
                          title: Text(v.customerName, style: AppTextStyles.bodyBold()),
                          subtitle: Text(
                            '${v.customerPhone} · ${v.siteAddress}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(color: AppColors.textSecondary),
                          ),
                          trailing:
                          const Icon(Icons.north_west, size: 16, color: AppColors.primary),
                          onTap: () => onSelectSiteVisit(v),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Padding(
                    padding: EdgeInsets.only(bottom: Responsive.h(12)),
                    child: Text('Tap a match to fill party name and address',
                        style: AppTextStyles.caption(color: AppColors.textSecondary)),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

// =====================================================================
// STEP 2 — ADD ITEMS
// Amount is never computed locally. Box Qty / Piece Qty only render for
// box-unit products. Limits: Quantity/Piece Qty -> 5 digits (+2 dec),
// Rate -> 8 digits (+2 dec).
// =====================================================================

class AddItemsSteps extends StatelessWidget {
  const AddItemsSteps({
    super.key,
    required this.selectedProduct,
    required this.onProductSelected,
    required this.itemCompanyCtrl,
    required this.itemSizeCtrl,
    required this.itemUnitCtrl,
    required this.itemPackingCtrl,
    required this.itemMrpCtrl,
    required this.itemQtyCtrl,
    required this.itemBoxQtyCtrl,
    required this.itemPieceQtyCtrl,
    required this.itemRateCtrl,
    required this.isAdding,
    required this.onQuantityChanged,
    required this.onQtyRateChanged,
    required this.items,
    required this.editingIndex,
    required this.onAddItem,
    required this.onEditItem,
    required this.onCancelEdit,
    required this.onRemoveItem,
    required this.onCancel,
    required this.onSaveItems,
  });

  final ActiveProductModel? selectedProduct;
  final ValueChanged<ActiveProductModel?> onProductSelected;
  final TextEditingController itemCompanyCtrl;
  final TextEditingController itemSizeCtrl;
  final TextEditingController itemUnitCtrl;
  final TextEditingController itemPackingCtrl;
  final TextEditingController itemMrpCtrl;
  final TextEditingController itemQtyCtrl;
  final TextEditingController itemBoxQtyCtrl;
  final TextEditingController itemPieceQtyCtrl;
  final TextEditingController itemRateCtrl;
  final bool isAdding;

  final VoidCallback onQuantityChanged;
  final VoidCallback onQtyRateChanged;

  final List<AddedItem> items;
  final int? editingIndex;
  final VoidCallback onAddItem;
  final void Function(int) onEditItem;
  final VoidCallback onCancelEdit;
  final void Function(int) onRemoveItem;
  final VoidCallback onCancel;
  final VoidCallback onSaveItems;

  _UnitFieldVisibility get _fieldVisibility => _UnitFieldVisibility.forProduct(selectedProduct);
  bool get _isBoxUnit => selectedProduct?.isBoxUnit ?? false;

  Widget _autoField(String label, String hint, IconData icon, TextEditingController c,
      {TextInputType keyboardType = TextInputType.text}) {
    return LabeledField(
      label: label,
      field: IgnorePointer(
        child: CustomTextField(
          hint: hint,
          icon: icon,
          keyboardType: keyboardType,
          controller: c,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final visibility = _fieldVisibility;
    final isEditing = editingIndex != null;
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final gap = SizedBox(width: Responsive.w(10));

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                    Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                children: [
                  // ---------- Add / Edit item card ----------
                  _SectionCard(
                    title: isEditing ? 'Edit Item' : 'Add Item',
                    icon: isEditing ? Icons.edit_outlined : Icons.add_box_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
                          buildWhen: (prev, curr) =>
                          prev.products != curr.products ||
                              prev.productsStatus != curr.productsStatus,
                          builder: (context, state) {
                            if (state.productsStatus == LoadStatus.loading &&
                                state.products.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (state.productsStatus == LoadStatus.failure &&
                                state.products.isEmpty) {
                              return Container(
                                margin: EdgeInsets.only(bottom: Responsive.h(12)),
                                padding: EdgeInsets.all(Responsive.w(12)),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.error.withOpacity(0.25)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.productsError ?? 'Failed to load products.',
                                        style: AppTextStyles.caption(color: AppColors.error),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context
                                          .read<SalesmanEstimateBloc>()
                                          .add(const ActiveProductsRequested()),
                                      child: Text('Retry', style: AppTextStyles.bodyBold()),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return LabeledField(
                              label: 'Select Product',
                              field: KeyedSubtree(
                                key: ValueKey(selectedProduct?.id ?? 'none'),
                                child: Autocomplete<ActiveProductModel>(
                                  displayStringForOption: (p) => '${p.name} — ${p.company}',
                                  initialValue: TextEditingValue(
                                    text: selectedProduct != null
                                        ? '${selectedProduct!.name} — ${selectedProduct!.company}'
                                        : '',
                                  ),
                                  optionsBuilder: (textEditingValue) {
                                    final query = textEditingValue.text.trim().toLowerCase();
                                    if (query.isEmpty) return state.products;
                                    return state.products.where((p) =>
                                    p.name.toLowerCase().contains(query) ||
                                        p.company.toLowerCase().contains(query));
                                  },
                                  onSelected: (p) {
                                    onProductSelected(p);
                                    setLocalState(() {});
                                  },
                                  fieldViewBuilder:
                                      (context, controller, focusNode, onFieldSubmitted) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      style: AppTextStyles.body(),
                                      decoration: InputDecoration(
                                        hintText: 'Search product by name',
                                        hintStyle: AppTextStyles.body(color: AppColors.textHint),
                                        prefixIcon: Icon(Icons.search,
                                            size: 20, color: AppColors.textSecondary),
                                        suffixIcon: controller.text.isNotEmpty
                                            ? IconButton(
                                          icon: Icon(Icons.clear,
                                              size: 18, color: AppColors.textSecondary),
                                          onPressed: () {
                                            controller.clear();
                                            onProductSelected(null);
                                            setLocalState(() {});
                                          },
                                        )
                                            : null,
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
                                    );
                                  },
                                  optionsViewBuilder: (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        color: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          side: const BorderSide(color: AppColors.border),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: ConstrainedBox(
                                          constraints:
                                          BoxConstraints(maxHeight: Responsive.h(260)),
                                          child: options.isEmpty
                                              ? Padding(
                                            padding: EdgeInsets.all(Responsive.w(14)),
                                            child: Text('No matching products',
                                                style: AppTextStyles.caption(
                                                    color: AppColors.textSecondary)),
                                          )
                                              : ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            separatorBuilder: (_, __) => const Divider(
                                                height: 1, color: AppColors.border),
                                            itemBuilder: (context, i) {
                                              final p = options.elementAt(i);
                                              return ListTile(
                                                dense: true,
                                                leading: const _IconBadge(
                                                    Icons.inventory_2_outlined,
                                                    size: 14),
                                                title: Text(p.name,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTextStyles.bodyBold()),
                                                subtitle: Text(p.company,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTextStyles.caption(
                                                        color: AppColors.textSecondary)),
                                                onTap: () => onSelected(p),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        _autoField('Company (auto)', 'Select a product first',
                            Icons.factory_outlined, itemCompanyCtrl),
                        Row(
                          children: [
                            Expanded(
                                child: _autoField('Size (auto)', 'Select a product first',
                                    Icons.straighten_outlined, itemSizeCtrl)),
                            gap,
                            Expanded(
                                child: _autoField('Unit (auto)', 'Select a product first',
                                    Icons.square_foot_outlined, itemUnitCtrl)),
                          ],
                        ),
                        if (visibility.showPacking)
                          _autoField('Packing (auto)', 'Select a product first',
                              Icons.inventory_outlined, itemPackingCtrl),
                        Row(
                          children: [
                            Expanded(
                                child: _autoField('MRP (auto)', 'MRP', Icons.currency_rupee,
                                    itemMrpCtrl,
                                    keyboardType: TextInputType.number)),
                            gap,
                            Expanded(
                              child: LabeledField(
                                label: 'Rate',
                                field: CustomTextField(
                                  hint: 'Rate',
                                  icon: Icons.currency_rupee,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                                  controller: itemRateCtrl,
                                  // Rate: max 8 digits + 2 decimals
                                  inputFormatters: DValidator.priceNumber,
                                  onChanged: (_) {
                                    setLocalState(() {});
                                    onQtyRateChanged();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        LabeledField(
                          label: _isBoxUnit ? 'Quantity (Box)' : 'Quantity',
                          field: CustomTextField(
                            hint: 'Enter quantity',
                            icon: Icons.numbers_outlined,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            controller: itemQtyCtrl,
                            // Quantity: max 5 digits + 2 decimals
                            inputFormatters: DValidator.quantityNumber,
                            onChanged: (_) {
                              setLocalState(() {});
                              onQuantityChanged();
                            },
                          ),
                        ),
                        if (_isBoxUnit)
                          Row(
                            children: [
                              Expanded(
                                  child: _autoField('Box Qty (auto)', '0',
                                      Icons.inventory_2_outlined, itemBoxQtyCtrl,
                                      keyboardType: TextInputType.number)),
                              gap,
                              Expanded(
                                child: LabeledField(
                                  label: 'Piece Qty',
                                  field: CustomTextField(
                                    hint: '0',
                                    icon: Icons.widgets_outlined,
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    controller: itemPieceQtyCtrl,
                                    // Piece qty: max 5 digits + 2 decimals
                                    inputFormatters: DValidator.quantityNumber,
                                    onChanged: (_) {
                                      setLocalState(() {});
                                      onQtyRateChanged();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                        if (selectedProduct != null) ...[
                          SizedBox(height: Responsive.h(2)),
                          const _IncentivePreviewCard(),
                          SizedBox(height: Responsive.h(10)),
                        ] else
                          SizedBox(height: Responsive.h(2)),

                        if (isEditing)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(12), vertical: Responsive.h(10)),
                            margin: EdgeInsets.only(bottom: Responsive.h(10)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined,
                                    size: 16, color: AppColors.primary),
                                SizedBox(width: Responsive.w(6)),
                                Expanded(
                                  child: Text('Editing item #${editingIndex! + 1}',
                                      style: AppTextStyles.caption(
                                          color: AppColors.textSecondary)),
                                ),
                                InkWell(
                                  onTap: () {
                                    onCancelEdit();
                                    setLocalState(() {});
                                  },
                                  child: Text('Cancel',
                                      style: AppTextStyles.bodyBold(color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          height: Responsive.h(48),
                          child: ElevatedButton.icon(
                            onPressed: isAdding
                                ? null
                                : () {
                              onAddItem();
                              setLocalState(() {});
                            },
                            icon: isAdding
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                                : Icon(isEditing ? Icons.save_outlined : Icons.add,
                                color: Colors.white),
                            label: Text(
                              isAdding
                                  ? 'Calculating…'
                                  : (isEditing ? 'Update Item' : 'Add Item'),
                              style: AppTextStyles.bodyBold(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: buttonShape,
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(8)),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(18)),

                  // ---------- Items list ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionHeader('Items'),
                      _Pill(
                        label: '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(10)),

                  if (items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Responsive.w(18)),
                      decoration: _cardDecoration(),
                      child: Text('No items added yet',
                          style: AppTextStyles.caption(color: AppColors.textSecondary)),
                    )
                  else
                    ...items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return _AddedItemTile(
                        serialNo: i + 1,
                        item: item,
                        currency: currency,
                        isEditing: editingIndex == i,
                        onEdit: () {
                          onEditItem(i);
                          setLocalState(() {});
                        },
                        onDelete: () {
                          onRemoveItem(i);
                          setLocalState(() {});
                        },
                      );
                    }),
                ],
              ),
            ),
            BottomActionBar(
              left: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(Responsive.h(48)),
                  side: const BorderSide(color: AppColors.border),
                  shape: buttonShape,
                ),
                child: Text('Back', style: AppTextStyles.bodyBold()),
              ),
              right: PrimaryButton(label: 'Save Items', height: 48, onPressed: onSaveItems),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================================
// INCENTIVE PREVIEW (salesman-only, live from the bloc)
// =====================================================================

class _IncentivePreviewCard extends StatelessWidget {
  const _IncentivePreviewCard();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
      buildWhen: (prev, curr) =>
      prev.incentiveStatus != curr.incentiveStatus ||
          prev.incentive != curr.incentive ||
          prev.incentiveError != curr.incentiveError,
      builder: (context, state) {
        if (state.incentiveStatus == LoadStatus.initial) {
          return const SizedBox.shrink();
        }

        if (state.incentiveStatus == LoadStatus.loading) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: Responsive.w(10)),
                Text('Checking incentive…',
                    style: AppTextStyles.caption(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        if (state.incentiveStatus == LoadStatus.failure) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.25)),
            ),
            child: Text(
              state.incentiveError ?? 'Couldn\'t fetch incentive for this item.',
              style: AppTextStyles.caption(color: AppColors.error),
            ),
          );
        }

        final incentive = state.incentive;
        if (incentive == null) return const SizedBox.shrink();

        if (!incentive.isEligible) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    incentive.eligibilityReason.isNotEmpty
                        ? incentive.eligibilityReason
                        : 'Not eligible for incentive on this quantity/rate.',
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(Responsive.w(12)),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBadge(Icons.percent, color: AppColors.success, size: 14),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Text('Incentive on this item',
                        style: AppTextStyles.bodyBold(color: AppColors.success)),
                  ),
                  Text(
                    currency.format(incentive.totalIncentive),
                    style: AppTextStyles.bodyBold(color: AppColors.success),
                  ),
                ],
              ),
              if (incentive.eligibilityReason.isNotEmpty) ...[
                SizedBox(height: Responsive.h(6)),
                Text(incentive.eligibilityReason,
                    style: AppTextStyles.caption(color: AppColors.textSecondary)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AddedItemTile extends StatelessWidget {
  const _AddedItemTile({
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.isEditing = false,
  });
  final int serialNo;
  final AddedItem item;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final hasBoxPiece = item.boxQuantity > 0 || item.pieceQuantity > 0;
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: isEditing ? AppColors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEditing ? AppColors.primary : AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$serialNo', style: AppTextStyles.caption(color: AppColors.primary)),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(2)),
                Text(
                  '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}'
                      '${item.packing.isNotEmpty ? ' | ${item.packing}' : ''}',
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Qty: ${item.quantity.toStringAsFixed(2)} ${item.unit}'
                      '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
                      '   Rate: ${item.rate.toStringAsFixed(0)}',
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
                if (hasBoxPiece) ...[
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    'Box: ${item.boxQuantity.toStringAsFixed(0)}   Piece: ${item.pieceQuantity.toStringAsFixed(0)}',
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                  ),
                ],
                if (item.incentiveEligible && item.incentiveAmount > 0) ...[
                  SizedBox(height: Responsive.h(4)),
                  Row(
                    children: [
                      Icon(Icons.percent, size: 12, color: AppColors.success),
                      SizedBox(width: Responsive.w(3)),
                      Text(
                        'Incentive: ${currency.format(item.incentiveAmount)}',
                        style: AppTextStyles.caption(color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(item.amount),
                  style: AppTextStyles.bodyBold(color: AppColors.primary)),
              SizedBox(height: Responsive.h(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  ),
                  SizedBox(width: Responsive.w(14)),
                  InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// STEP 3 — PREVIEW
// Items are shown in an Excel-style grid with all columns (Sl.No, Item,
// Company, Size, Qty, Unit, Box/Piece Qty, MRP, Rate, Amount, Incentive).
// Box Qty / Piece Qty columns only render when at least one item has
// them.
// =====================================================================

class PreviewStep extends StatelessWidget {
  const PreviewStep({
    super.key,
    required this.date,
    required this.partyName,
    required this.address,
    required this.phone,
    required this.customerEmail,
    required this.contractorName,
    required this.contractorPhone,
    required this.contractorEmail,
    required this.handlingChargeCtrl,
    required this.notesCtrl,
    required this.onHandlingChargeChanged,
    required this.onRetryPreview,
    required this.onSaveDraft,
    required this.onSubmit,
  });

  final DateTime date;
  final String partyName;
  final String address;
  final String phone;
  final String customerEmail;
  final String contractorName;
  final String contractorPhone;
  final String contractorEmail;
  final TextEditingController handlingChargeCtrl;
  final TextEditingController notesCtrl;
  final VoidCallback onHandlingChargeChanged;
  final VoidCallback onRetryPreview;
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');
    final sectionGap = SizedBox(height: Responsive.h(14));
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return Column(
      children: [
        Expanded(
          child: BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
            buildWhen: (prev, curr) =>
            prev.previewStatus != curr.previewStatus ||
                prev.previewData != curr.previewData ||
                prev.previewError != curr.previewError,
            builder: (context, state) {
              if (state.previewStatus == LoadStatus.loading && state.previewData == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.previewStatus == LoadStatus.failure && state.previewData == null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(24)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.previewError ?? 'Failed to calculate preview.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.error),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        ElevatedButton(
                          onPressed: onRetryPreview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: buttonShape,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final preview = state.previewData;
              if (preview == null) return const SizedBox.shrink();

              return ListView(
                padding: EdgeInsets.fromLTRB(
                    Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                children: [
                  // ---- Header (title + date) ----
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(14), vertical: Responsive.h(12)),
                    decoration: _cardDecoration(),
                    child: Row(
                      children: [
                        const _IconBadge(Icons.description_outlined),
                        SizedBox(width: Responsive.w(10)),
                        Expanded(child: Text('New Estimate', style: AppTextStyles.bodyBold())),
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.textSecondary),
                        SizedBox(width: Responsive.w(6)),
                        Text(DateFormat('dd-MM-yyyy').format(date),
                            style: AppTextStyles.body()),
                      ],
                    ),
                  ),
                  sectionGap,

                  _PreviewSection(
                    title: 'Customer Details',
                    icon: Icons.groups_2_outlined,
                    rows: [
                      _PreviewRow('Party Name', partyName.isEmpty ? '-' : partyName),
                      _PreviewRow('Address', address.isEmpty ? '-' : address),
                      _PreviewRow('Contact No.', phone.isEmpty ? '-' : phone),
                      _PreviewRow('Email', customerEmail.isEmpty ? '-' : customerEmail),
                    ],
                  ),
                  sectionGap,

                  _PreviewSection(
                    title: 'Contractor Details',
                    icon: Icons.engineering_outlined,
                    rows: [
                      _PreviewRow('Name', contractorName.isEmpty ? '-' : contractorName),
                      _PreviewRow('Contact No.', contractorPhone.isEmpty ? '-' : contractorPhone),
                      _PreviewRow('Email', contractorEmail.isEmpty ? '-' : contractorEmail),
                    ],
                  ),
                  SizedBox(height: Responsive.h(18)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionHeader('Items'),
                      _Pill(
                        label: 'Total Items: ${preview.totals.totalItems}',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(10)),

                  // ---------- Items table (Excel-style grid) ----------
                  _ItemsTable(
                    items: preview.items,
                    currency: currency,
                    number: number,
                  ),
                  sectionGap,

                  // ---- Other details ----
                  _SectionCard(
                    title: 'Other Details',
                    icon: Icons.tune_rounded,
                    child: Column(
                      children: [
                        LabeledField(
                          label: 'Handling Charge',
                          field: CustomTextField(
                            hint: 'Enter handling charge',
                            icon: Icons.currency_rupee,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            controller: handlingChargeCtrl,
                            // Handling charge: max 8 digits + 2 decimals
                            inputFormatters: DValidator.priceNumber,
                            onChanged: (_) => onHandlingChargeChanged(),
                          ),
                        ),
                        LabeledField(
                          label: 'Notes (optional)',
                          field: CustomTextField(
                            hint: 'e.g. Customer enquiry for new project',
                            icon: Icons.notes_outlined,
                            controller: notesCtrl,
                            inputFormatters: DValidator.textWithLimit,
                          ),
                        ),
                      ],
                    ),
                  ),
                  sectionGap,

                  // ---- Summary ----
                  _SectionCard(
                    title: 'Summary',
                    icon: Icons.calculate_outlined,
                    child: Column(
                      children: [
                        _TotalRow('Total Sq.Ft', number.format(preview.totals.totalSquareFeet)),
                        SizedBox(height: Responsive.h(10)),
                        _TotalRow('Subtotal', currency.format(preview.totals.subtotal)),
                        SizedBox(height: Responsive.h(10)),
                        _TotalRow(
                            'Handling Charge', currency.format(preview.totals.handlingCharge)),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                          child: const Divider(height: 1, color: AppColors.border),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Grand Total', style: AppTextStyles.bodyBold()),
                            SizedBox(width: Responsive.w(12)),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    currency.format(preview.totals.grandTotal),
                                    maxLines: 1,
                                    style: AppTextStyles.amount(color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (preview.totals.totalIncentive > 0) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                            child: const Divider(height: 1, color: AppColors.border),
                          ),
                          Row(
                            children: [
                              _IconBadge(Icons.percent, color: AppColors.success, size: 14),
                              SizedBox(width: Responsive.w(8)),
                              Expanded(
                                child: Text('Incentive Total',
                                    style: AppTextStyles.bodyBold(color: AppColors.success)),
                              ),
                              Text(
                                currency.format(preview.totals.totalIncentive),
                                style: AppTextStyles.bodyBold(color: AppColors.success),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: Responsive.h(8)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
          buildWhen: (prev, curr) =>
          prev.submitStatus != curr.submitStatus || prev.submitAction != curr.submitAction,
          builder: (context, state) {
            final submitting = state.submitStatus == SubmitStatus.submitting;
            final savingDraft = submitting && state.submitAction == 'save_quotation';
            final submittingForApproval = submitting && state.submitAction == 'submit';

            return BottomActionBar(
              left: OutlinedButton.icon(
                onPressed: submitting ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(Responsive.h(48)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  side: const BorderSide(color: AppColors.primary),
                  shape: buttonShape,
                ),
                icon: savingDraft
                    ? const SizedBox(
                    width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.request_quote_outlined,
                    size: 16, color: AppColors.primary),
                label: Text(
                  savingDraft ? 'Saving…' : 'Save as Quotation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(color: AppColors.primary),
                ),
              ),
              right: PrimaryButton(
                label: submittingForApproval ? 'Submitting…' : 'Submit for Approval',
                height: 48,
                onPressed: submitting ? null : onSubmit,
              ),
            );
          },
        ),
      ],
    );
  }
}

// =====================================================================
// ITEMS TABLE — Excel-style grid inside a bordered card.
// Columns stretch to the screen width; if the screen is too narrow the
// table scrolls sideways instead of squeezing the text.
// =====================================================================

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({
    required this.items,
    required this.currency,
    required this.number,
  });

  // Change `dynamic` to your preview item model type for strict typing.
  final List<dynamic> items;
  final NumberFormat currency;
  final NumberFormat number;

  static const double _padH = 8;
  static const double _padV = 10;

  Widget _head(String text, {bool right = false}) => Container(
    alignment: right ? Alignment.centerRight : Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
    child: Text(text, maxLines: 1, style: AppTextStyles.bodyBold()),
  );

  Widget _text(String text, {bool right = false, bool bold = false}) => Container(
    alignment: right ? Alignment.centerRight : Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
    child: Text(
      text,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: bold ? AppTextStyles.bodyBold() : AppTextStyles.body(),
    ),
  );

  Widget _num(String text, {bool bold = false, Color? color}) {
    final TextStyle style;
    if (bold) {
      style = color == null
          ? AppTextStyles.bodyBold()
          : AppTextStyles.bodyBold(color: color);
    } else {
      style = color == null ? AppTextStyles.body() : AppTextStyles.body(color: color);
    }
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.right,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBoxPieceData =
    items.any((item) => item.boxQuantity > 0 || item.pieceQuantity > 0);

    // label, minimum width, right-aligned?
    final cols = <_Col>[
      const _Col('Sl.No', 60),
      const _Col('Item', 200),
      const _Col('Company', 200),
      const _Col('Size', 120),
      const _Col('Qty', 80, right: true),
      const _Col('Unit', 120),
      if (hasBoxPieceData) const _Col('Box Qty', 85, right: true),
      if (hasBoxPieceData) const _Col('Piece Qty', 95, right: true),
      const _Col('MRP', 120, right: true),
      const _Col('Rate', 120, right: true),
      const _Col('Amount', 180, right: true),
      const _Col('Incentive', 130, right: true),
    ];

    final minTotal = cols.fold<double>(0, (a, c) => a + c.minWidth);
    final gridBorder = TableBorder.all(color: AppColors.border, width: 1);

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth =
          minTotal > constraints.maxWidth ? minTotal : constraints.maxWidth;

          final table = SizedBox(
            width: tableWidth,
            child: Table(
              border: gridBorder,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              // Flex by minimum width => columns stretch proportionally
              columnWidths: {
                for (var i = 0; i < cols.length; i++) i: FlexColumnWidth(cols[i].minWidth),
              },
              children: [
                // ---------- Header row ----------
                TableRow(
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
                  children: [for (final c in cols) _head(c.label, right: c.right)],
                ),

                // ---------- Data rows ----------
                ...List.generate(items.length, (i) {
                  final item = items[i];
                  final company = (item.productCompany as String).trim();
                  final size = (item.productSize as String).trim();

                  return TableRow(
                    decoration: BoxDecoration(
                      color: i.isOdd ? AppColors.background : Colors.white,
                    ),
                    children: [
                      _text('${i + 1}'),
                      _text(item.productName as String),
                      _text(company.isEmpty ? '-' : company),
                      _text(size.isEmpty ? '-' : size),
                      _num(number.format(item.quantity)),
                      _text(item.productUnit as String),
                      if (hasBoxPieceData)
                        _num(item.boxQuantity > 0 ? number.format(item.boxQuantity) : '-'),
                      if (hasBoxPieceData)
                        _num(item.pieceQuantity > 0 ? number.format(item.pieceQuantity) : '-'),
                      _num(item.mrp > 0 ? number.format(item.mrp) : '-'),
                      _num(number.format(item.rate)),
                      _num(currency.format(item.amount), bold: true),
                      _num(
                        item.incentiveAmount > 0 ? currency.format(item.incentiveAmount) : '-',
                        bold: true,
                        color: item.incentiveAmount > 0 ? AppColors.success : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
          );

          // Fits the screen -> no scroll. Too wide -> scroll sideways.
          if (minTotal <= constraints.maxWidth) return table;
          return SingleChildScrollView(scrollDirection: Axis.horizontal, child: table);
        },
      ),
    );
  }
}

class _Col {
  final String label;
  final double minWidth;
  final bool right;
  const _Col(this.label, this.minWidth, {this.right = false});
}

class _PreviewRow {
  final String label;
  final String value;
  _PreviewRow(this.label, this.value);
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.rows, this.icon});
  final String title;
  final IconData? icon;
  final List<_PreviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      icon: icon,
      child: Column(
        children: rows
            .map((r) => Padding(
          padding: EdgeInsets.only(bottom: Responsive.h(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Responsive.w(100),
                child: Text(r.label,
                    style: AppTextStyles.caption(color: AppColors.textSecondary)),
              ),
              Expanded(child: Text(r.value, style: AppTextStyles.body())),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    this.left,
    required this.right,
  });

  final Widget? left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          Responsive.w(20), Responsive.h(10), Responsive.w(20), Responsive.h(14)),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (left != null) ...[
            Expanded(child: left!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(child: right),
        ],
      ),
    );
  }
}