import 'package:flutter/material.dart';
import '../../../data/models/puzzle_fragment.dart';

/// Widget que renderiza un fragmento del puzzle
/// Usa ClipRect para mostrar solo una porción de la imagen completa
class PuzzleFragmentWidget extends StatelessWidget {
  final PuzzleFragment fragment;
  final String completeImagePath;
  final double size; // Tamaño del fragmento en pantalla
  final double rotation; // Rotación actual (0, 90, 180, 270)
  
  const PuzzleFragmentWidget({
    super.key,
    required this.fragment,
    required this.completeImagePath,
    this.size = 150,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * (3.14159 / 180), // Convertir grados a radianes
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRect(
          child: OverflowBox(
            alignment: fragment.imageAlignment,
            minWidth: 0,
            minHeight: 0,
            maxWidth: size * 3, // 3 columnas
            maxHeight: size * 2, // 2 filas
            child: Image.asset(
              completeImagePath,
              fit: BoxFit.cover,
              width: size * 3, // Ancho total de la imagen (3 fragmentos)
              height: size * 2, // Alto total de la imagen (2 fragmentos)
              errorBuilder: (context, error, stackTrace) {
                // Placeholder si la imagen no existe
                return Container(
                  width: size,
                  height: size,
                  color: Colors.grey[800],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: size * 0.3,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fragmento ${fragment.fragmentNumber}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
