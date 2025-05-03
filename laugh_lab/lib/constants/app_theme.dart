import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // App colors
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFFFF5722);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1F1F1F);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color errorColor = Color(0xFFB00020);
  
  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFFE57373), // Red
    Color(0xFF81C784), // Green
    Color(0xFF64B5F6), // Blue
    Color(0xFFFFD54F), // Yellow
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DB6AC), // Teal
    Color(0xFFFF8A65), // Orange
    Color(0xFF90A4AE), // Blue Grey
  ];

  // Button size
  static const double minButtonSize = 44.0;
  
  // Avatar sizes
  static const double avatarSizeSmall = 40.0;
  static const double avatarSizeMedium = 60.0;
  static const double avatarSizeLarge = 100.0;
  
  // Text sizes
  static const double bodyTextSize = 16.0;
  static const double headlineTextSize = 24.0;
  static const double titleTextSize = 20.0;
  static const double subtitleTextSize = 18.0;
  static const double captionTextSize = 14.0;

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.roboto(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.roboto(
        color: textColor,
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.roboto(
        color: textColor,
        fontSize: headlineTextSize,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.roboto(
        color: textColor,
        fontSize: titleTextSize,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.roboto(
        color: textColor,
        fontSize: subtitleTextSize,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.roboto(
        color: textColor,
        fontSize: bodyTextSize,
      ),
      bodyMedium: GoogleFonts.roboto(
        color: secondaryTextColor,
        fontSize: captionTextSize,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorColor, width: 1.0),
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      minWidth: minButtonSize,
      height: minButtonSize,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(minButtonSize, minButtonSize),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: bodyTextSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
} 