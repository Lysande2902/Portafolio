import 'package:flutter/material.dart';
import 'dart:math';

class TypingIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;
  final double spacing;

  const TypingIndicator({
    super.key,
    required this.color,
    this.dotSize = 6.0,
    this.spacing = 4.0,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(3, (index) {
            // Wave animation logic
            // Each dot has a phase shift
            double t = (_controller.value + index * 0.2) % 1.0;
            
            // Simple bounce (scale) & fade (opacity)
            // Peak at t=0.5
            double sinVal = 0.5 + 0.5 * sin(t * 6.28318);
            
            // Or simpler pulse
            double opacity = 0.3 + 0.7 * (1.0 - (t - 0.5).abs() * 2.0).clamp(0.0, 1.0);
            
            // Let's use a simpler staggered opacity
            double interval = 1.0 / 3.0; // 0.33
            double activeStart = index * 0.2;
            double activeEnd = activeStart + 0.4;
            double currentT = _controller.value;
            
            // If current time is within active window, full opacity, else dim
            bool isActive = false;
            // Wrap around logic simplified: Just use sine for smooth
            
            double value = (1.0 + sin(currentT * 6.28 + index * 1.5)) / 2.0;
            // Map -1..1 to 0..1 then map to opacity range
            
            double finalScale = 0.8 + 0.4 * value; // 0.8 to 1.2
            double finalOpacity = 0.4 + 0.6 * value; // 0.4 to 1.0

            return Transform.scale(
              scale: finalScale,
              child: Container(
                width: widget.dotSize,
                height: widget.dotSize,
                margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(finalOpacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
