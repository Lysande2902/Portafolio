import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/data/providers/arc_data_provider.dart';
import 'package:humano/game/puzzle/effects/sound_manager.dart';

/// Game over screen shown when player loses
class GameOverScreen extends StatefulWidget {
  final String arcId;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const GameOverScreen({
    super.key,
    required this.arcId,
    required this.onRetry,
    required this.onExit,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> with TickerProviderStateMixin {
  late final String randomMessage;
  late final String arcTitle;
  late final String flavorText;
  
  String _displayedMessage = '';
  int _charIndex = 0;
  Timer? _typewriterTimer;
  bool _isTypewriterFinished = false;
  
  late AnimationController _flashController;
  late AnimationController _fadeController;
  
  @override
  void initState() {
    super.initState();
    
    // Get arc-specific content
    final arcDataProvider = ArcDataProvider();
    final arcContent = arcDataProvider.getArcContent(widget.arcId);
    
    arcTitle = arcContent?.title ?? 'DESCONOCIDO';
    final arcMessages = arcContent?.gameOver.messages ?? ['CONEXIÓN PERDIDA'];
    final flavorTexts = arcContent?.gameOver.flavorTexts ?? [];
    final defaultFlavor = arcContent?.gameOver.flavorText ?? '';
    
    final random = DateTime.now().millisecond;
    
    // Select random message
    if (arcMessages.isNotEmpty) {
      randomMessage = arcMessages[random % arcMessages.length];
    } else {
      randomMessage = 'CONEXIÓN PERDIDA';
    }
    
    // Select random flavor text
    if (flavorTexts.isNotEmpty) {
      final flavorRandom = (random * 7 + 13) % flavorTexts.length;
      flavorText = flavorTexts[flavorRandom];
    } else {
      flavorText = defaultFlavor;
    }

    // Animation controllers
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initial sequence
    Future.delayed(const Duration(milliseconds: 100), () {
      _startGameOverSequence();
    });
  }

  void _startGameOverSequence() async {
    // 1. Red Flash & Rumble
    _flashController.forward().then((_) => _flashController.reverse());
    SoundManager().playErrorSound();
    SoundManager().heavyHaptic();
    
    // 2. Short pause
    await Future.delayed(const Duration(milliseconds: 600));
    
    // 3. Start Typewriter
    _startTypewriter();
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_charIndex < randomMessage.length) {
        if (mounted) {
          setState(() {
            _displayedMessage += randomMessage[_charIndex];
            _charIndex++;
          });
          if (_charIndex % 2 == 0) {
            SoundManager().playBlip();
            HapticFeedback.lightImpact();
          }
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => _isTypewriterFinished = true);
          _fadeController.forward();
        }
      }
    });
  }

  void _skipTypewriter() {
    if (_isTypewriterFinished) return;
    _typewriterTimer?.cancel();
    if (mounted) {
      setState(() {
        _displayedMessage = randomMessage;
        _charIndex = randomMessage.length;
        _isTypewriterFinished = true;
      });
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _flashController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Stack(
      children: [
        // Skip typewriter detector (only active during typewriter)
        if (!_isTypewriterFinished)
          Positioned.fill(
            child: GestureDetector(
              onTap: _skipTypewriter,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.shrink(),
            ),
          ),
          
        // Main Background
        Container(
          color: Colors.black.withOpacity(0.96),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 36,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'GAME OVER',
                      style: GoogleFonts.pressStart2p(
                        fontSize: isSmallScreen ? 20 : 26,
                        color: Colors.red.shade900,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(color: Colors.red.withOpacity(0.5), blurRadius: 10),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Arc title
                    Text(
                      arcTitle.toUpperCase(),
                      style: GoogleFonts.shareTechMono(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.red.shade800.withOpacity(0.7),
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Mocking message (Typewriter)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 80),
                      child: Text(
                        _displayedMessage,
                        style: GoogleFonts.shareTechMono(
                          fontSize: isSmallScreen ? 18 : 22,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Flavor text
                    if (flavorText.isNotEmpty)
                      AnimatedOpacity(
                        opacity: _isTypewriterFinished ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          flavorText,
                          style: GoogleFonts.shareTechMono(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: Colors.white24,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    const SizedBox(height: 60),
                    
                    // Buttons
                    AnimatedOpacity(
                      opacity: _isTypewriterFinished ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: IgnorePointer(
                        ignoring: !_isTypewriterFinished,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: widget.onRetry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[900],
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: Text(
                                  'REINTENTAR CONEXIÓN',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: widget.onExit,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white38,
                                  side: const BorderSide(color: Colors.white10),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: Text(
                                  'SALIR DEL SISTEMA',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 14,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Red Flash Overlay
        IgnorePointer(
          child: FadeTransition(
            opacity: _flashController,
            child: Container(
              color: Colors.red.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
}
