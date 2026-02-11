import 'package:flutter/material.dart';
import 'colors.dart';

/// Custom theme extension for semantic colors not covered by ColorScheme.
@immutable
class TerraThemeExtension extends ThemeExtension<TerraThemeExtension> {
  final Color accent;
  final Color accentMuted;
  final Color danger;
  final Color dangerContainer;
  final Color warning;
  final Color warningContainer;
  final Color success;
  final Color successContainer;
  final Color textSecondary;
  final Color textDisabled;
  final Color surfaceVariant;
  final Color surfaceTint;
  final Color primaryLight;
  final Color primaryContainer;
  final Color secondaryLight;
  final Color secondaryContainer;
  final LinearGradient streakGradient;
  final LinearGradient pointsGradient;
  final LinearGradient tierGradient;
  final LinearGradient checkinSuccessGradient;
  final List<Color> moduleColors;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color tierNewcomer;
  final Color tierBeginner;
  final Color tierIntermediate;
  final Color tierExpert;
  final Color tierMaster;
  final Color tierLegendary;
  final Color medalGold;
  final Color medalSilver;
  final Color medalBronze;

  const TerraThemeExtension({
    required this.accent,
    required this.accentMuted,
    required this.danger,
    required this.dangerContainer,
    required this.warning,
    required this.warningContainer,
    required this.success,
    required this.successContainer,
    required this.textSecondary,
    required this.textDisabled,
    required this.surfaceVariant,
    required this.surfaceTint,
    required this.primaryLight,
    required this.primaryContainer,
    required this.secondaryLight,
    required this.secondaryContainer,
    required this.streakGradient,
    required this.pointsGradient,
    required this.tierGradient,
    required this.checkinSuccessGradient,
    required this.moduleColors,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.tierNewcomer,
    required this.tierBeginner,
    required this.tierIntermediate,
    required this.tierExpert,
    required this.tierMaster,
    required this.tierLegendary,
    required this.medalGold,
    required this.medalSilver,
    required this.medalBronze,
  });

