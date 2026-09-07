import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Orange Colors
  static const Color primaryOrange = Color(0xFFF97316); // Tailwind Orange 500
  static const Color darkOrange = Color(0xFFEA580C);    // Tailwind Orange 600
  static const Color lightOrange = Color(0xFFFDBA74);   // Tailwind Orange 300
  static const Color orangeContainer = Color(0xFFFFEDD5); // Tailwind Orange 100
  static const Color darkOrangeText = Color(0xFF9A3412);  // Tailwind Orange 800

  static Color getBackgroundColor(String themeName) {
    switch (themeName) {
      case 'Warm Peach':
        return const Color(0xFFFFF8F3);
      case 'Warm Cream':
        return const Color(0xFFFDFBF7);
      case 'Soft Amber':
        return const Color(0xFFFEF9EE);
      case 'Soft Mint':
        return const Color(0xFFF2FAF4);
      case 'Light Gray':
        return const Color(0xFFF8F9FA);
      case 'White':
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  static ThemeData getTheme({
    required String fontFamily,
    required double fontSize,
    required double letterSpacing,
    required double lineHeight,
    required String backgroundTheme,
  }) {
    final bgColor = getBackgroundColor(backgroundTheme);
    
    // Dyslexia-friendly typography setup:
    // Lexend is scientifically designed to enhance reading fluency and reduce visual stress.
    TextStyle baseTextStyle;
    if (fontFamily == 'OpenDyslexic') {
      baseTextStyle = const TextStyle(fontFamily: 'OpenDyslexic');
    } else if (fontFamily == 'System') {
      baseTextStyle = GoogleFonts.inter();
    } else {
      // Default: Lexend
      baseTextStyle = GoogleFonts.lexend();
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryOrange,
      primary: primaryOrange,
      secondary: darkOrange,
      tertiary: const Color(0xFFF59E0B),
      surface: bgColor,
      primaryContainer: orangeContainer,
      onPrimaryContainer: darkOrangeText,
      outlineVariant: const Color(0xFFFED7AA),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        titleTextStyle: baseTextStyle.copyWith(
          color: const Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: baseTextStyle.copyWith(
          fontSize: fontSize + 8,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1F2937),
          height: 1.3,
        ),
        titleLarge: baseTextStyle.copyWith(
          fontSize: fontSize + 4,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
        ),
        titleMedium: baseTextStyle.copyWith(
          fontSize: fontSize + 1,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        bodyLarge: baseTextStyle.copyWith(
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          height: lineHeight,
          color: const Color(0xFF1F2937),
        ),
        bodyMedium: baseTextStyle.copyWith(
          fontSize: fontSize - 2,
          letterSpacing: letterSpacing,
          height: lineHeight,
          color: const Color(0xFF4B5563),
        ),
        labelLarge: baseTextStyle.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryOrange.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: Color(0xFFFDBA74), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: baseTextStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFFFEDD5), width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: orangeContainer,
        secondarySelectedColor: primaryOrange,
        labelStyle: baseTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4B5563),
        ),
        secondaryLabelStyle: baseTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: darkOrangeText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFED7AA)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryOrange,
        inactiveTrackColor: const Color(0xFFFFEDD5),
        thumbColor: darkOrange,
        overlayColor: primaryOrange.withOpacity(0.15),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFED7AA), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFED7AA), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        labelStyle: baseTextStyle.copyWith(color: const Color(0xFF6B7280)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
