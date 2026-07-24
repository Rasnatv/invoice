import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../salesman/incentive/salesmanincentivescreen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _PersonOption {
  const _PersonOption(this.name, this.mobile);
  final String name;
  final String mobile;
}

enum _DocType { bill, quotation }

class _DocProductLine {
  const _DocProductLine({
    required this.name,
    required this.company,
    required this.sqft,
    required this.rate,
    required this.amount,
  });
  final String name;
  final String company;
  final double sqft;
  final double rate;
  final double amount;
}

class _DocumentItem {
  const _DocumentItem({
    required this.id,
    required this.date,
    required this.customerName,
    required this.customerMobile,
    required this.customerAddress,
    required this.sqft,
    required this.amount,
    required this.type,
    required this.products,
    this.approvedBy,
  });
  final String id;
  final DateTime date;
  final String customerName;
  final String customerMobile;
  final String customerAddress;
  final double sqft;
  final double amount;
  final _DocType type;
  final List<_DocProductLine> products;
  // Only set for Bills — a bill exists because its estimate was approved.
  // Quotations never carry this.
  final String? approvedBy;
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _personTypes = ['Salesman', 'Engineer/Contractor'];
  String _personType = 'Salesman';

  static const _salesmen = [
    _PersonOption('Rahul Kumar', '9123456780'),
    _PersonOption('Anoop Menon', '9123456781'),
    _PersonOption('Divya Prasad', '9123456782'),
  ];

  static const _contractors = [
    _PersonOption('Ramesh Constructions', '9876543210'),
    _PersonOption('Suresh Builders', '9876500001'),
    _PersonOption('Green Valley Homes', '9876500002'),
  ];

  late _PersonOption _selectedPerson = _salesmen.first;

  DateTime _fromDate = DateTime(2026, 1, 1);
  DateTime _toDate = DateTime(2026, 2, 24);

  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _dateFmt = DateFormat('dd-MM-yyyy');

  List<_PersonOption> get _currentOptions => _personType == 'Salesman' ? _salesmen : _contractors;

  bool get _isSalesman => _personType == 'Salesman';

  // ---- demo report data (deterministic dummy based on selected person) ----
  int get _noOfBills => 8 + (_selectedPerson.name.length % 5);
  int get _noOfQuotations => 3 + (_selectedPerson.name.length % 3);
  double get _totalSqft => 2400 + (_selectedPerson.name.length * 37);
  double get _totalSale => 185000 + (_selectedPerson.name.length * 2150);

  // ---- demo date-wise document generation (bills / quotations) ----
  List<_DocumentItem> _generateDocuments(_DocType type) {
    final count = type == _DocType.bill ? _noOfBills : _noOfQuotations;
    final totalSpan = _toDate.difference(_fromDate).inDays.clamp(1, 100000);
    final seed = _selectedPerson.name.length + _selectedPerson.mobile.hashCode.abs();
    final prefix = type == _DocType.bill ? 'Est.No' : 'DS';

    final customers = [
      'Anil Nair',
      'Beena Thomas',
      'Chandran K.',
      'Deepa Varma',
      'Faisal Rahman',
      'Geetha Pillai',
    ];

    final addresses = [
      'No. 12, MG Road, Kozhikode',
      'Near Bus Stand, Kanhangad',
      'Beach Road, Kasaragod',
      'Palace Road, Kanhangad',
      'Hosdurg, Kasaragod',
      'Bekal Road, Kanhangad',
    ];

    // Bills exist because their estimate was approved by an owner/admin.

    return List.generate(count, (i) {
      final dayOffset = ((seed + i * 13) % totalSpan);
      final date = _fromDate.add(Duration(days: dayOffset));
      final customer = customers[(seed + i) % customers.length];
      final address = addresses[(seed + i) % addresses.length];
      final sqft = 80.0 + ((seed + i * 17) % 220);
      final rate1 = 55.0 + ((seed + i * 3) % 40);
      final rate2 = 40.0 + ((seed + i * 5) % 25);
      final sqft1 = (sqft * 0.6).roundToDouble();
      final sqft2 = (sqft - sqft1).roundToDouble();
      final amount1 = sqft1 * rate1;
      final amount2 = sqft2 * rate2;
      return _DocumentItem(
        id: '$prefix-${1000 + seed % 900 + i}',
        date: date,
        customerName: customer,
        customerMobile: '9${(700000000 + (seed + i) * 137) % 100000000}',
        customerAddress: address,
        sqft: sqft,
        amount: amount1 + amount2,
        type: type,
        approvedBy: type == _DocType.bill ? 'Nitheesh' : null,
        products: [
          _DocProductLine(
            name: 'Vitrified Tile 600x600',
            company: 'Kajaria',
            sqft: sqft1,
            rate: rate1,
            amount: amount1,
          ),
          _DocProductLine(
            name: 'Wall Tile 300x450',
            company: 'Somany',
            sqft: sqft2,
            rate: rate2,
            amount: amount2,
          ),
        ],
      );
    })..sort((a, b) => b.date.compareTo(a.date));
  }

