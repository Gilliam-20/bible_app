import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────
  static const Color bgDeep = Color(0xFF0D0E14); // near-black parchment
  static const Color bgCard = Color(0xFF161820); // elevated card
  static const Color bgSurface = Color(0xFF1E2030); // sheet / modal bg
  static const Color gold = Color(0xFFC9A84C); // signature gold
  static const Color goldLight = Color(0xFFE8CC7A);
  static const Color goldDim = Color(0xFF7A6230);
  static const Color parchment = Color(0xFFF5EED8); // text on dark
  static const Color textMid = Color(0xFFB0A880);
  static const Color textDim = Color(0xFF6B6550);
  static const Color accent = Color(0xFF4A6FA5); // muted indigo
  static const Color accentSoft = Color(0xFF2A3F60);
  static const Color divider = Color(0xFF252830);

  // ── Text Styles ───────────────────────────────────────────
  static TextStyle display(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        color: color ?? parchment,
        fontWeight: weight ?? FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.lora(
        fontSize: size,
        color: color ?? parchment,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.75,
      );

  static TextStyle label(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.inter(
        fontSize: size,
        color: color ?? textMid,
        fontWeight: weight ?? FontWeight.w500,
        letterSpacing: 0.5,
      );

  // ── Theme Data ────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: accent,
      surface: bgCard,
      onPrimary: bgDeep,
      onSurface: parchment,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bgDeep,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: display(18, color: parchment),
      iconTheme: const IconThemeData(color: gold),
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: gold,
      unselectedItemColor: textDim,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: display(32),
      displayMedium: display(24),
      bodyLarge: body(17),
      bodyMedium: body(15),
      labelLarge: label(14),
      labelSmall: label(11),
    ),
  );
}
