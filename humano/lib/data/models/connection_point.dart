enum ConnectionType { tab, blank, flat }

enum EdgeSide { top, right, bottom, left }

class ConnectionPoint {
  final EdgeSide side;
  final ConnectionType type;
  final double position; // 0.0 to 1.0 along the edge
  final String matchId; // ID of the complementary connection point

  const ConnectionPoint({
    required this.side,
    required this.type,
    required this.position,
    required this.matchId,
  });

  Map<String, dynamic> toJson() => {
        'side': side.index,
        'type': type.index,
        'position': position,
        'matchId': matchId,
      };

  factory ConnectionPoint.fromJson(Map<String, dynamic> json) {
    return ConnectionPoint(
      side: EdgeSide.values[json['side'] as int],
      type: ConnectionType.values[json['type'] as int],
      position: json['position'] as double,
      matchId: json['matchId'] as String,
    );
  }

  bool isComplementaryTo(ConnectionPoint other) {
    if (type == ConnectionType.flat || other.type == ConnectionType.flat) {
      return type == other.type;
    }
    // Tab should match with blank
    return (type == ConnectionType.tab && other.type == ConnectionType.blank) ||
        (type == ConnectionType.blank && other.type == ConnectionType.tab);
  }
}
