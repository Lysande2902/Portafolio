import 'package:flutter/material.dart';

/// In-game hint overlay that appears without pausing the game
/// Shows contextual tips based on game state
/// Designed to be minimal and non-intrusive
class InGameHint extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration duration;

  const InGameHint({
    super.key,
    required this.message,
    required this.icon,
    required this.onDismiss,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<InGameHint> createState() => _InGameHintState();
}

class _InGameHintState extends State<InGameHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 100),
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _dismiss,
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Manager for in-game hints
/// Tracks which hints have been shown and when to show them
class InGameHintManager {
  final Set<String> _shownHints = {};
  
  /// Check if a hint has been shown
  bool hasShown(String hintId) => _shownHints.contains(hintId);
  
  /// Mark a hint as shown
  void markShown(String hintId) => _shownHints.add(hintId);
  
  /// Reset all hints (for new game)
  void reset() => _shownHints.clear();
}
