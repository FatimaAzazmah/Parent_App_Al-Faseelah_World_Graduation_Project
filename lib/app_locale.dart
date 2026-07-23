import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds app [Locale] so settings can update language without a hardcoded
/// [MaterialApp.locale]. Uses [SharedPreferences] key `app_locale` (`ar` / `en`).
class AppLocale {
  AppLocale._();

  static final ValueNotifier<Locale> notifier =
      ValueNotifier<Locale>(const Locale('ar'));

  static const String _prefsKey = 'app_locale';

  static Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? 'ar';
    final locale = Locale(code);
    if (notifier.value.languageCode != locale.languageCode) {
      notifier.value = locale;
    }
  }

  static Future<void> setLocale(Locale locale) async {
    notifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
