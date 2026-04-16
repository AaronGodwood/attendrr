import 'package:flutter/material.dart';

/// Version A color system — plain blue-grey palette for both dark and light themes.
abstract class TerraColors {
  // ─── Dark Theme ───────────────────────────────────────────────
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceVariant = Color(0xFF2A2A2A);
  static const darkSurfaceTint = Color(0xFF333333);

  static const darkPrimary = Color(0xFF5B8CDE);
  static const darkPrimaryLight = Color(0xFF7BA6E8);
  static const darkPrimaryContainer = Color(0xFF1A2A3D);

  static const darkSecondary = Color(0xFF7EA8C7);
  static const darkSecondaryLight = Color(0xFF9BBDD6);
  static const darkSecondaryContainer = Color(0xFF1A2A35);

  static const darkAccent = Color(0xFFB8BEC8);
  static const darkAccentMuted = Color(0xFF8890A0);

  static const darkTextPrimary = Color(0xFFE8E8E8);
  static const darkTextSecondary = Color(0xFF9098A8);
  static const darkTextDisabled = Color(0xFF505868);

  static const darkDanger = Color(0xFFE05555);
  static const darkDangerContainer = Color(0xFF2A1515);

  static const darkWarning = Color(0xFFE09840);
  static const darkWarningContainer = Color(0xFF2A2010);

  static const darkOutline = Color(0xFF383838);
  static const darkOutlineVariant = Color(0xFF454545);

  // ─── Light Theme ──────────────────────────────────────────────
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFEEEEEE);
  static const lightSurfaceTint = Color(0xFFE5E5E5);

  static const lightPrimary = Color(0xFF2D6BE4);
  static const lightPrimaryLight = Color(0xFF5B8CDE);
  static const lightPrimaryContainer = Color(0xFFE8F0FD);

  static const lightSecondary = Color(0xFF3A82B5);
  static const lightSecondaryLight = Color(0xFF5B9ED6);
  static const lightSecondaryContainer = Color(0xFFE0EEF8);

  static const lightAccent = Color(0xFF6878A0);
  static const lightAccentMuted = Color(0xFF8890A8);

  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF606878);
  static const lightTextDisabled = Color(0xFFB0B8C8);

  static const lightDanger = Color(0xFFD03030);
  static const lightDangerContainer = Color(0xFFFCEAEA);

  static const lightWarning = Color(0xFFB87820);
  static const lightWarningContainer = Color(0xFFFFF5DC);

  static const lightOutline = Color(0xFFDDDDDD);
  static const lightOutlineVariant = Color(0xFFCCCCCC);

  // ─── Tier Colors ──────────────────────────────────────────────
  static const tierNewcomer = Color(0xFF9098A8);
  static const tierBeginner = Color(0xFF7EA8C7);
  static const tierIntermediate = Color(0xFF7B8EAA);
  static const tierExpert = Color(0xFF8890A0);
  static const tierMaster = Color(0xFF5B8CDE);
  static const tierLegendary = Color(0xFF7BA6E8);

  // ─── Medal Colors ─────────────────────────────────────────────
  static const medalGold = Color(0xFFB8BEC8);
  static const medalSilver = Color(0xFF8890A0);
  static const medalBronze = Color(0xFF5B8CDE);

  // ─── Module Palette ───────────────────────────────────────────
  static const moduleColors = <Color>[
    Color(0xFF5B8CDE), // Blue
    Color(0xFF7EA8C7), // Sky blue
    Color(0xFF6878A0), // Slate blue
    Color(0xFF8890A8), // Grey blue
    Color(0xFF5B9E9E), // Teal
    Color(0xFF7898B8), // Dusty blue
    Color(0xFF8878A8), // Lavender
    Color(0xFF6898B8), // Steel blue
  ];

  // ─── Gradient Color Pairs ─────────────────────────────────────
  // Dark mode
  static const darkStreakGradientColors = [Color(0xFF5B8CDE), Color(0xFF7BA6E8), Color(0xFF9BBDD6)];
  static const darkPointsGradientColors = [Color(0xFF7EA8C7), Color(0xFF9BBDD6)];
  static const darkTierGradientColors = [Color(0xFFB8BEC8), Color(0xFF5B8CDE)];
  static const darkCheckinSuccessColors = [Color(0xFF5B8CDE), Color(0xFF3A6BB8)];

  // Light mode
  static const lightStreakGradientColors = [Color(0xFF2D6BE4), Color(0xFF5B8CDE), Color(0xFF7BA6E8)];
  static const lightPointsGradientColors = [Color(0xFF3A82B5), Color(0xFF5B9ED6)];
  static const lightTierGradientColors = [Color(0xFF6878A0), Color(0xFF2D6BE4)];
  static const lightCheckinSuccessColors = [Color(0xFF3A82B5), Color(0xFF1A5A8A)];
}
