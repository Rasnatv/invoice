import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/ownerquotationeditscreenwidget.dart';
import '../../bloc/ownerbloc/ownerquatationedit/owner_qtneditbloc.dart';
import '../../bloc/ownerbloc/ownerquatationedit/owner_qtneditestate.dart';
import '../../bloc/ownerbloc/ownerquatationedit/owner_qtneditevent.dart';
import '../../bloc/quotationitemremove/quotationitemremove_bloc.dart';
import '../../bloc/quotationitemremove/quotationitemremove_event.dart';
import '../../bloc/quotationitemremove/quotationitemremove_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/delete_helper.dart';
import '../../core/utils/responsive.dart';
import '../../core/validator/validationfile.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/primary_button.dart';
import '../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../models/salesmanmodels/quotationupdatemodel.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';

import '../../Apiprovider/salesman_quotationprovider.dart';

class OwnerQuotationEditScreen extends StatelessWidget {
  const OwnerQuotationEditScreen({super.key, required this.estimate});

  /// Already-loaded detail (from the owner details screen) used to
  /// prefill every field — no re-fetch needed for the quotation itself.
  final QuotationDetailModel estimate;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OwnerQuotationEditBloc()
            ..add(const OwnerEditActiveProductsRequested()),
        ),
        BlocProvider(create: (_) => QuotationItemRemoveBloc()),
      ],
      child: OwnerQuotationEditView(estimate: estimate),
    );
  }
}

class OwnerQuotationEditView extends StatefulWidget {
  const OwnerQuotationEditView({super.key, required this.estimate});
  final QuotationDetailModel estimate;

  @override
  State<OwnerQuotationEditView> createState() => OwnerQuotationEditViewState();
}

class OwnerQuotationEditViewState extends State<OwnerQuotationEditView> {
  final formKey = GlobalKey<FormState>();

  // Separate Form for the contractor name/phone pair so they can be
  // cross-validated on every keystroke without touching customer fields.
  final contractorFormKey = GlobalKey<FormState>();

  // ---- Customer / contractor / other details ----
  late final TextEditingController customerName;
  late final TextEditingController customerPhone;
  late final TextEditingController customerEmail;
  late final TextEditingController customerAddress;
  late final TextEditingController contractorName;
  late final TextEditingController contractorPhone;
  late final TextEditingController contractorEmail;
  late final TextEditingController contractorAddress;
  late final TextEditingController handlingCharge;
  late final TextEditingController notes;
  final TextEditingController termsConditions = TextEditingController();

  // ---- Items ----
  late List<OwnerEditItem> items;
  int newItemCounter = 0;
  int? editingItemIndex;

  // ---- Add / edit item form ----
  final itemFormKey = GlobalKey<FormState>();
  ActiveProductModel? selectedProduct;
  final productSearchCtrl = TextEditingController();
  final productSearchFocus = FocusNode();
  bool showProductSuggestions = false;
  final itemCompanyCtrl = TextEditingController();
  final itemSizeCtrl = TextEditingController();
  final itemUnitCtrl = TextEditingController();
  final itemMrpCtrl = TextEditingController();
  final itemQtyCtrl = TextEditingController();
  final itemRateCtrl = TextEditingController();
  final itemBoxQtyCtrl = TextEditingController();
  final itemPieceQtyCtrl = TextEditingController();

  Timer? incentiveDebounce;
  static const incentiveDebounceDuration = Duration(milliseconds: 450);

  bool backfilledFromCatalog = false;

  final QuotationProvider quotationProvider = QuotationProvider();
  bool isAddingItem = false;

  OwnerEditItem? pendingItemUpdate;

  bool get isBoxUnitProduct {
    if (editingItemIndex != null) {
      final item = items[editingItemIndex!];
      if (item.boxQuantity > 0 || item.pieceQuantity > 0) return true;
    }
    if (selectedProduct != null) return selectedProduct!.isBoxUnit;
    return false;
  }

  double get computedQuantity => double.tryParse(itemQtyCtrl.text) ?? 0;

  void recomputeBoxQtyIfNeeded() {
    if (!isBoxUnitProduct) return;
    itemBoxQtyCtrl.text = itemQtyCtrl.text;
  }

  bool get isOwner {
    final label = widget.estimate.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return widget.estimate.createdBy.role.trim().toLowerCase() == 'owner';
  }

  bool isUnsavedItem(OwnerEditItem item) => item.id.startsWith('new_');

