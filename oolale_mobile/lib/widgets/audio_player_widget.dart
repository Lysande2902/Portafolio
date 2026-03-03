import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../config/constants.dart';
import '../config/theme_colors.dart';

/// Widget profesional para reproducir audios con controles completos
/// Incluye play/pause, barra de progreso, velocidad de reproducción, y loop
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String? title;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.title,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  String? _error;
  double _speed = 1.0;
  bool _isLooping = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      
      _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
          
          // Auto-reset when finished (if not looping)
          if (state.processingState == ProcessingState.completed && !_isLooping) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar audio';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _changeSpeed() {
    setState(() {
      if (_speed == 1.0) {
        _speed = 1.25;
      } else if (_speed == 1.25) {
        _speed = 1.5;
      } else if (_speed == 1.5) {
        _speed = 2.0;
      } else {
        _speed = 1.0;
      }
      _audioPlayer.setSpeed(_speed);
    });
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
      _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
    });
  }

  void _skipForward() {
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition < _duration) {
      _audioPlayer.seek(newPosition);
    } else {
      _audioPlayer.seek(_duration);
    }
  }

  void _skipBackward() {
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _audioPlayer.seek(newPosition);
    } else {
      _audioPlayer.seek(Duration.zero);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? 'Mensaje de voz',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Speed control
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_speed}x',
                style: GoogleFonts.outfit(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onPressed: _changeSpeed,
          ),
          // Loop control
          IconButton(
            icon: Icon(
              Icons.repeat,
              color: _isLooping ? AppConstants.primaryColor : ThemeColors.icon(context),
            ),
            onPressed: _toggleLoop,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Audio icon with animation
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.graphic_eq : Icons.audiotrack,
                  size: 70,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 50),
              
              // Error or loading state
              if (_error != null)
                Text(
                  _error!,
                  style: GoogleFonts.outfit(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                )
              else if (_isLoading)
                const CircularProgressIndicator(color: AppConstants.primaryColor)
              else ...[
                // Progress slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    activeTrackColor: AppConstants.primaryColor,
                    inactiveTrackColor: ThemeColors.divider(context),
                    thumbColor: AppConstants.primaryColor,
                    overlayColor: AppConstants.primaryColor.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                
                // Time labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Skip backward 10s
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      iconSize: 40,
                      color: ThemeColors.icon(context),
                      onPressed: _skipBackward,
                    ),
                    const SizedBox(width: 20),
                    
                    // Play/Pause button
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Skip forward 10s
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      iconSize: 40,
                      color: ThemeColors.icon(context),
                      onPressed: _skipForward,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
