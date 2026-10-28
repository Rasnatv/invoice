

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DValidator {
  /// Max character limit for all text fields
  static const int maxTextLength = 50;

  /// Default expected length for a plain (no country code) mobile number.
  static const int defaultPhoneLength = 10;
  static const int maxPasswordLength = 18;
  static const int maxPaymentDigits = 15;

  static List<TextInputFormatter> get passwordLimit => [
    LengthLimitingTextInputFormatter(maxPasswordLength),
  ];
  static const int sizeMaxLength = 11;
  static String? validateSize(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Size is required';
    if (v.length > sizeMaxLength) {
      return 'Size must be at most $sizeMaxLength characters';
    }
    return null;
  }

  /// Any characters, capped at 11 chars.
  static List<TextInputFormatter> get sizeText => [
    LengthLimitingTextInputFormatter(sizeMaxLength),
  ];

  // ── Packing ───────────────────────────────────────────────
  static const int packingMaxLength = 20;

  /// Any characters, capped at 20 chars (e.g. "8pcs/box").
  static List<TextInputFormatter> get packingText => [
    LengthLimitingTextInputFormatter(packingMaxLength),
  ];

  // ── Generic empty check ───────────────────────────────────
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ── Unit (name / abbreviation) ────────────────────────────
  static const int unitNameMaxLength = 20;
  static const int unitAbbrMaxLength = 10;

  /// Unit name: any characters, capped at 20 chars.
  static List<TextInputFormatter> get unitNameText => [
    LengthLimitingTextInputFormatter(unitNameMaxLength),
  ];

  /// Abbreviation: any characters, capped at 10 chars.
  static List<TextInputFormatter> get unitAbbrText => [
    LengthLimitingTextInputFormatter(unitAbbrMaxLength),
  ];

  static List<TextInputFormatter> get paymentAmount =>
      decimalWithLimit(maxIntDigits: maxPaymentDigits);

  static String? validateUnitName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Unit name is required';
    if (v.length > unitNameMaxLength) {
      return 'Unit name must be at most $unitNameMaxLength characters';
    }
    return null;
  }

  static String? validateUnitAbbr(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Abbreviation is required';
    if (v.length > unitAbbrMaxLength) {
      return 'Abbreviation must be at most $unitAbbrMaxLength characters';
    }
    return null;
  }

  // ── Brand / Company (name / code) ─────────────────────────
  static const int brandNameMaxLength = 20;
  static const int brandCodeMaxLength = 10;

  /// Brand name: any characters, capped at 20 chars.
  static List<TextInputFormatter> get brandNameText => [
    LengthLimitingTextInputFormatter(brandNameMaxLength),
  ];

  /// Brand code: any characters, capped at 10 chars.
  static List<TextInputFormatter> get brandCodeText => [
    LengthLimitingTextInputFormatter(brandCodeMaxLength),
  ];

  static String? validateBrandName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Brand name is required';
    if (v.length > brandNameMaxLength) {
      return 'Brand name must be at most $brandNameMaxLength characters';
    }
    return null;
  }

  static String? validateBrandCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Brand code is required';
    if (v.length > brandCodeMaxLength) {
      return 'Brand code must be at most $brandCodeMaxLength characters';
    }
    return null;
  }

  // ── Designation ───────────────────────────────────────────
  static const int designationMaxLength = 20;

  /// Letters, spaces, apostrophes and hyphens only, capped at 20 chars.
  static List<TextInputFormatter> get designationText => [
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
    LengthLimitingTextInputFormatter(designationMaxLength),
  ];

  static String? validateDesignation(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Designation is required';
    if (v.length < 2) return 'Designation name must be at least 2 characters';
    if (v.length > designationMaxLength) {
      return 'Designation must be at most $designationMaxLength characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(v)) {
      return 'Enter a valid Designation';
    }
    return null;
  }

  static String? validateRequired(String? value, {String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? validateAlphaOnly(String fieldName, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return '$fieldName is required';
    }
    if (v.length > maxTextLength) {
      return '$fieldName must be at most $maxTextLength characters';
    }
    if (RegExp(r'[0-9]').hasMatch(v)) {
      return '$fieldName cannot contain numbers';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(v)) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }

  static List<TextInputFormatter> get alphaOnly => [
    FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
    LengthLimitingTextInputFormatter(maxTextLength),
  ];

  static String? validateName(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length > maxTextLength) {
      return '$fieldName must be at most $maxTextLength characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (value.trim().length > maxTextLength) {
      return 'Email must be at most $maxTextLength characters';
    }
    final emailRegExp = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]+$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // ── Phone number ──────────────────────────────────────────
  /// Plain string validator, no package dependency. Defaults to exactly
  /// 10 digits — pass `length:` if a screen needs a different country's
  /// number length.
  static String? validatePhoneNumber(String? value, {int length = defaultPhoneLength}) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phone = value.trim();

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'Phone number must contain digits only';
    }
    if (phone.length != length) {
      return 'Enter a valid $length-digit phone number';
    }
    return null;
  }

  /// Digits only, capped at 10 chars — attach directly to a TextField's
  /// inputFormatters for a plain mobile number field.
  static List<TextInputFormatter> get phoneNumber => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(defaultPhoneLength),
  ];

  // ── Vehicle number ────────────────────────────────────────
  /// Vehicle number is exactly 10 letters/digits (no fixed pattern).
  static const int vehicleNumberMaxLength = 10;

  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle number is required';
    }

    final v = value.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');

    // Only letters and numbers allowed
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(v)) {
      return 'Only letters and numbers are allowed';
    }

    if (v.length != vehicleNumberMaxLength) {
      return 'Vehicle number must be $vehicleNumberMaxLength characters';
    }

    return null;
  }

  /// Letters + digits only, auto-uppercased, capped at 10 chars —
  /// attach directly to the vehicle number field's inputFormatters.
  static List<TextInputFormatter> get vehicleNumber => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    UpperCaseTextFormatter(),
    LengthLimitingTextInputFormatter(vehicleNumberMaxLength),
  ];

  // ── Licence number ────────────────────────────────────────
  /// Indian driving licence numbers are 15 characters (any state).
  static const int licenseNumberLength = 15;

  static String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }
    final v = value.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');

    // Letters and numbers only (any state)
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(v)) {
      return 'Only letters and numbers are allowed';
    }

    if (v.length != licenseNumberLength) {
      return 'License number must be exactly $licenseNumberLength characters';
    }
    return null;
  }

  /// Letters + digits only, auto-uppercased, capped at 15 chars —
  /// attach directly to the license number field's inputFormatters.
  static List<TextInputFormatter> get licenseNumber => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    UpperCaseTextFormatter(),
    LengthLimitingTextInputFormatter(licenseNumberLength),
  ];

  // ── Dropdown / selection ──────────────────────────────────
  static String? validateDropdown<T>(String? fieldName, T? value) {
    if (value == null) {
      return 'Please select a $fieldName';
    }
    return null;
  }

  static List<TextInputFormatter> get digitsOnly => [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Letters and spaces only — use on name fields
  static List<TextInputFormatter> get lettersOnly => [
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
    LengthLimitingTextInputFormatter(maxTextLength),
  ];

  /// General text with max 100 char limiter
  static List<TextInputFormatter> get textWithLimit => [
    LengthLimitingTextInputFormatter(maxTextLength),
  ];

  static List<TextInputFormatter> get postalCode => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s-]')),
    LengthLimitingTextInputFormatter(10),
  ];

  static String? validateOptionalNumber(String fieldName, String? value, {double? max}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // optional field, nothing typed is fine
    final n = double.tryParse(v);
    if (n == null) {
      return 'Enter a valid $fieldName';
    }
    if (n < 0) {
      return '$fieldName cannot be negative';
    }
    if (max != null && n > max) {
      return '$fieldName must be at most $max';
    }
    return null;
  }

  /// Digits + a single decimal point — use on sqft/budget fields.
  static List<TextInputFormatter> get decimalNumber => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    LengthLimitingTextInputFormatter(12),
  ];

  // ── Quantity / Price limits ───────────────────────────────
  /// Quantity: max 5 integer digits (99999)
  static const int maxQuantityDigits = 5;
  static const double maxQuantity = 99999;

  /// Price / amount: max 8 integer digits (up to 9,99,99,999 – crore range)
  static const int maxPriceDigits = 8;
  static const double maxPrice = 99999999;

  /// Decimal input with a cap on integer digits and decimal places.
  static List<TextInputFormatter> decimalWithLimit({
    required int maxIntDigits,
    int maxDecimals = 2,
  }) =>
      [LimitedDecimalFormatter(maxIntDigits: maxIntDigits, maxDecimals: maxDecimals)];

  /// Quantity fields: up to 5 digits + 2 decimals
  static List<TextInputFormatter> get quantityNumber =>
      decimalWithLimit(maxIntDigits: maxQuantityDigits);

  /// Rate / price / amount fields: up to 8 digits + 2 decimals
  static List<TextInputFormatter> get priceNumber =>
      decimalWithLimit(maxIntDigits: maxPriceDigits);

  // ── Incentive setup ───────────────────────────────────────
  /// Monthly target: up to 8 integer digits (9,99,99,999)
  static const int maxTargetDigits = 8;
  static const double maxTarget = 99999999;

  /// Fixed incentive: up to 7 integer digits (99,99,999)
  static const int maxFixedBonusDigits = 7;
  static const double maxFixedBonus = 9999999;

  /// Percentage incentive can never go above 100.
  static const double maxBonusPercent = 100;

  static List<TextInputFormatter> get targetNumber =>
      decimalWithLimit(maxIntDigits: maxTargetDigits);

  static List<TextInputFormatter> get fixedBonusNumber =>
      decimalWithLimit(maxIntDigits: maxFixedBonusDigits);

  /// Percent: up to 3 integer digits (so "100" can be typed); the
  /// validator caps the value at 100.
  static List<TextInputFormatter> get percentNumber =>
      decimalWithLimit(maxIntDigits: 3);

  static final NumberFormat _inr = NumberFormat.decimalPattern('en_IN');

  static String? validateTargetAmount(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Target amount is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid target amount';
    if (n <= 0) return 'Target amount must be greater than 0';
    if (n > maxTarget) {
      return 'Target amount must be at most ₹${_inr.format(maxTarget)}';
    }
    return null;
  }

  /// Validates the incentive value.
  /// - Percentage: must be > 0 and <= 100.
  /// - Fixed: must be > 0, <= [maxFixedBonus], and not above the target
  ///   (pass the target field's text in [targetText] when a target is set).
  static String? validateBonusValue(
      String? value, {
        required bool isPercent,
        String? targetText,
      }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return isPercent ? 'Percentage is required' : 'Incentive amount is required';
    }
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid value';
    if (n <= 0) return 'Must be greater than 0';

    if (isPercent) {
      if (n > maxBonusPercent) return 'Percentage cannot exceed 100%';
      return null;
    }

    if (n > maxFixedBonus) {
      return 'Incentive must be at most ₹${_inr.format(maxFixedBonus)}';
    }

    final target = double.tryParse(targetText?.trim() ?? '');
    if (target != null && target > 0 && n > target) {
      return 'Incentive cannot exceed the target amount';
    }
    return null;
  }

  // ── MRP / Selling rate ────────────────────────────────────
  /// MRP / Selling rate: max 8 integer digits (9,99,99,999) + 2 decimals
  static const int maxMrpDigits = 8;
  static const double maxMrp = 99999999;

  static List<TextInputFormatter> get mrpNumber =>
      decimalWithLimit(maxIntDigits: maxMrpDigits);

  static String? validateMrp(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'MRP is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid MRP';
    if (n <= 0) return 'MRP must be greater than 0';
    if (n > maxMrp) return 'MRP must be at most ₹${_inr.format(maxMrp)}';
    return null;
  }

  static String? validateRate(String? value, {String? mrpText}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Selling rate is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid selling rate';
    if (n <= 0) return 'Selling rate must be greater than 0';
    if (n > maxMrp) return 'Selling rate must be at most ₹${_inr.format(maxMrp)}';

    // Selling rate should not be higher than MRP
    final mrp = double.tryParse(mrpText?.trim() ?? '');
    if (mrp != null && n > mrp) {
      return 'Selling rate cannot exceed MRP';
    }
    return null;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Rejects any edit that would exceed [maxIntDigits] before the decimal
/// point or [maxDecimals] after it.
class LimitedDecimalFormatter extends TextInputFormatter {
  LimitedDecimalFormatter({required int maxIntDigits, int maxDecimals = 2})
      : _regExp = RegExp(r'^\d{0,' '$maxIntDigits' r'}(\.\d{0,' '$maxDecimals' r'})?$');

  final RegExp _regExp;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return _regExp.hasMatch(newValue.text) ? newValue : oldValue;
  }
}