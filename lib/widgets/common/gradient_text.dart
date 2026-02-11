import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// Renders text with a gradient fill using ShaderMask.
/// Only use for key motivational numbers: streak count, points, tier name, rank.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<TerraThemeExtension>();
    final effectiveGradient = gradient ?? ext?.streakGradient ?? const LinearGradient(
      colors: [Color(0xFFC67B4E), Color(0xFFE8A87C)],
    );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => effectiveGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
