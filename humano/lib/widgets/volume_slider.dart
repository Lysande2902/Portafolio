import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VolumeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const VolumeSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: GoogleFonts.courierPrime(
              fontSize: 14,
              color: Colors.grey[400],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Slider and value
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.red[900],
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: Colors.red[700],
                    overlayColor: Colors.red.withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onChanged,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Percentage display
              SizedBox(
                width: 50,
                child: Text(
                  '${(value * 100).toInt()}%',
                  style: GoogleFonts.courierPrime(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
