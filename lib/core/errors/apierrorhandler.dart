import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final message = _extractErrorMessage(responseData);

    String errorMsg;

    if (error.response != null) {
      switch (statusCode) {
        case 400:
          errorMsg = message ?? "Bad request. Please try again.";
          break;
        case 401:
          errorMsg = message ?? "Authentication failed.";
          // _handleUnauthorizedIfLoggedIn();
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
          errorMsg = message ?? "Too many requests. Please try again!";
          break;
        case 500:
          errorMsg = message ?? "Server error. Try again later.";
          break;
        default:
          errorMsg = message ?? "Something went wrong.";
      }
    } else {
      // Handle connection errors
      switch (error.type) {
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
          errorMsg = _handleException(error);
      }
    }

    return errorMsg;
  }

  static String? _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData == null) return null;

      // If already a Map
      if (responseData is Map<String, dynamic>) {
        // First priority: 'message' key
        if (responseData.containsKey('message')) {
          return responseData['message']?.toString();
        }

        // Second priority: 'error' key
        if (responseData.containsKey('error')) {
          return responseData['error']?.toString();
        }

        // Third priority: 'errors' array
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is Map<String, dynamic> && errors.isNotEmpty) {
            final firstKey = errors.keys.first;
            final firstError = errors[firstKey];
            if (firstError is List && firstError.isNotEmpty) {
              return firstError[0].toString();
            }
          }
        }
      }

      // If it's a JSON string, decode it
      if (responseData is String) {
        try {
          final decoded = Map<String, dynamic>.from(jsonDecode(responseData));
          if (decoded.containsKey('message')) {
            return decoded['message']?.toString();
          }
          if (decoded.containsKey('error')) {
            return decoded['error']?.toString();
          }
        } catch (_) {
          // Not a JSON string, just return the raw text if meaningful
          return responseData.isNotEmpty ? responseData : null;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static String _handleException(Object error) {
    if (error is SocketException) {
      return 'No internet connection.';
    } else {
      return 'Unexpected error occurred.';
    }
  }

// static Future<void> _handleUnauthorizedIfLoggedIn() async {
//   final storage = AuthLocalStorage();
//   final token = await storage.getToken();
//
//   if (token != null && token.isNotEmpty) {
//     await storage.clearUser();
//     AppRouter.router.go('/login');
//   }
// }
}