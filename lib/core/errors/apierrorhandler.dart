//
// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
//
// import '../../ui/auth/login_screen.dart';
// import '../network/tokenstorage.dart';
// import '../../router/approuter.dart';
//
// class ApiErrorHandler {
//   // Prevents multiple concurrent 401 responses from each pushing
//   // LoginScreen separately (duplicate route entries in the nav stack).
//   static bool _isHandlingUnauthorized = false;
//
//   static Future<String> handleDioError(DioException e) async {
//     final statusCode = e.response?.statusCode;
//     final responseData = e.response?.data;
//     final message = _extractErrorMessage(responseData);
//
//     String errorMsg;
//
//     switch (statusCode) {
//       case 400:
//         errorMsg = message ?? "Bad request. Please try again.";
//         break;
//       case 401:
//         errorMsg = message ?? "Session expired. Please log in again.";
//         await _handleUnauthorized();
//         break;
//       case 403:
//         errorMsg = message ?? "Access denied.";
//         break;
//       case 404:
//         errorMsg = message ?? "Not found.";
//         break;
//       case 422:
//         errorMsg = message ?? "Validation error. Please check your input.";
//         break;
//       case 429:
//         errorMsg = "Too many requests. Please try again.";
//         break;
//       case 500:
//         errorMsg = message ?? "Server error. Try again later.";
//         break;
//       case 508:
//         errorMsg = "Resource limit reached. Please try again later.";
//         break;
//       default:
//         switch (e.type) {
//           case DioExceptionType.connectionTimeout:
//           case DioExceptionType.sendTimeout:
//           case DioExceptionType.receiveTimeout:
//             errorMsg = "Request timed out. Please try again.";
//             break;
//           case DioExceptionType.connectionError:
//             errorMsg = await _connectionErrorMessage();
//             break;
//           case DioExceptionType.cancel:
//             errorMsg = "Request cancelled.";
//             break;
//           case DioExceptionType.unknown:
//           default:
//             errorMsg = _handleException(e.error);
//         }
//     }
//
//     return errorMsg;
//   }
//
//   static String? _extractErrorMessage(dynamic responseData) {
//     try {
//       if (responseData == null) return null;
//
//       if (responseData is Map<String, dynamic>) {
//         if (responseData['message'] != null) return responseData['message'].toString();
//         if (responseData['error'] != null) return responseData['error'].toString();
//
//         if (responseData['errors'] is Map<String, dynamic>) {
//           final errors = responseData['errors'] as Map<String, dynamic>;
//           if (errors.isNotEmpty) {
//             final firstValue = errors.values.first;
//             if (firstValue is List && firstValue.isNotEmpty) return firstValue.first.toString();
//             return firstValue.toString();
//           }
//         }
//       }
//
//       if (responseData is String) {
//         try {
//           final decoded = jsonDecode(responseData);
//           if (decoded is Map<String, dynamic>) {
//             return decoded['message']?.toString() ?? decoded['error']?.toString();
//           }
//           return responseData;
//         } catch (_) {
//           return responseData.isNotEmpty ? responseData : null;
//         }
//       }
//     } catch (_) {}
//
//     return null;
//   }
//
//   static Future<void> _handleUnauthorized() async {
//     if (_isHandlingUnauthorized) return;
//     _isHandlingUnauthorized = true;
//
//     try {
//       final token = await TokenStorage.readToken();
//       if (token != null && token.isNotEmpty) {
//         await TokenStorage.clear();
//         AppRouter.router.go('/login'); // go_router, not pushAndRemoveUntil
//       }
//     } finally {
//       _isHandlingUnauthorized = false;
//     }
//   }
//
//   // Only says "no internet" if the device really can't reach the internet.
//   // If the internet works, the problem is the server / DNS.
//   static Future<String> _connectionErrorMessage() async {
//     try {
//       final result = await InternetAddress.lookup('google.com')
//           .timeout(const Duration(seconds: 3));
//       if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
//         return "Unable to reach the server. Please try again later.";
//       }
//     } catch (_) {}
//     return "No internet connection.";
//   }
//
//   static String _handleException(Object? error) {
//     if (error is SocketException) {
//       return "Unable to reach the server. Please try again later.";
//     }
//     return "Something went wrong. Please try again.";
//   }
// }
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

  static const String _genericServerMsg =
      "Something went wrong on our side. Please try again.";

  static Future<String> handleDioError(DioException e) async {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final message = _extractErrorMessage(responseData);

    String errorMsg;

    // Any 5xx = server problem. NEVER show server text to the user.
    if (statusCode != null && statusCode >= 500) {
      if (statusCode == 508) {
        return "Resource limit reached. Please try again later.";
      }
      return _genericServerMsg;
    }

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
      default:
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMsg = "Request timed out. Please try again.";
            break;
          case DioExceptionType.connectionError:
            errorMsg = await _connectionErrorMessage();
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

  /// Returns a message only if it is safe to show to the user.
  /// Technical text (SQL, stack traces, HTML, very long dumps) -> null,
  /// so the caller falls back to a friendly message.
  static String? _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData == null) return null;

      String? raw;

      if (responseData is Map<String, dynamic>) {
        if (responseData['message'] != null) {
          raw = responseData['message'].toString();
        } else if (responseData['error'] != null) {
          raw = responseData['error'].toString();
        } else if (responseData['errors'] is Map<String, dynamic>) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;
            raw = (firstValue is List && firstValue.isNotEmpty)
                ? firstValue.first.toString()
                : firstValue.toString();
          }
        }
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            raw = decoded['message']?.toString() ?? decoded['error']?.toString();
          } else {
            raw = responseData;
          }
        } catch (_) {
          raw = responseData.isNotEmpty ? responseData : null;
        }
      }

      if (raw == null || raw.trim().isEmpty) return null;
      if (_isTechnical(raw)) return null;
      return raw;
    } catch (_) {}

    return null;
  }

  /// Detects backend/technical errors that must never reach the UI.
  static bool _isTechnical(String msg) {
    final m = msg.toLowerCase();
    if (msg.length > 200) return true; // long dumps / HTML pages
    const markers = [
      'sqlstate',
      'sql:',
      'deadlock',
      'exception',
      'stack trace',
      'connection: mysql',
      'illuminate\\',
      'vendor/',
      '<html',
      '<!doctype',
      'syntax error',
      'undefined ',
      'call to ',
      'integrity constraint',
      'query',
    ];
    return markers.any(m.contains);
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

  // Only says "no internet" if the device really can't reach the internet.
  // If the internet works, the problem is the server / DNS.
  static Future<String> _connectionErrorMessage() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        return "Unable to reach the server. Please try again later.";
      }
    } catch (_) {}
    return "No internet connection.";
  }

  static String _handleException(Object? error) {
    if (error is SocketException) {
      return "Unable to reach the server. Please try again later.";
    }
    return "Something went wrong. Please try again.";
  }
}