import 'package:flutter_base/data_module/services/local/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecureStorageService', () {
    test('writes, reads, and deletes values', () async {
      final storage = _FakeKeyValueSecureStorage();
      final service = SecureStorageService(storage: storage);

      await service.writeString(key: 'access_token', value: 'token');

      expect(await service.readString('access_token'), 'token');
      expect(await service.containsKey('access_token'), isTrue);

      await service.delete('access_token');

      expect(await service.readString('access_token'), isNull);
      expect(await service.containsKey('access_token'), isFalse);
    });

    test('rejects blank keys', () async {
      final service = SecureStorageService(
        storage: _FakeKeyValueSecureStorage(),
      );

      expect(
        () => service.writeString(key: ' ', value: 'token'),
        throwsArgumentError,
      );
    });
  });
}

class _FakeKeyValueSecureStorage implements KeyValueSecureStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }
}
