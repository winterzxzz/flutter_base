import 'package:flutter/material.dart';

import '../../ui/home/home_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}
