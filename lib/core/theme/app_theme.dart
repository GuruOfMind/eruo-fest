import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual identity for EuroFest.
///
/// Uses the Cairo typeface (fetched at runtime via google_fonts) which renders
/// Arabic and Latin glyphs well — important for our Arabic-first, mixed-script
/// catalog (e.g. "عمرو دياب" alongside "Saint Levant").
class AppTheme {
  AppTheme._();

  // Warm, festival-leaning palette.
  static const Color _seed = Color(0xFF6C2BD9); // vivid violet
  static const Color _accent = Color(0xFFF59E0B); // amber

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ).copyWith(secondary: _accent);

    final base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
