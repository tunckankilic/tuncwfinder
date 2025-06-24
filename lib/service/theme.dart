import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElegantTheme {
  // Ana Renkler
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryColor = Color(0xFFCFB53B);
  static const Color backgroundColor = Color(0xFFF8F5E6);
  static const Color textColor = Color(0xFF333333);

  // Vurgu Renkleri
  static const Color accentBordeaux = Color(0xFF800020);
  static const Color accentEmerald = Color(0xFF0F574A);

  // Nötr Tonlar
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color mediumGrey = Color(0xFF9E9E9E);

  // Text Theme
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: textColor),
    displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: textColor),
    displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 48, fontWeight: FontWeight.w400, color: textColor),
    headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor),
    headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w400, color: textColor),
    titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textColor),
    titleMedium: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textColor),
    titleSmall: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor),
    bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor),
    bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor),
    labelLarge: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
        color: Colors.white),
    bodySmall: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textColor),
    labelSmall: GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: textColor),
  );

  // ThemeData
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        color: primaryColor,
        elevation: 0,
        toolbarTextStyle: textTheme
            .copyWith(
              titleLarge: textTheme.titleLarge?.copyWith(color: Colors.white),
            )
            .bodyMedium,
        titleTextStyle: textTheme
            .copyWith(
              titleLarge: textTheme.titleLarge?.copyWith(color: Colors.white),
            )
            .titleLarge,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: secondaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
      ),
      dividerColor: mediumGrey,
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(secondary: secondaryColor)
          .copyWith(surface: backgroundColor),
    );
  }
}
