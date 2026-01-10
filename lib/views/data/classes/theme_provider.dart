import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  bool isDark = true;

  ThemeProvider() {
    _loadThemeForUser();
  }

  /// Get unique key per user
  String _userThemeKey() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? 'isDarkMode_${user.uid}' : 'isDarkMode_guest';
  }

  /// Load theme for current user
  Future<void> _loadThemeForUser() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool(_userThemeKey()) ?? true;
    notifyListeners();
  }

  /// Toggle theme + save for this user
  Future<void> toggleTheme(bool val) async {
    isDark = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userThemeKey(), isDark);
    notifyListeners();
  }

  /// IMPORTANT: call this after login/logout
  Future<void> refreshThemeForUser() async {
    await _loadThemeForUser();
  }

  ThemeData get theme => isDark ? darkTheme : lightTheme;

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000),
    cardColor: const Color(0xFF1F1F1F),
    primaryColor: Colors.blueAccent,
    textTheme: GoogleFonts.lexendTextTheme(
      _baseTextTheme(Colors.white, Colors.grey),
    ),
  );

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xFFF3F4F6),
    primaryColor: Colors.blueAccent,
    textTheme: GoogleFonts.lexendTextTheme(
      _baseTextTheme(Colors.black, Colors.black54),
    ),
  );

  TextTheme _baseTextTheme(Color primary, Color secondary) {
    return TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: primary),
      titleMedium: TextStyle(fontWeight: FontWeight.w500, color: primary),
      bodyLarge: TextStyle(fontWeight: FontWeight.bold, color: primary),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(fontWeight: FontWeight.w500, color: primary),
    );
  }
}
