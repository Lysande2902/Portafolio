import 'package:flutter/material.dart';

/// Simple virtual joystick for mobile controls
/// Provides 360° directional input
class VirtualJoystick extends StatefulWidget {
  final Function(Offset) onDirectionChanged;
  final double size;

  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
    this.size = 120.0,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobPosition = Offset.zero;
  bool _isDragging = false;

  void _updatePosition(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final delta = localPosition - center;
    final distance = delta.distance;
    final maxDistance = widget.size / 2 - 20;

    if (distance > maxDistance) {
      // Clamp to circle boundary
      final direction = delta / distance;
      _knobPosition = direction * maxDistance;
    } else {
      _knobPosition = delta;
    }

    // Normalize and send direction
    final normalizedDirection = _knobPosition / maxDistance;
    
    // Deadzone check to prevent drift
    if (normalizedDirection.distance < 0.2) {
      widget.onDirectionChanged(Offset.zero);
    } else {
      widget.onDirectionChanged(normalizedDirection);
    }

    setState(() {});
  }

  void _resetPosition() {
    _knobPosition = Offset.zero;
    widget.onDirectionChanged(Offset.zero);
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
        _updatePosition(details.localPosition);
      },
      onPanUpdate: (details) {
        _updatePosition(details.localPosition);
      },
      onPanEnd: (details) {
        _resetPosition();
      },
      onPanCancel: () {
        _resetPosition();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Knob
            Transform.translate(
              offset: _knobPosition,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isDragging
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
