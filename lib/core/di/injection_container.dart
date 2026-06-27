import 'package:get_it/get_it.dart';

import '../../presentation_module/blocs/app/app_config_cubit.dart';
import '../../presentation_module/ui/home/home_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (!sl.isRegistered<AppConfigCubit>()) {
    sl.registerFactory<AppConfigCubit>(AppConfigCubit.new);
  }

  if (!sl.isRegistered<HomeCubit>()) {
    sl.registerFactory<HomeCubit>(HomeCubit.new);
  }
}

Future<void> resetDependencies() async {
  await sl.reset();
}
