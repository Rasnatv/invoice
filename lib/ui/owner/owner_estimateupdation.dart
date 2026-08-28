import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/apiclient/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';

import '../../models/owner_models/ownerestimate_updatemodel.dart';
import '../../widgets/primary_button.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';

/// Lightweight product record for the item picker, parsed loosely since
/// the shape of GET /products/active isn't modeled elsewhere yet.
class _ActiveProduct {
  final String id;
  final String name;
  final String size;
  final double rate;

  const _ActiveProduct({
    required this.id,
    required this.name,
    required this.size,
    required this.rate,
  });

  factory _ActiveProduct.fromJson(Map<String, dynamic> json) {
    double parseRate(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return _ActiveProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['product_name'] ?? '').toString(),
      size: (json['size'] ?? json['product_size'] ?? '').toString(),
      rate: parseRate(json['rate'] ?? json['default_rate'] ?? json['selling_rate']),
    );
  }
}

/// One editable row in the items table on the update screen.
class _EditableItem {
  String productId;
  String productName;
  final TextEditingController quantityCtrl;
  final TextEditingController boxQtyCtrl;
  final TextEditingController pieceQtyCtrl;
  final TextEditingController rateCtrl;

  _EditableItem({
    required this.productId,
    required this.productName,
    required String quantity,
    required String boxQty,
    required String pieceQty,
    required String rate,
  })  : quantityCtrl = TextEditingController(text: quantity),
        boxQtyCtrl = TextEditingController(text: boxQty),
        pieceQtyCtrl = TextEditingController(text: pieceQty),
        rateCtrl = TextEditingController(text: rate);

  void dispose() {
    quantityCtrl.dispose();
    boxQtyCtrl.dispose();
    pieceQtyCtrl.dispose();
    rateCtrl.dispose();
  }
}

/// Screen for editing an estimate's customer details, notes, terms, date
/// and item list via POST /estimates/update. Expects to be pushed with a
/// `BlocProvider.value` sharing the same [OwnerEstimateDetailBloc] as the
/// detail screen that opened it, so a successful update also refreshes
/// that screen's state.
class OwnerEstimateUpdateScreen extends StatefulWidget {
  const OwnerEstimateUpdateScreen({super.key, required this.detail});
  final EstimateDetailModel detail;

  @override
  State<OwnerEstimateUpdateScreen> createState() => _OwnerEstimateUpdateScreenState();
}

