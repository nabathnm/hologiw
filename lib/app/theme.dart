import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color _getBackgroundColor(String themeName) {
    switch (themeName) {
      case 'Warm Cream':
        return const Color(0xFFFDFBF7);
      case 'Soft Blue':
        return const Color(0xFFF0F8FF);
      case 'Soft Green':
        return const Color(0xFFF0FFF0);
      case 'Light Gray':
        return const Color(0xFFF5F5F5);
      case 'White':
      default:
        return Colors.white;
    }
  }

  static ThemeData getTheme({
    required String fontFamily,
    required double fontSize,
    required double letterSpacing,
    required double lineHeight,
    required String backgroundTheme,
  }) {
    final bgColor = _getBackgroundColor(backgroundTheme);
    
    // Fallback to system font if OpenDyslexic is not available/selected.
    // For MVP, we use a sans-serif from Google Fonts as default,
    // or standard if specified. (OpenDyslexic might need local asset if not in Google Fonts).
    TextStyle baseTextStyle;
    if (fontFamily == 'OpenDyslexic') {
      // Assuming we have it locally, otherwise fallback to standard for now
      baseTextStyle = const TextStyle(fontFamily: 'OpenDyslexic');
    } else {
      baseTextStyle = GoogleFonts.inter();
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5E81AC),
        surface: bgColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: baseTextStyle.copyWith(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: baseTextStyle.copyWith(
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          height: lineHeight,
          color: Colors.black87,
        ),
        bodyMedium: baseTextStyle.copyWith(
          fontSize: fontSize - 2,
          letterSpacing: letterSpacing,
          height: lineHeight,
          color: Colors.black87,
        ),
        titleLarge: baseTextStyle.copyWith(
          fontSize: fontSize + 4,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleMedium: baseTextStyle.copyWith(
          fontSize: fontSize + 2,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5E81AC),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
