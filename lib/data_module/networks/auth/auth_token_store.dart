import '../../services/local/hive_database_service.dart';
import '../../services/local/secure_storage_service.dart';
import 'auth_tokens.dart';

/// Reads and writes the auth token pair. Tokens are secrets, so the default
/// implementation is backed by [SecureStorageService].
abstract class AuthTokenStore {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens(AuthTokens tokens);

  Future<void> clear();
}

class SecureStorageAuthTokenStore implements AuthTokenStore {
  const SecureStorageAuthTokenStore({
    required SecureStorageService secureStorage,
  }) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  @override
  Future<String?> readAccessToken() =>
      _secureStorage.readString(SecureStorageKeys.accessToken);

  @override
  Future<String?> readRefreshToken() =>
      _secureStorage.readString(SecureStorageKeys.refreshToken);

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.writeString(
      key: SecureStorageKeys.accessToken,
      value: tokens.accessToken,
    );
    final refreshToken = tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;
    await _secureStorage.writeString(
      key: SecureStorageKeys.refreshToken,
      value: refreshToken,
    );
  }

  @override
  Future<void> clear() async {
    await _secureStorage.delete(SecureStorageKeys.accessToken);
    await _secureStorage.delete(SecureStorageKeys.refreshToken);
  }
}
