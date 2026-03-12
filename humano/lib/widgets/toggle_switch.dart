import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToggleSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.courierPrime(
                fontSize: 14,
                color: Colors.grey[400],
                letterSpacing: 1,
              ),
            ),
          ),
          // Switch
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: value ? Colors.red[900] : Colors.grey[800],
                border: Border.all(
                  color: value ? Colors.red[700]! : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: value ? 30 : 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 26,
                      decoration: BoxDecoration(
                        color: value ? Colors.red[300] : Colors.grey[500],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      value ? 'ON' : 'OFF',
                      style: GoogleFonts.courierPrime(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
