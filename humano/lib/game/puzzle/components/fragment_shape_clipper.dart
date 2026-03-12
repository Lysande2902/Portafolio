import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../../../data/models/fragment_shape.dart';

class FragmentShapeClipper extends CustomClipper<Path> {
  final FragmentShape shape;

  FragmentShapeClipper(this.shape);

  @override
  Path getClip(Size size) {
    try {
      // Parse SVG path string and create Flutter Path
      final path = parseSvgPathData(shape.svgPath);

      // Scale path to fit the size if needed
      final scaleX = size.width / shape.size.width;
      final scaleY = size.height / shape.size.height;

      if (scaleX != 1.0 || scaleY != 1.0) {
        final matrix = Matrix4.identity();
        matrix.scale(scaleX, scaleY);
        return path.transform(matrix.storage);
      }

      return path;
    } catch (e) {
      print('Error parsing SVG path: $e');
      // Fallback to rectangle if parsing fails
      return Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
  }

  @override
  bool shouldReclip(FragmentShapeClipper oldClipper) {
    return oldClipper.shape.svgPath != shape.svgPath;
  }
}
