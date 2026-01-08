import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  bool isDark = true;

  void toggleTheme(bool val) {
    isDark = !isDark;
    notifyListeners();
  }

  ThemeData get theme {
    return isDark ? darkTheme : lightTheme;
  }

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardColor: const Color(0xFF1F1F1F),
        primaryColor: Colors.blueAccent,
        textTheme: GoogleFonts.lexendTextTheme(
          _baseTextTheme(
            Colors.white,
            Colors.grey,
          ),
        ),
      );

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: const Color(0xFFF3F4F6),
        primaryColor: Colors.blueAccent,
        textTheme: GoogleFonts.lexendTextTheme(
          _baseTextTheme(
            Colors.black,
            Colors.black54,
          ),
        ),
      );

  TextTheme _baseTextTheme(Color primary, Color secondary) {
    return TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w500,
        color: primary,
      ),
    );
  }
}
