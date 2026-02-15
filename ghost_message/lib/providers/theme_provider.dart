import 'package:flutter/material.dart';


class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeMode get themeMode {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
  bool get isDarkMode {
    return _isDarkMode;
  }

  void updateTheme(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }
}