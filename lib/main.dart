import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart';
import 'presentation_module/app.dart';
import 'presentation_module/blocs/app/app_config_cubit.dart';
import 'presentation_module/ui/home/home_cubit.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env');
      await configureDependencies();
      runApp(const AppBootstrapper());
    },
    (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    },
  );
}

class AppBootstrapper extends StatelessWidget {
  const AppBootstrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AppConfigCubit>()),
        BlocProvider(create: (_) => sl<HomeCubit>()),
      ],
      child: const BaseApp(),
    );
  }
}
