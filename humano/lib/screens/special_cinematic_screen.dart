import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import '../utils/synthetic_audio_generator.dart';

/// Dialogue line with character info
class DialogueLine {
  final String character;
  final String text;
  final String? imagePath;
  final bool isNarration;
  
  const DialogueLine({
    required this.character,
    required this.text,
    this.imagePath,
    this.isNarration = false,
  });
}

/// Special cinematic screen with Undertale-style dialogue system
class SpecialCinematicScreen extends StatefulWidget {
  final String cinematicId;
  
  const SpecialCinematicScreen({
    super.key,
    required this.cinematicId,
  });

  @override
  State<SpecialCinematicScreen> createState() => _SpecialCinematicScreenState();
}

class _SpecialCinematicScreenState extends State<SpecialCinematicScreen>
    with SingleTickerProviderStateMixin {
  late final List<DialogueLine> _dialogueLines;
  late final String _title;
  int _currentLineIndex = 0;
  String _displayedText = '';
  bool _isTyping = false;
  Timer? _typingTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _soundCounter = 0; // To avoid playing sound on every character
  
  // Typewriter effect speed (milliseconds per character)
  static const int _typingSpeed = 40;

  @override
  void initState() {
    super.initState();
    _setupContent();
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _startDialogue();
  }

  void _setupContent() {
    switch (widget.cinematicId) {
      case 'cinematic_01':
        _title = 'LA ÚLTIMA LLAMADA';
        _dialogueLines = [
          const DialogueLine(
            character: 'VÍCTØR',
            text: '2 HØRÅS ÅNT€S',
            imagePath: 'assets/images/Victor_template.png',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'ÅL€X, SØY YØ... ØTR€ V€Z.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'MÅMÁ NØ PU€Đ€ PÅGÅR €Ł ÅŁ_#_QUIŁ€R.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'SÉ QU€ €STÁS GRÅBÅNĐØ. SI€MPR€ €STÁS GRÅBÅNĐØ.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'P€RØ... ¿PU€Đ€S ŁŁÅMÅRM€? SØŁØ 5 MINUTØS.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'NØ QUIØRØ ĐINRØ. SØŁØ... N€C€SITØ HÅBŁÅR CØN ÅLGUI€N.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'T€ €XTRÅNØ, H€RMÅNØ.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'FIN Đ€ ŁÅ NØTÅ Đ€ VØZ - 9 S€GUNDØS',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: '€STÅĐØ: NØ €SCUCHÅĐÅ',
            isNarration: true,
          ),
        ];
        break;
        
      case 'cinematic_02':
        _title = 'HABITACIÓN 304';
        _dialogueLines = [
          const DialogueLine(
            character: 'MÅGNØŁIÅ',
            text: 'HÅBITÅCIÓN 304',
            imagePath: 'assets/images/Magnolia_template.png',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ĐR. LØPZ',
            text: 'SRÅÅ. TØRR€S, Đ€B€ Đ€SCÅNSÅR.',
            imagePath: null, // Shadow
          ),
          const DialogueLine(
            character: 'MÅGNØŁIÅ',
            text: 'NØ PU€ĐØ. SI Đ€SPI€RTÅ Y NØ €STØY ÅQUÍ...',
            imagePath: 'assets/images/Magnolia_template.png',
          ),
          const DialogueLine(
            character: 'ĐR. LØPZ',
            text: 'HÅN PÅSÅĐØ 7 DÍÅS. ŁÅ SØBR€DØSIS FU€ S€V€RÅ.',
            imagePath: null,
          ),
          const DialogueLine(
            character: 'MÅGNØŁIÅ',
            text: 'ÉŁ NØ... NØ €S Đ€ €SØS. ÉŁ NØ TØMÅ ĐRØGÅS.',
            imagePath: 'assets/images/Magnolia_template.png',
          ),
          const DialogueLine(
            character: 'ĐR. LØPZ',
            text: 'ŁØS ÅNSIØŁÍTICØS SON ĐRØGÅS, SRÅÅ.',
            imagePath: null,
          ),
          const DialogueLine(
            character: 'MÅGNØŁIÅ',
            text: 'P€RĐÍ Å UNØ. NØ PU€ĐØ P€RĐ€R ÅŁ ØTRØ.',
            imagePath: 'assets/images/Magnolia_template.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: '€ŁŁÅ TØMÅ ŁÅ MÅNØ Đ€ ÅL€X',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'MÅGNØŁIÅ',
            text: 'VÍCTØR T€ €SP€RÅ. YØ T€ €SP€RØ.',
            imagePath: 'assets/images/Magnolia_template.png',
          ),
        ];
        break;
        
      case 'cinematic_03':
        _title = '2 MILLONES DE VISTAS';
        _dialogueLines = [
          const DialogueLine(
            character: 'ÅL€X',
            text: '3 DÍÅS Đ€SPU€S Đ€Ł FUN€RÅŁ',
            imagePath: 'assets/images/Alex.png',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: '€ĐITÅNĐØ VÍĐ€Ø: "€N HØNØR Å MI H€RMÅNØ VÍCTØR"',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: 'ØK€Y, €ST€ CØRT€ ĐØNĐ€ ŁŁØRØ... P€RF€CTØ.',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'ÅCTIVÅ MØNT€TIZÅCIÓN',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'MÅRCÅ: ÅNUNCIØS €N TØĐØS ŁØS PUNTØS',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: 'ŁØS PÅTRØCINÅĐØR€S VÅN Å ÅMÅ_#_R €STØ.',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'SUBI€NĐØ VÍĐ€Ø...',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: '2 HØRÅS Đ€SPU€S - 500K VISTÅS',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: '24 HØRÅS Đ€SPU€S - 2M VISTÅS',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'INGR€SØS: \$12,450 USD',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: 'VÍCTØR... €STØ €S PØR TI, H€RMÅNØ.',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'P€RØ ŁØS ÅNUNCIØS SIGU€N ÅCTIVØS',
            isNarration: true,
          ),
        ];
        break;
        
      case 'cinematic_04':
        _title = '12,847 ESPECTADORES';
        _dialogueLines = [
          const DialogueLine(
            character: 'ÅL€X',
            text: 'STR€ÅM €N VIVØ - 23:47',
            imagePath: 'assets/images/Alex.png',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: '¡GRÅCIÅS PØR ŁØS 500 BITS, @ĐÅRKFÅN_#_99!',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'T€ŁÉFØNØ VIBRÅ - VÍCTØR ŁŁÅMÅNĐØ',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: 'UN S€GUNDØ, CHIC_#_ØS...',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'IGNØRÅ ŁÅ ŁŁÅMÅĐÅ',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: 'ØK€Y, ¿ĐÓNĐ€ €STÁBÅMØS?',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'CHÅT',
            text: '¡ÅBRØ €Ł PØRTÅŁ!',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'CHÅT',
            text: '¡MÁS CØNT€NIĐØ!',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'T€ŁÉFØNØ VIBRÅ - VÍCTØR ŁŁÅMÅNĐØ',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'IGNØRÅ ŁÅ ŁŁÅMÅĐÅ',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: '€STØ VÅ Å €STÅR €PÍCØ...',
            imagePath: 'assets/images/Alex.png',
          ),
        ];
        break;
        
      case 'cinematic_05':
        _title = 'SI HUBIERAS CONTESTADO';
        _dialogueLines = [
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'ŁØ QU€ HUBIRA ĐICHØ',
            imagePath: 'assets/images/Victor_template.png',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'H€Y, ÅL€X. GRÅCIÅS PØR CØNT€STÅR.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'NØ, NØ €S SØBR€ €Ł ĐINRØ. MÅMÁ YÅ ŁØ R€SØŁVIÓ.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'SØŁØ... ¿R€CU€RĐÅS CUÅNĐØ ÉRÅMØS NIÑØS?',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'JUÁBÅMØS Å SER YØUTUB€RS. TÚ SI€MPR€ €RÅS €Ł CÅMÅRÓGRÅFØ.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'YØ €RÅ €Ł TØNTØ QU€ HÅCÍÅ CHIST€S MÅLØS.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: '¿CUÁNĐØ Đ€JÅMØS Đ€ R€ÍR JUNTØS?',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'T€ €XTRÅNØ, H€RMÅNØ. NØ ÅŁ STR€ÅM€R.',
            imagePath: 'assets/images/Victor_template.png',
          ),
          const DialogueLine(
            character: 'VÍCTØR',
            text: 'ÅŁ H€RMÅNØ QU€ T€NÍÅS ÅNT€S Đ€ TØĐØ €STØ.',
            imagePath: 'assets/images/Victor_template.png',
          ),
        ];
        break;
        
      case 'cinematic_06':
        _title = 'EL VEREDICTO';
        _dialogueLines = [
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'V€RĐICTØ FINÅŁ',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'JUICIØ CØMPŁ€TØ. 7 P€CÅĐØS PRØC€SÅĐØS.',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: '6 €RÅN FRÅGM€NTØS. 1 €RÅ R€ÅŁ.',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'ÅL€X TØRR€S. 23 ÅÑØS. CUŁPÅBŁ€.',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'MÅGNØŁIÅ',
            text: 'HÅBITÅCIÓN 304',
            imagePath: 'assets/images/Magnolia_template.png',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'MÅGNØŁIÅ',
            text: 'ĐØCTØR... SU MÅNØ... S€ MØVIÓ.',
            imagePath: 'assets/images/Magnolia_template.png',
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: '€Ł LIMBØ',
            imagePath: 'assets/images/Alex.png',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: 'SI Đ€SPI€RTØ... ¿QUÉ Ł€ ĐIGØ Å MÅMÁ?',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: '¿CÓMØ Ł€ €XPŁICØ QU€ VÍCTØR ŁŁÅMÓ 15 V€C€S?',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'ÅL€X',
            text: '¿CÓMØ Ł€ ĐIGØ QU€ YØ €STÅBÅ GRÅBÅNĐØ?',
            imagePath: 'assets/images/Alex.png',
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'ŁÅ €Ł€CCIÓN €S TUYÅ, ÅL€X.',
            isNarration: true,
          ),
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'P€RØ €Ł JUICIØ YÅ T€RMINÓ.',
            isNarration: true,
          ),
        ];
        break;
        
      default:
        _title = 'ERROR';
        _dialogueLines = [
          const DialogueLine(
            character: 'SIST€MÅ',
            text: 'CINEMÁTICA NO ENCONTRADA',
            isNarration: true,
          ),
        ];
    }
  }

  void _startDialogue() {
    if (_currentLineIndex < _dialogueLines.length) {
      _typeText(_dialogueLines[_currentLineIndex].text);
    }
  }

  void _typeText(String text) {
    setState(() {
      _isTyping = true;
      _displayedText = '';
    });

    int charIndex = 0;
    _typingTimer = Timer.periodic(Duration(milliseconds: _typingSpeed), (timer) {
      if (charIndex < text.length) {
        setState(() {
          _displayedText += text[charIndex];
        });
        _playTypeSound();
        charIndex++;
      } else {
        timer.cancel();
        setState(() => _isTyping = false);
      }
    });
  }

  void _playTypeSound() async {
    // Play character-specific beep sound based on current character
    final currentLine = _dialogueLines[_currentLineIndex];
    
    // Skip sound for spaces and some punctuation (play every 2nd character for performance)
    _soundCounter++;
    if (_soundCounter % 2 != 0) return;
    
    if (_displayedText.isEmpty || 
        _displayedText.endsWith(' ') || 
        _displayedText.endsWith('\n')) {
      return;
    }
    
    // Use haptic feedback as a simple alternative to audio
    // This provides tactile feedback without needing audio files
    try {
      if (currentLine.character.contains('VÍCTØR')) {
        // Victor: Low, somber (light impact)
        HapticFeedback.lightImpact();
      } else if (currentLine.character.contains('MÅGNØŁIÅ')) {
        // Magnolia: Warm, gentle (selection click)
        HapticFeedback.selectionClick();
      } else if (currentLine.character.contains('ÅL€X')) {
        // Alex: Medium, nervous (medium impact)
        HapticFeedback.mediumImpact();
      } else if (currentLine.character.contains('ĐR. LØPZ')) {
        // Dr. Lopez: Professional (light impact)
        HapticFeedback.lightImpact();
      } else {
        // System/Narration: Glitchy (selection click)
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Silently fail if haptic feedback is not available
    }
  }

  void _nextLine() {
    if (_isTyping) {
      // Skip typing animation
      _typingTimer?.cancel();
      setState(() {
        _displayedText = _dialogueLines[_currentLineIndex].text;
        _isTyping = false;
      });
    } else {
      // Move to next line
      if (_currentLineIndex < _dialogueLines.length - 1) {
        setState(() => _currentLineIndex++);
        _startDialogue();
      } else {
        // End of dialogue
        _exitCinematic();
      }
    }
  }

  void _exitCinematic() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLine = _dialogueLines[_currentLineIndex];
    
    return Material(
      color: Colors.black,
      child: GestureDetector(
        onTap: _nextLine,
        child: Stack(
          children: [
            // Background
            Container(color: Colors.black),
            
            // Character portrait (left side)
            if (!currentLine.isNarration)
              Positioned(
                left: 40,
                top: 0,
                bottom: 120,
                child: Center(
                  child: _buildCharacterPortrait(currentLine),
                ),
              ),
            
            // Dialogue box (bottom)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildDialogueBox(currentLine),
            ),
            
            // Skip button
            Positioned(
              top: 20,
              right: 20,
              child: SafeArea(
                child: TextButton(
                  onPressed: _exitCinematic,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'SALIR',
                        style: GoogleFonts.courierPrime(
                          fontSize: 12,
                          color: Colors.grey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Title at top
            Positioned(
              top: 20,
              left: 20,
              child: SafeArea(
                child: Text(
                  _title,
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: Colors.white38,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterPortrait(DialogueLine line) {
    if (line.imagePath == null) {
      // Doctor shadow
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.grey.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.grey.withOpacity(0.5),
        ),
      );
    }
    
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00F0FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        line.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: const Icon(Icons.person, size: 80, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildDialogueBox(DialogueLine line) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: line.isNarration 
              ? Colors.grey[700]! 
              : const Color(0xFF00F0FF),
          width: 3,
        ),
        boxShadow: line.isNarration ? null : [
          BoxShadow(
            color: const Color(0xFF00F0FF).withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Character name
          if (!line.isNarration)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                line.character,
                style: GoogleFonts.shareTechMono(
                  fontSize: 16,
                  color: const Color(0xFF00F0FF),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          
          // Dialogue text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (line.isNarration)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    '*',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  _displayedText,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 16,
                    color: line.isNarration ? Colors.grey[400] : Colors.white,
                    height: 1.5,
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              // Typing indicator
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _TypingIndicator(),
                ),
            ],
          ),
          
          // Continue indicator
          if (!_isTyping)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        '▼',
        style: GoogleFonts.shareTechMono(
          fontSize: 14,
          color: const Color(0xFF00F0FF),
        ),
      ),
    );
  }
}
