import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogueOverlay extends StatefulWidget {
  final String speakerName;
  final String text;
  final VoidCallback onDismiss;

  const DialogueOverlay({
    super.key,
    required this.speakerName,
    required this.text,
    required this.onDismiss,
  });

  @override
  _DialogueOverlayState createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  int _charCount = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 30),
      vsync: this,
    );

    _textController.addListener(() {
      setState(() {
        _charCount = (widget.text.length * _textController.value).toInt();
        if (_textController.value == 1.0) {
          _isFinished = true;
        }
      });
    });

    _textController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speaker Name Bar
              _buildNameBar(widget.speakerName),
              // Main Dialogue Box
              _buildDialogueBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameBar(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.7), width: 1.5),
          left: BorderSide(color: Colors.white.withOpacity(0.7), width: 1.5),
          right: BorderSide(color: Colors.white.withOpacity(0.7), width: 1.5),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        name,
        style: GoogleFonts.shareTechMono(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildDialogueBox() {
    return CustomPaint(
      painter: OrnateBorderPainter(),
      child: GestureDetector(
        onTap: () {
          if (_isFinished) {
            widget.onDismiss();
          } else {
            _textController.forward(from: 1.0);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          constraints: const BoxConstraints(minHeight: 120),
          child: Stack(
            children: [
              Text(
                widget.text.substring(0, _charCount),
                style: GoogleFonts.ebGaramond(
                  color: Colors.grey[300],
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              // Scanlines locales para el cuadro de diálogo
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: LocalScanlinePainter(),
                    ),
                  ),
                ),
              ),
              if (_isFinished)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrnateBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Dibujar el marco principal sutilmente
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    
    canvas.drawPath(path, paint);

    // Ornamentos en las esquinas (estilo gótico mostrado en la imagen)
    _drawCornerOrnament(canvas, const Offset(0, 0), paint, 0);
    _drawCornerOrnament(canvas, Offset(size.width, 0), paint, 1);
    _drawCornerOrnament(canvas, Offset(0, size.height), paint, 2);
    _drawCornerOrnament(canvas, Offset(size.width, size.height), paint, 3);
  }

  void _drawCornerOrnament(Canvas canvas, Offset offset, Paint paint, int type) {
    const double size = 15;
    // Un pequeño círculo o diamante en la esquina
    canvas.drawRect(
      Rect.fromCenter(center: offset, width: 4, height: 4),
      Paint()..color = paint.color..style = PaintingStyle.fill,
    );
    
    // Líneas decorativas cortas (estilo gótico simple)
    if (type == 0) { // Top Left
      canvas.drawLine(offset, offset + const Offset(size, 0), paint);
      canvas.drawLine(offset, offset + const Offset(0, size), paint);
    } else if (type == 1) { // Top Right
      canvas.drawLine(offset, offset + const Offset(-size, 0), paint);
      canvas.drawLine(offset, offset + const Offset(0, size), paint);
    } else if (type == 2) { // Bottom Left
      canvas.drawLine(offset, offset + const Offset(size, 0), paint);
      canvas.drawLine(offset, offset + const Offset(0, -size), paint);
    } else if (type == 3) { // Bottom Right
      canvas.drawLine(offset, offset + const Offset(-size, 0), paint);
      canvas.drawLine(offset, offset + const Offset(0, -size), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LocalScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.height; i += 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
