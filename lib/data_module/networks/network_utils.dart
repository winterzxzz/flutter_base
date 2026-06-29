import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../presentation_module/configs/app_constants.dart';
import '../api/api_interceptors.dart';

typedef EnvReader = String? Function(String key);

/// Builds the shared [Dio] and reads public client environment config.
///
/// Prefer `--dart-define` for app builds. Products may optionally add their own
/// `.env` asset, but Flutter client config is never secret once shipped.
class NetworkUtils {
  const NetworkUtils._();

  static Dio createDio({
    bool enableLogging = kDebugMode,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio()
      ..options.connectTimeout = AppConstants.timeout
      ..options.receiveTimeout = AppConstants.timeout
      ..interceptors.add(NetworkInterceptor(enabled: enableLogging))
      ..interceptors.addAll(interceptors);

    if (enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          enabled: enableLogging,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          compact: false,
        ),
      );
    }

    return dio;
  }

  /// Reads a required env var, throwing if it is missing or blank.
  static String requiredEnv(String key, {EnvReader? envReader}) {
    final value = (envReader ?? _defaultEnvReader)(key)?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('$key is not configured');
    }
    return value;
  }

  static String get apiBaseUrl => requiredEnv('API_BASE_URL');

  static String? _defaultEnvReader(String key) {
    final dotenvValue = dotenv.isInitialized ? dotenv.maybeGet(key) : null;
    if (dotenvValue != null && dotenvValue.trim().isNotEmpty) {
      return dotenvValue;
    }

    return switch (key) {
      'API_BASE_URL' => const String.fromEnvironment('API_BASE_URL'),
      _ => null,
    };
  }
}
