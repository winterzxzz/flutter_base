import 'dart:io';

import 'package:flutter_base/data_module/services/local/hive_database_service.dart';
import 'package:flutter_base/data_module/services/local/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('SecureStorageHiveEncryptionKeyService', () {
    test('creates and reuses an encoded Hive encryption key', () async {
      final secureStorage = SecureStorageService(
        storage: _FakeKeyValueSecureStorage(),
      );
      final keyService = SecureStorageHiveEncryptionKeyService(
        secureStorage: secureStorage,
        generateSecureKey: () => List<int>.filled(32, 7),
      );

      final firstKey = await keyService.readOrCreateKey();
      final secondKey = await keyService.readOrCreateKey();

      expect(firstKey, List<int>.filled(32, 7));
      expect(secondKey, firstKey);
      expect(
        await secureStorage.readString(SecureStorageKeys.hiveEncryptionKey),
        isNotEmpty,
      );
    });
  });

  group('HiveLocalDatabaseService', () {
    late Directory tempDirectory;
    late HiveLocalDatabaseService databaseService;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'flutter_base_hive_',
      );
      final secureStorage = SecureStorageService(
        storage: _FakeKeyValueSecureStorage(),
      );
      databaseService = HiveLocalDatabaseService(
        encryptionKeyService: SecureStorageHiveEncryptionKeyService(
          secureStorage: secureStorage,
          generateSecureKey: () => List<int>.filled(32, 9),
        ),
        appDirectoryProvider: () async => tempDirectory,
      );
    });

    tearDown(() async {
      await databaseService.close();
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('opens a plain Hive box for non-sensitive cache data', () async {
      final box = await databaseService.openBox<String>(HiveBoxNames.appCache);

      await box.put('locale', 'en');

      expect(box.get('locale'), 'en');
      expect(Hive.isBoxOpen(HiveBoxNames.appCache), isTrue);
    });

    test('opens an encrypted Hive box for sensitive data', () async {
      final box = await databaseService.openEncryptedBox<String>(
        HiveBoxNames.secureSession,
      );

      await box.put('access_token', 'secret-token');

      expect(box.get('access_token'), 'secret-token');
      expect(Hive.isBoxOpen(HiveBoxNames.secureSession), isTrue);
    });

    test(
      'does not let a box switch between encrypted and plain modes',
      () async {
        await databaseService.openEncryptedBox<String>(
          HiveBoxNames.secureSession,
        );

        expect(
          databaseService.openBox<String>(HiveBoxNames.secureSession),
          throwsStateError,
        );
      },
    );
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
