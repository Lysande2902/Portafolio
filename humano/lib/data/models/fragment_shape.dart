import 'package:flutter/material.dart';
import 'connection_point.dart';

class FragmentShape {
  final String svgPath;
  final List<ConnectionPoint> connectionPoints;
  final Size size;

  const FragmentShape({
    required this.svgPath,
    required this.connectionPoints,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'svgPath': svgPath,
        'connectionPoints':
            connectionPoints.map((cp) => cp.toJson()).toList(),
        'width': size.width,
        'height': size.height,
      };

  factory FragmentShape.fromJson(Map<String, dynamic> json) {
    return FragmentShape(
      svgPath: json['svgPath'] as String,
      connectionPoints: (json['connectionPoints'] as List)
          .map((cp) => ConnectionPoint.fromJson(cp as Map<String, dynamic>))
          .toList(),
      size: Size(
        json['width'] as double,
        json['height'] as double,
      ),
    );
  }

  ConnectionPoint? getConnectionPoint(EdgeSide side) {
    try {
      return connectionPoints.firstWhere((cp) => cp.side == side);
    } catch (e) {
      return null;
    }
  }
}
