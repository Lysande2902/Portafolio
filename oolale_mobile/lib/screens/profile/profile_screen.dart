import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/profile.dart';
import '../../config/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  Perfil? _profile;

  List<dynamic> _instrumentos = [];
  List<dynamic> _generos = [];
  List<dynamic> _muestras = [];
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      // 1. Load Profile
      try {
        final profileData = await _api.get('/perfiles/usuario/${user.id}');
        _profile = Perfil.fromJson(profileData);
      } catch (e) {
        print('Profile not found: $e');
      }

      if (_profile != null) {
        // 2. Load Instruments
        try {
          final instData = await _api.get('/perfiles/${_profile!.id}/instrumentos');
          if (instData is List) _instrumentos = instData;
        } catch (e) { print('Error loading instruments: $e'); }

        // 3. Load Genres
        try {
          final genData = await _api.get('/perfiles/${_profile!.id}/generos');
          if (genData is List) _generos = genData;
        } catch (e) { print('Error loading genres: $e'); }
      }

      // 4. Load Samples (User's samples)
      try {
        final samplesData = await _api.get('/muestras/mis-muestras');
        if (samplesData is List) _muestras = samplesData;
      } catch (e) { print('Error loading samples: $e'); }
      
      // 5. Load Reviews
      if (_profile != null) {
        try {
          final reviewsData = await _api.get('/referencias/usuario/${_profile!.id}');
          if (reviewsData is List) _reviews = reviewsData;
        } catch (e) { print('Error loading reviews: $e'); }
      }

      setState(() => _isLoading = false);

    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.7, -0.6),
            radius: 1.2,
            colors: [
              AppConstants.primaryColor.withOpacity(0.08),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Custom App Bar for Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Text(
                      'MI PERFIL',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                      onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Premium Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppConstants.primaryColor, AppConstants.accentColor],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppConstants.primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: AppConstants.backgroundColor,
                              child: Text(
                                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                style: GoogleFonts.outfit(
                                  color: AppConstants.primaryColor,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _profile?.nombreArtistico ?? user?.name ?? 'Usuario',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white, 
                          fontSize: 26, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_rounded, size: 16, color: AppConstants.primaryColor.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Text(
                            _profile?.ubicacion ?? 'Ubicación no disponible',
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppConstants.accentColor.withOpacity(0.2), Colors.transparent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppConstants.accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          _profile?.nivelExperiencia.toUpperCase() ?? 'TALENTO EMERGENTE',
                          style: GoogleFonts.outfit(
                            color: AppConstants.accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Bio Section with Premium Design
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_edu_rounded, color: AppConstants.primaryColor, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'BIOGRAFÍA',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profile?.bio ?? 'Sin biografía disponible. ¡Cuéntanos tu historia musical!',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Instruments
              _buildSectionHeader('Mis Instrumentos', Icons.music_note),
              const SizedBox(height: 10),
              _instrumentos.isEmpty
                  ? const Text('No has agregado instrumentos', style: TextStyle(color: Colors.white38))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _instrumentos.map((i) => _buildTag(i['nombre'] ?? 'Instrumento')).toList(),
                    ),
              
              const SizedBox(height: 25),

              // Genres
              _buildSectionHeader('Géneros Favoritos', Icons.album),
              const SizedBox(height: 10),
              _generos.isEmpty
                  ? const Text('No has agregado géneros', style: TextStyle(color: Colors.white38))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _generos.map((g) => _buildTag(g['nombre'] ?? 'Género')).toList(),
                    ),

              const SizedBox(height: 25),

              // Audio Samples
              _buildSectionHeader('Mis Muestras', Icons.graphic_eq),
              const SizedBox(height: 10),
              _muestras.isEmpty
                  ? const Text('No has subido muestras aún', style: TextStyle(color: Colors.white38))
                  : Column(children: _muestras.map((m) => _buildSampleCard(m)).toList()),

              const SizedBox(height: 25),
              _buildReviewsSection(), // Call it here
              
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                     final result = await Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => EditProfileScreen(profile: _profile)),
                     );
                     if (result == true) {
                       _loadAllData();
                     }
                  },
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.black),
                  label: Text(
                    'PERSONALIZAR PERFIL',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          ),
        ),
      ),
    );
  }

  // Updated _buildReviewsSection
  Widget _buildReviewsSection() {
    if (_reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildSectionHeader('Referencias & Valoraciones', Icons.star),
           const SizedBox(height: 10),
           const Text('Aún no tienes valoraciones.', style: TextStyle(color: Colors.white38)),
        ],
      );
    }

    // Calculate average
    double average = 0;
    if (_reviews.isNotEmpty) {
      final num sum = _reviews.fold(0, (sum, item) => sum + (item['calificacion'] ?? 0));
      average = sum / _reviews.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         _buildSectionHeader('Referencias & Valoraciones', Icons.star),
         const SizedBox(height: 10),
         Card(
           color: AppConstants.cardColor,
           child: Padding(
             padding: const EdgeInsets.all(20),
             child: Column(
               children: [
                 Text(average.toStringAsFixed(1), style: const TextStyle(color: AppConstants.accentColor, fontSize: 40, fontWeight: FontWeight.bold)), // Usage of accentColor (Amber) for stars/rating
                 const Text('Valoración General', style: TextStyle(color: Colors.white70)),
                 Text('Basado en ${_reviews.length} valoraciones', style: const TextStyle(color: Colors.white38, fontSize: 12)),
               ],
             ),
           ),
         ),
         const SizedBox(height: 10),
         ..._reviews.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: const Border(left: BorderSide(color: AppConstants.accentColor, width: 3))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r['nombre_evaluador'] ?? 'Usuario', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Row(children: List.generate(5, (i) => Icon(
                       i < (r['calificacion'] ?? 0) ? Icons.star : Icons.star_border,
                       color: AppConstants.accentColor, size: 16
                    ))),
                  ],
                ),
                const SizedBox(height: 5),
                if(r['comentario'] != null) Text(r['comentario'], style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text(
                   r['fecha_creacion'] != null 
                     ? r['fecha_creacion'].toString().split('T')[0] 
                     : '', 
                   style: const TextStyle(color: Colors.white24, fontSize: 10)
                ),
              ],
             ),
          ))
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _buildSampleCard(dynamic sample) {
    return SamplePlayerCard(sample: sample);
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              value.toUpperCase(), 
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(color: Colors.white70, height: 1.5)),
      ],
    );
  }
}

