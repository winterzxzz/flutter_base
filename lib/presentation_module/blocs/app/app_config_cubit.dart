import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit() : super(const AppConfigState());

  void setThemeMode(ThemeMode themeMode) {
    if (themeMode == state.themeMode) return;
    emit(state.copyWith(themeMode: themeMode));
  }

  void setLocale(Locale locale) {
    if (locale == state.locale) return;
    emit(state.copyWith(locale: locale));
  }
}

class AppConfigState extends Equatable {
  const AppConfigState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  AppConfigState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppConfigState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}
