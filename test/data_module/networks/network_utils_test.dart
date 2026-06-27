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
}
