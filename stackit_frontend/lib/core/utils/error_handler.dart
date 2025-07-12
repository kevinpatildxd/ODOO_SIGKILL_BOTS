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
} 