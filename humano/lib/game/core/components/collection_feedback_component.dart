import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Visual feedback component shown when collecting items
/// Displays floating text with fade-out animation
class CollectionFeedbackComponent extends TextComponent {
  final double duration;
  final Color initialColor;
  
  double _elapsed = 0.0;
  
  CollectionFeedbackComponent({
    required Vector2 position,
    required String message,
    Color textColor = Colors.white,
    this.duration = 1.5,
  }) : initialColor = textColor,
       super(
         text: message,
         position: position,
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: TextStyle(
             color: textColor,
             fontSize: 24,
             fontWeight: FontWeight.bold,
             shadows: [
               Shadow(
                 color: Colors.black.withOpacity(0.8),
                 offset: const Offset(2, 2),
                 blurRadius: 4,
               ),
             ],
           ),
         ),
       );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    _elapsed += dt;
    
    // Float upward
    position.y -= 50 * dt;
    
    // Fade out
    final progress = _elapsed / duration;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    
    textRenderer = TextPaint(
      style: TextStyle(
        color: initialColor.withOpacity(alpha),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8 * alpha),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
    
    // Remove when fully faded
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}
