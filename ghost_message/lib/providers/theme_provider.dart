import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  //dark theme
  static const Color bgDark = Color.fromARGB(255, 34, 34, 34);
  static const Color textDark = Color(0xFFD3D3D3);
  static const Color buttonDark = Color(0xFF2C2C2C);
  static const Color fieldDark = Color(0xFF555555);
  static const Color borderDark = Color(0xFF4A4A4A);
  static const Color hintDark = Color(0xFF9A9A9A);

  //light theme
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color textLight = Color.fromARGB(255, 22, 22, 22);
  static const Color buttonLight = Color(0xFFD9D9D9);
  static const Color pillLight = Color(0xFFEDEDED);
  static const Color borderLight = Color(0xFFD9D9D9);
  static const Color hintLight = Color(0xFF8E8E93);

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _isDarkMode;

  void updateTheme(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: bgLight,
        canvasColor: bgLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: bgLight,
          foregroundColor: textLight,
          elevation: 0,
        ),
        textTheme: const TextTheme().apply(
          bodyColor: textLight,
          displayColor: textLight,
        ),
        cardTheme: const CardThemeData(
          color: pillLight,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: borderLight,
          thickness: 1,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: bgLight,
          titleTextStyle: TextStyle(
            color: textLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(color: textLight),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        canvasColor: bgDark,
        textTheme: const TextTheme().apply(
          bodyColor: textDark,
          displayColor: textDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgDark,
          foregroundColor: textDark,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: buttonDark,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: borderDark,
          thickness: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonDark,
            foregroundColor: textDark,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fieldDark,
          labelStyle: const TextStyle(color: textDark),
          hintStyle: TextStyle(color: textDark.withOpacity(0.7)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: textDark),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: buttonDark,
          titleTextStyle: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(color: textDark),
        ),
      );
}