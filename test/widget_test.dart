import 'package:flutter/material.dart';
import 'package:flutter_base/core/di/injection_container.dart';
import 'package:flutter_base/data_module/services/local/hive_database_service.dart';
import 'package:flutter_base/presentation_module/shared_view/layout/wrapper_layout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:flutter_base/main.dart';

void main() {
  setUp(() async {
    await resetDependencies();
    await configureDependencies(localDatabase: _FakeLocalDatabaseService());
  });

  tearDown(resetDependencies);

  testWidgets('base app shell wires app provider and route-scoped home cubit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppBootstrapper());

    expect(find.byType(WrapperLayoutView), findsOneWidget);
    expect(find.text('Flutter Base'), findsOneWidget);
    expect(find.text('Reusable Flutter starter'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('app initializes ScreenUtil for responsive sizing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppBootstrapper());

    expect(find.byType(ScreenUtilInit), findsOneWidget);
    final init = tester.widget<ScreenUtilInit>(find.byType(ScreenUtilInit));
    expect(init.designSize, const Size(390, 844));
    expect(init.minTextAdapt, isTrue);
    expect(init.splitScreenMode, isTrue);
  });

  testWidgets('home page uses .r text sizes for responsive text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppBootstrapper());

    final title = tester.widget<Text>(find.text('Ready for features'));
    final subtitle = tester.widget<Text>(find.text('Reusable Flutter starter'));
    final count = tester.widget<Text>(find.text('0'));

    expect(title.style?.fontSize, 28.r);
    expect(subtitle.style?.fontSize, 16.r);
    expect(count.style?.fontSize, 64.r);
  });
}

class _FakeLocalDatabaseService implements LocalDatabaseService {
  @override
  Future<void> init() async {}

  @override
  Future<Box<E>> openBox<E>(String name) {
    throw UnimplementedError('Widget tests do not use local database.');
  }

  @override
  Future<Box<E>> openEncryptedBox<E>(String name) {
    throw UnimplementedError('Widget tests do not use local database.');
  }

  @override
  Future<void> deleteBox(String name) async {}

  @override
  Future<void> close() async {}
}
