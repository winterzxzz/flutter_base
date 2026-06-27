import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Typed network failure. `type` lets Cubits branch on the failure kind
/// (timeout, no connection, unauthorized, ...) instead of parsing strings.
class NetworkError extends Equatable implements Exception {
  const NetworkError({
    this.message = 'Unexpected error occurred',
    this.statusCode,
    this.type,
  });

  final String message;
  final int? statusCode;
  final DioExceptionType? type;

  bool get isUnauthorized => statusCode == 401;

  bool get isTimeout =>
      type == DioExceptionType.connectionTimeout ||
      type == DioExceptionType.receiveTimeout ||
      type == DioExceptionType.sendTimeout;

  bool get isConnectionError => type == DioExceptionType.connectionError;

  factory NetworkError.fromDioError(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final type = dioException.type;
    String message;

    switch (type) {
      case DioExceptionType.cancel:
        message = 'Request to API server was cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout with API server';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout in connection with API server';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout in connection with API server';
        break;
      case DioExceptionType.connectionError:
        message = dioException.error is SocketException
            ? 'Please check your internet connection'
            : 'Unexpected connection error occurred';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioExceptionType.badResponse:
        message = _messageFromResponse(statusCode, dioException.response?.data);
        break;
      case DioExceptionType.unknown:
        message = 'Unexpected error occurred';
        break;
    }

    return NetworkError(message: message, statusCode: statusCode, type: type);
  }

  static String _messageFromResponse(int? statusCode, Object? data) {
    if (statusCode == 401) {
      return 'Unauthorized';
    }
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      final firstError = errors is List<dynamic> && errors.isNotEmpty
          ? errors.first
          : null;
      final nestedMessage = firstError is Map<String, dynamic>
          ? firstError['message']
          : null;
      return (nestedMessage ?? data['message'] ?? 'Unexpected error occurred')
          .toString();
    }
    if (data is String && data.isNotEmpty) {
      final preview = data.length > 100 ? data.substring(0, 100) : data;
      return 'Server error: $statusCode - $preview';
    }
    return 'Unexpected error occurred';
  }

  @override
  List<Object?> get props => [message, statusCode, type];
}
