import 'package:flutter/material.dart';

/// A product that a salesman earns incentive on.
class IncentiveProduct {
  const IncentiveProduct({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.saleValue,
    required this.units,
    required this.incentivePercent,
    required this.incentiveEarned,
    required this.unitLabel,
  });

  final String name;
  final IconData icon;
  final Color iconColor;
  final double saleValue;
  final int units;
  final double incentivePercent;
  final double incentiveEarned;

  /// Quantity unit shown to the user for this product — e.g. tiles are sold
  /// in Sq.Ft, pipes in Running Ft, packaged FMCG items in Units.
  final String unitLabel;
}

/// A single dated sale of one [IncentiveProduct], billed against an
/// estimation/quotation number and sold to a contractor.
class ProductSaleEntry {
  const ProductSaleEntry({
    required this.saleDate,
    required this.dispatchedDate,
    required this.estimationNumber,
    required this.contractorName,
    required this.units,
    required this.saleValue,
    required this.incentiveEarned,
  });

  /// Date the sale / booking was made.
  final DateTime saleDate;

  /// Date the material was actually dispatched from the store/warehouse.
  final DateTime dispatchedDate;

  /// The estimate / quotation number this sale was billed against, e.g.
  /// "EST/2026/07/103".
  final String estimationNumber;

  /// Site contractor the material was sold to.
  final String contractorName;

  /// Quantity sold — interpret using the parent product's [IncentiveProduct.unitLabel]
  /// (Sq.Ft / Running Ft / Units).
  final int units;

  final double saleValue;
  final double incentiveEarned;
}

/// Mock data generator — swap this out for a real API/DB call when ready.
/// Kept here so both the list screen and the detail screen generate
/// consistent numbers from the same seed.
class IncentiveMockData {
  static const List<String> contractors = [
    'Nair Constructions',
    'Thomas Builders',
    'Chandran Associates',
    'Varma Infra Projects',
    'Rahman Contractors',
    'Pillai Engineering Works',
  ];

  static List<IncentiveProduct> products(String salesmanName, DateTime month) {
    final seed = salesmanName.length + month.month * 7;
    return [
      IncentiveProduct(
        name: 'Tile',
        icon: Icons.grid_view_rounded,
        iconColor: const Color(0xFF8D6E63),
        saleValue: 125000 + (seed % 5) * 1000,
        units: 250 + (seed % 5) * 2,
        incentivePercent: 5,
        incentiveEarned: (125000 + (seed % 5) * 1000) * 0.05,
        unitLabel: 'Sq.Ft',
      ),
      IncentiveProduct(
        name: 'Pipe',
        icon: Icons.plumbing_rounded,
        iconColor: const Color(0xFF43A047),
        saleValue: 85000 + (seed % 4) * 800,
        units: 170 + (seed % 4) * 2,
        incentivePercent: 4,
        incentiveEarned: (85000 + (seed % 4) * 800) * 0.04,
        unitLabel: 'Running Ft',
      ),
      IncentiveProduct(
        name: 'Protein Powder',
        icon: Icons.fitness_center_rounded,
        iconColor: const Color(0xFF6D4C41),
        saleValue: 140000 + (seed % 3) * 900,
        units: 100 + (seed % 3) * 3,
        incentivePercent: 6,
        incentiveEarned: (140000 + (seed % 3) * 900) * 0.06,
        unitLabel: 'Units',
      ),
      IncentiveProduct(
        name: 'Orange Juice 1L',
        icon: Icons.local_drink_rounded,
        iconColor: const Color(0xFFFB8C00),
        saleValue: 60000 + (seed % 6) * 500,
        units: 120 + (seed % 6) * 2,
        incentivePercent: 3,
        incentiveEarned: (60000 + (seed % 6) * 500) * 0.03,
        unitLabel: 'Units',
      ),
      IncentiveProduct(
        name: 'Healthy Cookies',
        icon: Icons.cookie_rounded,
        iconColor: const Color(0xFF3F51B5),
        saleValue: 48750 + (seed % 7) * 400,
        units: 195 + (seed % 7) * 2,
        incentivePercent: 2,
        incentiveEarned: (48750 + (seed % 7) * 400) * 0.02,
        unitLabel: 'Units',
      ),
    ];
  }

  static List<ProductSaleEntry> salesFor({
    required IncentiveProduct product,
    required DateTime month,
    required String salesmanName,
  }) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final seed = salesmanName.length + product.name.length;
    final entryCount = 6 + (seed % 6);

    final entries = List.generate(entryCount, (i) {
      final saleDay = 1 + ((seed + i * 5) % daysInMonth);
      // Dispatch typically happens a day or a few days after the sale/booking,
      // capped to the last day of the month.
      final dispatchLag = 1 + (i % 4);
      final dispatchDay = (saleDay + dispatchLag).clamp(1, daysInMonth);

      final units = 5 + ((seed + i * 3) % 20);
      final unitValue = product.saleValue / product.units;
      final saleValue = units * unitValue;
      final estimationNumber =
          'EST/${month.year}/${month.month.toString().padLeft(2, '0')}/${(101 + i + seed % 50).toString().padLeft(3, '0')}';

      return ProductSaleEntry(
        saleDate: DateTime(month.year, month.month, saleDay),
        dispatchedDate: DateTime(month.year, month.month, dispatchDay),
        estimationNumber: estimationNumber,
        contractorName: contractors[(seed + i) % contractors.length],
        units: units,
        saleValue: saleValue,
        incentiveEarned: saleValue * (product.incentivePercent / 100),
      );
    });
    entries.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    return entries;
  }
}