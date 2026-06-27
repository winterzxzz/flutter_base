import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Logs request failures in one place. Product-neutral: it does not refresh
/// tokens or mutate requests; add an auth interceptor separately when needed.
class NetworkInterceptor extends QueuedInterceptorsWrapper {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    developer.log(
      '⚠️ ERROR[$statusCode] => PATH: $path\nResponse: ${err.response?.data}',
      name: 'network',
      error: err,
    );
    handler.next(err);
  }
}
