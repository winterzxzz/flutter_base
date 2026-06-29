import 'package:dio/dio.dart';
import 'package:flutter_base/data_module/api/api_interceptors.dart';
import 'package:flutter_base/data_module/networks/network_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkUtils.requiredEnv', () {
    test('returns the trimmed value when present', () {
      final value = NetworkUtils.requiredEnv(
        'API_BASE_URL',
        envReader: (_) => '  https://api.example.com  ',
      );

      expect(value, 'https://api.example.com');
    });

    test('throws when the value is missing', () {
      expect(
        () => NetworkUtils.requiredEnv('API_BASE_URL', envReader: (_) => null),
        throwsStateError,
      );
    });

    test('throws when the value is blank', () {
      expect(
        () => NetworkUtils.requiredEnv('API_BASE_URL', envReader: (_) => '   '),
        throwsStateError,
      );
    });
  });

  group('NetworkUtils.createDio', () {
    test('applies the configured timeouts and interceptors', () {
      final dio = NetworkUtils.createDio(enableLogging: false);

      expect(dio.options.connectTimeout, isNotNull);
      expect(dio.options.receiveTimeout, isNotNull);
      expect(dio.interceptors, isNotEmpty);
    });
  });

  group('NetworkInterceptor', () {
    test('redacts sensitive response fields from debug messages', () {
      final interceptor = NetworkInterceptor();
      final error = DioException(
        requestOptions: RequestOptions(method: 'POST', path: '/login'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(method: 'POST', path: '/login'),
          statusCode: 401,
          data: const {
            'message': 'invalid',
            'accessToken': 'secret-access',
            'refresh_token': 'secret-refresh',
            'profile': {'password': 'secret-password', 'name': 'Ada'},
          },
        ),
      );

      final message = interceptor.debugMessageFor(error);

      expect(message, contains('POST /login'));
      expect(message, contains('<redacted>'));
      expect(message, contains('Ada'));
      expect(message, isNot(contains('secret-access')));
      expect(message, isNot(contains('secret-refresh')));
      expect(message, isNot(contains('secret-password')));
    });
  });
}
