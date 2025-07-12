import 'dart:io';

import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final String? stackTrace;

  NetworkException({
    required this.message,
    this.statusCode,
    this.stackTrace,
  });

  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message: 'Connection timeout. Please try again.',
          stackTrace: error.stackTrace?.toString(),
        );
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Send timeout. Please try again.',
          stackTrace: error.stackTrace?.toString(),
        );
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Receive timeout. Please try again.',
          stackTrace: error.stackTrace?.toString(),
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled.',
          stackTrace: error.stackTrace?.toString(),
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Connection error. Please check your internet connection.',
          stackTrace: error.stackTrace?.toString(),
        );
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: error.message ?? 'Something went wrong. Please try again.',
          stackTrace: error.stackTrace?.toString(),
        );
    }
  }

  static NetworkException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    String message;

    switch (statusCode) {
      case 400:
        message = 'Bad request. Please check your input.';
        break;
      case 401:
        message = 'Unauthorized. Please login again.';
        break;
      case 403:
        message = 'Forbidden. You don\'t have permission.';
        break;
      case 404:
        message = 'Not found. The resource doesn\'t exist.';
        break;
      case 500:
        message = 'Server error. Please try again later.';
        break;
      default:
        message = 'An error occurred. Please try again.';
    }

    return NetworkException(
      message: message,
      statusCode: statusCode,
      stackTrace: error.stackTrace?.toString(),
    );
  }

  factory NetworkException.fromException(Exception error) {
    if (error is SocketException) {
      return NetworkException(
        message: 'No internet connection. Please check your network.',
      );
    } else {
      return NetworkException(
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  @override
  String toString() => message;
}
