import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'settings_provider.dart';
import 'user_data_provider.dart';

class AudioProvider extends ChangeNotifier {
  final SettingsProvider _settings;
  UserDataProvider? _userDataProvider;
  
  // Audios para efectos cortos
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  // Audios para música de fondo
  final ja.AudioPlayer _bgmPlayer = ja.AudioPlayer();
  
  // Estado actual
  String? _currentBgm;
  bool _shouldBePlaying = false;
  String? _lastEquippedMusicId;
  Timer? _fadeTimer;
  Timer? _watchdogTimer;

  AudioProvider(this._settings, [this._userDataProvider]) {
    _settings.addListener(_updateVolumes);
    _initAudioSession();
    _updateVolumes();
    
    // Inicializar el ID de la música actual si el provider ya tiene datos
    _lastEquippedMusicId = _userDataProvider?.inventory.equippedMusic;
  }

  void updateUserData(UserDataProvider userDataProvider) {
    final newMusic = userDataProvider.inventory.equippedMusic;
    
    // Si la música equipada cambió respecto a lo que sabíamos nosotros
    if (newMusic != _lastEquippedMusicId && newMusic != null) {
      print('🔄 [AudioProvider] Cambio de música detectado: $_lastEquippedMusicId -> $newMusic');
      _lastEquippedMusicId = newMusic;
      _userDataProvider = userDataProvider; // Actualizar referencia antes de llamar a play
      playArcMusic('current');
    } else {
      _userDataProvider = userDataProvider;
    }
  }

