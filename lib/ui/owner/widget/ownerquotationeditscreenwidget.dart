import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/ownerbloc/ownerquatationedit/owner_qtneditbloc.dart';
import '../../../bloc/ownerbloc/ownerquatationedit/owner_qtneditestate.dart';
import '../../../bloc/ownerbloc/ownerquatationedit/owner_qtneditevent.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../widgets/custom_text_field.dart'; // CustomTextField (+ LabeledField if defined there)

const Color _redColor = Color(0xFFDC2626);

String ownerProductDisplayString(ActiveProductModel p) {
  final size = p.size.trim();
  return size.isEmpty
      ? '${p.name} — ${p.company}'
      : '${p.name} — ${p.company} — $size';
}

/// White card, radius 16, 1px border, no shadow.
BoxDecoration ownerCardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
);

/// Small rounded icon badge used in card titles.
class OwnerIconBadge extends StatelessWidget {
  const OwnerIconBadge(this.icon, {super.key, this.color, this.size = 16});
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

/// Small pill (e.g. "3 items").
class OwnerPill extends StatelessWidget {
  const OwnerPill({super.key, required this.label, required this.color});
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

/// Blue-bar section heading.
class OwnerSectionHeader extends StatelessWidget {
  const OwnerSectionHeader(this.title, {super.key});
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

/// White card header row (icon badge + title) with a divider underneath.
class OwnerCardTitle extends StatelessWidget {
  const OwnerCardTitle({super.key, required this.title, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            OwnerIconBadge(icon!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Card with a title bar and a padded body — wraps every form block.
class OwnerSectionCard extends StatelessWidget {
  const OwnerSectionCard({
    super.key,
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
      decoration: ownerCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OwnerCardTitle(title: title, icon: icon, trailing: trailing),
          Padding(
            padding: EdgeInsets.fromLTRB(Responsive.w(14), Responsive.h(14),
                Responsive.w(14), Responsive.h(6)),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class OwnerEditItem {
  const OwnerEditItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.company = '',
    this.size = '',
    this.mrp = 0,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    this.incentiveAmount = 0,
    this.incentiveEligible = false,
    this.incentiveReason,
  });

  final String id;
  final String productId;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double quantity;
  final double rate;
  final double amount;
  final double mrp;
  final double boxQuantity;
  final double pieceQuantity;
  final double incentiveAmount;
  final bool incentiveEligible;
  final String? incentiveReason;

  OwnerEditItem copyWith({String? company, double? mrp}) {
    return OwnerEditItem(
      id: id,
      productId: productId,
      name: name,
      unit: unit,
      quantity: quantity,
      rate: rate,
      amount: amount,
      company: company ?? this.company,
      size: size,
      mrp: mrp ?? this.mrp,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
      incentiveAmount: incentiveAmount,
      incentiveEligible: incentiveEligible,
      incentiveReason: incentiveReason,
    );
  }
}

class TotalRow extends StatelessWidget {
  const TotalRow(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyBold()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Customer section
// ---------------------------------------------------------------------------
class OwnerCustomerSection extends StatelessWidget {
  const OwnerCustomerSection({
    super.key,
    required this.phone,
    required this.name,
    required this.address,
    required this.email,
    required this.phoneValidator,
    required this.nameValidator,
    required this.addressValidator,
    required this.emailValidator,
  });

  final TextEditingController phone;
  final TextEditingController name;
  final TextEditingController address;
  final TextEditingController email;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) nameValidator;
  final String? Function(String?) addressValidator;
  final String? Function(String?) emailValidator;

  @override
  Widget build(BuildContext context) {
    return OwnerSectionCard(
      title: 'Customer Details',
      icon: Icons.groups_2_outlined,
      child: Column(
        children: [
          LabeledField(
            label: 'Contact No.',
            field: CustomTextField(
              hint: 'Enter phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              controller: phone,
              inputFormatters: DValidator.phoneNumber,
              validator: phoneValidator,
            ),
          ),
          LabeledField(
            label: 'Customer Name',
            field: CustomTextField(
              hint: 'Enter customer name',
              icon: Icons.groups_2_outlined,
              controller: name,
              validator: nameValidator,
            ),
          ),
          LabeledField(
            label: 'Address',
            field: CustomTextField(
              hint: 'Enter site address',
              icon: Icons.location_on_outlined,
              controller: address,
              validator: addressValidator,
            ),
          ),
          LabeledField(
            label: 'Email',
            field: CustomTextField(
              hint: 'Enter customer email',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              controller: email,
              validator: emailValidator,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contractor section (name/phone in their own Form for live cross-validation)
// ---------------------------------------------------------------------------
class OwnerContractorSection extends StatelessWidget {
  const OwnerContractorSection({
    super.key,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.email,
    required this.nameValidator,
    required this.phoneValidator,
    required this.emailValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final String? Function(String?) nameValidator;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) emailValidator;

  @override
  Widget build(BuildContext context) {
    return OwnerSectionCard(
      title: 'Contractor Details',
      icon: Icons.engineering_outlined,
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                LabeledField(
                  label: 'Contractor Name',
                  field: CustomTextField(
                    hint: 'Enter contractor name',
                    icon: Icons.engineering_outlined,
                    controller: name,
                    inputFormatters: DValidator.lettersOnly,
                    validator: nameValidator,
                  ),
                ),
                LabeledField(
                  label: 'Contact No.',
                  field: CustomTextField(
                    hint: 'Enter contractor phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: phone,
                    inputFormatters: DValidator.phoneNumber,
                    validator: phoneValidator,
                  ),
                ),
              ],
            ),
          ),
          LabeledField(
            label: 'Email (optional)',
            field: CustomTextField(
              hint: 'Enter contractor email',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              controller: email,
              validator: emailValidator,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit item form fields (fields only — the screen wraps them in a card)
// ---------------------------------------------------------------------------
class OwnerItemFormFields extends StatelessWidget {
  const OwnerItemFormFields({
    super.key,
    required this.formKey,
    required this.productField,
    required this.companyCtrl,
    required this.sizeCtrl,
    required this.unitCtrl,
    required this.mrpCtrl,
    required this.rateCtrl,
    required this.qtyCtrl,
    required this.boxQtyCtrl,
    required this.pieceQtyCtrl,
    required this.isBoxUnit,
    required this.onRateChanged,
    required this.onQtyChanged,
    required this.onPieceChanged,
  });

  final GlobalKey<FormState> formKey;
  final Widget productField;
  final TextEditingController companyCtrl;
  final TextEditingController sizeCtrl;
  final TextEditingController unitCtrl;
  final TextEditingController mrpCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController boxQtyCtrl;
  final TextEditingController pieceQtyCtrl;
  final bool isBoxUnit;
  final ValueChanged<String> onRateChanged;
  final ValueChanged<String> onQtyChanged;
  final ValueChanged<String> onPieceChanged;

  Widget autoField(String label, String hint, IconData icon, TextEditingController c,
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
    const decimal = TextInputType.numberWithOptions(decimal: true);
    final gap = SizedBox(width: Responsive.w(10));

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          productField,
          SizedBox(height: Responsive.h(10)),
          autoField('Company (auto)', 'Select a product first', Icons.factory_outlined,
              companyCtrl),
          Row(
            children: [
              Expanded(
                  child: autoField('Size (auto)', 'Select a product first',
                      Icons.straighten_outlined, sizeCtrl)),
              gap,
              Expanded(
                  child: autoField('Unit (auto)', 'Select a product first',
                      Icons.square_foot_outlined, unitCtrl)),
            ],
          ),
          // MRP and Rate share one row.
          Row(
            children: [
              Expanded(
                  child: autoField('MRP (auto)', 'MRP', Icons.currency_rupee, mrpCtrl,
                      keyboardType: TextInputType.number)),
              gap,
              Expanded(
                child: LabeledField(
                  label: 'Rate',
                  field: CustomTextField(
                    hint: 'Rate',
                    icon: Icons.currency_rupee,
                    keyboardType: decimal,
                    controller: rateCtrl,
                    inputFormatters: DValidator.priceNumber,
                    validator: (v) {
                      final n = double.tryParse((v ?? '').trim());
                      if (n == null || n <= 0) return 'Enter a valid rate';
                      if (n > DValidator.maxPrice) {
                        return 'Rate can have at most ${DValidator.maxPriceDigits} digits';
                      }
                      return null;
                    },
                    onChanged: onRateChanged,
                  ),
                ),
              ),
            ],
          ),
          LabeledField(
            label: 'Quantity',
            field: CustomTextField(
              hint: 'Enter quantity',
              icon: Icons.numbers_outlined,
              keyboardType: decimal,
              controller: qtyCtrl,
              inputFormatters: DValidator.quantityNumber,
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n <= 0) {
                  return isBoxUnit
                      ? 'Enter a valid box/piece quantity'
                      : 'Enter a valid quantity';
                }
                if (n > DValidator.maxQuantity) {
                  return 'Quantity can have at most ${DValidator.maxQuantityDigits} digits';
                }
                return null;
              },
              onChanged: onQtyChanged,
            ),
          ),
          if (isBoxUnit)
            Row(
              children: [
                Expanded(
                    child: autoField('Box Quantity (auto)', '0',
                        Icons.inventory_2_outlined, boxQtyCtrl,
                        keyboardType: TextInputType.number)),
                gap,
                Expanded(
                  child: LabeledField(
                    label: 'Piece Quantity',
                    field: CustomTextField(
                      hint: 'Enter piece qty',
                      icon: Icons.widgets_outlined,
                      keyboardType: decimal,
                      controller: pieceQtyCtrl,
                      inputFormatters: DValidator.quantityNumber,
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim());
                        if (n != null && n > DValidator.maxQuantity) {
                          return 'Piece quantity can have at most ${DValidator.maxQuantityDigits} digits';
                        }
                        return null;
                      },
                      onChanged: onPieceChanged,
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

class OwnerProductDropdown extends StatelessWidget {
  const OwnerProductDropdown({
    super.key,
    required this.searchCtrl,
    required this.focusNode,
    required this.selectedProduct,
    required this.showSuggestions,
    required this.onFieldTap,
    required this.onTextChanged,
    required this.onClear,
    required this.onSelected,
    this.excludedProductIds = const {},
  });

  final TextEditingController searchCtrl;
  final FocusNode focusNode;
  final ActiveProductModel? selectedProduct;
  final bool showSuggestions;
  final VoidCallback onFieldTap;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onClear;
  final ValueChanged<ActiveProductModel> onSelected;

  /// Product IDs already added to the quotation (hidden from suggestions).
  final Set<String> excludedProductIds;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerQuotationEditBloc, OwnerQuotationEditState>(
      buildWhen: (prev, curr) =>
      prev.products != curr.products || prev.productsStatus != curr.productsStatus,
      builder: (context, state) {
        if (state.productsStatus == OwnerEditLoadStatus.loading && state.products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.productsStatus == OwnerEditLoadStatus.failure && state.products.isEmpty) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: _redColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _redColor.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.productsError ?? 'Failed to load products.',
                    style: AppTextStyles.caption(color: _redColor),
                  ),
                ),
                TextButton(
                  onPressed: () => context
                      .read<OwnerQuotationEditBloc>()
                      .add(const OwnerEditActiveProductsRequested()),
                  child: Text('Retry', style: AppTextStyles.bodyBold()),
                ),
              ],
            ),
          );
        }

        final products = state.products;

        // Hide products already added to the quotation
        final available =
        products.where((p) => !excludedProductIds.contains(p.id)).toList();
        final allAdded = products.isNotEmpty && available.isEmpty;

        // When a product is already chosen the box shows its full text;
        // treat that as "no search" so tapping lists every product.
        final typed = searchCtrl.text.trim();
        final showingChosenText =
            selectedProduct != null && typed == ownerProductDisplayString(selectedProduct!);
        final query = showingChosenText ? '' : typed.toLowerCase();

        final filtered = query.isEmpty
            ? available
            : available.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.company.toLowerCase().contains(query) ||
              p.size.toLowerCase().contains(query) ||
              p.packing.toLowerCase().contains(query);
        }).toList();

        return LabeledField(
          label: 'Select Product',
          field: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: searchCtrl,
                focusNode: focusNode,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: 'Search product by name, company or size',
                  hintStyle: AppTextStyles.body(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: 'Clear',
                    onPressed: onClear,
                  ),
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
                validator: (v) =>
                    DValidator.validateDropdown('product', selectedProduct?.id),
                onTap: onFieldTap,
                onChanged: onTextChanged,
              ),
              if (showSuggestions) ...[
                SizedBox(height: Responsive.h(6)),
                Container(
                  constraints: BoxConstraints(maxHeight: Responsive.h(260)),
                  decoration: ownerCardDecoration(radius: 14),
                  clipBehavior: Clip.antiAlias,
                  child: filtered.isEmpty
                      ? Padding(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    child: Text(
                      allAdded
                          ? 'All products already added'
                          : 'No matching products',
                      style: AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  )
                      : ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final company = p.company.trim();
                      final size = p.size.trim();
                      final packing = p.packing.trim();

                      return ListTile(
                        dense: true,
                        isThreeLine: true,
                        leading: const OwnerIconBadge(
                            Icons.inventory_2_outlined,
                            size: 14),
                        title: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold(),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (company.isNotEmpty)
                              Text(
                                company,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(
                                    color: AppColors.textSecondary),
                              ),
                            if (size.isNotEmpty || packing.isNotEmpty) ...[
                              SizedBox(height: Responsive.h(4)),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (size.isNotEmpty)
                                    OwnerPill(
                                      label: 'Size: $size',
                                      color: AppColors.primary,
                                    ),
                                  if (packing.isNotEmpty)
                                    OwnerPill(
                                      label: 'Packing: $packing',
                                      color: Colors.teal,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        onTap: () => onSelected(p),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
// ---------------------------------------------------------------------------
// "Editing item #n" banner
// ---------------------------------------------------------------------------
class OwnerEditingBanner extends StatelessWidget {
  const OwnerEditingBanner({super.key, required this.itemNumber, required this.onCancel});

  final int itemNumber;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(10)),
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
          SizedBox(width: Responsive.w(6)),
          Expanded(
              child: Text('Editing item #$itemNumber',
                  style: AppTextStyles.caption(color: AppColors.textSecondary))),
          InkWell(
            onTap: onCancel,
            child: Text('Cancel', style: AppTextStyles.bodyBold(color: _redColor)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Other details (handling charge + notes)
// ---------------------------------------------------------------------------
class OwnerOtherDetailsSection extends StatelessWidget {
  const OwnerOtherDetailsSection({
    super.key,
    required this.handlingCharge,
    required this.notes,
    required this.handlingValidator,
    required this.onHandlingChanged,
  });

  final TextEditingController handlingCharge;
  final TextEditingController notes;
  final String? Function(String?) handlingValidator;
  final ValueChanged<String> onHandlingChanged;

  @override
  Widget build(BuildContext context) {
    return OwnerSectionCard(
      title: 'Other Details',
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          LabeledField(
            label: 'Handling Charge',
            field: CustomTextField(
              hint: 'Enter handling charge',
              icon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: handlingCharge,
              inputFormatters: DValidator.priceNumber,
              validator: handlingValidator,
              onChanged: onHandlingChanged,
            ),
          ),
          LabeledField(
            label: 'Notes (optional)',
            field: CustomTextField(
              hint: 'e.g. Customer enquiry for new project',
              icon: Icons.notes_outlined,
              controller: notes,
              inputFormatters: DValidator.textWithLimit,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Totals card (Summary)
// ---------------------------------------------------------------------------
class OwnerTotalsCard extends StatelessWidget {
  const OwnerTotalsCard({
    super.key,
    required this.totalSqft,
    required this.mrpTotal,
    required this.itemsTotal,
    required this.handling,
    required this.grandTotal,
    required this.currency,
    required this.number,
  });

  final double totalSqft;
  final double mrpTotal;
  final double itemsTotal;
  final double handling;
  final double grandTotal;
  final NumberFormat currency;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: Responsive.h(10));
    return Container(
      width: double.infinity,
      decoration: ownerCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OwnerCardTitle(title: 'Summary', icon: Icons.calculate_outlined),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(
              children: [
                TotalRow('Total Sq.Ft', number.format(totalSqft)),
                gap,
                TotalRow('Items Total', currency.format(itemsTotal)),
                gap,
                TotalRow('Handling Charge', currency.format(handling)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  child: const Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total', style: AppTextStyles.bodyBold()),
                    Text(currency.format(grandTotal),
                        style: AppTextStyles.amount(color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Incentive total card
// ---------------------------------------------------------------------------
class OwnerIncentiveTotalCard extends StatelessWidget {
  const OwnerIncentiveTotalCard({super.key, required this.total, required this.currency});

  final double total;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(14)),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              OwnerIconBadge(Icons.percent_rounded, color: AppColors.success),
              SizedBox(width: Responsive.w(10)),
              Text('Incentive Total',
                  style: AppTextStyles.bodyBold(color: AppColors.success)),
            ],
          ),
          Text(currency.format(total),
              style: AppTextStyles.amount(color: AppColors.success)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Incentive preview (per item, while adding/editing)
// ---------------------------------------------------------------------------
class OwnerIncentivePreviewCard extends StatelessWidget {
  const OwnerIncentivePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return BlocBuilder<OwnerQuotationEditBloc, OwnerQuotationEditState>(
      buildWhen: (prev, curr) =>
      prev.incentiveStatus != curr.incentiveStatus ||
          prev.incentive != curr.incentive ||
          prev.incentiveError != curr.incentiveError,
      builder: (context, state) {
        if (state.incentiveStatus == OwnerEditLoadStatus.initial) {
          return const SizedBox.shrink();
        }

        BoxDecoration neutral() => ownerCardDecoration(radius: 14);

        if (state.incentiveStatus == OwnerEditLoadStatus.loading) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: neutral(),
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

        if (state.incentiveStatus == OwnerEditLoadStatus.failure) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: _redColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _redColor.withOpacity(0.25)),
            ),
            child: Text(
              state.incentiveError ?? 'Couldn\'t fetch incentive for this item.',
              style: AppTextStyles.caption(color: _redColor),
            ),
          );
        }

        final incentive = state.incentive;
        if (incentive == null) return const SizedBox.shrink();

        if (!incentive.isEligible) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: neutral(),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.percent, size: 16, color: AppColors.success),
                      SizedBox(width: Responsive.w(6)),
                      Text('Incentive on this item',
                          style: AppTextStyles.bodyBold(color: AppColors.success)),
                    ],
                  ),
                  Text(currency.format(incentive.totalIncentive),
                      style: AppTextStyles.bodyBold(color: AppColors.success)),
                ],
              ),
              if (incentive.eligibilityReason.isNotEmpty) ...[
                SizedBox(height: Responsive.h(4)),
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

// ---------------------------------------------------------------------------
// Item tile
// ---------------------------------------------------------------------------
class OwnerEditItemTile extends StatelessWidget {
  const OwnerEditItemTile({
    super.key,
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.isEditing = false,
    this.isRemoving = false,
    this.showIncentive = true,
  });

  final int serialNo;
  final OwnerEditItem item;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEditing;
  final bool isRemoving;
  final bool showIncentive;

  @override
  Widget build(BuildContext context) {
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
            child: Text('$serialNo',
                style: AppTextStyles.caption(color: AppColors.primary)),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(2)),
                if (item.size.isNotEmpty || item.company.isNotEmpty)
                  Text(
                    '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}',
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                  ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Qty: ${item.quantity.toStringAsFixed(0)} ${item.unit}'
                      '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
                      '   Rate: ${item.rate.toStringAsFixed(0)}',
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
                if (showIncentive && item.incentiveEligible && item.incentiveAmount > 0) ...[
                  SizedBox(height: Responsive.h(2)),
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
                    onTap: isRemoving ? null : onEdit,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: isRemoving ? AppColors.textHint : AppColors.primary,
                    ),
                  ),
                  SizedBox(width: Responsive.w(14)),
                  if (isRemoving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    InkWell(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline, size: 20, color: _redColor),
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