import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

/// Victory screen shown when player completes the arc
class VictoryScreen extends StatefulWidget {
  final int evidenceCollected;
  final int totalEvidence;
  final double timeSpent;
  final VoidCallback onContinue;
  final Map<String, dynamic>? additionalStats; // Optional additional statistics
  final bool hasBattlePass; // Battle Pass status
  final int coinsEarned; // Total coins earned (with bonus if applicable)
  final String arcNumber; // Arc number (e.g., "1", "2", "3")
  final String arcTitle; // Arc title (e.g., "GULA", "AVARICIA")

  const VictoryScreen({
    super.key,
    required this.evidenceCollected,
    required this.totalEvidence,
    required this.timeSpent,
    required this.onContinue,
    this.additionalStats,
    this.hasBattlePass = false,
    this.coinsEarned = 100,
    this.arcNumber = '1',
    this.arcTitle = 'GULA',
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  bool _showTitle = false;
  bool _showStat1 = false;
  bool _showStat2 = false;
  bool _showStat3 = false;
  bool _showAdditional = false;
  Timer? _autoDismissTimer;
  bool _isGlitching = true;
  double _glitchOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Idea 4: Victory Glitch Initial Burst
    setState(() {
      _isGlitching = true;
      _glitchOpacity = 0.8;
    });
    HapticFeedback.vibrate();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _glitchOpacity = 0.4);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _isGlitching = false);

    // Show title
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _showTitle = true);

    // Show stat 1
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _showStat1 = true);

    // Show stat 2
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _showStat2 = true);

    // Show stat 3
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _showStat3 = true);

    // Show additional stats
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _showAdditional = true);

    // Auto-dismiss after 10 seconds (giving more time to read)
    _autoDismissTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        widget.onContinue();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (widget.timeSpent / 60).floor();
    final seconds = (widget.timeSpent % 60).floor();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return WillPopScope(
      onWillPop: () async {
        widget.onContinue();
        return false;
      },
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
                    child: Row(
                      children: [
                        // Left side: Arc title
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedOpacity(
                                opacity: _showTitle ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  'ARCO ${widget.arcNumber}',
                                  style: GoogleFonts.courierPrime(
                                    fontSize: isSmallScreen ? 10 : 14,
                                    color: Colors.grey[700],
                                    letterSpacing: 1.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedOpacity(
                                opacity: _showTitle ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  widget.arcTitle.toUpperCase(),
                                  style: GoogleFonts.courierPrime(
                                    fontSize: isSmallScreen ? 20 : 36,
                                    color: const Color(0xFF8B0000), // Dark red
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: isSmallScreen ? 1.5 : 3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Right side: Stats (no scroll)
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedOpacity(
                                opacity: _showStat1 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: _buildStatRow('EVIDENCIAS', '${widget.evidenceCollected}/${widget.totalEvidence}', isSmallScreen),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 20),
                              AnimatedOpacity(
                                opacity: _showStat2 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: _buildStatRow('TIEMPO', '${minutes}m ${seconds}s', isSmallScreen),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 20),
                              AnimatedOpacity(
                                opacity: _showStat3 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: _buildStatRow('MONEDAS', '+${widget.coinsEarned}${widget.hasBattlePass ? ' 🎖️' : ''}', isSmallScreen),
                              ),
                              
                              // Additional stats if provided
                              if (widget.additionalStats != null && _showAdditional) 
                                ..._buildAdditionalStatsRows(isSmallScreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Victory Glitch Overlay (Idea 4)
            if (_isGlitching)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(_glitchOpacity),
                  child: Center(
                    child: Text(
                      'CONEXIÓN RESTABLECIDA',
                      style: GoogleFonts.courierPrime(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAdditionalStatsRows(bool isSmallScreen) {
    if (widget.additionalStats == null) return [];
    
    final List<Widget> widgets = [];
    
    // Arc 3 (Envy) stats - Prioritize most important (max 2 additional stats)
    if (widget.additionalStats!.containsKey('photosUsed')) {
      widgets.add(SizedBox(height: isSmallScreen ? 15 : 25));
      widgets.add(_buildStatRow('FOTOS USADAS', '${widget.additionalStats!['photosUsed']}', isSmallScreen));
    }
    
    if (widget.additionalStats!.containsKey('enemyBreakouts') && widgets.length < 4) {
      widgets.add(SizedBox(height: isSmallScreen ? 15 : 25));
      widgets.add(_buildStatRow('RUPTURAS', '${widget.additionalStats!['enemyBreakouts']}', isSmallScreen));
    }
    
    // Arc 2 (Greed) stats
    if (widget.additionalStats!.containsKey('stolenItems') && widgets.length < 4) {
      widgets.add(SizedBox(height: isSmallScreen ? 15 : 25));
      widgets.add(_buildStatRow('ITEMS ROBADOS', '${widget.additionalStats!['stolenItems']}', isSmallScreen));
    }
    
    if (widget.additionalStats!.containsKey('cashRegistersLooted') && widgets.length < 4) {
      widgets.add(SizedBox(height: isSmallScreen ? 15 : 25));
      widgets.add(_buildStatRow('CAJAS SAQUEADAS', '${widget.additionalStats!['cashRegistersLooted']}', isSmallScreen));
    }
    
    // Arc 1 (Gluttony) stats - Prioritize most important
    if (widget.additionalStats!.containsKey('foodThrown') && widgets.length < 4) {
      widgets.add(SizedBox(height: isSmallScreen ? 15 : 25));
      widgets.add(_buildStatRow('COMIDA LANZADA', '${widget.additionalStats!['foodThrown']}', isSmallScreen));
    }
    
    if (widget.additionalStats!.containsKey('timesHidden') && widgets.length < 4) {
      widgets.add(SizedBox(height: isSmallScreen ? 15 : 25));
      widgets.add(_buildStatRow('VECES ESCONDIDO', '${widget.additionalStats!['timesHidden']}', isSmallScreen));
    }
    
    return widgets;
  }

  Widget _buildStatRow(String label, String value, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.courierPrime(
            fontSize: isSmallScreen ? 7 : 10,
            color: Colors.grey[700],
            letterSpacing: 0.5,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.courierPrime(
            fontSize: isSmallScreen ? 10 : 20,
            color: const Color(0xFFCD5C5C), // Indian red (subtle)
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
