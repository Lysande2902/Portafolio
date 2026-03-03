import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import 'edit_profile_screen.dart';
import 'profile_detail_lists.dart';
import '../messages/chat_screen.dart';
import '../ratings/view_ratings_screen.dart';
import '../ratings/leave_rating_screen.dart';

class UnifiedProfileScreen extends StatefulWidget {
  final String userId;
  const UnifiedProfileScreen({super.key, required this.userId});

  @override
  State<UnifiedProfileScreen> createState() => _UnifiedProfileScreenState();
}

class _UnifiedProfileScreenState extends State<UnifiedProfileScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profileData;
  List<dynamic> _instrumentos = [];
  List<String> _genres = [];
  int _eventosCount = 0;
  int _seguidoresCount = 0;
  int _musicCount = 0;
  int _ratingsCount = 0;
  bool _isLoading = true;
  String? _connectionStatus;
  bool _isBlocked = false;
  bool _isMyProfile = false;
  bool _hasInteracted = false; // Para verificar si han trabajado juntos o son conexiones
  
  // Para actualización en tiempo real
  RealtimeChannel? _connectionChannel;
  RealtimeChannel? _profileChannel;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _setupRealtimeListener();
  }
  
  @override
  void dispose() {
    _connectionChannel?.unsubscribe();
    _profileChannel?.unsubscribe();
    super.dispose();
  }
  
  // Configurar listener de Realtime para actualizar contador de seguidores y perfil
  void _setupRealtimeListener() {
    // 1. Escuchar cambios en conexiones
    _connectionChannel = _supabase
        .channel('connections:${widget.userId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conexiones',
          callback: (payload) {
            debugPrint('🔄 Cambio en conexiones detectado, recargando...');
            _loadProfile();
          },
        )
        .subscribe();

    // 2. Escuchar cambios en el perfil mismo
    _profileChannel = _supabase
        .channel('profile:${widget.userId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'perfiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.userId,
          ),
          callback: (payload) {
            debugPrint('🔄 Cambio en perfil detectado, recargando datos...');
            _loadProfile();
          },
        )
        .subscribe();
  }
  
  // Recargar solo el contador de seguidores
  Future<void> _reloadFollowersCount() async {
    try {
      // Contar conexiones donde este usuario es el usuario_id
      // (en sistema bidireccional, estas son sus conexiones/seguidores)
      final seguidoresData = await _supabase
          .from('conexiones')
          .select()
          .eq('usuario_id', widget.userId)
          .eq('estatus', 'accepted');
      
      if (mounted) {
        setState(() {
          _seguidoresCount = (seguidoresData as List).length;
        });
        debugPrint('✅ Contador actualizado: $_seguidoresCount seguidores');
      }
    } catch (e) {
      debugPrint('❌ Error recargando contador de seguidores: $e');
    }
  }

  Future<void> _loadProfile() async {
    final myId = _supabase.auth.currentUser?.id;
    _isMyProfile = (myId == widget.userId);

    debugPrint('🔍 LOAD PROFILE: Starting for userId=${widget.userId}, isMyProfile=$_isMyProfile');

    try {
      final profile = await _supabase
          .from('perfiles')
          .select()
          .eq('id', widget.userId)
          .maybeSingle();

      debugPrint('🔍 LOAD PROFILE: Profile data received: $profile');

      if (profile == null) {
        debugPrint('❌ LOAD PROFILE: Profile is NULL');
        if (mounted) setState(() { _profileData = null; _isLoading = false; });
        return;
      }

      debugPrint('✅ LOAD PROFILE: Profile found');
      debugPrint('   - nombre_artistico: ${profile['nombre_artistico']}');
      final bioLength = profile['bio']?.toString().length ?? 0;
      final bioPreview = bioLength > 50 ? profile['bio']?.toString().substring(0, 50) : profile['bio']?.toString() ?? '';
      debugPrint('   - bio: $bioPreview...');
      debugPrint('   - ubicacion: ${profile['ubicacion']}');
      debugPrint('   - instrumento_principal: ${profile['instrumento_principal']}');
      debugPrint('   - foto_perfil: ${profile['foto_perfil']}');

      final gear = await _supabase
          .from('perfil_gear')
          .select('gear_catalog(nombre)')
          .eq('perfil_id', widget.userId);

      // Cargar géneros musicales
      final genresData = await _supabase
          .from('generos_perfil')
          .select('genre')
          .eq('profile_id', widget.userId);

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

      String? connectionStatus;
      bool isBlocked = false;
      bool hasInteracted = false;

      if (myId != null && !_isMyProfile) {
        final connectionData = await _supabase
            .from('conexiones')
            .select()
            .or('and(usuario_id.eq.$myId,conectado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},conectado_id.eq.$myId)')
            .limit(1)
            .maybeSingle();
        
        if (connectionData != null) {
          connectionStatus = connectionData['estatus'];
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
        
        final blockData = await _supabase
            .from('usuarios_bloqueados')
            .select()
            .eq('usuario_id', myId)
            .eq('bloqueado_id', widget.userId)
            .eq('activo', true)
            .limit(1)
            .maybeSingle();
        
        isBlocked = blockData != null;
      }

      debugPrint('✅ LOAD PROFILE: Setting state with data');
      debugPrint('   - instrumentos count: ${gear.length}');
      debugPrint('   - eventos count: ${(eventosData as List).length}');
      debugPrint('   - seguidores count: ${(seguidoresData as List).length}');
      debugPrint('   - music count: ${(musicData as List).length}');
      debugPrint('   - ratings count: ${profile['total_calificaciones'] ?? 0}');

      if (mounted) {
        setState(() {
          _profileData = profile;
          _instrumentos = gear;
          _genres = (genresData as List).map((g) => g['genre'].toString()).toList();
          _eventosCount = (eventosData as List).length;
          _seguidoresCount = (seguidoresData as List).length;
          _musicCount = (musicData as List).length;
          _ratingsCount = profile['total_calificaciones'] ?? 0;
          _connectionStatus = connectionStatus;
          _isBlocked = isBlocked;
          _hasInteracted = hasInteracted;
          _isLoading = false;
        });
        debugPrint('✅ LOAD PROFILE: State updated successfully');
        debugPrint('   - hasInteracted: $hasInteracted');
      }
    } catch (e) {
      ErrorHandler.logError('UnifiedProfileScreen._loadProfile', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando perfil',
          onRetry: _loadProfile,
        );
      }
    }
  }

  void _shareProfile() {
    if (_profileData == null) return;
    final slug = _profileData!['slug_url'] ?? "u/${widget.userId}";
    final text = _isMyProfile 
        ? '¡Checa mi perfil en Óolale! ${_profileData!['nombre_artistico']} - https://oolale.app/$slug'
        : '¡Checa este perfil en Óolale! ${_profileData!['nombre_artistico']} - https://oolale.app/$slug';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: ThemeColors.icon(context)),
        ),
        body: Center(
          child: Text(
            'Usuario no encontrado',
            style: TextStyle(color: ThemeColors.secondaryText(context)),
          ),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 10),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  if (_profileData?['instrumento_principal'] != null) ...[
                    _buildInstrumentCard(),
                    const SizedBox(height: 30),
                  ],
                  _buildSectionTitle('Bio'),
                  const SizedBox(height: 12),
                  _buildBioCard(),
                  const SizedBox(height: 30),
                  
                  if (_genres.isNotEmpty) ...[
                    _buildSectionTitle('Géneros Musicales'),
                    const SizedBox(height: 12),
                    _buildGenresCard(),
                    const SizedBox(height: 30),
                  ],
                  
                  if (_isMyProfile) ...[
                    _buildPortfolioButton(),
                  ],
                  
                  const SizedBox(height: 20),
                  _buildSectionTitle('Mi Equipo'),
                  const SizedBox(height: 12),
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
    debugPrint('🎨 RENDER: Building header');
    debugPrint('   - nombre_artistico: ${_profileData?['nombre_artistico']}');
    debugPrint('   - foto_perfil: ${_profileData?['foto_perfil']}');
    debugPrint('   - ubicacion: ${_profileData?['ubicacion']}');
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      // Se usa minHeight para permitir que el header crezca si el tamaño de fuente es grande
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppConstants.primaryColor.withOpacity(0.15),
                  Theme.of(context).scaffoldBackgroundColor,
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
            if (!_isMyProfile) ...[
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: ThemeColors.icon(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Theme.of(context).cardColor,
                    onSelected: (value) {
                      if (value == 'report') {
                        context.push('/create-report', extra: {
                          'reportedUserId': widget.userId,
                          'reportedUserName': _profileData?['nombre_artistico'] ?? 'Usuario',
                        });
                      } else if (value == 'block') {
                        _showBlockConfirmDialog();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, color: ThemeColors.icon(context), size: 20),
                            const SizedBox(width: 12),
                            Text('Reportar usuario', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context))),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            const Icon(Icons.block, color: Colors.red, size: 20),
                            const SizedBox(width: 12),
                            Text('Bloquear usuario', style: GoogleFonts.outfit(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_isMyProfile)
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : Colors.black),
                    onPressed: () => context.push('/settings'),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Permite que la columna se ajuste a su contenido
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  FadeInDown(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppConstants.primaryColor,
                          width: _isMyProfile ? 3 : 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: _profileData?['foto_perfil'] != null 
                            ? NetworkImage(_profileData!['foto_perfil']) 
                            : null,
                        child: _profileData?['foto_perfil'] == null
                            ? Icon(Icons.person, size: 60, color: ThemeColors.iconSecondary(context))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _profileData?['nombre_artistico'] ?? 'Artista',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.primaryText(context),
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                          if (_profileData?['verificado'] == true) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: AppConstants.primaryColor, size: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_profileData?['ubicacion'] != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: ThemeColors.secondaryText(context)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _profileData!['ubicacion'],
                              style: GoogleFonts.outfit(
                                color: ThemeColors.secondaryText(context),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_profileData?['rating_promedio'] != null && _profileData!['rating_promedio'] > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          final rating = _profileData!['rating_promedio'] ?? 0.0;
                          // FIX: Prevenir error NaN/Infinity con rating 0
                          final floorRating = rating > 0 ? rating.floor() : 0;
                          return Icon(
                            index < floorRating ? Icons.star : Icons.star_border,
                            color: AppConstants.primaryColor,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${_profileData!['rating_promedio'].toStringAsFixed(1)} (${_profileData!['total_calificaciones'] ?? 0})',
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_profileData?['open_to_work'] == true)
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
                      if (_profileData?['ranking_tipo'] == 'premium') ...[
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
                  userName: _profileData!['nombre_artistico'] ?? 'Artista',
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
              // Eliminamos maxLines: 1 para permitir que la etiqueta se ajuste si la fuente es muy grande
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isMyProfile) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                debugPrint('🔄 EDIT: Opening edit screen');
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                debugPrint('🔄 EDIT: Returned from edit screen, reloading profile...');
                _loadProfile();
              },
              icon: const Icon(Icons.edit_outlined),
              label: Text('Editar Perfil', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.divider(context)),
            ),
            child: IconButton(
              onPressed: () => context.push('/profile/${widget.userId}'),
              icon: Icon(Icons.remove_red_eye_outlined, color: ThemeColors.icon(context)),
              tooltip: 'Ver mi perfil público',
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.divider(context)),
            ),
            child: IconButton(
              onPressed: _shareProfile,
              icon: Icon(Icons.share_outlined, color: ThemeColors.icon(context)),
              tooltip: 'Compartir perfil',
            ),
          ),
        ],
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
            Expanded(
              flex: 2,
              child: _buildConnectionButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/portfolio/${widget.userId}'),
                icon: const Icon(Icons.collections_outlined, size: 18),
                label: const Text('Galería', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.primaryText(context),
                  side: BorderSide(color: ThemeColors.divider(context)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Solo mostrar botón de calificación si han interactuado
        if (_hasInteracted) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeaveRatingScreen(
                      userId: widget.userId,
                      userName: _profileData!['nombre_artistico'] ?? 'Artista',
                    ),
                  ),
                );
                if (result == true) {
                  _loadProfile();
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
          const SizedBox(height: 12),
        ],
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
      return ElevatedButton.icon(
        onPressed: () => context.push('/messages/${widget.userId}', extra: _profileData!['nombre_artistico'] ?? 'Artista'),
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
      final blockData = await _supabase
          .from('usuarios_bloqueados')
          .select()
          .or('and(usuario_id.eq.$myId,bloqueado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},bloqueado_id.eq.$myId)')
          .eq('activo', true)
          .maybeSingle();

      if (blockData != null) {
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
        title: Text('Bloquear usuario', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro que quieres bloquear a ${_profileData!['nombre_artistico']}? No podrás ver su contenido ni recibir mensajes.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
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

  Future<void> _showBlockConfirmDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Bloquear Usuario', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ThemeColors.primaryText(context))),
        content: Text(
          '¿Seguro que quieres bloquear a este usuario? No podrán ver tu perfil ni enviarte mensajes.',
          style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Bloquear', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
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
        title: Text('Desbloquear usuario', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro que quieres desbloquear a ${_profileData!['nombre_artistico']}? Podrás ver su contenido y recibir mensajes nuevamente.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Desbloquear', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _unblockUser();
    }
  }

  Future<void> _blockUser() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      await _supabase.from('usuarios_bloqueados').insert({
        'usuario_id': myId,
        'bloqueado_id': widget.userId,
        'motivo_bloqueo': 'manual',
        'activo': true,
      });

      await _supabase
          .from('conexiones')
          .delete()
          .or('and(usuario_id.eq.$myId,conectado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},conectado_id.eq.$myId)');

      if (mounted) {
        setState(() {
          _isBlocked = true;
          _connectionStatus = null;
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
      debugPrint('Error bloqueando usuario: $e');
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

  Future<void> _unblockUser() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: ThemeColors.primaryText(context),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInstrumentCard() {
    debugPrint('🎨 RENDER: Building instrument card');
    debugPrint('   - instrumento_principal: ${_profileData!['instrumento_principal']}');
    
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
        mainAxisSize: MainAxisSize.min,
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
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _profileData!['instrumento_principal'],
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryText(context),
                  ),
                  // Permitir que el nombre del instrumento se ajuste sin desbordar
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    final bioText = _profileData?['bio'] ?? (_isMyProfile 
        ? 'Sin biografía. Cuéntale al mundo quién eres.' 
        : 'Sin biografía.');
    
    debugPrint('🎨 RENDER: Building bio card');
    debugPrint('   - bio from data: ${_profileData?['bio']}');
    debugPrint('   - bio to display: $bioText');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.divider(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        bioText,
        style: GoogleFonts.outfit(
          color: ThemeColors.secondaryText(context),
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildGenresCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.divider(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _genres.map((genre) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              genre,
              style: GoogleFonts.outfit(
                color: AppConstants.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
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
          border: Border.all(color: ThemeColors.divider(context)),
        ),
        child: Center(
          child: Text(
            _isMyProfile ? 'No has agregado equipo aún' : 'No ha agregado equipo',
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.divider(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: AppConstants.primaryColor, size: 14),
              const SizedBox(width: 8),
              Text(
                i['gear_catalog']['nombre'],
                style: GoogleFonts.outfit(
                  color: ThemeColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceAndRateRow() {
    final yearsExp = _profileData?['years_experience'] ?? 0;
    final baseRate = _profileData?['base_rate'] ?? 0.0;
    final currency = _profileData?['currency'] ?? 'MXN';
    
    return Row(
      children: [
        if (yearsExp > 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline, color: AppConstants.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Experiencia',
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$yearsExp ${yearsExp == 1 ? 'año' : 'años'}',
                    style: GoogleFonts.outfit(
                      color: ThemeColors.primaryText(context),
                      fontSize: 14,
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
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money, color: AppConstants.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Tarifa Base',
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    final availability = _profileData?['availability'] as Map<String, dynamic>?;
    if (availability == null || availability.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.divider(context)),
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
        border: Border.all(color: ThemeColors.divider(context)),
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
                    : ThemeColors.divider(context),
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
    final socialLinks = _profileData?['social_links'] as Map<String, dynamic>?;
    if (socialLinks == null || socialLinks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.divider(context)),
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
        border: Border.all(color: ThemeColors.divider(context)),
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
                // Aquí podrías abrir el URL con url_launcher
                debugPrint('Opening: $url');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.divider(context)),
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

  Widget _buildPortfolioButton() {
    return GestureDetector(
      onTap: () => context.push('/portfolio/${widget.userId}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor.withOpacity(0.2),
              AppConstants.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                Icons.photo_library_outlined,
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
                    'Mi Galería',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sube imágenes, videos y audios',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: ThemeColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.primaryColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
