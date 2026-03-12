import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/models/fragment_shape.dart';
import '../../../data/models/connection_point.dart';

class ShapeGenerator {
  // Cache for generated shapes
  static final Map<String, List<FragmentShape>> _shapeCache = {};

  // Generate 5 interlocking puzzle piece shapes
  // Layout: 2x3 grid with one empty slot
  // [0] [1] [2]
  // [3] [4] [ ]
  static List<FragmentShape> generatePuzzleShapes({
    required Size totalSize,
    int rows = 2,
    int cols = 3,
  }) {
    // Create cache key
    final cacheKey = '${totalSize.width}x${totalSize.height}_${rows}x$cols';

    // Return cached shapes if available
    if (_shapeCache.containsKey(cacheKey)) {
      return _shapeCache[cacheKey]!;
    }

    // Generate new shapes
    List<FragmentShape> shapes = [];
    for (int i = 0; i < 5; i++) {
      shapes.add(_generateFragmentShape(i, totalSize, rows, cols));
    }

    // Cache the shapes
    _shapeCache[cacheKey] = shapes;

    return shapes;
  }

  // Clear cache if needed (for memory management)
  static void clearCache() {
    _shapeCache.clear();
  }

  static FragmentShape _generateFragmentShape(
    int index,
    Size totalSize,
    int rows,
    int cols,
  ) {
    // Calculate base rectangle for this piece
    int row = index ~/ cols;
    int col = index % cols;

    Size pieceSize = Size(totalSize.width / cols, totalSize.height / rows);

    // Generate SVG path with tabs and blanks
    String svgPath = _generatePuzzlePiecePath(
      row: row,
      col: col,
      totalRows: rows,
      totalCols: cols,
      pieceSize: pieceSize,
      index: index,
    );

    // Define connection points
    List<ConnectionPoint> connections = _generateConnectionPoints(
      index: index,
      row: row,
      col: col,
      totalRows: rows,
      totalCols: cols,
    );

    return FragmentShape(
      svgPath: svgPath,
      connectionPoints: connections,
      size: pieceSize,
    );
  }

