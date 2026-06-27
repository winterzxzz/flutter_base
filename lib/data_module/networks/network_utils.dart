import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../presentation_module/configs/app_constants.dart';
import '../api/api_interceptors.dart';

typedef EnvReader = String? Function(String key);

/// Builds the shared [Dio] and reads environment config.
///
/// Env values come from `.env` (loaded via `dotenv.load` in `main`). Keep base
/// URLs and secrets here, never hard-coded in API clients, Cubits, or widgets.
class NetworkUtils {
  const NetworkUtils._();

  static Dio createDio({
    bool enableLogging = kDebugMode,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio()
      ..options.connectTimeout = AppConstants.timeout
      ..options.receiveTimeout = AppConstants.timeout
      ..interceptors.add(NetworkInterceptor())
      ..interceptors.addAll(interceptors);

    if (enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          compact: false,
        ),
      );
    }

    return dio;
  }

  /// Reads a required env var, throwing if it is missing or blank.
  static String requiredEnv(String key, {EnvReader? envReader}) {
    final value = (envReader ?? dotenv.maybeGet)(key)?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('$key is not configured');
    }
    return value;
  }

  static String get apiBaseUrl => requiredEnv('API_BASE_URL');
}
