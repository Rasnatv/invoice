
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../ui/auth/login_screen.dart';
import '../network/tokenstorage.dart';
import '../../router/approuter.dart';

class ApiErrorHandler {
  // Prevents multiple concurrent 401 responses from each pushing
  // LoginScreen separately (duplicate route entries in the nav stack).
  static bool _isHandlingUnauthorized = false;

  static Future<String> handleDioError(DioException e) async {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final message = _extractErrorMessage(responseData);

    String errorMsg;

    switch (statusCode) {
      case 400:
        errorMsg = message ?? "Bad request. Please try again.";
        break;
      case 401:
        errorMsg = message ?? "Session expired. Please log in again.";
        await _handleUnauthorized();
        break;
      case 403:
        errorMsg = message ?? "Access denied.";
        break;
      case 404:
        errorMsg = message ?? "Not found.";
        break;
      case 422:
        errorMsg = message ?? "Validation error. Please check your input.";
        break;
      case 429:
        errorMsg = "Too many requests. Please try again.";
        break;
      case 500:
        errorMsg = message ?? "Server error. Try again later.";
        break;
      case 508:
        errorMsg = "Resource limit reached. Please try again later.";
        break;
      default:
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMsg = "Request timed out. Check your internet connection.";
            break;
          case DioExceptionType.connectionError:
            errorMsg = "Could not connect. Check your internet connection.";
            break;
          case DioExceptionType.cancel:
            errorMsg = "Request cancelled.";
            break;
          case DioExceptionType.unknown:
          default:
            errorMsg = _handleException(e.error);
        }
    }

    return errorMsg;
  }

  static String? _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData == null) return null;

      if (responseData is Map<String, dynamic>) {
        if (responseData['message'] != null) return responseData['message'].toString();
        if (responseData['error'] != null) return responseData['error'].toString();

        if (responseData['errors'] is Map<String, dynamic>) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) return firstValue.first.toString();
            return firstValue.toString();
          }
        }
      }

      if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return decoded['message']?.toString() ?? decoded['error']?.toString();
          }
          return responseData;
        } catch (_) {
          return responseData.isNotEmpty ? responseData : null;
        }
      }
    } catch (_) {}

    return null;
  }

  static Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    try {
      final token = await TokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        await TokenStorage.clear();
        AppRouter.router.go('/login'); // go_router, not pushAndRemoveUntil
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  static String _handleException(Object? error) {
    if (error is SocketException) return "No internet connection.";
    return "Unexpected error occurred.";
  }
}