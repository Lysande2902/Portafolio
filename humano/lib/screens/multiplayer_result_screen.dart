import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class MultiplayerResultScreen extends StatefulWidget {
  final String winner; // 'algorithm' or 'user'
  final String endReason;
  final bool isAlgorithm; // True if viewing as Algorithm, false if User

  const MultiplayerResultScreen({
    super.key,
    required this.winner,
    required this.endReason,
    required this.isAlgorithm,
  });

  @override
  State<MultiplayerResultScreen> createState() => _MultiplayerResultScreenState();
}

class _MultiplayerResultScreenState extends State<MultiplayerResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Vibration feedback
    _triggerVibration();
  }

  void _triggerVibration() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    final didWin = (widget.isAlgorithm && widget.winner == 'algorithm') ||
        (!widget.isAlgorithm && widget.winner == 'user');

    if (didWin) {
      // Victory vibration
      Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 100]);
    } else {
      // Defeat vibration
      Vibration.vibrate(duration: 500);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final didWin = (widget.isAlgorithm && widget.winner == 'algorithm') ||
        (!widget.isAlgorithm && widget.winner == 'user');

    final resultColor = didWin ? Colors.green[700]! : Colors.red[700]!;
    final resultText = didWin ? 'VICTORIA' : 'DERROTA';
    final resultIcon = didWin ? Icons.check_circle : Icons.cancel;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                resultColor.withOpacity(0.2),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    resultIcon,
                    size: 120,
                    color: resultColor,
                  ),
                ),

                const SizedBox(height: 40),

                // Result Text
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    resultText,
                    style: GoogleFonts.vt323(
                      fontSize: 72,
                      color: resultColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: resultColor.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Role Text
                Text(
                  widget.isAlgorithm ? 'ALGORITMO' : 'SUJETO',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 16,
                    color: Colors.grey[500],
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 60),

                // Reason
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border.all(color: resultColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'RAZÓN',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 12,
                          color: Colors.grey[600],
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getReasonText(widget.endReason),
                        style: GoogleFonts.courierPrime(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(
                      'SALIR',
                      Icons.exit_to_app,
                      () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      isSecondary: true,
                    ),
                    const SizedBox(width: 20),
                    _buildButton(
                      'REVANCHA',
                      Icons.refresh,
                      () {
                        // TODO: Implement rematch
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Revancha próximamente',
                              style: GoogleFonts.courierPrime(),
                            ),
                            backgroundColor: Colors.grey[800],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onTap, {bool isSecondary = false}) {
    final color = isSecondary ? Colors.grey[700]! : const Color(0xFF8B0000);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.vt323(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'user_caught':
        return widget.isAlgorithm
            ? 'Sujeto capturado exitosamente'
            : 'Fuiste atrapado por el Algoritmo';
      case 'user_escaped':
        return widget.isAlgorithm
            ? 'El Sujeto logró escapar'
            : 'Escapaste con éxito';
      case 'sanity_depleted':
        return widget.isAlgorithm
            ? 'Cordura del Sujeto agotada'
            : 'Tu cordura se agotó';
      case 'disconnect':
        return 'El oponente se desconectó';
      default:
        return 'Partida finalizada';
    }
  }
}
