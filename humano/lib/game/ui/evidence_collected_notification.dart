import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Notification widget shown when a fragment is collected
/// 5 fragments form 1 complete evidence
class EvidenceCollectedNotification extends StatefulWidget {
  final int currentCount;
  final int totalCount;
  final VoidCallback onComplete;

  const EvidenceCollectedNotification({
    super.key,
    required this.currentCount,
    required this.totalCount,
    required this.onComplete,
  });

  @override
  State<EvidenceCollectedNotification> createState() =>
      _EvidenceCollectedNotificationState();
}

class _EvidenceCollectedNotificationState
    extends State<EvidenceCollectedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Slide down from top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Fade in and out
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete();
    });
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
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 100),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              border: Border.all(
                color: const Color(0xFF00F0FF), // Cyan Neon
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5)),
                  ),
                  child: const Icon(
                    Icons.memory, // Memory icon
                    color: Color(0xFF00F0FF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                // Text
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FRAGMENTO DE ARCHIVO DESCUBIERTO!!',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 16,
                          color: const Color(0xFF00F0FF),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            const Shadow(
                              color: Color(0xFF00F0FF),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SECUENCIA ${widget.currentCount} RECUPERADA',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

