import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreference {
  static const _themeModeKey = 'themeMode';
  static const _fontSizeKey = 'fontSize';
  static const _fontFamilyKey = 'fontFamily';
  static const _languageKey = 'language';

  SharedPreferences? _prefs;

  ThemePreference(this._prefs);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await init();
    await _prefs!.setString(_themeModeKey, mode.toString());
  }

  Future<ThemeMode> getThemeMode() async {
    await init();
    final theme = _prefs!.getString(_themeModeKey);
    switch (theme) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  //  Font size
  Future<void> saveFontSize(double fontSize) async {
    await init();
    await _prefs!.setDouble(_fontSizeKey, fontSize);
  }

  Future<double> getFontSize() async {
    await init();
    return _prefs!.getDouble(_fontSizeKey) ?? 16.0;
  }

  //  Font family
  Future<void> saveFontFamily(String fontFamily) async {
    await init();
    await _prefs!.setString(_fontFamilyKey, fontFamily);
  }

  Future<String> getFontFamily() async {
    await init();
    return _prefs!.getString(_fontFamilyKey) ?? 'Roboto';
  }

  //  Language
  Future<void> saveLanguage(String lang) async {
    await init();
    await _prefs!.setString(_languageKey, lang);
  }

  Future<String> getLanguage() async {
    await init();
    return _prefs!.getString(_languageKey) ?? 'Theo hệ thống';
  }
}
