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
}