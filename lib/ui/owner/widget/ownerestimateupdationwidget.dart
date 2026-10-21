import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/validator/validationfile.dart';
import '../../../widgets/custom_text_field.dart'; // CustomTextField

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String estimateFormatQty(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

bool _parseBool(dynamic v) {
  if (v is bool) return v;
  final s = v?.toString().toLowerCase() ?? '';
  return s == '1' || s == 'true';
}

String estimateProductDisplayString(EstimateActiveProduct p) =>
    p.company.isEmpty ? p.name : '${p.name} — ${p.company}';

// ---------------------------------------------------------------------------
// Shared styles
// ---------------------------------------------------------------------------
TextStyle get _inputStyle => AppTextStyles.body();
TextStyle get _captionStyle => AppTextStyles.caption(color: AppColors.textSecondary);
TextStyle get _hintStyle => AppTextStyles.body(color: AppColors.textHint);
TextStyle get _errorStyle => AppTextStyles.caption(color: AppColors.error);

ThemeData _fieldTheme(BuildContext context) {
  final base = Theme.of(context);
  return base.copyWith(
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      labelStyle: _hintStyle,
      floatingLabelStyle: _hintStyle,
      hintStyle: _hintStyle,
      prefixStyle: _inputStyle,
      suffixStyle: _inputStyle,
      errorStyle: _errorStyle,
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
    textTheme: base.textTheme.copyWith(
      titleMedium: _inputStyle,
      bodyLarge: _inputStyle,
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared look (same as the Owner Quotation Edit screen)
// ---------------------------------------------------------------------------

/// White card, radius 16, 1px border, no shadow.
BoxDecoration estimateCardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
);

/// Small rounded icon badge used in card titles.
class EstimateIconBadge extends StatelessWidget {
  const EstimateIconBadge(this.icon, {super.key, this.color, this.size = 16});
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
class EstimatePill extends StatelessWidget {
  const EstimatePill({super.key, required this.label, required this.color});
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
class EstimateSectionHeader extends StatelessWidget {
  const EstimateSectionHeader(this.title, {super.key});
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

/// Card header row (icon badge + title) with a divider underneath.
class EstimateCardTitle extends StatelessWidget {
  const EstimateCardTitle({super.key, required this.title, this.icon, this.trailing});
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
            EstimateIconBadge(icon!),
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
class EstimateSectionCard extends StatelessWidget {
  const EstimateSectionCard({
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
      decoration: estimateCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EstimateCardTitle(title: title, icon: icon, trailing: trailing),
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
class EstimateActiveProduct {
  final String id;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double rate;
  final double mrp;
  final bool isBoxUnit;

  const EstimateActiveProduct({
    required this.id,
    required this.name,
    this.company = '',
    this.size = '',
    this.unit = '',
    required this.rate,
    this.mrp = 0,
    this.isBoxUnit = false,
  });

  factory EstimateActiveProduct.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return EstimateActiveProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['product_name'] ?? '').toString(),
      company: (json['company'] ?? json['company_name'] ?? '').toString(),
      size: (json['size'] ?? json['product_size'] ?? '').toString(),
      unit: (json['unit'] ?? json['product_unit'] ?? '').toString(),
      rate: parseNum(json['rate'] ?? json['default_rate'] ?? json['selling_rate']),
      mrp: parseNum(json['mrp']),
      isBoxUnit: _parseBool(
        json['is_box_unit'] ?? json['isBoxUnit'] ?? json['box_unit'],
      ),
    );
  }
}

class EstimateEditItem {
  const EstimateEditItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.amount,
    this.company = '',
    this.size = '',
    this.unit = '',
    required this.quantity,
    required this.rate,
    this.mrp = 0,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    this.isBoxUnit = false,
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
  final bool isBoxUnit;
  final double incentiveAmount;
  final bool incentiveEligible;
  final String? incentiveReason;

  EstimateEditItem copyWith({
    String? company,
    String? size,
    String? unit,
    double? mrp,
    bool? isBoxUnit,
    double? quantity,
    double? rate,
    double? boxQuantity,
    double? pieceQuantity,
    double? amount,
  }) {
    return EstimateEditItem(
      id: id,
      productId: productId,
      name: name,
      amount: amount ?? this.amount,
      company: company ?? this.company,
      size: size ?? this.size,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      mrp: mrp ?? this.mrp,
      boxQuantity: boxQuantity ?? this.boxQuantity,
      pieceQuantity: pieceQuantity ?? this.pieceQuantity,
      isBoxUnit: isBoxUnit ?? this.isBoxUnit,
      incentiveAmount: incentiveAmount,
      incentiveEligible: incentiveEligible,
      incentiveReason: incentiveReason,
    );
  }
}

// ---------------------------------------------------------------------------
// Customer section
// ---------------------------------------------------------------------------
class EstimateCustomerSection extends StatelessWidget {
  const EstimateCustomerSection({
    super.key,
    required this.phone,
    required this.name,
    required this.address,
    required this.email,
    required this.phoneValidator,
    required this.nameValidator,
    required this.emailValidator,
  });

  final TextEditingController phone;
  final TextEditingController name;
  final TextEditingController address;
  final TextEditingController email;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) nameValidator;
  final String? Function(String?) emailValidator;

  @override
  Widget build(BuildContext context) {
    return EstimateSectionCard(
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
// Contractor section
// ---------------------------------------------------------------------------
class EstimateContractorSection extends StatelessWidget {
  const EstimateContractorSection({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.nameValidator,
    required this.phoneValidator,
    required this.emailValidator,
    required this.onChanged,
  });

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final String? Function(String?) nameValidator;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) emailValidator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return EstimateSectionCard(
      title: 'Contractor Details',
      icon: Icons.engineering_outlined,
      child: Column(
        children: [
          LabeledField(
            label: 'Contractor Name',
            field: CustomTextField(
              hint: 'Enter contractor name',
              icon: Icons.engineering_outlined,
              controller: name,
              validator: nameValidator,
              onChanged: onChanged,
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
              onChanged: onChanged,
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
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Other details (handling charge + notes)
// ---------------------------------------------------------------------------
class EstimateOtherDetailsSection extends StatelessWidget {
  const EstimateOtherDetailsSection({
    super.key,
    required this.handlingCharge,
    required this.notes,
    required this.handlingValidator,
    this.onHandlingChanged,
  });

  final TextEditingController handlingCharge;
  final TextEditingController notes;
  final String? Function(String?) handlingValidator;
  final ValueChanged<String>? onHandlingChanged;

  @override
  Widget build(BuildContext context) {
    return EstimateSectionCard(
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
// Add / Edit item form fields (fields only — the screen wraps them in a card)
// ---------------------------------------------------------------------------
class EstimateItemFormFields extends StatelessWidget {
  const EstimateItemFormFields({
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
    const decimal = TextInputType.numberWithOptions(decimal: true);
    final gap = SizedBox(width: Responsive.w(10));

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          productField,
          SizedBox(height: Responsive.h(10)),
          _autoField('Company (auto)', 'Select a product first', Icons.factory_outlined,
              companyCtrl),
          Row(
            children: [
              Expanded(
                  child: _autoField('Size (auto)', 'Select a product first',
                      Icons.straighten_outlined, sizeCtrl)),
              gap,
              Expanded(
                  child: _autoField('Unit (auto)', 'Select a product first',
                      Icons.square_foot_outlined, unitCtrl)),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: _autoField('MRP (auto)', 'MRP', Icons.currency_rupee, mrpCtrl,
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
            label: isBoxUnit ? 'Quantity (Box)' : 'Quantity',
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
                    child: _autoField('Box Quantity (auto)', '0', Icons.inventory_2_outlined,
                        boxQtyCtrl,
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

// ---------------------------------------------------------------------------
// Product search (field + suggestion list)
//
// UPDATED: products whose IDs are in [excludedProductIds] (i.e. already added
// to the estimate) are hidden from the suggestion list. The screen leaves the
// item currently being edited out of that set, so it still shows while editing.
// ---------------------------------------------------------------------------
class EstimateProductSearch extends StatelessWidget {
  const EstimateProductSearch({
    super.key,
    required this.loading,
    required this.products,
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

  final bool loading;
  final List<EstimateActiveProduct> products;
  final TextEditingController searchCtrl;
  final FocusNode focusNode;
  final EstimateActiveProduct? selectedProduct;
  final bool showSuggestions;
  final VoidCallback onFieldTap;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onClear;
  final ValueChanged<EstimateActiveProduct> onSelected;

  /// Product IDs already added to the estimate (hidden from suggestions).
  final Set<String> excludedProductIds;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final typed = searchCtrl.text.trim();
    final showingChosenText =
        selectedProduct != null && typed == estimateProductDisplayString(selectedProduct!);
    final query = showingChosenText ? '' : typed.toLowerCase();

    // Hide products already added to the estimate
    final available =
    products.where((p) => !excludedProductIds.contains(p.id)).toList();
    final allAdded = products.isNotEmpty && available.isEmpty;

    final filtered = query.isEmpty
        ? available
        : available.where((p) {
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
            style: _inputStyle,
            decoration: InputDecoration(
              hintText: 'Search product by name',
              hintStyle: _hintStyle,
              errorStyle: _errorStyle,
              prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              suffixIcon: searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                icon: Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
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
            validator: (v) => DValidator.validateDropdown('product', selectedProduct?.id),
            onTap: onFieldTap,
            onChanged: onTextChanged,
          ),
          if (showSuggestions) ...[
            SizedBox(height: Responsive.h(6)),
            Container(
              constraints: BoxConstraints(maxHeight: Responsive.h(220)),
              decoration: estimateCardDecoration(radius: 14),
              clipBehavior: Clip.antiAlias,
              child: filtered.isEmpty
                  ? Padding(
                padding: EdgeInsets.all(Responsive.w(14)),
                child: Text(
                  allAdded ? 'All products already added' : 'No matching products',
                  style: _captionStyle,
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
                  return ListTile(
                    dense: true,
                    leading: const EstimateIconBadge(Icons.inventory_2_outlined,
                        size: 14),
                    title: Text(
                      p.name,
                      style: AppTextStyles.bodyBold(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${p.company}${p.size.isNotEmpty ? ' • ${p.size}' : ''}',
                      style: _captionStyle,
                      maxLines: 1,
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
  }
}

// ---------------------------------------------------------------------------
// "Editing item #n" banner
// ---------------------------------------------------------------------------
class EstimateEditingBanner extends StatelessWidget {
  const EstimateEditingBanner({super.key, required this.itemNumber, required this.onCancel});

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
          Expanded(child: Text('Editing item #$itemNumber', style: _captionStyle)),
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
// Totals card (Summary)
// ---------------------------------------------------------------------------
class EstimateTotalRow extends StatelessWidget {
  const EstimateTotalRow(this.label, this.value, {super.key});
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

class EstimateTotalsCard extends StatelessWidget {
  const EstimateTotalsCard({
    super.key,
    required this.totalSqft,
    required this.itemsTotal,
    required this.handling,
    required this.grandTotal,
    required this.currency,
    required this.number,
  });

  final double totalSqft;
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
      decoration: estimateCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EstimateCardTitle(title: 'Summary', icon: Icons.calculate_outlined),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(
              children: [
                EstimateTotalRow('Total Sq.Ft', number.format(totalSqft)),
                gap,
                EstimateTotalRow('Items Total', currency.format(itemsTotal)),
                gap,
                EstimateTotalRow('Handling Charge', currency.format(handling)),
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
// Item tile
// ---------------------------------------------------------------------------
class EstimateItemTile extends StatelessWidget {
  const EstimateItemTile({
    super.key,
    required this.serialNo,
    required this.item,
    required this.currency,
    required this.onDelete,
    required this.onEdit,
    this.isEditing = false,
  });

  final int serialNo;
  final EstimateEditItem item;
  final NumberFormat currency;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isEditing;

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
                Text(item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(2)),
                if (item.size.isNotEmpty || item.company.isNotEmpty)
                  Text(
                    '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _captionStyle,
                  ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Qty: ${estimateFormatQty(item.quantity)}${item.unit.isNotEmpty ? ' ${item.unit}' : ''}'
                      '${item.mrp > 0 ? '   MRP: ${estimateFormatQty(item.mrp)}' : ''}'
                      '   Rate: ${estimateFormatQty(item.rate)}',
                  style: _captionStyle,
                ),
                if (item.isBoxUnit) ...[
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    'Box: ${estimateFormatQty(item.boxQuantity)}   Piece: ${estimateFormatQty(item.pieceQuantity)}',
                    style: _captionStyle,
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

// ---------------------------------------------------------------------------
// Label + field wrapper
// ---------------------------------------------------------------------------
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.field});
  final String label;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _captionStyle),
          SizedBox(height: Responsive.h(4)),
          Theme(data: _fieldTheme(context), child: field),
        ],
      ),
    );
  }
}