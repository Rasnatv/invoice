
import 'package:flutter/services.dart';

class DValidator {
  /// Max character limit for all text fields
  static const int maxTextLength = 100;

  /// Default expected length for a plain (no country code) mobile number.
  static const int defaultPhoneLength = 10;
  static const int maxPasswordLength = 18;

  static List<TextInputFormatter> get passwordLimit => [
    LengthLimitingTextInputFormatter(maxPasswordLength),
  ];

  // ── Generic empty check ───────────────────────────────────
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
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

  static final RegExp _vehicleNumberRegExp = RegExp(
    r'^[A-Z]{2}[0-9]{1,2}[A-Z]{0,3}[0-9]{4}$|^[0-9]{2}BH[0-9]{4}[A-Z]{1,2}$',
  );

  /// Max raw characters allowed while typing (before/without validation),
  /// used to cap the field length. Longest valid form (SS+DD+AAA+NNNN) is 11.
  static const int vehicleNumberMaxLength = 11;

  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle number is required';
    }
    final v = value.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');
    if (v.length < 10 || v.length > vehicleNumberMaxLength) {
      return 'Vehicle number must be 9-$vehicleNumberMaxLength characters';
    }
    if (!_vehicleNumberRegExp.hasMatch(v)) {
      return 'Enter a valid vehicle number e.g. KL07AB1234';
    }
    return null;
  }

  /// Letters + digits only, auto-uppercased, capped at 11 chars —
  /// attach directly to the vehicle number field's inputFormatters.
  static List<TextInputFormatter> get vehicleNumber => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    UpperCaseTextFormatter(),
    LengthLimitingTextInputFormatter(vehicleNumberMaxLength),
  ];

  static final RegExp _licenseNumberRegExp = RegExp(
    r'^[A-Z]{2}[0-9]{2}[0-9]{4}[0-9]{7}$',
  );

  static const int licenseNumberLength = 15;

  static String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }
    final v = value.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');
    if (v.length != licenseNumberLength) {
      return 'License number must be exactly $licenseNumberLength characters';
    }
    if (!_licenseNumberRegExp.hasMatch(v)) {
      return 'Enter a valid license number e.g. KL0720230012345';
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