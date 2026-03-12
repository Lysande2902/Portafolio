import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../data/models/puzzle_fragment.dart';
import 'puzzle_fragment_widget.dart';

class DraggableFragment extends StatefulWidget {
  final PuzzleFragment fragment;
  final VoidCallback onPickup;
  final Function(Offset) onDrag;
  final Function(Offset) onDrop;
  final VoidCallback onTap;
  final bool isLocked;
  final Offset position;
  final double rotation;

  const DraggableFragment({
    super.key,
    required this.fragment,
    required this.onPickup,
    required this.onDrag,
    required this.onDrop,
    required this.onTap,
    required this.position,
    required this.rotation,
    this.isLocked = false,
  });

  @override
  State<DraggableFragment> createState() => _DraggableFragmentState();
}

class _DraggableFragmentState extends State<DraggableFragment>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDragging = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePickup() {
    if (widget.isLocked) return;

    setState(() {
      _isDragging = true;
    });
    _animationController.forward();
    widget.onPickup();
  }

  void _handleDrop(Offset globalPosition) {
    if (widget.isLocked) return;

    setState(() {
      _isDragging = false;
    });
    _animationController.reverse();

    // Convert global position to local
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(globalPosition);
      widget.onDrop(localPosition);
    }
  }

  void _handleTap() {
    if (widget.isLocked) return;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: RepaintBoundary(
        child: GestureDetector(
        onTap: _handleTap,
        onPanStart: (_) => _handlePickup(),
        onPanUpdate: (details) {
          if (!widget.isLocked) {
            widget.onDrag(details.globalPosition);
          }
        },
        onPanEnd: (details) => _handleDrop(details.globalPosition),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: widget.isLocked
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.grab,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: widget.rotation * math.pi / 180,
                  child: _buildFragmentContent(),
                ),
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildFragmentContent() {
    // Determinar la ruta de la imagen completa basada en el evidenceId
    final String completeImagePath;
    if (widget.fragment.evidenceId.contains('arc1')) {
      completeImagePath = 'assets/evidences/arc1_complete.png';
    } else if (widget.fragment.evidenceId.contains('arc2')) {
      completeImagePath = 'assets/evidences/arc2_complete.png';
    } else {
      completeImagePath = 'assets/evidences/arc3_complete.jpg';
    }
    
    return Container(
      width: 150, // Tamaño fijo del fragmento
      height: 150,
      decoration: BoxDecoration(
        boxShadow: _isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        children: [
          // Fragment usando el nuevo widget simplificado
          PuzzleFragmentWidget(
            fragment: widget.fragment,
            completeImagePath: completeImagePath,
            size: 150,
            rotation: 0, // La rotación se maneja en el Transform.rotate externo
          ),

          // Hover glow effect
          if (_isHovering && !widget.isLocked)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 3,
                ),
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

          // Lock indicator
          if (widget.isLocked)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
