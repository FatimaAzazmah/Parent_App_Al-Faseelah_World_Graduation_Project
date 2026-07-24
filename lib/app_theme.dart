import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app [ThemeMode] so settings can toggle dark mode without a
/// hardcoded [MaterialApp.themeMode]. Uses [SharedPreferences] key
/// `app_theme_mode` (`light` / `dark`). Mirrors the [AppLocale] pattern.
class AppTheme {
  AppTheme._();

  static final ValueNotifier<ThemeMode> notifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static const String _prefsKey = 'app_theme_mode';

  static bool get isDark => notifier.value == ThemeMode.dark;

  static Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey) ?? 'light';
    final mode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    if (notifier.value != mode) {
      notifier.value = mode;
    }
  }

  static Future<void> setDark(bool dark) async {
    notifier.value = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, dark ? 'dark' : 'light');
  }
}