class _OwnerEstimateUpdateScreenState extends State<OwnerEstimateUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _termsCtrl;
  DateTime? _date;

  final List<_EditableItem> _items = [];

  List<_ActiveProduct> _products = [];
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    final d = widget.detail;
    _nameCtrl = TextEditingController(text: d.customerName);
    _phoneCtrl = TextEditingController(text: d.customerPhone);
    _addressCtrl = TextEditingController(text: d.customerAddress);
    _emailCtrl = TextEditingController(text: d.customerEmail);
    _notesCtrl = TextEditingController(text: d.notes);
    _termsCtrl = TextEditingController(text: d.termsConditions);
    _date = d.date;

    for (final item in d.items) {
      _items.add(_EditableItem(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity == item.quantity.roundToDouble()
            ? item.quantity.toStringAsFixed(0)
            : item.quantity.toString(),
        boxQty: '0',
        pieceQty: '0',
        rate: item.rate == item.rate.roundToDouble()
            ? item.rate.toStringAsFixed(0)
            : item.rate.toString(),
      ));
    }

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await ApiClient().activeProducts();
      final body = response.data;
      List<dynamic> rawList = const [];
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['list'] is List) {
          rawList = data['list'] as List;
        }
      } else if (body is List) {
        rawList = body;
      }
      final parsed = rawList
          .whereType<Map>()
          .map((e) => _ActiveProduct.fromJson(e.cast<String, dynamic>()))
          .toList();
      if (mounted) {
        setState(() {
          _products = parsed;
          _loadingProducts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    _termsCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItemRow() {
    setState(() {
      _items.add(_EditableItem(
        productId: '',
        productName: '',
        quantity: '',
        boxQty: '0',
        pieceQty: '0',
        rate: '',
      ));
    });
  }

  void _removeItemRow(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  void _onProductPicked(_EditableItem row, String? productId) {
    if (productId == null) return;
    final product = _products.firstWhere(
          (p) => p.id == productId,
      orElse: () => const _ActiveProduct(id: '', name: '', size: '', rate: 0),
    );
    setState(() {
      row.productId = product.id;
      row.productName = product.name;
      if (row.rateCtrl.text.trim().isEmpty && product.rate > 0) {
        row.rateCtrl.text = product.rate.toStringAsFixed(2);
      }
    });
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item.')),
      );
      return;
    }

    final updateItems = <EstimateUpdateItem>[];
    for (final row in _items) {
      if (row.productId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a product for every item row.')),
        );
        return;
      }
      final qty = double.tryParse(row.quantityCtrl.text.trim());
      final rate = double.tryParse(row.rateCtrl.text.trim());
      if (qty == null || qty <= 0 || rate == null || rate < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid quantity and rate for every item.')),
        );
        return;
      }
      updateItems.add(EstimateUpdateItem(
        productId: row.productId,
        quantity: qty,
        boxQuantity: double.tryParse(row.boxQtyCtrl.text.trim()) ?? 0,
        pieceQuantity: double.tryParse(row.pieceQtyCtrl.text.trim()) ?? 0,
        rate: rate,
      ));
    }

    final request = OwnerUpdateEstimateRequest(
      id: widget.detail.id,
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerAddress: _addressCtrl.text.trim(),
      customerEmail: _emailCtrl.text.trim(),
      date: _date == null ? null : DateFormat('yyyy-MM-dd').format(_date!),
      notes: _notesCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim(),
      items: updateItems,
    );

    context.read<OwnerEstimateDetailBloc>().add(OwnerEstimateUpdateRequested(request));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Update Estimate', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocConsumer<OwnerEstimateDetailBloc, OwnerEstimateDetailState>(
          listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
          listener: (context, state) {
            if (state.actionStatus == OwnerEstimateActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage ?? 'Estimate updated.')),
              );
              Navigator.of(context).pop(true);
            } else if (state.actionStatus == OwnerEstimateActionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage ?? 'Failed to update estimate.')),
              );
            }
          },
          builder: (context, state) {
            final isBusy = state.actionStatus == OwnerEstimateActionStatus.inProgress;

            return Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(18)),
                      children: [
                        Text('Customer Details', style: AppTextStyles.bodyBold(color: AppColors.primary)),
                        SizedBox(height: Responsive.h(10)),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Customer Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _addressCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => _date = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Estimate Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_date == null
                                ? 'Select date'
                                : DateFormat('yyyy-MM-dd').format(_date!)),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _notesCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _termsCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Terms & Conditions',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: Responsive.h(20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items', style: AppTextStyles.h3()),
                            TextButton.icon(
                              onPressed: _loadingProducts ? null : _addItemRow,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Item'),
                            ),
                          ],
                        ),
                        if (_loadingProducts)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          ..._items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final row = entry.value;
                            return _ItemRowCard(
                              index: index,
                              row: row,
                              products: _products,
                              onProductPicked: (id) => _onProductPicked(row, id),
                              onRemove: () => _removeItemRow(index),
                            );
                          }),
                        if (!_loadingProducts && _items.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
                            child: Text('No items yet — tap "Add Item" to add one.',
                                style: AppTextStyles.caption()),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
                  child: PrimaryButton(
                    label: isBusy ? 'Saving...' : 'Save Changes',
                    height: 48,
                    onPressed: isBusy ? null : () => _submit(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ItemRowCard extends StatelessWidget {
  const _ItemRowCard({
    required this.index,
    required this.row,
    required this.products,
    required this.onProductPicked,
    required this.onRemove,
  });

  final int index;
  final _EditableItem row;
  final List<_ActiveProduct> products;
  final ValueChanged<String?> onProductPicked;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // Ensure the currently selected product is present in the dropdown
    // items even if it's not (or no longer) in the active products list.
    final dropdownIds = products.map((p) => p.id).toSet();
    final currentId = row.productId.isEmpty || dropdownIds.contains(row.productId)
        ? (row.productId.isEmpty ? null : row.productId)
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(12)),
      padding: EdgeInsets.all(Responsive.w(12)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Item ${index + 1}', style: AppTextStyles.bodyBold()),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Remove item',
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: currentId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Product',
              border: const OutlineInputBorder(),
              hintText: row.productId.isNotEmpty && currentId == null
                  ? row.productName
                  : null,
            ),
            items: products
                .map((p) => DropdownMenuItem(
              value: p.id,
              child: Text(
                p.size.isEmpty ? p.name : '${p.name} (${p.size})',
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            onChanged: onProductPicked,
          ),
          SizedBox(height: Responsive.h(10)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: TextFormField(
                  controller: row.rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.boxQtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Box Qty',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: TextFormField(
                  controller: row.pieceQtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Piece Qty',
                    border: OutlineInputBorder(),
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