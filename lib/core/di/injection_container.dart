import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data_module/api/example_api_client.dart';
import '../../data_module/networks/auth/auth_interceptor.dart';
import '../../data_module/networks/auth/auth_token_store.dart';
import '../../data_module/networks/auth/token_refresher.dart';
import '../../data_module/networks/network_utils.dart';
import '../../data_module/repositories/example_repository.dart';
import '../../data_module/services/local/hive_database_service.dart';
import '../../data_module/services/local/secure_storage_service.dart';
import '../../presentation_module/blocs/app/app_config_cubit.dart';
import '../../presentation_module/ui/example/example_cubit.dart';
import '../../presentation_module/ui/home/home_cubit.dart';

final sl = GetIt.instance;

/// Builds a [FlutterSecureStorage] hardened for storing sensitive data.
///
/// - Android: relies on the v10 default ciphers (RSA-OAEP key wrapping +
///   AES-GCM storage). Requires `minSdk >= 23` (set in app/build.gradle.kts).
/// - iOS/macOS Keychain: items are readable only after the first device
///   unlock following boot, and are never migrated to a new device via
///   encrypted backups (`first_unlock_this_device`).
FlutterSecureStorage _buildSecureStorage() {
  const keychainAccessibility = KeychainAccessibility.first_unlock_this_device;
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: keychainAccessibility),
    mOptions: MacOsOptions(accessibility: keychainAccessibility),
  );
}

Future<void> configureDependencies({
  LocalDatabaseService? localDatabase,
}) async {
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => NetworkUtils.createDio(interceptors: [sl<AuthInterceptor>()]),
    );
  }

  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerLazySingleton<FlutterSecureStorage>(_buildSecureStorage);
  }

  if (!sl.isRegistered<KeyValueSecureStorage>()) {
    sl.registerLazySingleton<KeyValueSecureStorage>(
      () => FlutterKeyValueSecureStorage(storage: sl<FlutterSecureStorage>()),
    );
  }

  if (!sl.isRegistered<SecureStorageService>()) {
    sl.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(storage: sl<KeyValueSecureStorage>()),
    );
  }

  if (!sl.isRegistered<HiveEncryptionKeyService>()) {
    sl.registerLazySingleton<HiveEncryptionKeyService>(
      () => SecureStorageHiveEncryptionKeyService(
        secureStorage: sl<SecureStorageService>(),
      ),
    );
  }

  if (!sl.isRegistered<AuthTokenStore>()) {
    sl.registerLazySingleton<AuthTokenStore>(
      () => SecureStorageAuthTokenStore(
        secureStorage: sl<SecureStorageService>(),
      ),
    );
  }

  // Products override this with a real refresher that calls their auth API.
  if (!sl.isRegistered<TokenRefresher>()) {
    sl.registerLazySingleton<TokenRefresher>(UnsupportedTokenRefresher.new);
  }

  if (!sl.isRegistered<AuthInterceptor>()) {
    sl.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(
        tokenStore: sl<AuthTokenStore>(),
        refresher: sl<TokenRefresher>(),
      ),
    );
  }

  if (!sl.isRegistered<LocalDatabaseService>()) {
    final database =
        localDatabase ??
        HiveLocalDatabaseService(
          encryptionKeyService: sl<HiveEncryptionKeyService>(),
        );
    await database.init();
    sl.registerSingleton<LocalDatabaseService>(database);
  }

  if (!sl.isRegistered<ExampleApiClient>()) {
    sl.registerLazySingleton<ExampleApiClient>(
      () => ExampleApiClient(sl<Dio>(), baseUrl: NetworkUtils.apiBaseUrl),
    );
  }

  if (!sl.isRegistered<ExampleRepository>()) {
    sl.registerLazySingleton<ExampleRepository>(
      () => ExampleRepositoryImpl(apiClient: sl<ExampleApiClient>()),
    );
  }

  if (!sl.isRegistered<AppConfigCubit>()) {
    sl.registerFactory<AppConfigCubit>(AppConfigCubit.new);
  }

  if (!sl.isRegistered<HomeCubit>()) {
    sl.registerFactory<HomeCubit>(HomeCubit.new);
  }

  if (!sl.isRegistered<ExampleCubit>()) {
    sl.registerFactory<ExampleCubit>(
      () => ExampleCubit(repository: sl<ExampleRepository>()),
    );
  }
}

Future<void> resetDependencies() async {
  if (sl.isRegistered<LocalDatabaseService>()) {
    await sl<LocalDatabaseService>().close();
  }
  await sl.reset();
}