  static String _generatePuzzlePiecePath({
    required int row,
    required int col,
    required int totalRows,
    required int totalCols,
    required Size pieceSize,
    required int index,
  }) {
    StringBuffer path = StringBuffer();
    double w = pieceSize.width;
    double h = pieceSize.height;
    double tabSize = min(w, h) * 0.15; // Tab protrusion size

    // Start at top-left
    path.write('M 0 0 ');

    // Top edge
    if (row > 0) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.top);
      path.write(_generateEdgeWithTab(w, tabSize, hasTab, false, false));
    } else {
      path.write('L $w 0 ');
    }

    // Right edge
    if (col < totalCols - 1 && _hasRightNeighbor(index)) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.right);
      path.write(_generateEdgeWithTab(h, tabSize, hasTab, true, false));
    } else {
      path.write('L $w $h ');
    }

    // Bottom edge
    if (row < totalRows - 1 && _hasBottomNeighbor(index)) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.bottom);
      path.write(_generateEdgeWithTab(w, tabSize, hasTab, false, true));
    } else {
      path.write('L 0 $h ');
    }

    // Left edge
    if (col > 0) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.left);
      path.write(_generateEdgeWithTab(h, tabSize, hasTab, true, true));
    } else {
      path.write('L 0 0 ');
    }

    path.write('Z');
    return path.toString();
  }

  static String _generateEdgeWithTab(
    double length,
    double tabSize,
    bool isTab,
    bool isVertical,
    bool reverse,
  ) {
    StringBuffer edge = StringBuffer();

    // Calculate tab position (centered on edge)
    double tabStart = length * 0.35;
    double tabEnd = length * 0.65;
    double tabDepth = tabSize * (isTab ? 1 : -1);

    if (isVertical) {
      if (reverse) {
        // Left edge (bottom to top)
        edge.write('L 0 ${length - tabEnd} ');
        edge.write(
            'Q $tabDepth ${length - tabEnd} $tabDepth ${length - (tabEnd + tabStart) / 2} ');
        edge.write('Q $tabDepth ${length - tabStart} 0 ${length - tabStart} ');
        edge.write('L 0 0 ');
      } else {
        // Right edge (top to bottom)
        edge.write('L ${0} $tabStart ');
        edge.write('Q $tabDepth $tabStart $tabDepth ${(tabStart + tabEnd) / 2} ');
        edge.write('Q $tabDepth $tabEnd ${0} $tabEnd ');
        edge.write('L ${0} $length ');
      }
    } else {
      if (reverse) {
        // Bottom edge (right to left)
        edge.write('L ${length - tabEnd} ${0} ');
        edge.write(
            'Q ${length - tabEnd} $tabDepth ${length - (tabEnd + tabStart) / 2} $tabDepth ');
        edge.write('Q ${length - tabStart} $tabDepth ${length - tabStart} ${0} ');
        edge.write('L 0 ${0} ');
      } else {
        // Top edge (left to right)
        edge.write('L $tabStart ${0} ');
        edge.write('Q $tabStart $tabDepth ${(tabStart + tabEnd) / 2} $tabDepth ');
        edge.write('Q $tabEnd $tabDepth $tabEnd ${0} ');
        edge.write('L $length ${0} ');
      }
    }

    return edge.toString();
  }

  static bool _shouldHaveTab(int index, EdgeSide side) {
    // Deterministic tab/blank assignment
    // Ensures adjacent pieces have complementary connections
    Map<int, Map<EdgeSide, bool>> tabMap = {
      0: {
        EdgeSide.top: false,
        EdgeSide.right: true,
        EdgeSide.bottom: false,
        EdgeSide.left: false,
      },
      1: {
        EdgeSide.top: false,
        EdgeSide.right: true,
        EdgeSide.bottom: true,
        EdgeSide.left: false, // Complementary to 0's right (tab)
      },
      2: {
        EdgeSide.top: false,
        EdgeSide.right: false,
        EdgeSide.bottom: false,
        EdgeSide.left: false, // Complementary to 1's right (tab)
      },
      3: {
        EdgeSide.top: true, // Complementary to 0's bottom (blank)
        EdgeSide.right: false,
        EdgeSide.bottom: false,
        EdgeSide.left: false,
      },
      4: {
        EdgeSide.top: false, // Complementary to 1's bottom (tab)
        EdgeSide.right: false,
        EdgeSide.bottom: false,
        EdgeSide.left: true, // Complementary to 3's right (blank)
      },
    };

    return tabMap[index]?[side] ?? false;
  }

  static bool _hasRightNeighbor(int index) {
    // Check if piece has a neighbor to the right
    return index == 0 || index == 1 || index == 3;
  }

  static bool _hasBottomNeighbor(int index) {
    // Check if piece has a neighbor below
    return index == 0 || index == 1;
  }

  static List<ConnectionPoint> _generateConnectionPoints({
    required int index,
    required int row,
    required int col,
    required int totalRows,
    required int totalCols,
  }) {
    List<ConnectionPoint> connections = [];

    // Top connection
    if (row > 0) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.top);
      connections.add(ConnectionPoint(
        side: EdgeSide.top,
        type: hasTab ? ConnectionType.tab : ConnectionType.blank,
        position: 0.5,
        matchId: 'piece_${index - totalCols}_bottom',
      ));
    }

    // Right connection
    if (col < totalCols - 1 && _hasRightNeighbor(index)) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.right);
      connections.add(ConnectionPoint(
        side: EdgeSide.right,
        type: hasTab ? ConnectionType.tab : ConnectionType.blank,
        position: 0.5,
        matchId: 'piece_${index + 1}_left',
      ));
    }

    // Bottom connection
    if (row < totalRows - 1 && _hasBottomNeighbor(index)) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.bottom);
      connections.add(ConnectionPoint(
        side: EdgeSide.bottom,
        type: hasTab ? ConnectionType.tab : ConnectionType.blank,
        position: 0.5,
        matchId: 'piece_${index + totalCols}_top',
      ));
    }

    // Left connection
    if (col > 0) {
      bool hasTab = _shouldHaveTab(index, EdgeSide.left);
      connections.add(ConnectionPoint(
        side: EdgeSide.left,
        type: hasTab ? ConnectionType.tab : ConnectionType.blank,
        position: 0.5,
        matchId: 'piece_${index - 1}_right',
      ));
    }

    return connections;
  }
}
