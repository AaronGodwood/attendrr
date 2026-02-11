import 'package:flutter/material.dart';

/// A card that follows the Terra Scholar spec: 16px radius, 1px outline border,
/// with an optional 3px colored left-border accent (signature element for lecture cards).
class ThemedCard extends StatelessWidget {
  final Widget child;
  final Color? leftBorderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const ThemedCard({
    super.key,
    required this.child,
    this.leftBorderColor,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (leftBorderColor != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(width: 3, color: leftBorderColor),
            Expanded(child: content),
          ],
        ),
      );
    }

    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: content,
            )
          : content,
    );

    return card;
  }
}
