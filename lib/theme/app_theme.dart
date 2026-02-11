import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'typography.dart';
import 'theme_extensions.dart';

class AppTheme {
  // ─── Dark Theme (Default) ───────────────────────────────────
  static ThemeData get dark {
    final textTheme = TerraTypography.textTheme(
      TerraColors.darkTextPrimary,
      TerraColors.darkTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TerraColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: TerraColors.darkPrimary,
        onPrimary: Colors.white,
        primaryContainer: TerraColors.darkPrimaryContainer,
        onPrimaryContainer: TerraColors.darkPrimaryLight,
        secondary: TerraColors.darkSecondary,
        onSecondary: Colors.white,
        secondaryContainer: TerraColors.darkSecondaryContainer,
        onSecondaryContainer: TerraColors.darkSecondaryLight,
        surface: TerraColors.darkSurface,
        onSurface: TerraColors.darkTextPrimary,
        surfaceContainerHighest: TerraColors.darkSurfaceVariant,
        error: TerraColors.darkDanger,
        onError: Colors.white,
        outline: TerraColors.darkOutline,
        outlineVariant: TerraColors.darkOutlineVariant,
      ),
      textTheme: textTheme,
      extensions: [TerraThemeExtension.dark()],

      // ─── AppBar ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: TerraColors.darkBackground,
        foregroundColor: TerraColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TerraColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: TerraColors.darkTextSecondary,
          size: 24,
        ),
      ),

      // ─── Cards ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: TerraColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TerraColors.darkOutline, width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.15),
      ),

      // ─── Elevated Buttons ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: TerraColors.darkPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // ─── Outlined Buttons ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TerraColors.darkTextPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: TerraColors.darkOutlineVariant, width: 1.5),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Text Buttons ──────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TerraColors.darkPrimary,
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Input Fields ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TerraColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.darkOutline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.darkOutline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.darkDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.darkDanger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.dmSans(color: TerraColors.darkTextSecondary),
        labelStyle: GoogleFonts.dmSans(color: TerraColors.darkTextSecondary),
        prefixIconColor: TerraColors.darkTextSecondary,
        errorStyle: GoogleFonts.dmSans(color: TerraColors.darkDanger),
      ),

      // ─── Bottom Navigation ─────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: TerraColors.darkBackground,
        selectedItemColor: TerraColors.darkPrimary,
        unselectedItemColor: TerraColors.darkTextSecondary,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
      ),

      // ─── Tab Bar ───────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: TerraColors.darkPrimary,
        unselectedLabelColor: TerraColors.darkTextSecondary,
        indicatorColor: TerraColors.darkPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      // ─── Chips ─────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: TerraColors.darkPrimaryContainer,
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: TerraColors.darkPrimaryLight,
        ),
      ),

      // ─── Dialogs ───────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: TerraColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TerraColors.darkTextPrimary,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TerraColors.darkTextPrimary,
        ),
      ),

      // ─── Bottom Sheets ─────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TerraColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ─── Divider ───────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: TerraColors.darkOutline,
        thickness: 1,
        space: 1,
      ),

      // ─── Switch / Radio ────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(TerraColors.darkPrimary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TerraColors.darkPrimary.withValues(alpha: 0.5);
          }
          return TerraColors.darkOutline;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(TerraColors.darkPrimary),
      ),

      // ─── Snackbar ──────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TerraColors.darkSurfaceVariant,
        contentTextStyle: GoogleFonts.dmSans(color: TerraColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Progress Indicator ────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TerraColors.darkPrimary,
        linearTrackColor: TerraColors.darkSurfaceVariant,
      ),
    );
  }

  // ─── Light Theme ────────────────────────────────────────────
  static ThemeData get light {
    final textTheme = TerraTypography.textTheme(
      TerraColors.lightTextPrimary,
      TerraColors.lightTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: TerraColors.lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: TerraColors.lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: TerraColors.lightPrimaryContainer,
        onPrimaryContainer: TerraColors.lightPrimary,
        secondary: TerraColors.lightSecondary,
        onSecondary: Colors.white,
        secondaryContainer: TerraColors.lightSecondaryContainer,
        onSecondaryContainer: TerraColors.lightSecondary,
        surface: TerraColors.lightSurface,
        onSurface: TerraColors.lightTextPrimary,
        surfaceContainerHighest: TerraColors.lightSurfaceVariant,
        error: TerraColors.lightDanger,
        onError: Colors.white,
        outline: TerraColors.lightOutline,
        outlineVariant: TerraColors.lightOutlineVariant,
      ),
      textTheme: textTheme,
      extensions: [TerraThemeExtension.light()],

      // ─── AppBar ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: TerraColors.lightBackground,
        foregroundColor: TerraColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TerraColors.lightTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: TerraColors.lightTextSecondary,
          size: 24,
        ),
      ),

      // ─── Cards ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: TerraColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TerraColors.lightOutline, width: 1),
        ),
        shadowColor: TerraColors.lightTextPrimary.withValues(alpha: 0.08),
      ),

      // ─── Elevated Buttons ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: TerraColors.lightPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // ─── Outlined Buttons ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TerraColors.lightTextPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: TerraColors.lightOutlineVariant, width: 1.5),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Text Buttons ──────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TerraColors.lightPrimary,
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Input Fields ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TerraColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.lightOutline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.lightOutline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.lightDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TerraColors.lightDanger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.dmSans(color: TerraColors.lightTextSecondary),
        labelStyle: GoogleFonts.dmSans(color: TerraColors.lightTextSecondary),
        prefixIconColor: TerraColors.lightTextSecondary,
        errorStyle: GoogleFonts.dmSans(color: TerraColors.lightDanger),
      ),

      // ─── Bottom Navigation ─────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: TerraColors.lightSurface,
        selectedItemColor: TerraColors.lightPrimary,
        unselectedItemColor: TerraColors.lightTextSecondary,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
      ),

      // ─── Tab Bar ───────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: TerraColors.lightPrimary,
        unselectedLabelColor: TerraColors.lightTextSecondary,
        indicatorColor: TerraColors.lightPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      // ─── Chips ─────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: TerraColors.lightPrimaryContainer,
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: TerraColors.lightPrimary,
        ),
      ),

      // ─── Dialogs ───────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: TerraColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TerraColors.lightTextPrimary,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TerraColors.lightTextPrimary,
        ),
      ),

      // ─── Bottom Sheets ─────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TerraColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ─── Divider ───────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: TerraColors.lightOutline,
        thickness: 1,
        space: 1,
      ),

      // ─── Switch / Radio ────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(TerraColors.lightPrimary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TerraColors.lightPrimary.withValues(alpha: 0.5);
          }
          return TerraColors.lightOutline;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(TerraColors.lightPrimary),
      ),

      // ─── Snackbar ──────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TerraColors.lightSurfaceVariant,
        contentTextStyle: GoogleFonts.dmSans(color: TerraColors.lightTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Progress Indicator ────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TerraColors.lightPrimary,
        linearTrackColor: TerraColors.lightSurfaceVariant,
      ),
    );
  }

  // ─── High Contrast Theme ────────────────────────────────────
  static ThemeData get highContrast {
    // High contrast inherits light theme structure with increased contrast
    return light.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF0000FF),
        onPrimary: Colors.white,
        secondary: Color(0xFF00FF00),
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        outline: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF0000FF),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF0000FF),
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      // Keep terra extensions so widgets don't crash
      extensions: [TerraThemeExtension.light()],
    );
  }
}