  factory TerraThemeExtension.dark() => TerraThemeExtension(
        accent: TerraColors.darkAccent,
        accentMuted: TerraColors.darkAccentMuted,
        danger: TerraColors.darkDanger,
        dangerContainer: TerraColors.darkDangerContainer,
        warning: TerraColors.darkWarning,
        warningContainer: TerraColors.darkWarningContainer,
        success: TerraColors.darkSecondary,
        successContainer: TerraColors.darkSecondaryContainer,
        textSecondary: TerraColors.darkTextSecondary,
        textDisabled: TerraColors.darkTextDisabled,
        surfaceVariant: TerraColors.darkSurfaceVariant,
        surfaceTint: TerraColors.darkSurfaceTint,
        primaryLight: TerraColors.darkPrimaryLight,
        primaryContainer: TerraColors.darkPrimaryContainer,
        secondaryLight: TerraColors.darkSecondaryLight,
        secondaryContainer: TerraColors.darkSecondaryContainer,
        streakGradient: const LinearGradient(
          begin: Alignment(-0.7, -0.7),
          end: Alignment(0.7, 0.7),
          colors: TerraColors.darkStreakGradientColors,
        ),
        pointsGradient: const LinearGradient(
          begin: Alignment(-0.7, -0.7),
          end: Alignment(0.7, 0.7),
          colors: TerraColors.darkPointsGradientColors,
        ),
        tierGradient: const LinearGradient(
          begin: Alignment(-0.7, -0.7),
          end: Alignment(0.7, 0.7),
          colors: TerraColors.darkTierGradientColors,
        ),
        checkinSuccessGradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: TerraColors.darkCheckinSuccessColors,
        ),
        moduleColors: TerraColors.moduleColors,
        shimmerBase: TerraColors.darkSurfaceVariant,
        shimmerHighlight: TerraColors.darkSurfaceTint,
        tierNewcomer: TerraColors.tierNewcomer,
        tierBeginner: TerraColors.tierBeginner,
        tierIntermediate: TerraColors.tierIntermediate,
        tierExpert: TerraColors.tierExpert,
        tierMaster: TerraColors.tierMaster,
        tierLegendary: TerraColors.tierLegendary,
        medalGold: TerraColors.medalGold,
        medalSilver: TerraColors.medalSilver,
        medalBronze: TerraColors.medalBronze,
      );

  factory TerraThemeExtension.light() => TerraThemeExtension(
        accent: TerraColors.lightAccent,
        accentMuted: TerraColors.lightAccentMuted,
        danger: TerraColors.lightDanger,
        dangerContainer: TerraColors.lightDangerContainer,
        warning: TerraColors.lightWarning,
        warningContainer: TerraColors.lightWarningContainer,
        success: TerraColors.lightSecondary,
        successContainer: TerraColors.lightSecondaryContainer,
        textSecondary: TerraColors.lightTextSecondary,
        textDisabled: TerraColors.lightTextDisabled,
        surfaceVariant: TerraColors.lightSurfaceVariant,
        surfaceTint: TerraColors.lightSurfaceTint,
        primaryLight: TerraColors.lightPrimaryLight,
        primaryContainer: TerraColors.lightPrimaryContainer,
        secondaryLight: TerraColors.lightSecondaryLight,
        secondaryContainer: TerraColors.lightSecondaryContainer,
        streakGradient: const LinearGradient(
          begin: Alignment(-0.7, -0.7),
          end: Alignment(0.7, 0.7),
          colors: TerraColors.lightStreakGradientColors,
        ),
        pointsGradient: const LinearGradient(
          begin: Alignment(-0.7, -0.7),
          end: Alignment(0.7, 0.7),
          colors: TerraColors.lightPointsGradientColors,
        ),
        tierGradient: const LinearGradient(
          begin: Alignment(-0.7, -0.7),
          end: Alignment(0.7, 0.7),
          colors: TerraColors.lightTierGradientColors,
        ),
        checkinSuccessGradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: TerraColors.lightCheckinSuccessColors,
        ),
        moduleColors: TerraColors.moduleColors,
        shimmerBase: TerraColors.lightSurfaceTint,
        shimmerHighlight: TerraColors.lightSurfaceVariant,
        tierNewcomer: TerraColors.tierNewcomer,
        tierBeginner: TerraColors.tierBeginner,
        tierIntermediate: TerraColors.tierIntermediate,
        tierExpert: TerraColors.tierExpert,
        tierMaster: TerraColors.tierMaster,
        tierLegendary: TerraColors.tierLegendary,
        medalGold: TerraColors.medalGold,
        medalSilver: TerraColors.medalSilver,
        medalBronze: TerraColors.medalBronze,
      );

  @override
  TerraThemeExtension copyWith({
    Color? accent,
    Color? accentMuted,
    Color? danger,
    Color? dangerContainer,
    Color? warning,
    Color? warningContainer,
    Color? success,
    Color? successContainer,
    Color? textSecondary,
    Color? textDisabled,
    Color? surfaceVariant,
    Color? surfaceTint,
    Color? primaryLight,
    Color? primaryContainer,
    Color? secondaryLight,
    Color? secondaryContainer,
    LinearGradient? streakGradient,
    LinearGradient? pointsGradient,
    LinearGradient? tierGradient,
    LinearGradient? checkinSuccessGradient,
    List<Color>? moduleColors,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? tierNewcomer,
    Color? tierBeginner,
    Color? tierIntermediate,
    Color? tierExpert,
    Color? tierMaster,
    Color? tierLegendary,
    Color? medalGold,
    Color? medalSilver,
    Color? medalBronze,
  }) {
    return TerraThemeExtension(
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      streakGradient: streakGradient ?? this.streakGradient,
      pointsGradient: pointsGradient ?? this.pointsGradient,
      tierGradient: tierGradient ?? this.tierGradient,
      checkinSuccessGradient: checkinSuccessGradient ?? this.checkinSuccessGradient,
      moduleColors: moduleColors ?? this.moduleColors,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      tierNewcomer: tierNewcomer ?? this.tierNewcomer,
      tierBeginner: tierBeginner ?? this.tierBeginner,
      tierIntermediate: tierIntermediate ?? this.tierIntermediate,
      tierExpert: tierExpert ?? this.tierExpert,
      tierMaster: tierMaster ?? this.tierMaster,
      tierLegendary: tierLegendary ?? this.tierLegendary,
      medalGold: medalGold ?? this.medalGold,
      medalSilver: medalSilver ?? this.medalSilver,
      medalBronze: medalBronze ?? this.medalBronze,
    );
  }

  @override
  TerraThemeExtension lerp(covariant TerraThemeExtension? other, double t) {
    if (other == null) return this;
    return TerraThemeExtension(
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      streakGradient: LinearGradient.lerp(streakGradient, other.streakGradient, t)!,
      pointsGradient: LinearGradient.lerp(pointsGradient, other.pointsGradient, t)!,
      tierGradient: LinearGradient.lerp(tierGradient, other.tierGradient, t)!,
      checkinSuccessGradient: LinearGradient.lerp(checkinSuccessGradient, other.checkinSuccessGradient, t)!,
      moduleColors: other.moduleColors,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      tierNewcomer: Color.lerp(tierNewcomer, other.tierNewcomer, t)!,
      tierBeginner: Color.lerp(tierBeginner, other.tierBeginner, t)!,
      tierIntermediate: Color.lerp(tierIntermediate, other.tierIntermediate, t)!,
      tierExpert: Color.lerp(tierExpert, other.tierExpert, t)!,
      tierMaster: Color.lerp(tierMaster, other.tierMaster, t)!,
      tierLegendary: Color.lerp(tierLegendary, other.tierLegendary, t)!,
      medalGold: Color.lerp(medalGold, other.medalGold, t)!,
      medalSilver: Color.lerp(medalSilver, other.medalSilver, t)!,
      medalBronze: Color.lerp(medalBronze, other.medalBronze, t)!,
    );
  }
}
