
import 'package:flutter/services.dart';

class DValidator {
  /// Max character limit for all text fields
  static const int maxTextLength = 100;

  /// Default expected length for a plain (no country code) mobile number.
  static const int defaultPhoneLength = 10;

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

  // ── Vehicle number (India) ─────────────────────────────────
  /// Standard format: SS DD AA NNNN  e.g. KL07AB1234
  ///   SS   = 2-letter state code
  ///   DD   = 1-2 digit RTO/district code
  ///   AA   = 0-3 letter series (some older plates skip this)
  ///   NNNN = 4-digit number
  /// Also matches the newer BH-series: 22BH1234AB
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
    if (v.length < 9 || v.length > vehicleNumberMaxLength) {
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

  // ── Driving License number (India) ─────────────────────────
  /// Standard format: SS RR YYYY NNNNNNN  e.g. KL0720230012345
  ///   SS      = 2-letter state code
  ///   RR      = 2-digit RTO code
  ///   YYYY    = 4-digit issue year
  ///   NNNNNNN = 7-digit serial number
  /// Total length is always 15 characters.
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

  // ── Optional decimal number (e.g. area sqft, budget) ──────
  /// For optional numeric fields. Empty is allowed (returns null).
  /// If something is typed, it must be a valid non-negative number.
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
}

/// Forces all typed text to uppercase — used for vehicle/license fields
/// since Indian registration formats are always uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}