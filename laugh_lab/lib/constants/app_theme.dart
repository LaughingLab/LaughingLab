import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // App colors - Black, White, and Red theme inspired by the logo
  static const Color primaryColor = Color(0xFFFFFFFF); // White (for primary elements, text, icons)
  static const Color secondaryColor = Color(0xFFCCCCCC); // Light Grey (alternative accent, secondary text)
  static const Color accentColor = Color(0xFFFF0000); // Red (for specific accents, errors - replaces pink)
  static const Color backgroundColor = Color(0xFF000000); // Black (main background)
  static const Color cardColor = Color(0xFF1A1A1A); // Dark Grey (for cards, surfaces, app bars)
  static const Color textColor = Color(0xFFFFFFFF); // White (primary text)
  static const Color secondaryTextColor = Color(0xFFBDBDBD); // Light Grey (secondary text, hints)
  static const Color errorColor = accentColor; // Use the red accent color for errors
  
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

  // Light theme - Replaced with Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, // Indicate this is a dark theme
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,       // White
      secondary: secondaryColor,   // Light Grey (Could potentially use accentColor here if more red is desired)
      surface: cardColor,        // Dark Grey
      background: backgroundColor, // Black
      error: errorColor,           // Red
      onPrimary: backgroundColor,  // Black (text/icon on white primary elements)
      onSecondary: backgroundColor, // Black (text/icon on grey secondary elements)
      onSurface: textColor,        // White (text/icon on dark grey surfaces)
      onBackground: textColor,     // White (text/icon on black background)
      onError: Color(0xFFFFFFFF),  // White (text/icon on red error elements)
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
      backgroundColor: cardColor, // Dark Grey for AppBar
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.roboto(
        color: textColor, // White title
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textColor), // White icons
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor, // Red FAB
      foregroundColor: primaryColor, // White icon/text on FAB
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
        color: secondaryTextColor, // Light Grey secondary text
        fontSize: captionTextSize,
      ),
    ).apply( // Ensure default text color is white
      bodyColor: textColor,
      displayColor: textColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor, // Dark Grey input field background
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      hintStyle: TextStyle(color: secondaryTextColor), // Light grey hint text
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
        borderSide: const BorderSide(color: primaryColor, width: 1.0), // White border when focused
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
      buttonColor: primaryColor, // White button background
      textTheme: ButtonTextTheme.primary, // Use primary color for text (which is black here due to ColorScheme)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor, // Red button background
        foregroundColor: primaryColor, // White button text
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
    // Add theme for BottomNavigationBar if needed
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor, // Dark Grey background
      selectedItemColor: accentColor, // Red selected item
      unselectedItemColor: secondaryTextColor, // Light Grey unselected item
      showSelectedLabels: true, // Optionally show labels
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed, // Ensure labels are always shown
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Style for selected label
      elevation: 4.0,
    ),
    // Add theme for TabBar if needed
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor, // White selected tab label
      unselectedLabelColor: secondaryTextColor, // Light Grey unselected tab label
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
    ),
  );
} 