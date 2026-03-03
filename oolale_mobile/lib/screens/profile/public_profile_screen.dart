import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../portfolio/portfolio_screen.dart';
import '../messages/chat_screen.dart';
import '../ratings/view_ratings_screen.dart';
import 'profile_detail_lists.dart';

// Importar LeaveRatingScreen
import '../ratings/leave_rating_screen.dart';
import '../reports/report_content_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  List<dynamic> _instrumentos = [];
  List<String> _genres = [];
  int _eventosCount = 0;
  int _seguidoresCount = 0;
  int _musicCount = 0;
  int _ratingsCount = 0;
  bool _isLoading = true;
  String? _connectionStatus; // null, 'pending', 'accepted', 'rejected'
  bool _isBlocked = false;
  bool _hasInteracted = false; // Para verificar si han trabajado juntos o son conexiones

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      
      final data = await _supabase
          .from('perfiles')
          .select()
          .eq('id', widget.userId)
          .single();

      final gear = await _supabase
          .from('perfil_gear')
          .select('gear_catalog(nombre)')
          .eq('perfil_id', widget.userId);

      // Cargar géneros musicales
      final genresData = await _supabase
          .from('generos_perfil')
          .select('genre')
          .eq('profile_id', widget.userId);

      // Cargar contadores
      final eventosData = await _supabase
          .from('participantes_evento')
          .select()
          .eq('user_id', widget.userId);

      final seguidoresData = await _supabase
          .from('conexiones')
          .select()
          .eq('usuario_id', widget.userId)
          .eq('estatus', 'accepted');

      final musicData = await _supabase
          .from('perfil_gear')
          .select()
          .eq('perfil_id', widget.userId);

      // Verificar estado de conexión
      String? connectionStatus;
      bool isBlocked = false;
      bool hasInteracted = false;
      
      if (myId != null && myId != widget.userId) {
        // Verificar si hay conexión
        final connectionData = await _supabase
            .from('conexiones')
            .select()
            .or('and(usuario_id.eq.$myId,conectado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},conectado_id.eq.$myId)')
            .maybeSingle();
        
        if (connectionData != null) {
          connectionStatus = connectionData['estatus']; // 'pending', 'accepted', 'rejected'
          // Si son conexiones aceptadas, han interactuado
          if (connectionData['estatus'] == 'accepted') {
            hasInteracted = true;
          }
        }
        
        // También verificar si trabajaron juntos en eventos
        if (!hasInteracted) {
          final myGigsData = await _supabase
              .from('participantes_evento')
              .select('event_id')
              .eq('user_id', myId);

          if (myGigsData.isNotEmpty) {
            final gigIds = myGigsData.map((g) => g['event_id']).toList();

            final sharedGigs = await _supabase
                .from('participantes_evento')
                .select('event_id')
                .eq('user_id', widget.userId)
                .inFilter('event_id', gigIds);

            hasInteracted = sharedGigs.isNotEmpty;
          }
        }
        
        // Verificar si está bloqueado
        final blockData = await _supabase
            .from('usuarios_bloqueados')
            .select()
            .eq('usuario_id', myId)
            .eq('bloqueado_id', widget.userId)
            .eq('activo', true)
            .maybeSingle();
        
        isBlocked = blockData != null;
      }

      if (mounted) {
        setState(() {
          _profile = data;
          _instrumentos = gear;
          _genres = (genresData as List).map((g) => g['genre'].toString()).toList();
          _eventosCount = (eventosData as List).length;
          _seguidoresCount = (seguidoresData as List).length;
          _musicCount = (musicData as List).length;
          _ratingsCount = data['total_calificaciones'] ?? 0;
          _connectionStatus = connectionStatus;
          _isBlocked = isBlocked;
          _hasInteracted = hasInteracted;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando perfil público: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _shareProfile() {
    if (_profile == null) return;
    Share.share('¡Checa este perfil en Óolale! ${_profile!['nombre_artistico']} - https://oolale.app/${_profile!['slug_url'] ?? "u/${widget.userId}"}');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: IconThemeData(color: ThemeColors.icon(context))),
        body: Center(child: Text('Usuario no encontrado', style: TextStyle(color: ThemeColors.secondaryText(context)))),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  // Instrumento Principal
                  if (_profile?['instrumento_principal'] != null) ...[
                    _buildInstrumentCard(),
                    const SizedBox(height: 30),
                  ],
                  _buildSectionTitle('Bio'),
                  const SizedBox(height: 10),
                  _buildBioCard(),
                  const SizedBox(height: 30),
                  
                  // Géneros musicales
                  if (_genres.isNotEmpty) ...[
                    _buildSectionTitle('Géneros Musicales'),
                    const SizedBox(height: 10),
                    _buildGenresCard(),
                    const SizedBox(height: 30),
                  ],
                  
                  // Años de experiencia y tarifa
                  if (_profile?['years_experience'] != null && _profile!['years_experience'] > 0 ||
                      _profile?['base_rate'] != null && _profile!['base_rate'] > 0) ...[
                    _buildExperienceAndRateRow(),
                    const SizedBox(height: 30),
                  ],
                  
                  // Disponibilidad
                  if (_profile?['availability'] != null && 
                      _profile!['availability'].toString() != '{}') ...[
                    _buildSectionTitle('Disponibilidad'),
                    const SizedBox(height: 10),
                    _buildAvailabilityCard(),
                    const SizedBox(height: 30),
                  ],
                  
                  // Redes sociales
                  if (_profile?['social_links'] != null && 
                      _profile!['social_links'].toString() != '{}') ...[
                    _buildSectionTitle('Redes Sociales'),
                    const SizedBox(height: 10),
                    _buildSocialLinksCard(),
                    const SizedBox(height: 30),
                  ],
                  
                  _buildSectionTitle('Mi Equipo'),
                  const SizedBox(height: 10),
                  _buildGearSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppConstants.primaryColor.withOpacity(0.2),
                  Colors.black,
                ]
              : [
                  AppConstants.primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConstants.primaryColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppConstants.bgDarkAlt,
                      backgroundImage: _profile!['foto_perfil'] != null ? NetworkImage(_profile!['foto_perfil']) : null,
                      child: _profile!['foto_perfil'] == null 
                        ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _profile!['nombre_artistico'] ?? 'Artista',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_profile!['verificado'] == true) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: AppConstants.primaryColor, size: 24),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Ubicación
                  if (_profile?['ubicacion'] != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: ThemeColors.secondaryText(context)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _profile!['ubicacion'],
                              style: GoogleFonts.outfit(
                                color: ThemeColors.secondaryText(context),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Calificación
                  if (_profile?['rating_promedio'] != null && _profile!['rating_promedio'] > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          final rating = _profile!['rating_promedio'] ?? 0.0;
                          return Icon(
                            index < rating.floor() ? Icons.star : Icons.star_border,
                            color: AppConstants.primaryColor,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${_profile!['rating_promedio'].toStringAsFixed(1)} (${_profile!['total_calificaciones'] ?? 0})',
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Badges
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_profile?['open_to_work'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.work_outline, size: 12, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Disponible',
                                style: GoogleFonts.outfit(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_profile?['ranking_tipo'] == 'premium') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.black),
                              const SizedBox(width: 4),
                              Text(
                                'PREMIUM',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ThemeColors.divider(context).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(
            _eventosCount.toString(), 'Eventos',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEventsScreen(userId: widget.userId))),
          ),
          _buildStatDivider(),
          _buildStat(
            _seguidoresCount.toString(), 'Seguidores',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileFollowersScreen(userId: widget.userId))),
          ),
          _buildStatDivider(),
          _buildStat(
            _musicCount.toString(), 'Equipo',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileGearScreen(userId: widget.userId))),
          ),
          _buildStatDivider(),
          _buildStat(
            _ratingsCount.toString(), 'Ratings',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewRatingsScreen(
                  userId: widget.userId,
                  userName: _profile!['nombre_artistico'] ?? 'Artista',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: ThemeColors.divider(context).withOpacity(0.08),
    );
  }

  Widget _buildStat(String value, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ThemeColors.primaryText(context),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context).withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    if (widget.userId == myId) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _shareProfile(),
          icon: const Icon(Icons.share_outlined),
          label: const Text('Compartir mi perfil'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: AppConstants.primaryColor),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
  
    if (_isBlocked) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Usuario bloqueado',
                  style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Botón para desbloquear
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showUnblockDialog,
              icon: const Icon(Icons.lock_open, size: 18),
              label: const Text('Desbloquear Usuario'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: BorderSide(color: AppConstants.primaryColor.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }
  
    return Column(
      children: [
        Row(
          children: [
            // Botón de Conectar/Mensaje
            Expanded(
              flex: 2,
              child: _buildConnectionButton(),
            ),
            const SizedBox(width: 12),
            // Botón de Galería
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/portfolio/${widget.userId}'),
                icon: const Icon(Icons.collections_outlined, size: 18),
                label: const Text('Galería', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppConstants.bgDarkAlt),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Botón de Calificar (solo visible si han interactuado)
        if (widget.userId != myId && _hasInteracted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeaveRatingScreen(
                      userId: widget.userId,
                      userName: _profile!['nombre_artistico'] ?? 'Artista',
                    ),
                  ),
                );
                if (result == true) {
                  _loadProfile(); // Recargar perfil para actualizar rating
                }
              },
              icon: const Icon(Icons.star_outline, size: 18),
              label: const Text('Dejar Calificación', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                foregroundColor: AppConstants.primaryColor,
                side: BorderSide(color: AppConstants.primaryColor.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (widget.userId != myId && _hasInteracted) const SizedBox(height: 12),
        // Botón de Bloquear (Reportar removido - no puedes reportar tu propio perfil)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showBlockDialog,
            icon: const Icon(Icons.block_outlined, size: 18),
            label: const Text('Bloquear', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionButton() {
    if (_connectionStatus == 'accepted') {
      // Ya son conexiones - Puede mensajear
      return ElevatedButton.icon(
        onPressed: () => context.push('/messages/${widget.userId}', extra: _profile!['nombre_artistico'] ?? 'Artista'),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Mensaje'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (_connectionStatus == 'pending') {
      // Solicitud pendiente
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty, size: 18),
        label: const Text('Solicitud enviada'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey,
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      // No hay conexión - Enviar solicitud
      return ElevatedButton.icon(
        onPressed: _sendConnectionRequest,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Conectar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _sendConnectionRequest() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      // Verificar si hay bloqueo (en cualquier dirección)
      final blockData = await _supabase
          .from('usuarios_bloqueados')
          .select()
          .or('and(usuario_id.eq.$myId,bloqueado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},bloqueado_id.eq.$myId)')
          .eq('activo', true)
          .maybeSingle();

      if (blockData != null) {
        // Hay un bloqueo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No puedes conectar con este usuario', style: GoogleFonts.outfit()),
              backgroundColor: Colors.red[700],
            ),
          );
        }
        return;
      }

      await _supabase.from('conexiones').insert({
        'usuario_id': myId,
        'conectado_id': widget.userId,
        'estatus': 'pending',
      });

      // Crear notificación para el receptor
      try {
        final myProfile = await _supabase
            .from('perfiles')
            .select('nombre_artistico')
            .eq('id', myId)
            .single();

        await _supabase.from('notificaciones').insert({
          'user_id': widget.userId,
          'tipo': 'connection_request',
          'titulo': 'Nueva solicitud de conexión',
          'mensaje': '${myProfile['nombre_artistico']} quiere conectar contigo',
          'leido': false,
          'data': {'sender_id': myId},
        });
      } catch (e) {
        debugPrint('Error enviando notificación: $e');
      }

      if (mounted) {
        setState(() => _connectionStatus = 'pending');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Solicitud enviada', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error enviando solicitud: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar solicitud', style: GoogleFonts.outfit()),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _showBlockDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: Text('Bloquear usuario', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro que quieres bloquear a ${_profile!['nombre_artistico']}? No podrás ver su contenido ni recibir mensajes.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Bloquear', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _blockUser();
    }
  }

  Future<void> _showUnblockDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: Text('Desbloquear usuario', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro que quieres desbloquear a ${_profile!['nombre_artistico']}? Podrás ver su contenido y recibir mensajes nuevamente.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
            ),
            child: Text('Desbloquear', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _unblockUser();
    }
  }

  Future<void> _unblockUser() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      // Eliminar el bloqueo (marcar como inactivo)
      await _supabase
          .from('usuarios_bloqueados')
          .update({
            'activo': false,
            'desbloqueado_en': DateTime.now().toIso8601String(),
          })
          .eq('usuario_id', myId)
          .eq('bloqueado_id', widget.userId);

      if (mounted) {
        setState(() => _isBlocked = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Usuario desbloqueado', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Recargar perfil para actualizar estado
        _loadProfile();
      }
    } catch (e) {
      debugPrint('Error desbloqueando usuario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desbloquear usuario', style: GoogleFonts.outfit()),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _blockUser() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      debugPrint('🚫 Bloqueando usuario: ${widget.userId}');
      
      // 1. Crear el bloqueo
      await _supabase.from('usuarios_bloqueados').insert({
        'usuario_id': myId,
        'bloqueado_id': widget.userId,
        'motivo_bloqueo': 'manual',
        'activo': true,
      });

      // 2. Eliminar conexión existente (si existe) - en ambas direcciones
      await _supabase
          .from('conexiones')
          .delete()
          .or('and(usuario_id.eq.$myId,conectado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},conectado_id.eq.$myId)');

      debugPrint('✅ Usuario bloqueado exitosamente');

      if (mounted) {
        setState(() {
          _isBlocked = true;
          _connectionStatus = null; // Resetear estado de conexión
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.block, color: Colors.white),
                const SizedBox(width: 12),
                Text('Usuario bloqueado', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error bloqueando usuario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al bloquear usuario', style: GoogleFonts.outfit()),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: ThemeColors.primaryText(context),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInstrumentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              color: AppConstants.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instrumento Principal',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: ThemeColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile!['instrumento_principal'],
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Text(
        _profile!['bio'] ?? 'Sin biografía.',
        style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 15, height: 1.6),
      ),
    );
  }

  Widget _buildGenresCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _genres.map((genre) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.primaryColor),
            ),
            child: Text(
              genre,
              style: GoogleFonts.outfit(
                color: AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperienceAndRateRow() {
    final yearsExp = _profile?['years_experience'] ?? 0;
    final baseRate = _profile?['base_rate'] ?? 0.0;
    final currency = _profile?['currency'] ?? 'MXN';
    
    return Row(
      children: [
        if (yearsExp > 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work_outline, color: AppConstants.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Experiencia',
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$yearsExp ${yearsExp == 1 ? 'año' : 'años'}',
                    style: GoogleFonts.outfit(
                      color: ThemeColors.primaryText(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (yearsExp > 0 && baseRate > 0) const SizedBox(width: 12),
        if (baseRate > 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: AppConstants.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tarifa Base',
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$$baseRate $currency',
                    style: GoogleFonts.outfit(
                      color: ThemeColors.primaryText(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    final availability = _profile?['availability'] as Map<String, dynamic>?;
    if (availability == null || availability.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            'Sin disponibilidad configurada',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
          ),
        ),
      );
    }

    final days = {
      'lunes': 'Lun',
      'martes': 'Mar',
      'miercoles': 'Mié',
      'jueves': 'Jue',
      'viernes': 'Vie',
      'sabado': 'Sáb',
      'domingo': 'Dom',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: days.entries.map((entry) {
          final isAvailable = availability[entry.key] == true;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isAvailable 
                  ? AppConstants.primaryColor.withOpacity(0.2) 
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAvailable 
                    ? AppConstants.primaryColor 
                    : Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Text(
              entry.value,
              style: GoogleFonts.outfit(
                color: isAvailable 
                    ? AppConstants.primaryColor 
                    : ThemeColors.secondaryText(context),
                fontSize: 12,
                fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSocialLinksCard() {
    final socialLinks = _profile?['social_links'] as Map<String, dynamic>?;
    if (socialLinks == null || socialLinks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            'Sin redes sociales configuradas',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
          ),
        ),
      );
    }

    final platforms = {
      'instagram': {'icon': Icons.camera_alt, 'label': 'Instagram'},
      'youtube': {'icon': Icons.play_circle_outline, 'label': 'YouTube'},
      'spotify': {'icon': Icons.music_note, 'label': 'Spotify'},
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: platforms.entries.where((entry) {
          return socialLinks.containsKey(entry.key) && 
                 socialLinks[entry.key] != null && 
                 socialLinks[entry.key].toString().isNotEmpty;
        }).map((entry) {
          final url = socialLinks[entry.key].toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                debugPrint('Opening: $url');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.value['icon'] as IconData,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value['label'] as String,
                            style: GoogleFonts.outfit(
                              color: ThemeColors.primaryText(context),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            url,
                            style: GoogleFonts.outfit(
                              color: ThemeColors.secondaryText(context),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: ThemeColors.iconSecondary(context),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGearSection() {
    if (_instrumentos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            'No ha agregado equipo',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _instrumentos.map((i) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            i['gear_catalog']['nombre'],
            style: GoogleFonts.outfit(
              color: ThemeColors.primaryText(context),
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: GoogleFonts.outfit(color: AppConstants.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
