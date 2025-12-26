import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/config/service_get_it.dart';
import '../../data/services/pref/preference.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() => SettingsNotifier());

class SettingsState {
  final double fontSize;
  final String fontFamily;
  final String language;
  final ThemeMode themeMode;

  const SettingsState({
    required this.fontSize,
    required this.fontFamily,
    required this.language,
    required this.themeMode,
  });

  SettingsState copyWith({double? fontSize, String? fontFamily, String? language, ThemeMode? themeMode}) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory SettingsState.initial() => SettingsState(
    fontSize: 16.0,
    fontFamily: 'Roboto',
    language: 'Theo hệ thống',
    themeMode: ThemeMode.light,
  );
}

// Constants - move to ViewModel
class SettingsConstants {
  static const List<String> availableFonts = [
    'Roboto',
    'Nunito',
    'OpenSans',
    'Lato',
    'Poppins',
    'Montserrat',
    'Times New Roman',
  ];

  static const List<String> languages = ['Theo hệ thống', 'Tiếng Việt', 'English', '中文', '日本語'];
}

class SettingsNotifier extends Notifier<SettingsState> {
  late final ThemePreference _pref;

  @override
  SettingsState build() {
    _pref = getIt<ThemePreference>();
    return SettingsState.initial();
  }

  Future<void> init() async {
    try {
      final theme = await _pref.getThemeMode();
      final fontSize = await _pref.getFontSize();
      final fontFamily = await _pref.getFontFamily();
      final language = await _pref.getLanguage();
      state = SettingsState(
        fontSize: fontSize,
        fontFamily: fontFamily,
        language: language,
        themeMode: theme,
      );
    } catch (e) {
      // Giữ state default nếu lỗi
    }
  }

  Future<void> setFontSize(double value) async {
    await _pref.saveFontSize(value);
    state = state.copyWith(fontSize: value);
  }

  Future<void> setFontFamily(String value) async {
    await _pref.saveFontFamily(value);
    state = state.copyWith(fontFamily: value);
  }

  Future<void> setLanguage(String value) async {
    await _pref.saveLanguage(value);
    state = state.copyWith(language: value);
  }

  Future<void> setTheme(ThemeMode value) async {
    await _pref.saveThemeMode(value);
    state = state.copyWith(themeMode: value);
  }

  // Dialog/UI Utilities
  static ThemeData buildLightTheme() {
    return ThemeData.light();
  }

  static ThemeData buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
    );
  }

  bool isDarkMode() => state.themeMode == ThemeMode.dark;
}
