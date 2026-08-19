import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  LanguageProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final code = prefs.getString('languageCode') ?? 'tr';
    final isDark = prefs.getBool('darkMode') ?? false;

    _locale = Locale(code);
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('languageCode', code);

    _locale = Locale(code);

    notifyListeners();
  }

  Future<void> changeTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('darkMode', isDark);

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}