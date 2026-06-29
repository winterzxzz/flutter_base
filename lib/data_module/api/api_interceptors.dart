import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef NetworkLogWriter =
    void Function(String message, {String name, Object? error});

/// Logs request failures in one place. Product-neutral: it does not refresh
/// tokens or mutate requests; add an auth interceptor separately when needed.
class NetworkInterceptor extends QueuedInterceptorsWrapper {
  NetworkInterceptor({this.enabled = kDebugMode, NetworkLogWriter? log})
    : _log = log ?? _defaultLog;

  final bool enabled;
  final NetworkLogWriter _log;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) {
      handler.next(err);
      return;
    }
    _log(debugMessageFor(err), name: 'network', error: err);
    handler.next(err);
  }

  @visibleForTesting
  String debugMessageFor(DioException err) {
    final statusCode = err.response?.statusCode;
    final method = err.requestOptions.method;
    final path = err.requestOptions.path;
    return 'ERROR[$statusCode] $method $path\n'
        'Response: ${_redact(err.response?.data)}';
  }

  static void _defaultLog(
    String message, {
    String name = 'network',
    Object? error,
  }) {
    developer.log(message, name: name, error: error);
  }

  static Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((key, nestedValue) {
        final keyText = key.toString();
        return MapEntry(
          key,
          _isSensitiveKey(keyText) ? '<redacted>' : _redact(nestedValue),
        );
      });
    }
    if (value is List) {
      return value.map(_redact).toList(growable: false);
    }
    if (value is String && value.length > 120) {
      return '${value.substring(0, 120)}...';
    }
    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('authorization') ||
        normalized.contains('password') ||
        normalized.contains('secret') ||
        normalized.contains('token') ||
        normalized.contains('api_key') ||
        normalized.contains('apikey');
  }
}