  void _openDocumentList(_DocType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DocumentListScreen(
          type: type,
          person: _selectedPerson,
          fromDate: _fromDate,
          toDate: _toDate,
          documents: _generateDocuments(type),
          currency: _currency,
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Report', style: AppTextStyles.h6())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(24)),
          children: [
            _FilterCard(
              personType: _personType,
              personTypes: _personTypes,
              onPersonTypeChanged: (v) {
                setState(() {
                  _personType = v;
                  _selectedPerson = _currentOptions.first;
                });
              },
              selectedPerson: _selectedPerson,
              options: _currentOptions,
              onPersonChanged: (p) => setState(() => _selectedPerson = p),
              fromDate: _dateFmt.format(_fromDate),
              toDate: _dateFmt.format(_toDate),
              onPickFrom: () => _pickDate(isFrom: true),
              onPickTo: () => _pickDate(isFrom: false),
            ),
            SizedBox(height: Responsive.h(18)),
            Text('Summary', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
            SizedBox(height: Responsive.h(10)),
            // Bills / Quotations / Sqft / Sale are now shown for BOTH
            // Salesman and Engineer/Contractor (previously contractor only
            // saw Sqft + Total Sale).
            _StatsGrid(
              noOfBills: _noOfBills,
              noOfQuotations: _noOfQuotations,
              totalSqft: _totalSqft,
              totalSale: _currency.format(_totalSale),
              onTapBills: () => _openDocumentList(_DocType.bill),
              onTapQuotations: () => _openDocumentList(_DocType.quotation),
            ),
            if (_isSalesman) ...[
              SizedBox(height: Responsive.h(20)),
              _IncentiveEntryCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SalesmanIncentiveScreen(salesmanName: _selectedPerson.name),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------- FILTER CARD ----------------

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.personType,
    required this.personTypes,
    required this.onPersonTypeChanged,
    required this.selectedPerson,
    required this.options,
    required this.onPersonChanged,
    required this.fromDate,
    required this.toDate,
    required this.onPickFrom,
    required this.onPickTo,
  });

  final String personType;
  final List<String> personTypes;
  final ValueChanged<String> onPersonTypeChanged;
  final _PersonOption selectedPerson;
  final List<_PersonOption> options;
  final ValueChanged<_PersonOption> onPersonChanged;
  final String fromDate;
  final String toDate;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: personTypes.map((t) {
              final selected = t == personType;
              return Padding(
                padding: EdgeInsets.only(right: Responsive.w(8)),
                child: ChoiceChip(
                  label: Text(t),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  labelStyle: AppTextStyles.bodyBold(color: selected ? Colors.white : AppColors.textPrimary)
                      .copyWith(fontSize: 12.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  onSelected: (_) => onPersonTypeChanged(t),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: Responsive.h(14)),
          Text(personType == 'Salesman' ? 'Salesman' : 'Engineer/Contractor', style: AppTextStyles.caption()),
          SizedBox(height: Responsive.h(6)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_PersonOption>(
                value: selectedPerson,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: options
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text('${p.name}  ·  ${p.mobile}', style: AppTextStyles.bodyBold().copyWith(fontSize: 13)),
                ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onPersonChanged(v);
                },
              ),
            ),
          ),
          SizedBox(height: Responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: _DatePickField(label: 'From', value: fromDate, onTap: onPickFrom),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: _DatePickField(label: 'To', value: toDate, onTap: onPickTo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePickField extends StatelessWidget {
  const _DatePickField({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        SizedBox(height: Responsive.h(6)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(11)),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(8)),
                Text(value, style: AppTextStyles.bodyBold().copyWith(fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- STATS GRID ----------------

/// Shows all 4 tiles for BOTH Salesman and Engineer/Contractor: No. of
/// Bills and No. of Quotations (tappable, opens a date-wise document
/// list) plus Total Sqft and Total Sale.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.noOfBills,
    required this.noOfQuotations,
    required this.totalSqft,
    required this.totalSale,
    required this.onTapBills,
    required this.onTapQuotations,
  });

  final int noOfBills;
  final int noOfQuotations;
  final double totalSqft;
  final String totalSale;
  final VoidCallback onTapBills;
  final VoidCallback onTapQuotations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _StatTile(
                icon: Icons.receipt_long_rounded,
                label: 'No. of Bills',
                value: '$noOfBills',
                color: AppColors.primary,
                onTap: onTapBills,
              ),
              SizedBox(height: Responsive.h(10)),
              _StatTile(icon: Icons.square_foot_rounded, label: 'Total Sqft', value: totalSqft.toStringAsFixed(0), color: AppColors.warning),
            ],
          ),
        ),
        SizedBox(width: Responsive.w(10)),
        Expanded(
          child: Column(
            children: [
              _StatTile(
                icon: Icons.request_quote_outlined,
                label: 'No. of Quot',
                value: '$noOfQuotations',
                color: AppColors.info,
                onTap: onTapQuotations,
              ),
              SizedBox(height: Responsive.h(10)),
              _StatTile(icon: Icons.currency_rupee_rounded, label: 'Total Sale', value: totalSale, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, required this.color, this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(12)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14)),
                    ),
                    Text(label, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              if (tappable) const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- INCENTIVE ENTRY CARD ----------------

/// Salesman-only entry point that replaces the old inline incentive
/// section — tapping it opens the dedicated [SalesmanIncentiveScreen].
class _IncentiveEntryCard extends StatelessWidget {
  const _IncentiveEntryCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('View Incentive Details', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14))),
                    SizedBox(height: Responsive.h(2)),
                    Text('Product-wise incentive & monthly target', style: AppTextStyles.caption()),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- BILLS / QUOTATIONS LIST SCREEN ----------------

/// Lists every Bill / Quotation raised by [person] between [fromDate] and
/// [toDate]. Styled the same way as the Owner Estimates screen: a search
/// bar and cards. No status is shown or filtered on. Tapping a card opens
/// [_DocumentDetailScreen].
class _DocumentListScreen extends StatefulWidget {
  const _DocumentListScreen({
    required this.type,
    required this.person,
    required this.fromDate,
    required this.toDate,
    required this.documents,
    required this.currency,
  });

  final _DocType type;
  final _PersonOption person;
  final DateTime fromDate;
  final DateTime toDate;
  final List<_DocumentItem> documents;
  final NumberFormat currency;

  @override
  State<_DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<_DocumentListScreen> {
  final _searchCtrl = TextEditingController();

  String get _title => widget.type == _DocType.bill ? 'Bills' : 'Quotations';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_DocumentItem> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return widget.documents.where((d) {
      final matchesSearch = q.isEmpty ||
          d.customerName.toLowerCase().contains(q) ||
          d.customerMobile.contains(q) ||
          d.id.toLowerCase().contains(q);
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final dateFmt = DateFormat('dd-MM-yyyy');
    final items = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_title, style: AppTextStyles.h6())),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search customer or ID',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  Container(
                    padding: EdgeInsets.all(Responsive.w(12)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.person.name, style: AppTextStyles.bodyBold()),
                              Text(widget.person.mobile, style: AppTextStyles.caption()),
                            ],
                          ),
                        ),
                        Text(
                          '${dateFmt.format(widget.fromDate)} – ${dateFmt.format(widget.toDate)}',
                          style: AppTextStyles.caption(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            Expanded(
              child: items.isEmpty
                  ? Center(
                child: Text('No $_title found', style: AppTextStyles.subtitle()),
              )
                  : ListView.separated(
                padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                itemBuilder: (context, i) {
                  final doc = items[i];
                  return _DocumentCard(
                    doc: doc,
                    currency: widget.currency,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _DocumentDetailScreen(
                          doc: doc,
                          person: widget.person,
                          currency: widget.currency,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card styled the same way as the Owner Estimates `_OwnerEstimateCard`,
/// minus the status badge — just customer, ID, contact/sqft, date and
/// amount.
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc, required this.currency, required this.onTap});
  final _DocumentItem doc;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBill = doc.type == _DocType.bill;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc.customerName, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: Responsive.h(4)),
            Text(
              '${isBill ? 'Bill' : 'Quotation'} No: ${doc.id}',
              style: AppTextStyles.caption(),
            ),
            SizedBox(height: Responsive.h(4)),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Expanded(
                  child: Text(
                    '${doc.customerMobile} · ${doc.sqft.toStringAsFixed(0)} sqft',
                    style: AppTextStyles.caption(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (doc.approvedBy != null) ...[
              SizedBox(height: Responsive.h(4)),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      'Approved by ${doc.approvedBy}',
                      style: AppTextStyles.caption(color: AppColors.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: Responsive.h(8)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd-MM-yyyy').format(doc.date), style: AppTextStyles.caption()),
                Text(currency.format(doc.amount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- DOCUMENT DETAIL SCREEN ----------------
// Styled the same way as OwnerEstimateDetailsScreen: a summary card with
// ID/date, a type chip, detail sections, an items DataTable, a totals
// box, and round edit/share icon buttons at the bottom. No status shown.

// Same placeholder incentive % pattern used on the salesman Estimate
// Details screen — replace with real per-product incentive % once
// admin-config exposes it.
const double _dummyDocIncentivePercent = 5.0;

double _incentiveAmountForDoc(_DocProductLine item) =>
    item.amount * _dummyDocIncentivePercent / 100;

class _DocumentDetailScreen extends StatelessWidget {
  const _DocumentDetailScreen({required this.doc, required this.person, required this.currency});
  final _DocumentItem doc;
  final _PersonOption person;
  final NumberFormat currency;

  bool get _isBill => doc.type == _DocType.bill;

  double get _incentiveTotal =>
      doc.products.fold(0.0, (s, item) => s + _incentiveAmountForDoc(item));

  String _buildShareText(NumberFormat currency, NumberFormat number) {
    final buffer = StringBuffer()
      ..writeln('${_isBill ? 'Bill' : 'Quotation'} ${doc.id}')
      ..writeln('Party Name: ${doc.customerName}')
      ..writeln('Party Address: ${doc.customerAddress}')
      ..writeln('Phone: ${doc.customerMobile}')
      ..writeln('Date: ${DateFormat('dd MMM yyyy').format(doc.date)}')
      ..writeln('---');
    for (final item in doc.products) {
      buffer.writeln('${item.name} (${item.company}) x ${item.sqft.toStringAsFixed(0)} sqft = ${currency.format(item.amount)}');
    }
    buffer
      ..writeln('---')
      ..writeln('Total Sqft: ${number.format(doc.sqft)}')
      ..writeln('Total: ${currency.format(doc.amount)}')
      ..writeln('Salesman: ${person.name}');
    if (doc.approvedBy != null) {
      buffer.writeln('Approved By: ${doc.approvedBy}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final number = NumberFormat.decimalPattern('en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isBill ? 'Bill Details' : 'Quotation Details', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  // Top summary card — Bill/Quotation No. + Date, matching
                  // the Owner Estimate Details layout.
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
                            Text(_isBill ? 'Bill No.' : 'Quotation No.', style: AppTextStyles.caption()),
                            Text(doc.id, style: AppTextStyles.h3()),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Date', style: AppTextStyles.caption()),
                            Text(DateFormat('dd-MM-yyyy').format(doc.date), style: AppTextStyles.h3()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_isBill ? 'Bill' : 'Quotation', style: AppTextStyles.bodyBold()),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  _DetailSection(
                    title: 'Party Details',
                    rows: [
                      _Row('Party Name', doc.customerName, icon: Icons.groups_2_outlined),
                      _Row('Party Address', doc.customerAddress, icon: Icons.location_on_outlined),
                      _Row('Phone Number', doc.customerMobile, icon: Icons.phone_outlined),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: 'Contractor Details',
                    rows: [
                      _Row('Contractor Name', doc.customerName, icon: Icons.engineering_outlined),
                      _Row('Contact No.', doc.customerMobile, icon: Icons.phone_outlined),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: 'Salesman',
                    rows: [
                      _Row('Name', person.name, icon: Icons.badge_outlined),
                    ],
                  ),
                  if (doc.approvedBy != null) ...[
                    SizedBox(height: Responsive.h(14)),
                    _DetailSection(
                      title: 'Approval',
                      rows: [
                        _Row('Approved By', doc.approvedBy!, icon: Icons.check_circle_outline),
                      ],
                    ),
                  ],
                  SizedBox(height: Responsive.h(20)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Products', style: AppTextStyles.h3()),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Items: ${doc.products.length}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(12)),

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
                          DataColumn(label: Text('Sqft'), numeric: true),
                          DataColumn(label: Text('Rate'), numeric: true),
                          DataColumn(label: Text('Amount'), numeric: true),
                          DataColumn(label: Text('Incentive'), numeric: true),
                        ],
                        rows: doc.products.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(item.name)),
                            DataCell(Text(item.company.isEmpty ? '-' : item.company)),
                            DataCell(Text(number.format(item.sqft))),
                            DataCell(Text(number.format(item.rate))),
                            DataCell(Text(
                              currency.format(item.amount),
                              style: AppTextStyles.bodyBold(),
                            )),
                            DataCell(Text(
                              currency.format(_incentiveAmountForDoc(item)),
                              style: AppTextStyles.bodyBold(color: AppColors.success),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Items', style: AppTextStyles.body()),
                            Text('${doc.products.length}', style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Sqft', style: AppTextStyles.body()),
                            Text(number.format(doc.sqft), style: AppTextStyles.body()),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_isBill ? 'Total Amount' : 'Quoted Amount', style: AppTextStyles.h3()),
                            Text(currency.format(doc.amount), style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  // Separate, visually distinct box for incentive so it's
                  // clear this is internal/salesman info, not part of the
                  // customer's total above. Values are dummy (5%) until
                  // admin-configured incentive data is wired up.
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
                            SizedBox(width: Responsive.w(6)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_dummyDocIncentivePercent.toStringAsFixed(0)}% · dummy',
                                style: AppTextStyles.caption(color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currency.format(_incentiveTotal),
                          style: AppTextStyles.h3(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onPressed: () {
                      // Hand this document off to your edit flow (e.g.
                      // re-open the create/edit screen pre-filled).
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wire this up to your edit flow')),
                      );
                    },
                  ),
                  SizedBox(width: Responsive.w(10)),
                  _RoundIconButton(
                    icon: Icons.share_outlined,
                    tooltip: 'Share',
                    onPressed: () async {
                      // Swap for `Share.share(...)` (share_plus package)
                      // once it's added to pubspec.yaml.
                      await Clipboard.setData(ClipboardData(text: _buildShareText(currency, number)));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Summary copied to clipboard')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _Row {
  final String label;
  final String value;
  final IconData? icon;
  _Row(this.label, this.value, {this.icon});
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

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
          SizedBox(height: Responsive.h(10)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 16, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                SizedBox(
                  width: r.icon != null ? 88 : 100,
                  child: Text(r.label, style: AppTextStyles.caption()),
                ),
                Expanded(
                  child: Text(
                    r.value.isEmpty ? '-' : r.value,
                    style: AppTextStyles.bodyBold(),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}