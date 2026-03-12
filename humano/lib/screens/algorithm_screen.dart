import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:humano/services/multiplayer_service.dart';
import 'package:humano/providers/auth_provider.dart';

/// Pantalla del Algoritmo en modo multijugador
/// - Controla al Sujeto desde aquí
/// - Ve radar en tiempo real
/// - Lanza 3 habilidades: SONDA, GLITCH, LAG
class AlgorithmScreen extends StatefulWidget {
  final String matchId;
  final String arcId;

  const AlgorithmScreen({
    super.key,
    required this.matchId,
    required this.arcId,
  });

  @override
  State<AlgorithmScreen> createState() => _AlgorithmScreenState();
}

class _AlgorithmScreenState extends State<AlgorithmScreen> {
  late MultiplayerService _multiplayerService;
  double _energy = 100.0; // 0-100
  static const double maxEnergy = 100.0;
  static const double energyRegenRate = 2.0; // +2 cada 0.5s
  
  late Timer _energyTimer;
  
  // State tracking
  double _subjectSanity = 1.0;
  int _evidenceCount = 0;
  bool _subjectAlive = true;
  Map<String, dynamic>? _lastSignal;
  String _matchStatus = 'waiting';
  
  // Ability costs
  static const double probeCost = 20.0;
  static const double glitchCost = 40.0;
  static const double lagCost = 60.0;