  @override
  void initState() {
    super.initState();
    final e = widget.estimate;

    customerName = TextEditingController(text: e.customer.name);
    customerPhone = TextEditingController(text: e.customer.phone);
    customerEmail = TextEditingController(text: e.customer.email);
    customerAddress = TextEditingController(text: e.customer.address);

    // Clearing the customer phone also clears name / address / email.
    customerPhone.addListener(onCustomerPhoneChanged);

    // Product suggestions open when the product field is tapped/focused.
    productSearchFocus.addListener(onProductFocusChanged);

    contractorName = TextEditingController(text: e.contractor.name);
    contractorPhone = TextEditingController(text: e.contractor.mobile);
    contractorEmail = TextEditingController(text: e.contractor.email);
    contractorAddress = TextEditingController(text: e.contractor.address);
    contractorName.addListener(revalidateContractorFields);
    contractorPhone.addListener(revalidateContractorFields);

    handlingCharge = TextEditingController(text: formatPrice(e.handlingCharge));
    notes = TextEditingController(text: e.notes);

    items = e.items
        .map((it) => OwnerEditItem(
      id: it.id,
      productId: it.productId,
      name: it.productName,
      unit: it.productUnit,
      size: it.productSize,
      quantity: it.quantity,
      rate: it.rate,
      amount: it.amount,
      boxQuantity: it.boxQuantity,
      pieceQuantity: it.pieceQuantity,
      incentiveAmount: it.incentiveAmount,
      incentiveEligible: it.incentiveAmount > 0,
    ))
        .toList();
  }

  void onCustomerPhoneChanged() {
    if (customerPhone.text.trim().isNotEmpty) return;
    if (customerName.text.isEmpty &&
        customerAddress.text.isEmpty &&
        customerEmail.text.isEmpty) {
      return;
    }
    customerName.clear();
    customerAddress.clear();
    customerEmail.clear();
  }

