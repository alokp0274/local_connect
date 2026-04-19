// core/theme/app_theme.dart
//
// Centralised design-token class for the LocalConnect premium dark luxury theme.
// Every colour, radius, gradient, shadow, and motion constant lives here.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Primary Palette (Deep Navy Dark) ─────────────────────
  static const Color primary = Color(0xFF60A5FA);
  static const Color primaryLight = Color(0xFF93C5FD);
  static const Color primaryDark = Color(0xFF0B1445);
  static const Color primaryDeep = Color(0xFF050B2D);

  // ── Accent Colours ───────────────────────────────────────
  static const Color accent = Color(0xFFFACC15);
  static const Color accentGold = Color(0xFFFACC15);
  static const Color accentGoldLight = Color(0xFFFDE68A);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentTeal = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFFA78BFA);

  // ── Backgrounds & Surfaces ───────────────────────────────
  static const Color background = Color(0xFF050B2D);
  static const Color surface = Color(0x0FFFFFFF);
  static const Color surfaceCard = Color(0x0FFFFFFF);
  static const Color surfaceElevated = Color(0x1AFFFFFF);
  static const Color surfaceInput = Color(0x14FFFFFF);
  static const Color surfaceDivider = Color(0x1FFFFFFF);

  // ── Solid Surface (for bottom sheets, dialogs) ───────────
  static const Color surfaceSolid = Color(0xFF0B1445);
  static const Color surfaceSolidLight = Color(0xFF101B52);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textOnAccent = Color(0xFF050B2D);

  // ── Glass / Overlay ──────────────────────────────────────
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBorderLight = Color(0x14FFFFFF);
  static const Color glassDark = Color(0x33000000);
  static const Color glassDarkStrong = Color(0x4D000000);
  static const Color glassWhite = Color(0x0FFFFFFF);

  // ── Status ───────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFACC15);
  static const Color urgent = Color(0xFFEF4444);
  static const Color border = Color(0x1FFFFFFF);

  // ── Radii ────────────────────────────────────────────────
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 18.0;
  static const double radiusLG = 22.0;
  static const double radiusXL = 26.0;
  static const double radiusFull = 100.0;

  // ── Animation Tokens ─────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 350);
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationDramatic = Duration(milliseconds: 700);
  static const Curve curveBounce = Curves.easeOutBack;
  static const Curve curveDramatic = Curves.easeOutQuart;
  static const double pressScale = 0.96;
  static const int staggerDelayMs = 50;

  // ── Gradients ────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFACC15), Color(0xFFFDE68A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldSubtleGradient = LinearGradient(
    colors: [Color(0x26FACC15), Color(0x0DFACC15)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFACC15), Color(0xFFFFD84D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primarySubtleGradient = LinearGradient(
    colors: [Color(0x1A60A5FA), Color(0x0D60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF050B2D), Color(0xFF0B1445)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFF050B2D), Color(0xFF0B1445)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF050B2D), Color(0xFF0B1445)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Box Shadows ──────────────────────────────────────────
  static const List<BoxShadow> goldGlow = [
    BoxShadow(color: Color(0x40FACC15), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> tealGlow = [
    BoxShadow(color: Color(0x3010B981), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> softGlow = [
    BoxShadow(color: Color(0x2060A5FA), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(color: Color(0x50000000), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> glassShadow = [
    BoxShadow(color: Color(0x20000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // ── Responsive Helpers ───────────────────────────────────
  static double responsivePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 12;
    if (w < 400) return 16;
    return 20;
  }

  // ── Material ThemeData ───────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: primary,
      scaffoldBackgroundColor: background,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 0.3,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: textOnAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textMuted),
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceDivider,
        thickness: 0.5,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceSolid,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceSolidLight,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceSolid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceInput,
        selectedColor: accentGold,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: border, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentGold,
        unselectedLabelColor: textMuted,
        indicatorColor: accentGold,
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentGold,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? accentGold : textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accentGold.withAlpha(60)
              : surfaceInput,
        ),
      ),
    );
  }
}
