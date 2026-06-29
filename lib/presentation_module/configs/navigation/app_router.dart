import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../ui/home/home_cubit.dart';
import '../../ui/home/home_page.dart';
import '../../ui/not_found/not_found.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const notFound = '/not-found';
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _homeRoute(settings);
      case AppRoutes.notFound:
        return _notFoundRoute(settings);
      default:
        return _notFoundRoute(settings);
    }
  }

  static MaterialPageRoute<void> _homeRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          BlocProvider(create: (_) => sl<HomeCubit>(), child: const HomePage()),
      settings: settings,
    );
  }

  static MaterialPageRoute<void> _notFoundRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const NotFoundPage(),
      settings: settings,
    );
  }
}