  @override
  void initState() {
    super.initState();
    _multiplayerService = MultiplayerService();
    
    // Regenerar energía cada 0.5s
    _energyTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _energy = (_energy + energyRegenRate).clamp(0.0, maxEnergy);
      });
    });
  }

  @override
  void dispose() {
    _energyTimer.cancel();
    super.dispose();
  }

  Future<void> _launchAbility(String abilityType, double cost) async {
    if (_energy < cost) {
      _showMessage('❌ Energía insuficiente ($cost requerida)');
      return;
    }

    setState(() => _energy -= cost);
    
    try {
      await _multiplayerService.performAction(
        widget.matchId,
        abilityType,
        {'timestamp': DateTime.now().millisecondsSinceEpoch},
      );
      
      String abilityName = '';
      String effect = '';
      switch (abilityType) {
        case 'ping':
          abilityName = 'SONDA';
          effect = 'Vibración enviada';
          break;
        case 'glitch':
          abilityName = 'GLITCH';
          effect = 'Aberración cromática activada';
          break;
        case 'lag':
          abilityName = 'LAG';
          effect = 'Congelamiento enviado';
          break;
      }
      
      _showMessage('✅ $abilityName lanzada - $effect');
    } catch (e) {
      _showMessage('❌ Error: $e');
      setState(() => _energy += cost); // Devolver energía si falla
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _multiplayerService.matchStream(widget.matchId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final matchData = snapshot.data!.data() as Map<String, dynamic>;
          _matchStatus = matchData['status'] ?? 'waiting';
          
          final userState = matchData['userState'] as Map<String, dynamic>?;
          if (userState != null) {
            _subjectSanity = (userState['sanity'] as num?)?.toDouble() ?? 1.0;
            _evidenceCount = (userState['evidenceCount'] as num?)?.toInt() ?? 0;
            _subjectAlive = userState['isAlive'] as bool? ?? true;
          }

          final lastSignal = matchData['lastSignal'] as Map<String, dynamic>?;
          if (lastSignal != null) {
            _lastSignal = lastSignal;
          }

          return SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(matchData),
                
                const SizedBox(height: 20),
                
                // Radar/Estado Sujeto
                Expanded(
                  child: _buildRadar(matchData),
                ),
                
                const SizedBox(height: 20),
                
                // Energía
                _buildEnergyBar(),
                
                const SizedBox(height: 20),
                
                // Habilidades
                _buildAbilitiesPanel(),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> matchData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        color: Colors.black87,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ALGORITMO - CONTROL',
                style: GoogleFonts.courierPrime(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _matchStatus == 'active' ? Colors.green : Colors.yellow,
                    width: 1,
                  ),
                  color: Colors.black,
                ),
                child: Text(
                  _matchStatus.toUpperCase(),
                  style: GoogleFonts.courierPrime(
                    color: _matchStatus == 'active' ? Colors.green : Colors.yellow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBox('SUJETO', _subjectAlive ? '🟢 VIVO' : '🔴 MUERTO'),
              _buildStatBox('CORDURA', '${(_subjectSanity * 100).toStringAsFixed(0)}%'),
              _buildStatBox('EVIDENCIA', '$_evidenceCount/5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.courierPrime(
            color: Colors.grey,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.courierPrime(
            color: Colors.cyan,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRadar(Map<String, dynamic> matchData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan, width: 2),
        color: Colors.black87,
      ),
      child: Column(
        children: [
          Text(
            'RADAR EN TIEMPO REAL',
            style: GoogleFonts.courierPrime(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: RadarPainter(
                subjectSanity: _subjectSanity,
                lastSignal: _lastSignal,
              ),
              size: const Size.fromHeight(200),
            ),
          ),
          const SizedBox(height: 12),
          if (_lastSignal != null)
            Text(
              'Última señal: ${_lastSignal!['type']} (${DateTime.fromMillisecondsSinceEpoch(((_lastSignal!['timestamp'] as Timestamp).millisecondsSinceEpoch)).toString().split('.')[0]})',
              style: GoogleFonts.courierPrime(
                color: Colors.yellow,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnergyBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        color: Colors.black87,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENERGÍA',
                style: GoogleFonts.courierPrime(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${_energy.toStringAsFixed(0)}/$maxEnergy',
                style: GoogleFonts.courierPrime(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _energy / maxEnergy,
              minHeight: 20,
              backgroundColor: Colors.orange.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _energy > 50 ? Colors.orange : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2),
        color: Colors.black87,
      ),
      child: Column(
        children: [
          Text(
            'HABILIDADES',
            style: GoogleFonts.courierPrime(
              color: Colors.purple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAbilityButton(
                name: 'SONDA',
                cost: probeCost,
                icon: '📡',
                color: Colors.cyan,
                onPressed: () => _launchAbility('ping', probeCost),
              ),
              _buildAbilityButton(
                name: 'GLITCH',
                cost: glitchCost,
                icon: '⚡',
                color: Colors.yellow,
                onPressed: () => _launchAbility('glitch', glitchCost),
              ),
              _buildAbilityButton(
                name: 'LAG',
                cost: lagCost,
                icon: '⏸️',
                color: Colors.red,
                onPressed: () => _launchAbility('lag', lagCost),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityButton({
    required String name,
    required double cost,
    required String icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final canUse = _energy >= cost && _subjectAlive && _matchStatus == 'active';
    
    return GestureDetector(
      onTap: canUse ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: canUse ? color : Colors.grey,
            width: 2,
          ),
          color: canUse ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.courierPrime(
                color: canUse ? color : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$cost E',
              style: GoogleFonts.courierPrime(
                color: canUse ? color : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter para dibujar el radar
class RadarPainter extends CustomPainter {
  final double subjectSanity;
  final Map<String, dynamic>? lastSignal;

  RadarPainter({
    required this.subjectSanity,
    required this.lastSignal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Dibujar círculos del radar
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.66, paint);
    canvas.drawCircle(center, radius * 0.33, paint);

    // Dibujar cruz
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // Dibujar punto del Sujeto en el centro (siempre visible en radar del Algoritmo)
    final subjectPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, subjectPaint);

    // Pulsación basada en cordura
    final pulsePaint = Paint()
      ..color = Colors.green.withOpacity(0.5 * subjectSanity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 12, pulsePaint);

    // Texto
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SUJETO',
        style: TextStyle(
          color: Colors.green,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx + 15, center.dy - 5),
    );
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return oldDelegate.subjectSanity != subjectSanity ||
        oldDelegate.lastSignal != lastSignal;
  }
}
