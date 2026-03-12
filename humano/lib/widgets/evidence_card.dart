import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/evidence.dart';

class EvidenceCard extends StatelessWidget {
  final Evidence evidence;
  final VoidCallback onTap;

  const EvidenceCard({
    super.key,
    required this.evidence,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: evidence.isUnlocked
                ? Colors.black.withOpacity(0.7)
                : Colors.black.withOpacity(0.9),
            border: Border.all(
              color: evidence.isUnlocked
                  ? Colors.red.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Content
              Center(
                child: evidence.isUnlocked
                    ? _buildUnlockedContent()
                    : _buildLockedContent(),
              ),
              
              // Type icon in corner
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    border: Border.all(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    evidence.type.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockedContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Type icon large
          Text(
            evidence.type.icon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            evidence.title,
            style: GoogleFonts.courierPrime(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lock icon
        Icon(
          Icons.lock,
          color: Colors.grey[700],
          size: 40,
        ),
        const SizedBox(height: 8),
        // Locked text
        Text(
          'BLOQUEADO',
          style: GoogleFonts.courierPrime(
            fontSize: 10,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