  void onProductFocusChanged() {
    if (productSearchFocus.hasFocus) {
      setState(() => showProductSuggestions = true);
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted || productSearchFocus.hasFocus) return;
        setState(() => showProductSuggestions = false);
      });
    }
  }

  void revalidateContractorFields() {
    contractorFormKey.currentState?.validate();
  }

  @override
  void dispose() {
    incentiveDebounce?.cancel();
    customerPhone.removeListener(onCustomerPhoneChanged);
    productSearchFocus.removeListener(onProductFocusChanged);
    contractorName.removeListener(revalidateContractorFields);
    contractorPhone.removeListener(revalidateContractorFields);
    customerName.dispose();
    customerPhone.dispose();
    customerEmail.dispose();
    customerAddress.dispose();
    contractorName.dispose();
    contractorPhone.dispose();
    contractorEmail.dispose();
    contractorAddress.dispose();
    handlingCharge.dispose();
    notes.dispose();
    termsConditions.dispose();
    productSearchCtrl.dispose();
    productSearchFocus.dispose();
    itemCompanyCtrl.dispose();
    itemSizeCtrl.dispose();
    itemUnitCtrl.dispose();
    itemMrpCtrl.dispose();
    itemQtyCtrl.dispose();
    itemBoxQtyCtrl.dispose();
    itemPieceQtyCtrl.dispose();
    itemRateCtrl.dispose();
    super.dispose();
  }

  // ---- Derived totals ----
  double get itemsTotal => items.fold(0.0, (s, i) => s + i.amount);
  double get handling => double.tryParse(handlingCharge.text.trim()) ?? 0;
  double get grandTotal => itemsTotal + handling;
  double get incentiveTotal => items.fold(0.0, (s, i) => s + i.incentiveAmount);
  double get mrpTotal => items.fold(0.0, (s, i) => s + (i.mrp * i.quantity));

  double get totalSqft => items.fold(0.0, (s, i) {
    final u = i.unit
        .toLowerCase()
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll('²', '2');
    final isSqft = u == 'sqft' ||
        u == 'sqfeet' ||
        u == 'squarefeet' ||
        u == 'squareft' ||
        u == 'sft' ||
        u == 'ft2' ||
        u.contains('sqft') ||
        u.contains('squareft') ||
        u.contains('squarefeet');
    return s + (isSqft ? i.quantity : 0);
  });

  static String formatPrice(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  void showError(String msg) => AppSnackbar.error(msg);

  ActiveProductModel? findCatalogMatch(List<ActiveProductModel> products, String productId) {
    for (final p in products) {
      if (p.id == productId) return p;
    }
    return null;
  }

  /// Fills in company/mrp for existing items once the active-products
  /// catalog is available (/quotations/show doesn't return either field).
  void backfillCompanyAndMrp(List<ActiveProductModel> products) {
    if (products.isEmpty) return;
    var changed = false;
    final updated = items.map((item) {
      if (item.company.isNotEmpty) return item;
      final match = findCatalogMatch(products, item.productId);
      if (match == null) return item;
      changed = true;
      return item.copyWith(company: match.company, mrp: match.mrp);
    }).toList();

    if (changed) {
      setState(() {
        items = updated;
        backfilledFromCatalog = true;
      });
    } else {
      backfilledFromCatalog = true;
    }
  }

  // ---------------- Field-level validators ----------------

  String? validatePartyName(String? v) => DValidator.validateName('Customer name', v);

  String? validateCustomerPhone(String? v) => DValidator.validatePhoneNumber(v);

  String? validateCustomerAddress(String? v) =>
      DValidator.validateRequired(v, message: 'Site address is required');

  String? validateOptionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return DValidator.validateEmail(v);
  }

  /// Contractor name is optional, but required once contractor phone is filled.
  String? validateOptionalName(String fieldName, String? v) {
    final name = (v ?? '').trim();
    final phone = contractorPhone.text.trim();

    if (name.isEmpty && phone.isNotEmpty) {
      return '$fieldName is required when contractor phone number is entered';
    }
    if (name.isEmpty) return null;
    return DValidator.validateAlphaOnly(fieldName, name);
  }

  /// Contractor phone is optional, but required once contractor name is filled.
  String? validateOptionalPhone(String? v) {
    final phone = (v ?? '').trim();
    final name = contractorName.text.trim();

    if (phone.isEmpty && name.isNotEmpty) {
      return 'Contractor phone number is required when contractor name is entered';
    }
    if (phone.isEmpty) return null;
    return DValidator.validatePhoneNumber(phone);
  }

  String? validateHandlingCharge(String? v) =>
      DValidator.validateOptionalNumber('Handling charge', v);

  // ---- Add-item form wiring ----
  static String productDisplayString(ActiveProductModel p) => ownerProductDisplayString(p);

  void onProductSelected(ActiveProductModel? product) {
    setState(() {
      selectedProduct = product;
      if (product != null) {
        productSearchCtrl.text = productDisplayString(product);
        itemCompanyCtrl.text = product.company;
        itemSizeCtrl.text = product.size;
        itemUnitCtrl.text = product.unit;
        itemMrpCtrl.text = formatPrice(product.mrp);
        itemRateCtrl.text = formatPrice(product.rate);
      } else {
        itemCompanyCtrl.clear();
        itemSizeCtrl.clear();
        itemUnitCtrl.clear();
        itemMrpCtrl.clear();
        itemRateCtrl.clear();
      }
      itemQtyCtrl.clear();
      itemBoxQtyCtrl.clear();
      itemPieceQtyCtrl.clear();
    });
    scheduleIncentiveFetch();
  }

  /// Clears the product search box itself (clear button / form reset).
  void clearProductSelection() {
    productSearchCtrl.clear();
    onProductSelected(null);
  }

  void scheduleIncentiveFetch() {
    incentiveDebounce?.cancel();

    final product = selectedProduct;
    final qty = computedQuantity;
    final rate = double.tryParse(itemRateCtrl.text) ?? 0;
    final fallbackProductId =
    editingItemIndex != null ? items[editingItemIndex!].productId : null;
    final productId = product != null
        ? int.tryParse(product.id)
        : (fallbackProductId != null ? int.tryParse(fallbackProductId) : null);

    if (productId == null || qty <= 0 || rate <= 0) {
      context.read<OwnerQuotationEditBloc>().add(const OwnerEditProductIncentiveCleared());
      return;
    }

    incentiveDebounce = Timer(incentiveDebounceDuration, () {
      if (!mounted) return;
      context.read<OwnerQuotationEditBloc>().add(OwnerEditProductIncentiveRequested(
        productId: productId,
        quantity: qty,
        rate: rate,
      ));
    });
  }

  void resetItemForm() {
    incentiveDebounce?.cancel();
    setState(() {
      selectedProduct = null;
      editingItemIndex = null;
      showProductSuggestions = false;
      productSearchCtrl.clear();
      itemCompanyCtrl.clear();
      itemSizeCtrl.clear();
      itemUnitCtrl.clear();
      itemMrpCtrl.clear();
      itemQtyCtrl.clear();
      itemBoxQtyCtrl.clear();
      itemPieceQtyCtrl.clear();
      itemRateCtrl.clear();
    });
    context.read<OwnerQuotationEditBloc>().add(const OwnerEditProductIncentiveCleared());
    itemFormKey.currentState?.reset();
  }

  Future<void> saveItemFromForm() async {
    if (isAddingItem) return;

    if (!(itemFormKey.currentState?.validate() ?? true)) return;

    final qty = computedQuantity;
    final rate = double.tryParse(itemRateCtrl.text) ?? 0;

    String productIdStr;
    String name;
    if (selectedProduct != null) {
      productIdStr = selectedProduct!.id;
      name = selectedProduct!.name;
    } else if (editingItemIndex != null) {
      productIdStr = items[editingItemIndex!].productId;
      name = items[editingItemIndex!].name;
    } else {
      showError('Please select a product');
      return;
    }
    if (qty <= 0) {
      showError(isBoxUnitProduct
          ? 'Please enter a valid box/piece quantity'
          : 'Please enter a valid quantity');
      return;
    }
    if (rate <= 0) {
      showError('Please enter a valid rate');
      return;
    }

    final productId = int.tryParse(productIdStr);
    if (productId == null) {
      showError('Invalid product selected.');
      return;
    }

    // Box Quantity mirrors Quantity; Piece Quantity is entered separately.
    // Non-box-unit items send null for both.
    recomputeBoxQtyIfNeeded();
    final boxQuantity = isBoxUnitProduct ? (double.tryParse(itemBoxQtyCtrl.text) ?? 0) : null;
    final pieceQuantity = isBoxUnitProduct ? (double.tryParse(itemPieceQtyCtrl.text) ?? 0) : null;

    setState(() => isAddingItem = true);

    final result = await quotationProvider.getProductIncentive(ProductIncentiveRequest(
      productId: productId,
      quantity: qty,
      rate: rate,
      boxQuantity: boxQuantity,
      pieceQuantity: pieceQuantity,
    ));

    if (!mounted) return;

    if (!result.success || result.incentive == null) {
      setState(() => isAddingItem = false);
      showError(result.errorMessage ?? 'Could not calculate the amount for this item. Please try again.');
      return;
    }

    final incentive = result.incentive!;
    final editingIndex = editingItemIndex;

    final formCompany = itemCompanyCtrl.text.trim();
    final formMrp = double.tryParse(itemMrpCtrl.text);
    final previousCompany = editingIndex != null ? items[editingIndex].company : '';
    final previousMrp = editingIndex != null ? items[editingIndex].mrp : 0.0;

    final newItem = OwnerEditItem(
      id: editingIndex != null ? items[editingIndex].id : 'new_${newItemCounter++}',
      productId: productIdStr,
      name: name,
      company: formCompany.isNotEmpty ? formCompany : previousCompany,
      size: itemSizeCtrl.text.trim(),
      unit: itemUnitCtrl.text.trim(),
      quantity: qty,
      rate: rate,
      amount: incentive.amount,
      mrp: formMrp ?? previousMrp,
      boxQuantity: isBoxUnitProduct ? (boxQuantity ?? 0) : 0,
      pieceQuantity: isBoxUnitProduct ? (pieceQuantity ?? 0) : 0,
      // Incentive is salesman-facing; stored here but hidden when isOwner.
      incentiveAmount: incentive.totalIncentive,
      incentiveEligible: incentive.isEligible,
      incentiveReason: incentive.eligibilityReason,
    );

    final existingItem = editingIndex != null ? items[editingIndex] : null;

    if (existingItem != null && !isUnsavedItem(existingItem)) {
      // Already-saved item — persist immediately via PUT /quotations/update-item.
      // isAddingItem stays true until the itemUpdateStatus listener reports back.
      pendingItemUpdate = newItem;
      context.read<OwnerQuotationEditBloc>().add(OwnerQuotationItemUpdateSubmitted(
        quotationId: widget.estimate.id,
        quotationItemId: existingItem.id,
        quantity: qty,
        rate: rate,
        boxQuantity: boxQuantity,
        pieceQuantity: pieceQuantity,
      ));
      return;
    }

    // Brand-new / unsaved item — keep purely local.
    setState(() {
      isAddingItem = false;
      if (editingIndex != null) {
        items[editingIndex] = newItem;
      } else {
        items.add(newItem);
      }
    });
    resetItemForm();
  }

  void editItem(int index) {
    final item = items[index];
    final products = context.read<OwnerQuotationEditBloc>().state.products;
    final match = findCatalogMatch(products, item.productId);

    setState(() {
      editingItemIndex = index;
      selectedProduct = match;
      showProductSuggestions = false;
      productSearchCtrl.text = match != null ? productDisplayString(match) : item.name;
      itemCompanyCtrl.text = match?.company ?? item.company;
      itemSizeCtrl.text = item.size;
      itemUnitCtrl.text = item.unit;
      itemMrpCtrl.text = formatPrice(match?.mrp ?? item.mrp);
      itemQtyCtrl.text = formatPrice(item.quantity);
      itemRateCtrl.text = formatPrice(item.rate);
      // Show the item's own saved box quantity; don't derive it from Quantity.
      itemBoxQtyCtrl.text = formatPrice(item.boxQuantity);
      itemPieceQtyCtrl.text = formatPrice(item.pieceQuantity);
    });

    productSearchFocus.unfocus();

    context.read<OwnerQuotationEditBloc>().add(const OwnerEditProductIncentiveCleared());
    if (match != null) scheduleIncentiveFetch();
  }

  void cancelEditItem() => resetItemForm();

  Future<void> removeItem(int index) async {
    final item = items[index];

    if (isUnsavedItem(item)) {
      removeLocalItemAt(index);
      return;
    }

    await deleteItem(
      context,
      itemName: 'item',
      onConfirmed: () async {
        if (!mounted) return;
        context.read<QuotationItemRemoveBloc>().add(QuotationItemRemoveRequested(
          quotationId: widget.estimate.id,
          quotationItemId: item.id,
        ));
      },
    );
  }

  /// Removes the item at [index] locally and fixes up the editing index.
  void removeLocalItemAt(int index) {
    setState(() {
      items.removeAt(index);
      if (editingItemIndex != null) {
        if (editingItemIndex == index) {
          editingItemIndex = null;
          resetItemForm();
        } else if (editingItemIndex! > index) {
          editingItemIndex = editingItemIndex! - 1;
        }
      }
    });
  }

  /// Called once the remove-item API call has succeeded.
  void dropItemById(String itemId) {
    final index = items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    removeLocalItemAt(index);
  }

  /// Called once PUT /quotations/update-item has succeeded.
  void applyPendingItemUpdate() {
    final pending = pendingItemUpdate;
    final editingIndex = editingItemIndex;
    pendingItemUpdate = null;
    if (pending == null || editingIndex == null) {
      setState(() => isAddingItem = false);
      return;
    }
    setState(() {
      isAddingItem = false;
      items[editingIndex] = pending;
    });
    resetItemForm();
  }

  // ---- Submit ----
  bool validate() {
    final formValid = formKey.currentState?.validate() ?? true;
    final contractorValid = contractorFormKey.currentState?.validate() ?? true;

    if (!formValid || !contractorValid) {
      showError('Please fix the highlighted fields');
      return false;
    }
    if (items.isEmpty) {
      showError('Add at least one item');
      return false;
    }
    return true;
  }

  String? nullIfEmpty(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  void submit() {
    if (!validate()) return;

    final request = QuotationUpdateRequest(
      id: widget.estimate.id,
      customerName: customerName.text.trim(),
      customerPhone: customerPhone.text.trim(),
      customerEmail: nullIfEmpty(customerEmail),
      customerAddress: nullIfEmpty(customerAddress),
      contractorName: nullIfEmpty(contractorName),
      contractorPhone: nullIfEmpty(contractorPhone),
      contractorEmail: nullIfEmpty(contractorEmail),
      contractorAddress: nullIfEmpty(contractorAddress),
      handlingCharge: handling,
      notes: nullIfEmpty(notes),
      termsConditions: nullIfEmpty(termsConditions),
      items: items
          .map((i) => QuotationUpdateItemRequest(
        productId: i.productId,
        quantity: i.quantity,
        rate: i.rate,
        // toJson() omits nulls, so regular (non-box) items are unaffected.
        boxQuantity: i.boxQuantity > 0 ? i.boxQuantity : null,
        pieceQuantity: i.pieceQuantity > 0 ? i.pieceQuantity : null,
      ))
          .toList(),
    );

    context.read<OwnerQuotationEditBloc>().add(OwnerQuotationUpdateSubmitted(request));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Edit Quotation', style: AppTextStyles.h6())),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<OwnerQuotationEditBloc, OwnerQuotationEditState>(
                listenWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
                listener: (context, state) {
                  if (state.updateStatus == OwnerQuotationUpdateStatus.success) {
                    AppSnackbar.success(state.updateMessage ?? 'Quotation updated.');
                    context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationUpdateResultConsumed());
                    Navigator.of(context).pop(true);
                  } else if (state.updateStatus == OwnerQuotationUpdateStatus.failure) {
                    showError(state.updateError ?? 'Failed to update quotation.');
                    context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationUpdateResultConsumed());
                  }
                },
              ),
              BlocListener<OwnerQuotationEditBloc, OwnerQuotationEditState>(
                listenWhen: (prev, curr) => prev.itemUpdateStatus != curr.itemUpdateStatus,
                listener: (context, state) {
                  if (state.itemUpdateStatus == OwnerItemUpdateStatus.success) {
                    applyPendingItemUpdate();
                    AppSnackbar.success(state.itemUpdateMessage ?? 'Item updated successfully');
                    context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationItemUpdateResultConsumed());
                  } else if (state.itemUpdateStatus == OwnerItemUpdateStatus.failure) {
                    pendingItemUpdate = null;
                    setState(() => isAddingItem = false);
                    showError(state.itemUpdateError ?? 'Failed to update item.');
                    context.read<OwnerQuotationEditBloc>().add(const OwnerQuotationItemUpdateResultConsumed());
                  }
                },
              ),
              BlocListener<OwnerQuotationEditBloc, OwnerQuotationEditState>(
                listenWhen: (prev, curr) =>
                !backfilledFromCatalog &&
                    prev.productsStatus != curr.productsStatus &&
                    curr.productsStatus == OwnerEditLoadStatus.success,
                listener: (context, state) => backfillCompanyAndMrp(state.products),
              ),
              BlocListener<QuotationItemRemoveBloc, QuotationItemRemoveState>(
                listenWhen: (prev, curr) => prev.status != curr.status,
                listener: (context, state) {
                  if (state.status == QuotationItemRemoveStatus.success) {
                    final removedId = state.removedItemId;
                    if (removedId != null) dropItemById(removedId);
                    AppSnackbar.success(state.message ?? 'Item removed successfully');
                    context.read<QuotationItemRemoveBloc>().add(const QuotationItemRemoveResultConsumed());
                  } else if (state.status == QuotationItemRemoveStatus.failure) {
                    showError(state.errorMessage ?? 'Failed to remove item');
                    context.read<QuotationItemRemoveBloc>().add(const QuotationItemRemoveResultConsumed());
                  }
                },
              ),
            ],
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(18)),
                      children: [
                        Text('Customer Details', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(12)),
                        OwnerCustomerSection(
                          phone: customerPhone,
                          name: customerName,
                          address: customerAddress,
                          email: customerEmail,
                          phoneValidator: validateCustomerPhone,
                          nameValidator: validatePartyName,
                          addressValidator: validateCustomerAddress,
                          emailValidator: validateOptionalEmail,
                        ),
                        SizedBox(height: Responsive.h(16)),

                        Text('Contractor Details', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(12)),
                        OwnerContractorSection(
                          formKey: contractorFormKey,
                          name: contractorName,
                          phone: contractorPhone,
                          email: contractorEmail,
                          nameValidator: (v) => validateOptionalName('Contractor name', v),
                          phoneValidator: validateOptionalPhone,
                          emailValidator: validateOptionalEmail,
                        ),
                        SizedBox(height: Responsive.h(20)),

                        Text('Add / Edit Item', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(10)),
                        OwnerItemFormFields(
                          formKey: itemFormKey,
                          productField: OwnerProductDropdown(
                            searchCtrl: productSearchCtrl,
                            focusNode: productSearchFocus,
                            selectedProduct: selectedProduct,
                            showSuggestions: showProductSuggestions,
                            onFieldTap: () => setState(() => showProductSuggestions = true),
                            onTextChanged: (text) {
                              if (selectedProduct != null &&
                                  text != productDisplayString(selectedProduct!)) {
                                onProductSelected(null);
                              }
                              setState(() => showProductSuggestions = true);
                            },
                            onClear: clearProductSelection,
                            onSelected: (p) {
                              onProductSelected(p);
                              setState(() => showProductSuggestions = false);
                              productSearchFocus.unfocus();
                            },
                          ),
                          companyCtrl: itemCompanyCtrl,
                          sizeCtrl: itemSizeCtrl,
                          unitCtrl: itemUnitCtrl,
                          mrpCtrl: itemMrpCtrl,
                          rateCtrl: itemRateCtrl,
                          qtyCtrl: itemQtyCtrl,
                          boxQtyCtrl: itemBoxQtyCtrl,
                          pieceQtyCtrl: itemPieceQtyCtrl,
                          isBoxUnit: isBoxUnitProduct,
                          onRateChanged: (_) {
                            setState(() {});
                            scheduleIncentiveFetch();
                          },
                          onQtyChanged: (_) {
                            setState(recomputeBoxQtyIfNeeded);
                            scheduleIncentiveFetch();
                          },
                          onPieceChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: Responsive.h(6)),

                        // Incentive preview hidden for owner-created quotations.
                        if (!isOwner && (selectedProduct != null || editingItemIndex != null)) ...[
                          SizedBox(height: Responsive.h(8)),
                          const OwnerIncentivePreviewCard(),
                        ],

                        SizedBox(height: Responsive.h(14)),

                        if (editingItemIndex != null)
                          OwnerEditingBanner(
                            itemNumber: editingItemIndex! + 1,
                            onCancel: cancelEditItem,
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isAddingItem ? null : saveItemFromForm,
                            icon: isAddingItem
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Icon(
                              editingItemIndex != null ? Icons.save_outlined : Icons.add,
                              color: Colors.white,
                            ),
                            label: Text(
                              isAddingItem
                                  ? (editingItemIndex != null ? 'Updating…' : 'Calculating…')
                                  : (editingItemIndex != null ? 'Update Item' : 'Add Item'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(20)),

                        Text('Items (${items.length})', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(10)),
                        if (items.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
                            child: Center(
                              child: Text('No items added yet',
                                  style: AppTextStyles.body(color: AppColors.textHint)),
                            ),
                          )
                        else
                          BlocBuilder<QuotationItemRemoveBloc, QuotationItemRemoveState>(
                            buildWhen: (prev, curr) =>
                            prev.status != curr.status || prev.removedItemId != curr.removedItemId,
                            builder: (context, removeState) {
                              final removingId = removeState.status == QuotationItemRemoveStatus.inProgress
                                  ? removeState.removedItemId
                                  : null;
                              return Column(
                                children: items.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final item = entry.value;
                                  return OwnerEditItemTile(
                                    serialNo: i + 1,
                                    item: item,
                                    currency: currency,
                                    isEditing: editingItemIndex == i,
                                    isRemoving: item.id == removingId,
                                    showIncentive: !isOwner,
                                    onEdit: () => editItem(i),
                                    onDelete: () => removeItem(i),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        SizedBox(height: Responsive.h(20)),

                        Text('Other Details', style: AppTextStyles.h3()),
                        SizedBox(height: Responsive.h(12)),
                        OwnerOtherDetailsSection(
                          handlingCharge: handlingCharge,
                          notes: notes,
                          handlingValidator: validateHandlingCharge,
                          onHandlingChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: Responsive.h(10)),

                        OwnerTotalsCard(
                          totalSqft: totalSqft,
                          mrpTotal: mrpTotal,
                          itemsTotal: itemsTotal,
                          handling: handling,
                          grandTotal: grandTotal,
                          currency: currency,
                          number: number,
                        ),
                        SizedBox(height: Responsive.h(12)),

                        // Incentive total hidden for owner-created quotations.
                        if (!isOwner && incentiveTotal > 0)
                          OwnerIncentiveTotalCard(total: incentiveTotal, currency: currency),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<OwnerQuotationEditBloc, OwnerQuotationEditState>(
                  buildWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
                  builder: (context, state) {
                    final saving = state.updateStatus == OwnerQuotationUpdateStatus.submitting;
                    return Container(
                      padding: EdgeInsets.fromLTRB(
                          Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: PrimaryButton(
                        label: saving ? 'Saving…' : 'Save Changes',
                        height: 48,
                        onPressed: saving ? null : submit,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}