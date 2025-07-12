import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }
    return error.toString();
  }

  static bool isNetworkError(dynamic error) {
    return error is NetworkException;
  }

  static bool isAuthError(dynamic error) {
    if (error is NetworkException) {
      return error.statusCode == 401;
    }
    return false;
  }

  static bool isNotFoundError(dynamic error) {
    if (error is NetworkException) {
      return error.statusCode == 404;
    }
    return false;
  }

  static bool isServerError(dynamic error) {
    if (error is NetworkException) {
      return error.statusCode != null && error.statusCode! >= 500;
    }
    return false;
  }

  static bool isClientError(dynamic error) {
    if (error is NetworkException) {
      return error.statusCode != null && error.statusCode! >= 400 && error.statusCode! < 500;
    }
    return false;
  }
  
  // Log error with stack trace
  static void logError(dynamic error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('ERROR: ${error.toString()}');
      if (stackTrace != null) {
        print('STACK TRACE: $stackTrace');
      } else if (error is Error) {
        print('STACK TRACE: ${error.stackTrace}');
      }
    }
  }
  
  // Get appropriate user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    if (isAuthError(error)) {
      return 'Your session has expired. Please login again.';
    } else if (isNotFoundError(error)) {
      return 'The requested resource was not found.';
    } else if (isServerError(error)) {
      return 'Server error. Please try again later.';
    } else if (isNetworkError(error)) {
      return getErrorMessage(error);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  // Handle common error patterns
  static T handleError<T>(dynamic error, {required T Function() onError}) {
    logError(error);
    return onError();
  }
  
  // Get status code from error
  static int? getStatusCode(dynamic error) {
    if (error is NetworkException) {
      return error.statusCode;
    }
    return null;
  }
  
  // Check if error is related to offline status
  static bool isOfflineError(dynamic error) {
    if (error is NetworkException) {
      return error.message.contains('internet') || 
             error.message.contains('network') ||
             error.message.contains('connection');
    }
    return false;
  }
} 