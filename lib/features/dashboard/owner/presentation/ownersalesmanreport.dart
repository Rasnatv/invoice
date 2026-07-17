import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../salesman/incentive/salesmanincentivescreen.dart';
/// UI-only screen — no cubit dependency, since ReportsScreen is opened
/// directly from the dashboard (no BlocProvider.value).
///
/// Lets the owner pick a Salesman OR an Engineer/Contractor, a date
/// range, and see: no. of bills, no. of quotations, total sqft, and
/// total sale for that period.
///
/// Engineer/Contractor doesn't raise bills/quotations directly, so those
/// two stat tiles are hidden for that person type — only Sqft + Sale show.
/// For Salesman, the Bills / Quotations tiles are tappable and open a
/// date-wise list of that person's documents for the selected range,
/// which in turn opens a full detail screen per document.
///
/// Incentive breakdown is NOT shown inline here anymore — it now lives on
/// its own dedicated [SalesmanIncentiveScreen], reachable via the
/// "View Incentive Details" card below (Salesman only). That screen shows
/// product-wise incentive with a per-product, date-wise sales drill-down.
///
/// TODO(backend): replace `_salesmen`, `_contractors`, `_buildReport()`'s
/// dummy numbers, and `_generateDocuments()` with real aggregation over
/// OwnerCubit's estimates for the selected person + date range.
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
    required this.sqft,
    required this.amount,
    required this.type,
    required this.products,
  });
  final String id;
  final DateTime date;
  final String customerName;
  final String customerMobile;
  final double sqft;
  final double amount;
  final _DocType type;
  final List<_DocProductLine> products;
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
    final prefix = type == _DocType.bill ? 'BILL' : 'QTN';

    final customers = [
      'Anil Nair',
      'Beena Thomas',
      'Chandran K.',
      'Deepa Varma',
      'Faisal Rahman',
      'Geetha Pillai',
    ];

    return List.generate(count, (i) {
      final dayOffset = ((seed + i * 13) % totalSpan);
      final date = _fromDate.add(Duration(days: dayOffset));
      final customer = customers[(seed + i) % customers.length];
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
        sqft: sqft,
        amount: amount1 + amount2,
        type: type,
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
            _StatsGrid(
              isSalesman: _isSalesman,
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

/// For a Salesman, shows all 4 tiles (Bills + Quotations are tappable and
/// open a date-wise document list). For an Engineer/Contractor — who
/// doesn't raise bills/quotations directly — only Sqft + Total Sale show.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.isSalesman,
    required this.noOfBills,
    required this.noOfQuotations,
    required this.totalSqft,
    required this.totalSale,
    required this.onTapBills,
    required this.onTapQuotations,
  });

  final bool isSalesman;
  final int noOfBills;
  final int noOfQuotations;
  final double totalSqft;
  final String totalSale;
  final VoidCallback onTapBills;
  final VoidCallback onTapQuotations;

  @override
  Widget build(BuildContext context) {
    if (!isSalesman) {
      // Engineer/Contractor: no bills/quotations, just sqft + sale.
      return Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.square_foot_rounded,
              label: 'Total Sqft',
              value: totalSqft.toStringAsFixed(0),
              color: AppColors.warning,
            ),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: _StatTile(
              icon: Icons.currency_rupee_rounded,
              label: 'Total Sale',
              value: totalSale,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }

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

// ---------------- DATE-WISE DOCUMENT LIST SCREEN ----------------

/// Shows every Bill / Quotation raised by [person] between [fromDate] and
/// [toDate], grouped date-wise (most recent first). Tapping a row opens
/// [_DocumentDetailScreen].
class _DocumentListScreen extends StatelessWidget {
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

  String get _title => type == _DocType.bill ? 'Bills' : 'Quotations';

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final dateFmt = DateFormat('dd-MM-yyyy');
    final groupFmt = DateFormat('dd MMM, yyyy');

    // group date-wise, newest date first (documents already sorted desc).
    final Map<String, List<_DocumentItem>> grouped = {};
    for (final doc in documents) {
      final key = groupFmt.format(doc.date);
      grouped.putIfAbsent(key, () => []).add(doc);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title, style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: documents.isEmpty
            ? Center(
          child: Text('No $_title found in this period', style: AppTextStyles.caption()),
        )
            : ListView(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(24)),
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.w(12)),
              margin: EdgeInsets.only(bottom: Responsive.h(16)),
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
                        Text(person.name, style: AppTextStyles.bodyBold()),
                        Text(person.mobile, style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                  Text(
                    '${dateFmt.format(fromDate)} – ${dateFmt.format(toDate)}',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
            for (final entry in grouped.entries) ...[
              Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(8), top: Responsive.h(4)),
                child: Text(
                  entry.key,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13), color: AppColors.textSecondary),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: Responsive.h(16)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < entry.value.length; i++) ...[
                      _DocumentTile(
                        doc: entry.value[i],
                        currency: currency,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _DocumentDetailScreen(
                                doc: entry.value[i],
                                person: person,
                                currency: currency,
                              ),
                            ),
                          );
                        },
                      ),
                      if (i != entry.value.length - 1)
                        Divider(height: 1, indent: Responsive.w(14), endIndent: Responsive.w(14), color: AppColors.border),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.doc, required this.currency, required this.onTap});
  final _DocumentItem doc;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBill = doc.type == _DocType.bill;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isBill ? AppColors.primary : AppColors.info).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isBill ? Icons.receipt_long_rounded : Icons.request_quote_outlined,
                color: isBill ? AppColors.primary : AppColors.info,
                size: 18,
              ),
            ),
            SizedBox(width: Responsive.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.id, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: Responsive.h(2)),
                  Text('${doc.customerName} · ${doc.sqft.toStringAsFixed(0)} sqft', style: AppTextStyles.caption()),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currency.format(doc.amount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
                SizedBox(height: Responsive.h(2)),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- DOCUMENT DETAIL SCREEN ----------------

class _DocumentDetailScreen extends StatelessWidget {
  const _DocumentDetailScreen({required this.doc, required this.person, required this.currency});
  final _DocumentItem doc;
  final _PersonOption person;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isBill = doc.type == _DocType.bill;
    final dateFmt = DateFormat('dd MMM, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(isBill ? 'Bill Details' : 'Quotation Details', style: AppTextStyles.h6())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(24)),
          children: [
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(doc.id, style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isBill ? AppColors.primary : AppColors.info).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isBill ? 'BILL' : 'QUOTATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isBill ? AppColors.primary : AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(dateFmt.format(doc.date), style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(14)),
                  const Divider(height: 1, color: AppColors.border),
                  SizedBox(height: Responsive.h(14)),
                  Text('Customer', style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(4)),
                  Text(doc.customerName, style: AppTextStyles.bodyBold()),
                  Text(doc.customerMobile, style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(14)),
                  const Divider(height: 1, color: AppColors.border),
                  SizedBox(height: Responsive.h(14)),
                  Text(
                    isBill ? 'Billed By' : 'Prepared By',
                    style: AppTextStyles.caption(),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(person.name, style: AppTextStyles.bodyBold()),
                  Text(person.mobile, style: AppTextStyles.caption()),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(20)),
            Text('Products', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
            SizedBox(height: Responsive.h(10)),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < doc.products.length; i++) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.products[i].name, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                SizedBox(height: Responsive.h(2)),
                                Text(
                                  '${doc.products[i].company} · ${doc.products[i].sqft.toStringAsFixed(0)} sqft × ${currency.format(doc.products[i].rate)}',
                                  style: AppTextStyles.caption(),
                                ),
                              ],
                            ),
                          ),
                          Text(currency.format(doc.products[i].amount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    if (i != doc.products.length - 1)
                      Divider(height: 1, indent: Responsive.w(14), endIndent: Responsive.w(14), color: AppColors.border),
                  ],
                ],
              ),
            ),
            SizedBox(height: Responsive.h(20)),
            Container(
              padding: EdgeInsets.all(Responsive.w(14)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Sqft', style: AppTextStyles.caption()),
                      Text(doc.sqft.toStringAsFixed(0), style: AppTextStyles.bodyBold()),
                    ],
                  ),
                  SizedBox(height: Responsive.h(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isBill ? 'Total Amount' : 'Quoted Amount', style: AppTextStyles.bodyBold()),
                      Text(
                        currency.format(doc.amount),
                        style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: 16),
                      ),
                    ],
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
