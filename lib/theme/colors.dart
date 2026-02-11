import 'package:flutter/material.dart';

/// Terra Scholar color system — warm earth tones for both dark and light themes.
abstract class TerraColors {
  // ─── Dark Theme ───────────────────────────────────────────────
  static const darkBackground = Color(0xFF1A1714);
  static const darkSurface = Color(0xFF252118);
  static const darkSurfaceVariant = Color(0xFF302A22);
  static const darkSurfaceTint = Color(0xFF3A322A);

  static const darkPrimary = Color(0xFFC67B4E);
  static const darkPrimaryLight = Color(0xFFE8A87C);
  static const darkPrimaryContainer = Color(0xFF3D2A1E);

  static const darkSecondary = Color(0xFF7A9A6D);
  static const darkSecondaryLight = Color(0xFFA3C496);
  static const darkSecondaryContainer = Color(0xFF1E2E1A);

  static const darkAccent = Color(0xFFE8D5B7);
  static const darkAccentMuted = Color(0xFFB8A898);

  static const darkTextPrimary = Color(0xFFF2EAE0);
  static const darkTextSecondary = Color(0xFF9B8E80);
  static const darkTextDisabled = Color(0xFF5C544B);

  static const darkDanger = Color(0xFFC45C4A);
  static const darkDangerContainer = Color(0xFF3A1F1A);

  static const darkWarning = Color(0xFFD4A24E);
  static const darkWarningContainer = Color(0xFF3A2E1A);

  static const darkOutline = Color(0xFF3D362E);
  static const darkOutlineVariant = Color(0xFF4A4238);

  // ─── Light Theme ──────────────────────────────────────────────
  static const lightBackground = Color(0xFFFAF6F1);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF0EAE2);
  static const lightSurfaceTint = Color(0xFFE8E0D6);

  static const lightPrimary = Color(0xFFB5693E);
  static const lightPrimaryLight = Color(0xFFC67B4E);
  static const lightPrimaryContainer = Color(0xFFFCEADD);

  static const lightSecondary = Color(0xFF5E8352);
  static const lightSecondaryLight = Color(0xFF7A9A6D);
  static const lightSecondaryContainer = Color(0xFFE6F0E2);

  static const lightAccent = Color(0xFF8B7355);
  static const lightAccentMuted = Color(0xFFA09080);

  static const lightTextPrimary = Color(0xFF1A1714);
  static const lightTextSecondary = Color(0xFF6B5F53);
  static const lightTextDisabled = Color(0xFFB0A89E);

  static const lightDanger = Color(0xFFB84A38);
  static const lightDangerContainer = Color(0xFFFCEAE6);

  static const lightWarning = Color(0xFFB8862A);
  static const lightWarningContainer = Color(0xFFFFF3DC);

  static const lightOutline = Color(0xFFDDD5CB);
  static const lightOutlineVariant = Color(0xFFC8BEB2);

  // ─── Tier Colors ──────────────────────────────────────────────
  static const tierNewcomer = Color(0xFF9B8E80);
  static const tierBeginner = Color(0xFF7A9A6D);
  static const tierIntermediate = Color(0xFF7B8EAA);
  static const tierExpert = Color(0xFFAA7EA8);
  static const tierMaster = Color(0xFFC4956A);
  static const tierLegendary = Color(0xFFD4A24E);

  // ─── Medal Colors ─────────────────────────────────────────────
  static const medalGold = Color(0xFFE8D5B7);
  static const medalSilver = Color(0xFFB8A898);
  static const medalBronze = Color(0xFFC67B4E);

  // ─── Module Palette ───────────────────────────────────────────
  static const moduleColors = <Color>[
    Color(0xFFC67B4E), // Terracotta
    Color(0xFF7A9A6D), // Sage
    Color(0xFF7B8EAA), // Dusty blue
    Color(0xFFAA7EA8), // Muted plum
    Color(0xFFC4956A), // Warm tan
    Color(0xFF6B9B9B), // Teal sage
    Color(0xFFB8845E), // Copper
    Color(0xFF8B9A6D), // Olive sage
  ];

  // ─── Gradient Color Pairs ─────────────────────────────────────
  // Dark mode
  static const darkStreakGradientColors = [Color(0xFFC67B4E), Color(0xFFE8A87C), Color(0xFFF0C27F)];
  static const darkPointsGradientColors = [Color(0xFF7A9A6D), Color(0xFFA3C496)];
  static const darkTierGradientColors = [Color(0xFFE8D5B7), Color(0xFFC67B4E)];
  static const darkCheckinSuccessColors = [Color(0xFF7A9A6D), Color(0xFF5E8352)];

  // Light mode
  static const lightStreakGradientColors = [Color(0xFFB5693E), Color(0xFFC67B4E), Color(0xFFD4955E)];
  static const lightPointsGradientColors = [Color(0xFF5E8352), Color(0xFF7A9A6D)];
  static const lightTierGradientColors = [Color(0xFF8B7355), Color(0xFFB5693E)];
  static const lightCheckinSuccessColors = [Color(0xFF5E8352), Color(0xFF3D6B30)];
}
