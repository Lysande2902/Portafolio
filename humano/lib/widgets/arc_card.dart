import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/arc.dart';
import '../data/models/arc_progress.dart';

class ArcCard extends StatelessWidget {
  final Arc arc;
  final ArcProgress? progress;
  final bool isLocked;
  final VoidCallback onTap;

  const ArcCard({
    super.key,
    required this.arc,
    this.progress,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = progress?.status ?? ArcStatus.notStarted;
    final progressPercent = progress?.progressPercent ?? 0.0;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: MouseRegion(
        cursor:
            isLocked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isLocked
                ? Colors.black.withOpacity(0.7)
                : Colors.black.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLocked
                  ? Colors.grey.withOpacity(0.2)
                  : status == ArcStatus.completed
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (like a social media post)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Profile pic / Arc number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getArcColor(),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${arc.number}',
                          style: GoogleFonts.courierPrime(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            arc.title.toUpperCase(),
                            style: GoogleFonts.courierPrime(
                              fontSize: 16,
                              color:
                                  isLocked ? Colors.grey[600] : Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            arc.subtitle,
                            style: GoogleFonts.courierPrime(
                              fontSize: 12,
                              color: isLocked
                                  ? Colors.grey[700]
                                  : Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    // Status icon
                    _buildStatusIcon(status),
                  ],
                ),
              ),

              // Content area (thumbnail)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(
                    top: BorderSide(color: Colors.grey[800]!, width: 1),
                    bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                  ),
                ),
                child: isLocked
                    ? Center(
                        child: Icon(
                          Icons.lock,
                          color: Colors.grey[600],
                          size: 50,
                        ),
                      )
                    : _buildThumbnail(),
              ),

              // Footer (stats and progress)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress or Status
                    if (!isLocked) ...[
                      if (status == ArcStatus.notStarted)
                        _buildStatusBadge('NUEVO', Colors.red[900]!)
                      else if (status == ArcStatus.inProgress)
                        _buildProgressBar(progressPercent)
                      else if (status == ArcStatus.completed)
                        _buildStatusBadge('COMPLETADO', Colors.green[900]!),
                    ] else
                      _buildStatusBadge('BLOQUEADO', Colors.grey[800]!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getArcColor() {
    final colors = {
      1: Colors.red[900]!, // Gula
      2: Colors.amber[900]!, // Avaricia
      3: Colors.grey[700]!, // Pereza
      4: Colors.pink[900]!, // Lujuria
      5: Colors.purple[900]!, // Soberbia
      6: Colors.green[900]!, // Envidia
      7: Colors.red[700]!, // Ira
    };
    return colors[arc.number] ?? Colors.grey[900]!;
  }

  Widget _buildThumbnail() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getArcColor().withOpacity(0.6),
            _getArcColor().withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getArcIcon(),
              size: 50,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'ARCO ${arc.number}',
              style: GoogleFonts.courierPrime(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getArcIcon() {
    final icons = {
      1: Icons.restaurant, // Gula
      2: Icons.attach_money, // Avaricia
      3: Icons.hotel, // Pereza
      4: Icons.favorite, // Lujuria
      5: Icons.star, // Soberbia
      6: Icons.remove_red_eye, // Envidia
      7: Icons.whatshot, // Ira
    };
    return icons[arc.number] ?? Icons.circle;
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.courierPrime(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildProgressBar(double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percent,
                  child: Container(
                    color: Colors.red[900],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(percent * 100).toInt()}%',
              style: GoogleFonts.courierPrime(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIcon(ArcStatus status) {
    if (isLocked) {
      return Icon(
        Icons.lock,
        color: Colors.grey[600],
        size: 24,
      );
    }

    switch (status) {
      case ArcStatus.completed:
        return Icon(
          Icons.check_circle,
          color: Colors.green[400],
          size: 24,
        );
      case ArcStatus.inProgress:
        return Icon(
          Icons.play_circle_outline,
          color: Colors.red[400],
          size: 24,
        );
      case ArcStatus.notStarted:
        return Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[600],
          size: 20,
        );
    }
  }
}
