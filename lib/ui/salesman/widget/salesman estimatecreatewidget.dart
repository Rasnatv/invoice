
// =====================================================================
// STEP 2 — ADD ITEMS
// =====================================================================
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
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';

class AddItemsSteps extends StatelessWidget {
  const AddItemsSteps({
    required this.selectedProduct,
    required this.onProductSelected,
    required this.itemCompanyCtrl,
    required this.itemSizeCtrl,
    required this.itemUnitCtrl,
    required this.itemMrpCtrl,
    required this.itemQtyCtrl,
    required this.itemRateCtrl,
    required this.currentAmount,
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
  final TextEditingController itemMrpCtrl;
  final TextEditingController itemQtyCtrl;
  final TextEditingController itemRateCtrl;
  final double currentAmount;

  /// Fired on every Quantity keystroke.
  final VoidCallback onQuantityChanged;

  /// Fired when Rate changes, so the parent can (re)schedule a fresh
  /// live-incentive lookup.
  final VoidCallback onQtyRateChanged;

  final List<AddedItem> items;
  final int? editingIndex;
  final VoidCallback onAddItem;
  final void Function(int) onEditItem;
  final VoidCallback onCancelEdit;
  final void Function(int) onRemoveItem;
  final VoidCallback onCancel;
  final VoidCallback onSaveItems;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  BlocBuilder<SalesmanEstimateBloc, SalesmanEstimateState>(
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
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Search product by name',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: controller.text.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      controller.clear();
                                      onProductSelected(null);
                                      setLocalState(() {});
                                    },
                                  )
                                      : null,
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
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: Responsive.h(260),
                                    ),
                                    child: options.isEmpty
                                        ? Padding(
                                      padding: EdgeInsets.all(Responsive.w(14)),
                                      child: Text('No matching products', style: AppTextStyles.caption()),
                                    )
                                        : ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      separatorBuilder: (_, __) => const Divider(height: 1),
                                      itemBuilder: (context, i) {
                                        final p = options.elementAt(i);
                                        return ListTile(
                                          dense: true,
                                          title: Text(p.name, overflow: TextOverflow.ellipsis),
                                          subtitle: Text(p.company, overflow: TextOverflow.ellipsis),
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

                  SizedBox(height: Responsive.h(10)),

                  // ---- Auto-filled, read-only product attributes ----
                  LabeledField(
                    label: 'Company (auto)',
                    field: IgnorePointer(
                      child: CustomTextField(
                        hint: 'Select a product first',
                        icon: Icons.factory_outlined,
                        controller: itemCompanyCtrl,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Size (auto)',
                          field: IgnorePointer(
                            child: CustomTextField(
                              hint: 'Select a product first',
                              icon: Icons.straighten_outlined,
                              controller: itemSizeCtrl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        child: LabeledField(
                          label: 'Unit (auto)',
                          field: IgnorePointer(
                            child: CustomTextField(
                              hint: 'Select a product first',
                              icon: Icons.square_foot_outlined,
                              controller: itemUnitCtrl,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  LabeledField(
                    label: 'MRP (auto)',
                    field: IgnorePointer(
                      child: CustomTextField(
                        hint: 'Select a product first',
                        icon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        controller: itemMrpCtrl,
                      ),
                    ),
                  ),

                  // Quantity is the single manual entry for every product
                  // — box-unit or not. Box Qty / Piece Qty are no longer
                  // shown in the UI; they're still computed and sent to
                  // the API silently in the background.
                  LabeledField(
                    label: 'Quantity',
                    field: CustomTextField(
                      hint: 'Enter quantity',
                      icon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                      controller: itemQtyCtrl,
                      inputFormatters: DValidator.decimalNumber,
                      onChanged: (_) {
                        setLocalState(() {});
                        onQuantityChanged();
                      },
                    ),
                  ),
                  LabeledField(
                    label: 'Rate',
                    field: CustomTextField(
                      hint: 'Enter rate per unit',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      controller: itemRateCtrl,
                      inputFormatters: DValidator.decimalNumber,
                      onChanged: (_) {
                        setLocalState(() {});
                        onQtyRateChanged();
                      },
                    ),
                  ),
                  SizedBox(height: Responsive.h(6)),
                  Container(
                    padding: EdgeInsets.all(Responsive.w(12)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount', style: AppTextStyles.bodyBold()),
                        Text(currency.format(currentAmount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
                      ],
                    ),
                  ),

                  // Live incentive preview for the item currently being
                  // entered — only shown once a product is selected.
                  if (selectedProduct != null) ...[
                    SizedBox(height: Responsive.h(8)),
                    const _IncentivePreviewCard(),
                  ],

                  SizedBox(height: Responsive.h(14)),

                  if (editingIndex != null) ...[
                    Container(
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
                          Expanded(
                            child: Text(
                              'Editing item #${editingIndex! + 1}',
                              style: AppTextStyles.caption(),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              onCancelEdit();
                              setLocalState(() {});
                            },
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.bodyBold(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onAddItem();
                        setLocalState(() {});
                      },
                      icon: Icon(
                        editingIndex != null ? Icons.save_outlined : Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(editingIndex != null ? 'Update Item' : 'Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(20)),

                  Text('Items Added (${items.length})', style: AppTextStyles.h3()),
                  SizedBox(height: Responsive.h(10)),

                  if (items.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
                      child: Center(
                        child: Text(
                          'No items added yet',
                          style: AppTextStyles.body(color: AppColors.textHint),
                        ),
                      ),
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel'),
              ),
              right: PrimaryButton(label: 'Save Items', height: 48, onPressed: onSaveItems),
            ),
          ],
        );
      },
    );
  }
}

/// Shows the live /quotations/product-incentive result for whatever is
/// currently in the product/quantity/rate fields on the Add Items step.
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
                      Text('Incentive on this item', style: AppTextStyles.bodyBold(color: AppColors.success)),
                    ],
                  ),
                  Text(
                    currency.format(incentive.totalIncentive),
                    style: AppTextStyles.bodyBold(color: AppColors.success),
                  ),
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
                Text(
                  '${item.size.isNotEmpty ? '${item.size} | ' : ''}${item.company}',
                  style: AppTextStyles.caption(),
                ),
                SizedBox(height: Responsive.h(2)),
                // Text(
                //   'Qty: ${item.quantity.toStringAsFixed(0)} ${item.unit}'
                //       '${item.mrp > 0 ? '   MRP: ${item.mrp.toStringAsFixed(0)}' : ''}'
                //       '   Rate: ${item.rate.toStringAsFixed(0)}',
                //   style: AppTextStyles.caption(),
                // ),
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
              Text(currency.format(item.amount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
              SizedBox(height: Responsive.h(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(onTap: onEdit, child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary)),
                  SizedBox(width: Responsive.w(14)),
                  InkWell(onTap: onDelete, child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error)),
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
// Reads everything (items, subtotal, handling charge, grand total, MRP
// total, total qty/sqft, incentive total) straight from the server's
// POST /quotations/preview response — `QuotationPreviewData`, the same
// model class the owner flow's Preview step uses — instead of computing
// it locally from `_items`.
// =====================================================================

class PreviewStep extends StatelessWidget {
  const PreviewStep({
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
                        ElevatedButton(onPressed: onRetryPreview, child: const Text('Retry')),
                      ],
                    ),
                  ),
                );
              }

              final preview = state.previewData;
              if (preview == null) return const SizedBox.shrink();

              return ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Estimate', style: AppTextStyles.h3()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Date', style: AppTextStyles.caption()),
                            Text(DateFormat('dd-MM-yyyy').format(date), style: AppTextStyles.h3()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  _PreviewSection(
                    title: 'Customer Details',
                    rows: [
                      _PreviewRow('Party Name', partyName.isEmpty ? '-' : partyName),
                      _PreviewRow('Address', address.isEmpty ? '-' : address),
                      _PreviewRow('Contact No.', phone.isEmpty ? '-' : phone),
                      _PreviewRow('Email', customerEmail.isEmpty ? '-' : customerEmail),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),

                  _PreviewSection(
                    title: 'Contractor',
                    rows: [
                      _PreviewRow('Name', contractorName.isEmpty ? '-' : contractorName),
                      _PreviewRow('Contact No.', contractorPhone.isEmpty ? '-' : contractorPhone),
                      _PreviewRow('Email', contractorEmail.isEmpty ? '-' : contractorEmail),
                    ],
                  ),
                  SizedBox(height: Responsive.h(20)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items', style: AppTextStyles.h3()),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Items: ${preview.totals.totalItems}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(10)),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
                        headingTextStyle: AppTextStyles.bodyBold(),
                        dataTextStyle: AppTextStyles.body(),
                        columnSpacing: 18,
                        columns: const [
                          DataColumn(label: Text('Sl.No')),
                          DataColumn(label: Text('Item')),
                          DataColumn(label: Text('Company')),
                          DataColumn(label: Text('Size')),
                          DataColumn(label: Text('Qty'), numeric: true),
                          DataColumn(label: Text('Unit')),
                          DataColumn(label: Text('MRP'), numeric: true),
                          DataColumn(label: Text('Rate'), numeric: true),
                          DataColumn(label: Text('Amount'), numeric: true),
                          DataColumn(label: Text('Incentive'), numeric: true),
                        ],
                        rows: preview.items.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(item.productName)),
                            DataCell(Text(item.productCompany.isEmpty ? '-' : item.productCompany)),
                            DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
                            DataCell(Text(number.format(item.quantity))),
                            DataCell(Text(item.productUnit)),
                            DataCell(Text(item.mrp > 0 ? number.format(item.mrp) : '-')),
                            DataCell(Text(number.format(item.rate))),
                            DataCell(Text(currency.format(item.amount), style: AppTextStyles.bodyBold())),
                            DataCell(Text(
                              item.incentiveAmount > 0 ? currency.format(item.incentiveAmount) : '-',
                              style: AppTextStyles.bodyBold(color: AppColors.success),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  LabeledField(
                    label: 'Handling Charge',
                    field: CustomTextField(
                      hint: 'Enter handling charge',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      controller: handlingChargeCtrl,
                      inputFormatters: DValidator.decimalNumber,
                      onChanged: (_) => onHandlingChargeChanged(),
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  LabeledField(
                    label: 'Notes (optional)',
                    field: CustomTextField(
                      hint: 'e.g. Customer enquiry for new project',
                      icon: Icons.notes_outlined,
                      controller: notesCtrl,
                      inputFormatters: DValidator.textWithLimit,
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),

                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _totalRow('Total Items', '${preview.totals.totalItems}'),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Total Qty', number.format(preview.totals.totalQuantity)),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Total Sq.Ft', number.format(preview.totals.totalSquareFeet)),
                        if (preview.totals.mrpTotal > 0) ...[
                          SizedBox(height: Responsive.h(6)),
                          _totalRow('Total MRP', currency.format(preview.totals.mrpTotal)),
                        ],
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Subtotal', currency.format(preview.totals.subtotal)),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Handling Charge', currency.format(preview.totals.handlingCharge)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grand Total', style: AppTextStyles.h3()),
                            Text(currency.format(preview.totals.grandTotal), style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  // Separate, visually distinct box for incentive so it's
                  // clear this is salesman-facing info, not part of the
                  // customer's bill total above.
                  if (preview.totals.totalIncentive > 0)
                    Container(
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
                          Text(
                            currency.format(preview.totals.totalIncentive),
                            style: AppTextStyles.h3(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: Responsive.h(12)),
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: savingDraft
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.request_quote_outlined, size: 18),
                label: Text(savingDraft ? 'Saving…' : 'Save as Quotation'),
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

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: AppTextStyles.body()),
      ],
    );
  }
}

class _PreviewRow {
  final String label;
  final String value;
  _PreviewRow(this.label, this.value);
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.rows});
  final String title;
  final List<_PreviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
          SizedBox(height: Responsive.h(8)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(4)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 100, child: Text(r.label, style: AppTextStyles.caption())),
                Expanded(child: Text(r.value, style: AppTextStyles.body())),
              ],
            ),
          )),
        ],
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
        Responsive.w(18),
        Responsive.h(10),
        Responsive.w(18),
        Responsive.h(14),
      ),
      decoration: BoxDecoration(
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
