import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


import '../../ui/auth/login_screen.dart';
import '../network/tokenstorage.dart';
import '../utils/approuter.dart';

class ApiErrorHandler {
  static Future<String> handleDioError(DioException error) async {
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
          errorMsg = message ?? "Too many requests. Please try again.";
          break;

        case 500:
          errorMsg = message ?? "Server error. Try again later.";
          break;

        default:
          errorMsg = message ?? "Something went wrong.";
      }
    } else {
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

        case DioExceptionType.badCertificate:
          errorMsg = "Certificate verification failed.";
          break;

        case DioExceptionType.badResponse:
          errorMsg = message ?? "Server returned an invalid response.";
          break;

        case DioExceptionType.unknown:
        default:
          errorMsg = _handleException(error.error);
      }
    }

    return errorMsg;
  }

  static String? _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData == null) return null;

      if (responseData is Map<String, dynamic>) {
        if (responseData['message'] != null) {
          return responseData['message'].toString();
        }

        if (responseData['error'] != null) {
          return responseData['error'].toString();
        }

        if (responseData['errors'] is Map<String, dynamic>) {
          final errors = responseData['errors'] as Map<String, dynamic>;

          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;

            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }

            return firstValue.toString();
          }
        }
      }

      if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);

          if (decoded is Map<String, dynamic>) {
            return decoded['message']?.toString() ??
                decoded['error']?.toString();
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
    final token = await TokenStorage.readToken();

    if (token != null && token.isNotEmpty) {
      await TokenStorage.clear();

      // Drive the actual imperative Navigator stack directly, since most
      // screens in this app are pushed with Navigator.push (not GoRoutes),
      // so AppRouter.router.go('/login') alone can't clear them.
      final navState = AppRouter.navigatorKey.currentState;
      navState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  static String _handleException(Object? error) {
    if (error is SocketException) {
      return "No internet connection.";
    }

    return "Unexpected error occurred.";
  }
}