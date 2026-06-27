import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/presentation_module/blocs/app/app_config_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfigCubit', () {
    test('starts with light theme and English locale', () {
      final cubit = AppConfigCubit();

      expect(cubit.state.themeMode, ThemeMode.light);
      expect(cubit.state.locale, const Locale('en'));

      cubit.close();
    });

    blocTest<AppConfigCubit, AppConfigState>(
      'emits selected theme mode',
      build: AppConfigCubit.new,
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => const [AppConfigState(themeMode: ThemeMode.dark)],
    );

    blocTest<AppConfigCubit, AppConfigState>(
      'emits selected locale',
      build: AppConfigCubit.new,
      act: (cubit) => cubit.setLocale(const Locale('vi')),
      expect: () => const [AppConfigState(locale: Locale('vi'))],
    );
  });
}
