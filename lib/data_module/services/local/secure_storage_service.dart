import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class KeyValueSecureStorage {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<bool> containsKey({required String key});

  Future<void> delete({required String key});

  Future<void> deleteAll();
}

class FlutterKeyValueSecureStorage implements KeyValueSecureStorage {
  const FlutterKeyValueSecureStorage({required FlutterSecureStorage storage})
    : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<bool> containsKey({required String key}) {
    return _storage.containsKey(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() {
    return _storage.deleteAll();
  }
}

class SecureStorageService {
  const SecureStorageService({required KeyValueSecureStorage storage})
    : _storage = storage;

  final KeyValueSecureStorage _storage;

  Future<void> writeString({required String key, required String value}) {
    _validateKey(key);
    return _storage.write(key: key, value: value);
  }

  Future<String?> readString(String key) {
    _validateKey(key);
    return _storage.read(key: key);
  }

  Future<bool> containsKey(String key) {
    _validateKey(key);
    return _storage.containsKey(key: key);
  }

  Future<void> delete(String key) {
    _validateKey(key);
    return _storage.delete(key: key);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }

  void _validateKey(String key) {
    if (key.trim().isEmpty) {
      throw ArgumentError.value(key, 'key', 'Secure storage key is required.');
    }
  }
}