class SamplePlayerCard extends StatefulWidget {
  final dynamic sample;
  const SamplePlayerCard({super.key, required this.sample});

  @override
  State<SamplePlayerCard> createState() => _SamplePlayerCardState();
}

class _SamplePlayerCardState extends State<SamplePlayerCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isVideo = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkFileType();
    
    // Audio listeners
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if(mounted && !_isVideo) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if(mounted && !_isVideo) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if(mounted && !_isVideo) setState(() => _position = p);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      if(mounted && !_isVideo) {
        setState(() {
         _isPlaying = false;
         _position = Duration.zero;
      });
      }
    });
  }

  void _checkFileType() {
    final url = widget.sample['archivo_url'] ?? widget.sample['url'];
    if (url != null) {
      final String lowerUrl = url.toString().toLowerCase();
      if (lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.mov') || lowerUrl.endsWith('.avi')) {
         _isVideo = true;
         _initializeVideo(url);
      }
    }
  }

  Future<void> _initializeVideo(String url) async {
      String finalUrl = url;
      if (!url.startsWith('http')) {
         final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
         finalUrl = '$baseUrl$url'; 
      }
      
      _videoController = VideoPlayerController.networkUrl(Uri.parse(finalUrl));
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
      );
      
      if(mounted) setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioPlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      String? url = widget.sample['archivo_url'] ?? widget.sample['url'];
      if (url != null) {
         if (!url.startsWith('http')) {
             final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
             url = '$baseUrl$url'; 
         }
         try {
            await _audioPlayer.play(UrlSource(url));
         } catch(e) {
            if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al reproducir audio')));
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      if (!_isInitialized) {
         return Container(
           height: 200, 
           margin: const EdgeInsets.only(bottom: 10),
           decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
           child: const Center(child: CircularProgressIndicator())
         );
      }
      return Container(
        height: 220,
        margin: const EdgeInsets.only(bottom: 15),
        child: ClipRRect(
           borderRadius: BorderRadius.circular(12),
           child: Chewie(controller: _chewieController!),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _toggleAudioPlay,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, 
                    color: AppConstants.primaryColor
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sample['titulo'] ?? 'Audio Clip',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.sample['duracion'] ?? '0:00',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white24, size: 20),
                onPressed: () {},
              )
            ],
          ),
          if (_isPlaying || _position > Duration.zero)
            Slider(
              activeColor: AppConstants.primaryColor,
              inactiveColor: Colors.white10,
              min: 0,
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 100,
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 100),
              onChanged: (v) async {
                await _audioPlayer.seek(Duration(seconds: v.toInt()));
              },
            )
        ],
      ),
    );
  }
}
