import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../data_module/api/example_api_client.dart';
import '../../data_module/repositories/example_repository.dart';
import '../../presentation_module/blocs/app/app_config_cubit.dart';
import '../../presentation_module/ui/example/example_cubit.dart';
import '../../presentation_module/ui/home/home_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(Dio.new);
  }

  if (!sl.isRegistered<ExampleApiClient>()) {
    sl.registerLazySingleton<ExampleApiClient>(
      () => ExampleApiClient(sl<Dio>(), baseUrl: 'https://example.com'),
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
  await sl.reset();
}
