import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as java_math;
import 'package:humano/game/ui/item_bar.dart';
import 'package:provider/provider.dart';
import 'package:humano/providers/theme_provider.dart';

/// Game HUD - displays sanity, evidence count, and controls
class GameHUD extends StatefulWidget {
  final double sanity; // 0.0 to 1.0
  final int evidenceCollected;
  final int totalEvidence;
  final bool showHideButton;
  final VoidCallback? onPause;
  final VoidCallback? onHide;
  final Map<String, int>? availableItems;
  final Function(String)? onUseItem;
  final bool modoIncognitoActive;
  final bool firewallActive;
  final bool vpnActive;
  final bool altAccountActive;
  final double? noiseLevel; // For Sloth arc - 0.0 to 1.0
  final int? foodInventoryCount; // For Gluttony arc - food count
  final int? maxFoodInventory; // For Gluttony arc - max food capacity
  final int? coinInventoryCount; // For Greed arc - coin count
  final int? maxCoinInventory; // For Greed arc - max coin capacity
  final int? cameraInventoryCount; // For Envy arc - camera count
  final int? maxCameraInventory; // For Envy arc - max camera capacity
  final bool showSanityBar;

  const GameHUD({
    super.key,
    required this.sanity,
    required this.evidenceCollected,
    required this.totalEvidence,
    this.showHideButton = false,
    this.onPause,
    this.onHide,
    this.availableItems,
    this.onUseItem,
    this.modoIncognitoActive = false,
    this.firewallActive = false,
    this.vpnActive = false,
    this.altAccountActive = false,
    this.noiseLevel,
    this.foodInventoryCount,
    this.maxFoodInventory,
    this.coinInventoryCount,
    this.maxCoinInventory,
    this.cameraInventoryCount,
    this.maxCameraInventory,
    this.showSanityBar = true,
  });

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> {
  java_math.Random _random = java_math.Random();
  bool _isShowingSecret = false;
  Timer? _secretTimer;
  Timer? _spectatorPressureTimer;
  bool _hudGlitch = false;

  @override
  void initState() {
    super.initState();
    _startSpectatorPressure();
  }

  void _startSpectatorPressure() {
    _spectatorPressureTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      if (widget.sanity < 0.2) {
        // Audiencia en éxtasis — vibración doble intensa
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
        setState(() => _hudGlitch = true);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _hudGlitch = false);
        });
      } else if (widget.sanity < 0.5) {
        // Audiencia creciente — vibración media
        HapticFeedback.mediumImpact();
        setState(() => _hudGlitch = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _hudGlitch = false);
        });
      }
      // sanity >= 0.5: sin vibración — nadie se preocupa aún
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Stack(
      children: [
        // LEFT COLUMN: Sanity -> Noise -> Effects
        Positioned(
          top: 35, // Moved down to avoid overlapping with system bars
          left: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showSanityBar) _buildSanityTimer(isSmallScreen),
              const SizedBox(height: 8),
              if (widget.noiseLevel != null) ...[
                _buildNoiseIndicator(isSmallScreen),
                const SizedBox(height: 8),
              ],
            ],

          ),
        ),

        // RIGHT COLUMN: Evidence -> Arc Inventory -> Items
        Positioned(
          top: 35, // Moved down
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Arc Specific Inventory
              if (widget.foodInventoryCount != null && widget.maxFoodInventory != null)
                _buildFoodInventory(isSmallScreen),
              if (widget.coinInventoryCount != null && widget.maxCoinInventory != null)
                _buildCoinInventory(isSmallScreen),
              if (widget.cameraInventoryCount != null && widget.maxCameraInventory != null)
                _buildCameraInventory(isSmallScreen),
                
              const SizedBox(height: 8),
              
              // Consumable Items
              if (widget.availableItems != null && widget.availableItems!.isNotEmpty && widget.onUseItem != null)
                ItemBar(
                  availableItems: widget.availableItems!,
                  onUseItem: widget.onUseItem!,
                  isGameActive: !widget.modoIncognitoActive,
                ),
            ],
          ),
        ),

        // TOP RIGHT: Spectator Count & Effects Icons (Higher Position)
        Positioned(
          top: 12,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSpectatorCount(isSmallScreen),
            ],
          ),
        ),

        // CENTER: Pause Button
        if (widget.onPause != null)
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: IconButton(
                  onPressed: widget.onPause,
                  icon: const Icon(Icons.pause),
                  color: Colors.white,
                  iconSize: isSmallScreen ? 20 : 24,
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                ),
              ),
            ),
          ),

        // BOTTOM RIGHT: Hide Button
        if (widget.showHideButton && widget.onHide != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: widget.onHide,
              child: Container(
                width: isSmallScreen ? 56 : 64,
                height: isSmallScreen ? 56 : 64,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.visibility_off,
                  color: Colors.white,
                  size: isSmallScreen ? 26 : 30,
                ),
              ),
            ),
          ),

        // SECRET OVERLAY (Punto 7)
        if (_isShowingSecret)
          _buildSecretOverlay(),
      ],
    );
  }


  Widget _buildSanityTimer(bool isSmallScreen) {
    final appTheme = Provider.of<AppThemeProvider>(context, listen: false).currentTheme;
    // Calculamos el tiempo basado en la estabilidad (tomamos 180 segundos como base del 100%)
    final totalSeconds = widget.sanity * 180; 
    final minutes = (totalSeconds / 60).floor();
    final seconds = (totalSeconds % 60).floor();
    final centiseconds = ((totalSeconds % 1) * 100).floor();

    final isLow = widget.sanity < 0.2;
    final color = isLow ? appTheme.primaryColor : Colors.white;

    // Colores de la barra
    final Color barFillColor = widget.sanity > 0.5 
      ? Color.lerp(Colors.grey[400], Colors.white, (widget.sanity - 0.5) * 2)!
      : Color.lerp(appTheme.backgroundColor, Colors.grey[400]!, widget.sanity * 2)!;

    final timerDisplay = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: widget.showSanityBar ? BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isLow ? appTheme.primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.25), 
          width: 1.2,
        ),
      ) : null,
      child: widget.showSanityBar ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Icon + Title + Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology,
                color: color.withOpacity(0.8),
                size: isSmallScreen ? 14 : 16,
              ),
              const SizedBox(width: 6),
              Text(
                'ESTABILIDAD MENTAL',
                style: GoogleFonts.shareTechMono(
                  color: color,
                  fontSize: isSmallScreen ? 9 : 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isLow ? '[CRÍTICO]' : '[OK]',
                style: GoogleFonts.shareTechMono(
                  color: isLow ? appTheme.primaryColor : Colors.green,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Middle Row: Timer + Bar
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Numerical Timer (Compact)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.shareTechMono(
                        color: color,
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: ':${centiseconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.shareTechMono(
                        color: color.withOpacity(0.5),
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Visual Sanity Bar (Restaurada)
              Container(
                height: isSmallScreen ? 12 : 14,
                width: isSmallScreen ? 80 : 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(1),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widget.sanity.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLow ? appTheme.primaryColor : barFillColor,
                          boxShadow: [
                            if (widget.sanity > 0.2)
                              BoxShadow(
                                color: (isLow ? appTheme.primaryColor : barFillColor).withOpacity(0.3),
                                blurRadius: 4,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ) : const SizedBox(width: 40, height: 40), // Invisible hit area for secret
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _secretTimer?.cancel();
        _secretTimer = Timer(const Duration(seconds: 2), () {
          HapticFeedback.heavyImpact();
          setState(() {
            _isShowingSecret = true;
          });
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() => _isShowingSecret = false);
            }
          });
        });
      },
      onTapUp: (_) => _secretTimer?.cancel(),
      onTapCancel: () => _secretTimer?.cancel(),
      child: timerDisplay,
    );
  }

  Widget _buildSecretOverlay() {
    final appTheme = Provider.of<AppThemeProvider>(context, listen: false).currentTheme;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _isShowingSecret = false),
        child: Container(
          color: Colors.black.withOpacity(0.9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, color: appTheme.accentColor, size: 48),
              const SizedBox(height: 20),
              Text(
                'ACCESO NO AUTORIZADO DETECTADO',
                style: GoogleFonts.shareTechMono(
                  color: appTheme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'NODO_ORIGEN: 40.4168 -3.7038',
                style: GoogleFonts.shareTechMono(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ESTADO: SUJETO_00_UBICACIÓN_REVELADA',
                style: GoogleFonts.shareTechMono(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                '[ TOCAL PARA CERRAR ]',
                style: GoogleFonts.shareTechMono(
                  color: appTheme.accentColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceCounter(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 140 : 160,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.yellow[700]!.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Fragment icons (visual representation) - Wrap to avoid overflows with 10 fragments
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 2,
            runSpacing: 2,
            children: List.generate(widget.totalEvidence, (index) {
              final isCollected = index < widget.evidenceCollected;
              return Icon(
                isCollected ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                color: isCollected ? Colors.yellow[700] : Colors.grey[900],
                size: isSmallScreen ? 12 : 14,
              );
            }),
          ),
          const SizedBox(height: 6),
          // Text counter
          Text(
            '${widget.evidenceCollected}/${widget.totalEvidence} FRAGMENTOS',
            style: GoogleFonts.shareTechMono(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoiseIndicator(bool isSmallScreen) {
    final noise = widget.noiseLevel ?? 0.0;
    
    // Color based on noise level
    Color noiseColor;
    IconData noiseIcon;
    String noiseText;
    
    if (noise < 0.3) {
      noiseColor = Colors.green;
      noiseIcon = Icons.volume_off;
      noiseText = 'SILENCIO';
    } else if (noise < 0.7) {
      noiseColor = Colors.orange;
      noiseIcon = Icons.volume_down;
      noiseText = 'CUIDADO';
    } else {
      noiseColor = Colors.red;
      noiseIcon = Icons.volume_up;
      noiseText = '¡ALERTA!';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: noiseColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: noiseColor.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                noiseIcon,
                color: noiseColor,
                size: isSmallScreen ? 14 : 16,
              ),
              const SizedBox(width: 4),
              Text(
                noiseText,
                style: GoogleFonts.shareTechMono(
                  color: noiseColor,
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Noise bar
          Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 4 : 6,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: noise.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: noiseColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: noiseColor.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFoodInventory(bool isSmallScreen) {
    final count = widget.foodInventoryCount ?? 0;
    final max = widget.maxFoodInventory ?? 2;
    
    // Color based on inventory status
    Color inventoryColor;
    String statusText;
    
    if (count == 0) {
      inventoryColor = Colors.red;
      statusText = '¡SIN COMIDA!';
    } else if (count < max) {
      inventoryColor = Colors.orange;
      statusText = 'BUSCA MÁS';
    } else {
      inventoryColor = Colors.green;
      statusText = 'LLENO';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: inventoryColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: inventoryColor.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Food icons (visual representation)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(max, (index) {
              final hasFood = index < count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  hasFood ? Icons.restaurant : Icons.restaurant_outlined,
                  color: hasFood ? Colors.green : Colors.grey.shade700,
                  size: isSmallScreen ? 16 : 18,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          // Status text
          Text(
            statusText,
            style: GoogleFonts.shareTechMono(
              color: inventoryColor,
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          // Counter text
          Text(
            '$count/$max COMIDAS',
            style: GoogleFonts.shareTechMono(
              color: Colors.white,
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCoinInventory(bool isSmallScreen) {
    final count = widget.coinInventoryCount ?? 0;
    final max = widget.maxCoinInventory ?? 2;
    
    // Color based on inventory status
    Color inventoryColor;
    String statusText;
    
    if (count == 0) {
      inventoryColor = Colors.red;
      statusText = '¡SIN MONEDAS!';
    } else if (count < max) {
      inventoryColor = Colors.orange;
      statusText = 'BUSCA MÁS';
    } else {
      inventoryColor = Colors.green;
      statusText = 'LLENO';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: inventoryColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: inventoryColor.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Coin icons (visual representation)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(max, (index) {
              final hasCoin = index < count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  hasCoin ? Icons.monetization_on : Icons.monetization_on_outlined,
                  color: hasCoin ? Colors.amber : Colors.grey.shade700,
                  size: isSmallScreen ? 16 : 18,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          // Status text
          Text(
            statusText,
            style: GoogleFonts.shareTechMono(
              color: inventoryColor,
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          // Counter text
          Text(
            '$count/$max MONEDAS',
            style: GoogleFonts.shareTechMono(
              color: Colors.white,
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCameraInventory(bool isSmallScreen) {
    final count = widget.cameraInventoryCount ?? 0;
    final max = widget.maxCameraInventory ?? 3;
    
    // Color based on inventory status
    Color inventoryColor;
    String statusText;
    
    if (count == 0) {
      inventoryColor = Colors.red;
      statusText = '¡SIN FOTOS!';
    } else if (count < max) {
      inventoryColor = Colors.orange;
      statusText = 'BUSCA MÁS';
    } else {
      inventoryColor = Colors.green;
      statusText = 'LLENO';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: inventoryColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: inventoryColor.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Camera icons (visual representation)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(max, (index) {
              final hasCamera = index < count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  hasCamera ? Icons.camera_alt : Icons.camera_alt_outlined,
                  color: hasCamera ? Colors.purple : Colors.grey.shade700,
                  size: isSmallScreen ? 16 : 18,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          // Status text
          Text(
            statusText,
            style: GoogleFonts.shareTechMono(
              color: inventoryColor,
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          // Counter text
          Text(
            '$count/$max FOTOS',
            style: GoogleFonts.shareTechMono(
              color: Colors.white,
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectatorCount(bool isSmallScreen) {
    int spectators;
    String pressureMsg;
    Color spectatorColor;

    if (widget.sanity < 0.2) {
      spectators = 85000 + (_random.nextInt(40000));
      // La audiencia se vuelve loca cuando Alex está al borde
      pressureMsg = _hudGlitch ? 'TE VEN MORIR' : 'TESTIGOS: ACTIVOS';
      spectatorColor = Colors.red;
    } else if (widget.sanity < 0.5) {
      spectators = 25000 + (_random.nextInt(15000));
      pressureMsg = 'TESTIGOS: ALERTA';
      spectatorColor = Colors.orange;
    } else {
      spectators = 12000 + (_random.nextInt(5000));
      pressureMsg = 'TESTIGOS: PASIVOS';
      spectatorColor = Colors.red[700]!;
    }

    final formattedValue = (spectators / 1000).toStringAsFixed(1) + "k";
    final isDanger = widget.sanity < 0.2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _secretTimer?.cancel();
        _secretTimer = Timer(const Duration(seconds: 2), () {
          HapticFeedback.heavyImpact();
          setState(() {
            _isShowingSecret = true;
          });
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() => _isShowingSecret = false);
            }
          });
        });
      },
      onTapUp: (_) => _secretTimer?.cancel(),
      onTapCancel: () => _secretTimer?.cancel(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _hudGlitch
              ? Colors.red.withOpacity(0.5)
              : (isDanger ? Colors.red.withOpacity(0.3) : Colors.black.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: spectatorColor.withOpacity(_hudGlitch ? 1.0 : 0.5),
            width: _hudGlitch ? 2 : 1,
          ),
          boxShadow: _hudGlitch
              ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDanger ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                  color: spectatorColor,
                  size: isSmallScreen ? 12 : 14,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedValue,
                  style: GoogleFonts.shareTechMono(
                    color: spectatorColor,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              pressureMsg,
              style: GoogleFonts.shareTechMono(
                color: spectatorColor.withOpacity(0.6),
                fontSize: 7,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _secretTimer?.cancel();
    _spectatorPressureTimer?.cancel();
    super.dispose();
  }
}

class BarNoisePainter extends CustomPainter {
  final double intensity;

  BarNoisePainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final random = java_math.Random();
    final paint = Paint()..color = Colors.white.withOpacity(0.05 + (intensity * 0.1));

    // Dibujar puntos de ruido aleatorios
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }

    // Líneas de interferencia horizontales sutiles
    if (intensity > 0.5) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..strokeWidth = 0.5;
      
      for (int i = 0; i < 3; i++) {
        final y = random.nextDouble() * size.height;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarNoisePainter oldDelegate) => true;
}

