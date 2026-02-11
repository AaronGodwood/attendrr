import 'package:flutter/material.dart';

/// Animated number display that counts up from 0 to [value] over [duration].
/// Uses Curves.easeOutCubic for a satisfying fast-start, gentle-landing feel.
class CountUpText extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: _animation.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          '${widget.prefix}${_animation.value}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
