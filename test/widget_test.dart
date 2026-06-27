import 'package:flutter/material.dart';
import 'package:flutter_base/core/di/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_base/main.dart';

void main() {
  setUp(() async {
    await resetDependencies();
    await configureDependencies();
  });

  tearDown(resetDependencies);

  testWidgets('base app shell wires providers and home cubit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppBootstrapper());

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
