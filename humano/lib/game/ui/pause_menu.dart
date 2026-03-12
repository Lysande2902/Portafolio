import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pause menu overlay
class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onExit;
  final VoidCallback? onShowTutorial;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onExit,
    this.onShowTutorial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 350),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DETENER SESIÓN',
                      style: GoogleFonts.courierPrime(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onResume,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                        ),
                        child: Text(
                          'CONTINUAR',
                          style: GoogleFonts.courierPrime(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onExit,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                        ),
                        child: Text(
                          'SALIR',
                          style: GoogleFonts.courierPrime(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tutorial icon button - subtle and icon-only
            if (onShowTutorial != null)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: IconButton(
                    onPressed: onShowTutorial,
                    icon: Icon(
                      Icons.help_outline,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
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
