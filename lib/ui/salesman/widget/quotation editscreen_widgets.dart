import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/salemanbloc/estimate/salesman_estimate_bloc.dart';
import '../../../bloc/salemanbloc/estimate/salesmanestimate_event.dart';
import '../../../bloc/salemanbloc/estimate/salesmanestimate_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../widgets/custom_text_field.dart'; // CustomTextField (+ LabeledField if defined there)

String qeProductDisplayString(ActiveProductModel p) => '${p.name} — ${p.company}';

class EditItem {
  const EditItem({
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

  EditItem copyWith({String? company, double? mrp}) {
    return EditItem(
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

class QeTotalRow extends StatelessWidget {
  const QeTotalRow(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: AppTextStyles.body()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Customer section
// ---------------------------------------------------------------------------
class QeCustomerSection extends StatelessWidget {
  const QeCustomerSection({
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
    return Column(
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
          label: 'Party Name',
          field: CustomTextField(
            hint: 'Enter party name',
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
    );
  }
}

// ---------------------------------------------------------------------------
// Contractor section
// ---------------------------------------------------------------------------
class QeContractorSection extends StatelessWidget {
  const QeContractorSection({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.nameValidator,
    required this.phoneValidator,
    required this.emailValidator,
    required this.onNamePhoneChanged,
  });

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final String? Function(String?) nameValidator;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) emailValidator;
  final ValueChanged<String> onNamePhoneChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabeledField(
          label: 'Contractor Name',
          field: CustomTextField(
            hint: 'Enter contractor name',
            icon: Icons.engineering_outlined,
            controller: name,
            inputFormatters: DValidator.lettersOnly,
            validator: nameValidator,
            onChanged: onNamePhoneChanged,
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
            onChanged: onNamePhoneChanged,
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
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit item form fields
// ---------------------------------------------------------------------------
class QeItemFormFields extends StatelessWidget {
  const QeItemFormFields({
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
    required this.onMrpChanged,
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
  final ValueChanged<String> onMrpChanged;
  final ValueChanged<String> onRateChanged;
  final ValueChanged<String> onQtyChanged;
  final ValueChanged<String> onPieceChanged;

  @override
  Widget build(BuildContext context) {
    const decimal = TextInputType.numberWithOptions(decimal: true);

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          productField,
          SizedBox(height: Responsive.h(10)),
          LabeledField(
            label: 'Company (auto)',
            field: IgnorePointer(
              child: CustomTextField(
                hint: 'Select a product first',
                icon: Icons.factory_outlined,
                controller: companyCtrl,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Size (auto)',
                  field: CustomTextField(
                    hint: 'e.g. 600x1200',
                    icon: Icons.straighten_outlined,
                    controller: sizeCtrl,
                    inputFormatters: DValidator.textWithLimit,
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: LabeledField(
                  label: 'Unit (auto)',
                  field: CustomTextField(
                    hint: 'e.g. sqft',
                    icon: Icons.square_foot_outlined,
                    controller: unitCtrl,
                    inputFormatters: DValidator.textWithLimit,
                  ),
                ),
              ),
            ],
          ),
          LabeledField(
            label: 'MRP (auto)',
            field: CustomTextField(
              hint: '0',
              icon: Icons.currency_rupee,
              keyboardType: decimal,
              controller: mrpCtrl,
              inputFormatters: DValidator.priceNumber,
              validator: (v) =>
                  DValidator.validateOptionalNumber('MRP', v, max: DValidator.maxPrice),
              onChanged: onMrpChanged,
            ),
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
                  child: LabeledField(
                    label: 'Box Quantity (auto)',
                    field: IgnorePointer(
                      child: CustomTextField(
                        hint: '0',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        controller: boxQtyCtrl,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.w(10)),
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
          LabeledField(
            label: 'Rate',
            field: CustomTextField(
              hint: 'Enter rate per unit',
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product search dropdown
// ---------------------------------------------------------------------------
class QeProductDropdown extends StatelessWidget {
  const QeProductDropdown({
    super.key,
    required this.searchCtrl,
    required this.focusNode,
    required this.selectedProduct,
    required this.editingProductId,
    required this.showSuggestions,
    required this.onFieldTap,
    required this.onTextChanged,
    required this.onClear,
    required this.onSelected,
  });

  final TextEditingController searchCtrl;
  final FocusNode focusNode;
  final ActiveProductModel? selectedProduct;

  /// Product id of the item being edited (used so validation doesn't block
  /// items that have no catalog match).
  final String? editingProductId;
  final bool showSuggestions;
  final VoidCallback onFieldTap;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onClear;
  final ValueChanged<ActiveProductModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
      buildWhen: (prev, curr) =>
      prev.products != curr.products || prev.productsStatus != curr.productsStatus,
      builder: (context, state) {
        if (state.productsStatus == LoadStatus.loading && state.products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.productsStatus == LoadStatus.failure && state.products.isEmpty) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
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
                  onPressed: () =>
                      context.read<SalesmanEstimateBloc>().add(const ActiveProductsRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final products = state.products;
        final typed = searchCtrl.text.trim();
        final showingChosenText =
            selectedProduct != null && typed == qeProductDisplayString(selectedProduct!);
        final query = showingChosenText ? '' : typed.toLowerCase();

        final filtered = query.isEmpty
            ? products
            : products.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.company.toLowerCase().contains(query) ||
              p.size.toLowerCase().contains(query);
        }).toList();

        return LabeledField(
          label: 'Select Product',
          field: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: searchCtrl,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search product by name',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: 'Clear',
                    onPressed: onClear,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (v) => DValidator.validateDropdown(
                  'product',
                  selectedProduct?.id ?? editingProductId,
                ),
                onTap: onFieldTap,
                onChanged: onTextChanged,
              ),
              if (showSuggestions) ...[
                SizedBox(height: Responsive.h(6)),
                Container(
                  constraints: BoxConstraints(maxHeight: Responsive.h(220)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: filtered.isEmpty
                      ? Padding(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    child: Text('No matching products', style: AppTextStyles.caption()),
                  )
                      : ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.inventory_2_outlined, size: 18),
                        title: Text(p.name, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          '${p.company}${p.size.isNotEmpty ? ' • ${p.size}' : ''}',
                          overflow: TextOverflow.ellipsis,
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
class QeEditingBanner extends StatelessWidget {
  const QeEditingBanner({super.key, required this.itemNumber, required this.onCancel});

  final int itemNumber;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(8)),
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
          SizedBox(width: Responsive.w(6)),
          Expanded(child: Text('Editing item #$itemNumber', style: AppTextStyles.caption())),
          InkWell(
            onTap: onCancel,
            child: Text('Cancel', style: AppTextStyles.bodyBold(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Other details (handling charge + notes)
// ---------------------------------------------------------------------------
class QeOtherDetailsSection extends StatelessWidget {
  const QeOtherDetailsSection({
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
    return Column(
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
    );
  }
}

// ---------------------------------------------------------------------------
// Totals card
// ---------------------------------------------------------------------------
class QeTotalsCard extends StatelessWidget {
  const QeTotalsCard({
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
    final gap = SizedBox(height: Responsive.h(6));
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          gap,
          QeTotalRow('Total Sq.Ft', number.format(totalSqft)),
          if (mrpTotal > 0) ...[gap, QeTotalRow('Total MRP', currency.format(mrpTotal))],
          gap,
          QeTotalRow('Items Total', currency.format(itemsTotal)),
          gap,
          QeTotalRow('Handling Charge', currency.format(handling)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: AppTextStyles.h3()),
              Text(currency.format(grandTotal),
                  style: AppTextStyles.h2(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Incentive total card
// ---------------------------------------------------------------------------
class QeIncentiveTotalCard extends StatelessWidget {
  const QeIncentiveTotalCard({super.key, required this.total, required this.currency});

  final double total;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
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
              Icon(Icons.percent, size: 18, color: AppColors.success),
              SizedBox(width: Responsive.w(8)),
              Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
            ],
          ),
          Text(currency.format(total), style: AppTextStyles.h3(color: AppColors.success)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Incentive preview (live /quotations/product-incentive result)
// ---------------------------------------------------------------------------
class IncentivePreviewCard extends StatelessWidget {
  const IncentivePreviewCard({super.key});

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
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: Responsive.w(10)),
                Text('Checking incentive…', style: AppTextStyles.caption()),
              ],
            ),
          );
        }

        if (state.incentiveStatus == LoadStatus.failure) {
          return Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
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
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
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
                    style: AppTextStyles.caption(),
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
            borderRadius: BorderRadius.circular(12),
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
                Text(incentive.eligibilityReason, style: AppTextStyles.caption()),
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
class EditItemTile extends StatelessWidget {
  const EditItemTile({
    super.key,
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.isEditing = false,
    this.isRemoving = false,
  });

  final int serialNo;
  final EditItem item;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEditing;
  final bool isRemoving;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(10)),
      padding: EdgeInsets.all(Responsive.w(12)),
      decoration: BoxDecoration(
        color: isEditing ? AppColors.primary.withOpacity(0.06) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isEditing ? AppColors.primary : AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.surfaceAlt,
            child: Text('$serialNo', style: AppTextStyles.caption()),
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
                    style: AppTextStyles.caption(),
                  ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Qty: ${item.quantity.toStringAsFixed(0)} ${item.unit}'
                      '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
                      '   Rate: ${item.rate.toStringAsFixed(0)}',
                  style: AppTextStyles.caption(),
                ),
                if (item.incentiveEligible && item.incentiveAmount > 0) ...[
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