  Future<void> _initAudioSession() async {
    try {
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gain,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
        ),
      ));
      print('✅ [AudioProvider] Sesión de audio configurada (Focus: GAIN, Type: MUSIC)');
    } catch (e) {
      print('⚠️ [AudioProvider] Error configurando AudioSession: $e');
    }
  }

  void _updateVolumes() {
    _bgmPlayer.setVolume(_targetMusicVolume);
  }

  double get _targetMusicVolume {
    final vol = _settings.masterVolume * _settings.musicVolume;
    return vol.clamp(0.0, 1.0);
  }

  /// Reproduce un efecto de sonido corto
  Future<void> playSfx(String assetPath) async {
    // SFX Desactivados por petición del usuario para priorizar la música
    return;
  }

  bool _isProcessingBgm = false;

  /// Reproduce música de fondo en bucle con fade-in suave
  Future<void> playBgm(String assetPath, {bool fadeIn = true}) async {
    print('🎵 [AudioProvider] SOLICITUD playBgm: $assetPath');
    
    // 1. Si ya está sonando EXACTAMENTE esto, ignorar para evitar micro-cortes
    if (_currentBgm == assetPath && _bgmPlayer.playing) {
      print('🎵 [AudioProvider] La pista ya está sonando. Ignorando.');
      _shouldBePlaying = true;
      return;
    }

    // 2. Si ya estamos procesando esta misma pista, esperar/ignorar para evitar colisiones
    if (_isProcessingBgm && _currentBgm == assetPath) {
      print('🎵 [AudioProvider] Ya se está cargando esta pista. Ignorando duplicado.');
      return;
    }

    _isProcessingBgm = true;
    _fadeTimer?.cancel();
    _shouldBePlaying = true;

    try {
      // 3. SOLO detener y recargar si la pista es DIFERENTE
      if (_currentBgm != assetPath) {
        print('🎵 [AudioProvider] Cambiando de pista: $_currentBgm -> $assetPath');
        _currentBgm = assetPath;
        
        await _bgmPlayer.stop();
        await _bgmPlayer.setAsset(assetPath, preload: true);
        await _bgmPlayer.setLoopMode(ja.LoopMode.all);
        await _bgmPlayer.seek(Duration.zero);
      } else {
        print('🎵 [AudioProvider] Reanudando pista actual (ya estaba cargada): $assetPath');
      }
      
      final double targetVol = _targetMusicVolume;

      if (fadeIn && targetVol > 0.05) {
        // Si no está sonando, fadeIn
        if (!_bgmPlayer.playing) {
          await _bgmPlayer.setVolume(0.0);
          await _bgmPlayer.play();
          _fadeIn(targetVol);
        } else {
          // Si ya estaba sonando pero entramos aquí (p.ej. no detectamos playing antes), 
          // simplemente asegurar volumen
          await _bgmPlayer.setVolume(targetVol);
        }
      } else {
        await _bgmPlayer.setVolume(targetVol);
        if (!_bgmPlayer.playing) await _bgmPlayer.play();
      }

      _startWatchdog(assetPath);

    } catch (e, stack) {
      print('❌ [AudioProvider] ERROR CRÍTICO en playBgm: $e');
      print('Stack trace:\n$stack');
      _currentBgm = null;
    } finally {
      _isProcessingBgm = false;
    }
  }

  /// Música específica para cada arco con fade-in automático
  /// AHORA: Usa la música equipada globalmente ignorando el arco
  Future<void> playArcMusic(String arcId) async {
    print('🎮 [AudioProvider] playArcMusic recibida para arcId: "$arcId" (USANDO GLOBAL)');
    
    final musicId = _userDataProvider?.inventory.equippedMusic ?? 'music_reflections';
    final asset = _assetForMusicId(musicId);
    
    await playBgm(asset);
  }

  String _assetForMusicId(String musicId) {
    switch (musicId) {
      case 'music_reflections':
        return 'assets/music/REFLECTIONS_origin.mp3';
      case 'music_excess':
        return 'assets/music/EXCESS__origin.mp3';
      case 'music_spotlight':
        return 'assets/music/SPOTLIGHT.mp3';
      case 'music_ashes':
        return 'assets/music/ASHES_origin.mp3';
      case 'music_witness':
        return 'assets/music/WITNESS_origin.mp3';
      default:
        return 'assets/music/REFLECTIONS_origin.mp3';
    }
  }


  /// Reproduce el tema de la revelación final (WITNESS)
  Future<void> playWitnessTheme() async {
    await playBgm('assets/music/WITNESS_origin.mp3');
  }

  /// Detiene la música de fondo con fade-out suave
  Future<void> stopBgm({bool fadeOut = true}) async {
    print('🎵 [AudioProvider] SOLICITUD stopBgm (fadeOut: $fadeOut)');
    _fadeTimer?.cancel();
    
    if (!fadeOut || _bgmPlayer.volume <= 0) {
      await _bgmPlayer.stop();
      _currentBgm = null;
      print('🎵 [AudioProvider] BGM detenido inmediatamente.');
      return;
    }
    
    await _fadeOut();
    await _bgmPlayer.stop();
    _currentBgm = null;
    _shouldBePlaying = false;
    _watchdogTimer?.cancel();
    print('🎵 [AudioProvider] BGM detenido tras fade-out.');
  }

  void _fadeIn(double target) {
    _fadeTimer?.cancel();
    const int steps = 20;
    const int intervalMs = 50;
    final double increment = target / steps;
    double current = 0.0;

    _fadeTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      current += increment;
      if (current >= target) {
        current = target;
        timer.cancel();
        print('🎵 [AudioProvider] FADE-IN completado. Volumen final: ${current.toStringAsFixed(2)}');
      }
      _bgmPlayer.setVolume(current);
    });
  }

  Future<void> _fadeOut() async {
    _fadeTimer?.cancel();
    final double start = _bgmPlayer.volume;
    if (start <= 0.01) return;
    
    const int steps = 20;
    const int intervalMs = 30;
    final double decrement = start / steps;
    double current = start;

    final completer = Completer<void>();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      current -= decrement;
      if (current <= 0) {
        current = 0;
        timer.cancel();
        _bgmPlayer.setVolume(0);
        completer.complete();
      } else {
        _bgmPlayer.setVolume(current);
      }
    });
    return completer.future;
  }

  void _startWatchdog(String assetPath) {
    _watchdogTimer?.cancel();
    // Ejecutamos el perro guardián periódicamente para pelear contra el foco agresivo
    _watchdogTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_shouldBePlaying && !_bgmPlayer.playing && 
          _bgmPlayer.processingState == ja.ProcessingState.ready) {
        print('🛡️ [AudioProvider] WATCHDOG: Forzando reanudación de BGM ($assetPath)...');
        _bgmPlayer.play();
      }
      
      if (!_shouldBePlaying) timer.cancel();
    });
  }

  /// Sonido específico para clics de teclado (efecto hacker)
  void playKeyboardClick() {
    // Desactivado por petición del usuario
  }

  @override
  void dispose() {
    print('🗑️ [AudioProvider] Dispensing AudioProvider');
    _fadeTimer?.cancel();
    _watchdogTimer?.cancel();
    _settings.removeListener(_updateVolumes);
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }
}
