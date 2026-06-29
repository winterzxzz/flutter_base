import 'package:flutter/material.dart';
import 'package:flutter_base/core/di/injection_container.dart';
import 'package:flutter_base/presentation_module/configs/navigation/app_router.dart';
import 'package:flutter_base/presentation_module/ui/home/home_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await resetDependencies();
    sl.registerFactory<HomeCubit>(HomeCubit.new);
  });

  tearDown(resetDependencies);

  testWidgets('unknown routes render the not found page', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          initialRoute: '/missing',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Route not found'), findsOneWidget);
  });
}
