import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'secure_storage_service.dart';

typedef AppDirectoryProvider = Future<Directory> Function();
typedef SecureKeyGenerator = List<int> Function();

class HiveBoxNames {
  const HiveBoxNames._();

  static const String appCache = 'app_cache';
  static const String secureSession = 'secure_session';
}

class SecureStorageKeys {
  const SecureStorageKeys._();

  static const String hiveEncryptionKey = 'hive_encryption_key';
}

abstract class HiveEncryptionKeyService {
  Future<List<int>> readOrCreateKey();

  Future<void> rotateKey();
}

class SecureStorageHiveEncryptionKeyService
    implements HiveEncryptionKeyService {
  SecureStorageHiveEncryptionKeyService({
    required SecureStorageService secureStorage,
    SecureKeyGenerator? generateSecureKey,
    String storageKey = SecureStorageKeys.hiveEncryptionKey,
  }) : _secureStorage = secureStorage,
       _generateSecureKey = generateSecureKey ?? _defaultGenerateSecureKey,
       _storageKey = storageKey;

  final SecureStorageService _secureStorage;
  final SecureKeyGenerator _generateSecureKey;
  final String _storageKey;

  @override
  Future<List<int>> readOrCreateKey() async {
    final storedKey = await _secureStorage.readString(_storageKey);
    if (storedKey != null && storedKey.isNotEmpty) {
      return base64Url.decode(storedKey);
    }

    final key = _generateSecureKey();
    await _secureStorage.writeString(
      key: _storageKey,
      value: base64UrlEncode(key),
    );
    return key;
  }

  @override
  Future<void> rotateKey() {
    return _secureStorage.delete(_storageKey);
  }
}

abstract class LocalDatabaseService {
  Future<void> init();

  Future<Box<E>> openBox<E>(String name);

  Future<Box<E>> openEncryptedBox<E>(String name);

  Future<void> deleteBox(String name);

  Future<void> close();
}

class HiveLocalDatabaseService implements LocalDatabaseService {
  HiveLocalDatabaseService({
    required HiveEncryptionKeyService encryptionKeyService,
    HiveInterface? hive,
    AppDirectoryProvider appDirectoryProvider =
        getApplicationDocumentsDirectory,
  }) : _encryptionKeyService = encryptionKeyService,
       _hive = hive ?? Hive,
       _appDirectoryProvider = appDirectoryProvider;

  final HiveEncryptionKeyService _encryptionKeyService;
  final HiveInterface _hive;
  final AppDirectoryProvider _appDirectoryProvider;
  final Set<String> _plainBoxes = <String>{};
  final Set<String> _encryptedBoxes = <String>{};
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    final directory = await _appDirectoryProvider();
    _hive.init(directory.path);
    _isInitialized = true;
  }

  @override
  Future<Box<E>> openBox<E>(String name) async {
    await init();
    final boxName = _normalizeBoxName(name);
    if (_encryptedBoxes.contains(boxName)) {
      throw StateError('Box "$boxName" was already opened as encrypted.');
    }
    _plainBoxes.add(boxName);
    return _hive.openBox<E>(boxName);
  }

  @override
  Future<Box<E>> openEncryptedBox<E>(String name) async {
    await init();
    final boxName = _normalizeBoxName(name);
    if (_plainBoxes.contains(boxName)) {
      throw StateError('Box "$boxName" was already opened as plain storage.');
    }
    final key = await _encryptionKeyService.readOrCreateKey();
    _encryptedBoxes.add(boxName);
    return _hive.openBox<E>(boxName, encryptionCipher: HiveAesCipher(key));
  }

  @override
  Future<void> deleteBox(String name) async {
    await init();
    final boxName = _normalizeBoxName(name);
    _plainBoxes.remove(boxName);
    _encryptedBoxes.remove(boxName);
    await _hive.deleteBoxFromDisk(boxName);
  }

  @override
  Future<void> close() async {
    _plainBoxes.clear();
    _encryptedBoxes.clear();
    await _hive.close();
  }

  String _normalizeBoxName(String name) {
    final boxName = name.trim().toLowerCase();
    if (boxName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Hive box name is required.');
    }
    return boxName;
  }
}

List<int> _defaultGenerateSecureKey() => Hive.generateSecureKey();
