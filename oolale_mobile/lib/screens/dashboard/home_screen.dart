import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../models/post.dart';
import 'package:intl/intl.dart';
import '../events/events_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/unified_profile_screen.dart';
import '../reports/report_content_screen.dart';
import '../../utils/error_handler.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _StreamView(onTabChange: (i) => setState(() => _currentIndex = i)),
      const UserSearchScreen(), 
      const EventsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Colors.white,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: screens),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor, 
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0)
          ],
        ),
      ),
      child: Center(
        child: Container(
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 20), // Un poco más ancho
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: isDark ? AppConstants.primaryColor.withOpacity(0.1) : AppConstants.borderLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarIcon(Icons.home_filled, 0, _currentIndex, (i) => setState(() => _currentIndex = i)),
              _NavBarIcon(Icons.search, 1, _currentIndex, (i) => setState(() => _currentIndex = i)),
              _AppLogoButton(onTap: () => setState(() => _currentIndex = 2)),
              _NavBarIcon(Icons.airplane_ticket_outlined, 2, _currentIndex, (i) => setState(() => _currentIndex = i)),
              _NavBarIcon(Icons.person_outline, 3, _currentIndex, (i) => setState(() => _currentIndex = i)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLogoButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AppLogoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 24),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavBarIcon(this.icon, this.index, this.currentIndex, this.onTap);

  @override
  Widget build(BuildContext context) {
    if (index == 2) return const SizedBox.shrink();
    final isSelected = index == currentIndex;
    return IconButton(
      icon: Icon(icon, color: isSelected ? AppConstants.primaryColor : ThemeColors.iconSecondary(context)),
      onPressed: () => onTap(index),
    );
  }
}

class _StreamView extends StatefulWidget {
  final Function(int) onTabChange;
  const _StreamView({required this.onTabChange});

  @override
  State<_StreamView> createState() => _StreamViewState();
}

class _StreamViewState extends State<_StreamView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _trendingGigs = []; // Se usa como fallback o para gigs urgentes
  List<Post> _posts = [];
  bool _isLoading = true;
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;
  int _unreadNotifications = 0; // Contador de notificaciones no leídas
  String? _artisticName;
  String? _profileAvatar;
  RealtimeChannel? _postsChannel;
  RealtimeChannel? _notificationsChannel;
  
  // Rotación
  Timer? _featuredGigTimer;
  Timer? _postsRefreshTimer;
  int _currentFeaturedIndex = 0;

  List<dynamic> _urgentGigs = [];
  List<dynamic> _headliners = [];
  bool _showHeadliner = false; // Toggle to show headliner vs gig

  @override
  void initState() {
    super.initState();
    _loadStreamData();
    _setupRealtime(); // Reemplaza _startPostsAutoRefresh()
    _loadUnreadNotifications(); // Cargar contador inicial
  }

  @override
  void dispose() {
    _featuredGigTimer?.cancel();
    _postsRefreshTimer?.cancel();
    _postsChannel?.unsubscribe();
    _notificationsChannel?.unsubscribe();
    _postController.dispose();
    super.dispose();
  }

  void _setupRealtime() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Escuchar nuevas publicaciones
    _postsChannel = _supabase
        .channel('public:publicaciones')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'publicaciones',
          callback: (payload) {
            debugPrint('🔔 REALTIME: Nueva publicación o cambio detectado');
            _loadPosts(); // Recargar posts al momento
          },
        )
        .subscribe();

    // 2. Escuchar nuevas notificaciones para el contador
    _notificationsChannel = _supabase
        .channel('public:notificaciones:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notificaciones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            debugPrint('🔔 REALTIME: Cambio en notificaciones detectado');
            _loadUnreadNotifications(); // Actualizar contador al momento
          },
        )
        .subscribe();
  }

  void _startPostsAutoRefresh() {
    _postsRefreshTimer?.cancel();
    _postsRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadPosts();
        _loadUnreadNotifications(); // También actualizar notificaciones
      }
    });
  }

  Future<void> _loadUnreadNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('notificaciones')
          .select('id')
          .eq('user_id', userId)
          .eq('leido', false);

      if (mounted) {
        setState(() {
          _unreadNotifications = data.length;
        });
      }
    } catch (e) {
      debugPrint('Error cargando notificaciones no leídas: $e');
      // Solo mostrar error si es crítico (no de red, ya que es carga en background)
      if (!ErrorHandler.isNetworkError(e) && mounted) {
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error cargando notificaciones');
      }
    }
  }

  Future<void> _loadPosts() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      // Obtener lista de usuarios bloqueados
      final blockedUsers = await _supabase
          .from('usuarios_bloqueados')
          .select('bloqueado_id')
          .eq('usuario_id', myId)
          .eq('activo', true);
      
      final blockedIds = blockedUsers.map((b) => b['bloqueado_id'] as String).toList();

      // Cargar 20 posts ALEATORIOS en lugar de cronológicos
      final postsData = await _supabase
          .rpc('get_random_posts', params: {'limit_count': 20});

      if (mounted) {
        // Filtrar posts de usuarios bloqueados
        final filteredPosts = (postsData as List)
            .where((p) => !blockedIds.contains(p['author_id']))
            .map((p) => Post.fromJson(p))
            .toList();

        setState(() {
          _posts = filteredPosts;
        });
      }
    } catch (e) {
      debugPrint('Error cargando posts: $e');
      // Fallback: si no existe la función RPC, usar query normal
      try {
        final blockedUsers = await _supabase
            .from('usuarios_bloqueados')
            .select('bloqueado_id')
            .eq('usuario_id', myId)
            .eq('activo', true);
        
        final blockedIds = blockedUsers.map((b) => b['bloqueado_id'] as String).toList();

        final postsData = await _supabase
            .from('publicaciones')
            .select('*, author:perfiles(nombre_artistico, foto_perfil)')
            .order('created_at', ascending: false)
            .limit(20);

        if (mounted) {
          final filteredPosts = (postsData as List)
              .where((p) => !blockedIds.contains(p['author_id']))
              .map((p) => Post.fromJson(p))
              .toList();

          setState(() {
            _posts = filteredPosts;
          });
        }
      } catch (e2) {
        debugPrint('Error en fallback: $e2');
      }
    }
  }

  Future<void> _loadStreamData() async {
    final userId = _supabase.auth.currentUser?.id;
    try {
      // 1. Cargar perfil propio
      if (userId != null) {
        debugPrint('HOME: Cargando perfil para $userId');
        final profile = await _supabase.from('perfiles').select().eq('id', userId).maybeSingle();
        debugPrint('HOME: Perfil cargado: $profile');
        
        if (profile != null && mounted) {
          setState(() {
            _artisticName = profile['nombre_artistico'];
            // Fallback robusto
            if (_artisticName == null || _artisticName!.trim().isEmpty) {
               _artisticName = 'Artista';
            }
            _profileAvatar = profile['foto_perfil'];
          });
        }
      }

      // 2. Obtener lista de usuarios bloqueados (Mutual: mis bloqueados + quienes me bloquearon)
      List<String> blockedIds = [];
      if (userId != null) {
        final blockedUsers = await _supabase
            .from('usuarios_bloqueados')
            .select('usuario_id, bloqueado_id')
            .or('usuario_id.eq.$userId,bloqueado_id.eq.$userId')
            .eq('activo', true);
        
        blockedIds = blockedUsers.map((b) => 
          b['usuario_id'] == userId ? b['bloqueado_id'].toString() : b['usuario_id'].toString()
        ).toList();
        
        debugPrint('HOME: Usuarios bloqueados (mutual): ${blockedIds.length}');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      final threeDaysLater = DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0];

      // 3. Gigs Urgentes (Próximos 7 días)
      var urgentQuery = _supabase.from('eventos').select();
      if (blockedIds.isNotEmpty) {
        urgentQuery = urgentQuery.filter('organizador_id', 'not.in', '(${blockedIds.join(',')})');
      }
      
      final urgentGigsResponse = await urgentQuery
          .gte('fecha_gig', today)
          .lte('fecha_gig', threeDaysLater)
          .limit(10);
      
      // 4. Headliners (Artistas Destacados)
      var headlinersQuery = _supabase.from('perfiles')
          .select()
          .eq('verificado', true);
      
      if (userId != null) {
        headlinersQuery = headlinersQuery.neq('id', userId);
      }
      if (blockedIds.isNotEmpty) {
        headlinersQuery = headlinersQuery.filter('id', 'not.in', '(${blockedIds.join(',')})');
      }
      
      final headlinersResponse = await headlinersQuery.limit(10);

      // 5. Últimos Posts (20 aleatorios, sin bloqueados)
      List<dynamic> postsData;
      try {
        // Intentar cargar posts aleatorios
        postsData = await _supabase
            .rpc('get_random_posts', params: {'limit_count': 20});
      } catch (e) {
        debugPrint('RPC no disponible, usando query normal: $e');
        // Fallback: cargar posts normales
        postsData = await _supabase
            .from('publicaciones')
            .select('*, author:perfiles(nombre_artistico, foto_perfil)')
            .order('created_at', ascending: false)
            .limit(20);
      }

      if (mounted) {
        // Filtrar posts de usuarios bloqueados
        final filteredPosts = (postsData as List)
            .where((p) => !blockedIds.contains(p['author_id']))
            .map((p) => Post.fromJson(p))
            .toList();

        setState(() {
          // Mezclar un poco para que sea dinámico
          _urgentGigs = List.from(urgentGigsResponse)..shuffle();
          _headliners = List.from(headlinersResponse)
              .where((h) => h['id'] != userId && !blockedIds.contains(h['id']))
              .toList()..shuffle();
          
          // Fallback si no hay urgentes, usar cualquiera futuro
          if (_urgentGigs.isEmpty) {
             _loadBackupGigs();
          } else {
             _trendingGigs = _urgentGigs;
          }

          _posts = filteredPosts;
          _isLoading = false;
        });
        
        _startFeaturedRotation();
      }
    } catch (e) {
      debugPrint('Error loading stream: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBackupGigs() async {
    // Cargar cualquier evento futuro si no hay urgentes
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _supabase.from('eventos')
        .select()
        .gte('fecha_gig', today)
        .order('fecha_gig', ascending: true)
        .limit(5);
    
    if (mounted) {
      if (response.isNotEmpty) {
          setState(() {
            _trendingGigs = response; // Sin shuffle para que sean los más próximos
          });
      } else {
         // Si de plano no hay nada, no mostramos nada o mostramos pasados (no ideal)
         setState(() => _trendingGigs = []);
      }
    }
  }

  void _startFeaturedRotation() {
    _featuredGigTimer?.cancel();
    _featuredGigTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          // Rotar entre Gigs y Headliners si hay ambos
          if (_urgentGigs.isNotEmpty && _headliners.isNotEmpty) {
             _showHeadliner = !_showHeadliner; 
          } else if (_headliners.isNotEmpty) {
             _showHeadliner = true;
          } else {
             _showHeadliner = false;
          }

          // Rotar índice del carrusel específico
          if (!_showHeadliner && _urgentGigs.isNotEmpty) {
             _currentFeaturedIndex = (_currentFeaturedIndex + 1) % _urgentGigs.length;
          } else if (_showHeadliner && _headliners.isNotEmpty) {
             _currentFeaturedIndex = (_currentFeaturedIndex + 1) % _headliners.length;
          }
        });
      }
    });
  }
  Future<void> _createPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isPosting = true);
    try {
      await _supabase.from('publicaciones').insert({
        'author_id': userId,
        'content': content,
      });
      _postController.clear();
      _loadStreamData();
    } catch (e) {
      debugPrint('Error creating post: $e');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    // Usar el índice rotativo para mostrar diferentes eventos
    final featuredGig = _trendingGigs.isNotEmpty ? _trendingGigs[_currentFeaturedIndex] : null;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadStreamData,
        color: AppConstants.primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola,', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 14)),
                        Text(
                          (_artisticName ?? 'ARTISTA').toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.primaryText(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Row(
                    children: [
                      // Notificaciones con badge
                      GestureDetector(
                        onTap: () async {
                          await context.push('/notifications');
                          _loadUnreadNotifications(); // Recargar después de ver notificaciones
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                              ),
                              child: Icon(Icons.notifications_outlined, color: AppConstants.primaryColor, size: 22),
                            ),
                            if (_unreadNotifications > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    _unreadNotifications > 9 ? '9+' : _unreadNotifications.toString(),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Mensajes
                      GestureDetector(
                        onTap: () => context.push('/messages'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                          ),
                          child: Icon(Icons.chat_bubble_outline, color: AppConstants.primaryColor, size: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Avatar
                      GestureDetector(
                        onTap: () => widget.onTabChange(3),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppConstants.primaryColor, width: 2),
                          ),
                           child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Theme.of(context).cardColor,
                            backgroundImage: _profileAvatar != null ? NetworkImage(_profileAvatar!) : null,
                            child: _profileAvatar == null 
                              ? Text(
                                  (_artisticName ?? 'A').substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontWeight: FontWeight.bold),
                                )
                              : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 30),

              // PRÓXIMO EVENTO (DESTACADO CON ROTACIÓN)
              // LOGICA DE DESTACADO MIXTO (EVENTO URGENTE vs ARTISTA VIP)
              Builder(
                builder: (context) {
                  dynamic featuredItem;
                  bool isGig = true;

                  if (_showHeadliner && _headliners.isNotEmpty) {
                    featuredItem = _headliners[_currentFeaturedIndex % _headliners.length];
                    isGig = false;
                  } else if (_urgentGigs.isNotEmpty) {
                    featuredItem = _urgentGigs[_currentFeaturedIndex % _urgentGigs.length];
                    isGig = true;
                  } else if (_trendingGigs.isNotEmpty) {
                    featuredItem = _trendingGigs[_currentFeaturedIndex % _trendingGigs.length];
                    isGig = true;
                  }

                  if (featuredItem == null) {
                    return Container(
                      height: 180,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ThemeColors.divider(context)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_outlined, color: ThemeColors.iconSecondary(context), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No hay eventos destacados',
                            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  isGig ? Icons.event_available : Icons.star,
                                  color: AppConstants.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isGig ? 'Evento Sugerido' : 'Artista Recomendado',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColors.primaryText(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppConstants.primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isGig ? 'MUY PRONTO' : 'DESTACADO',
                              style: GoogleFonts.outfit(
                                color: AppConstants.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          if (isGig) {
                            context.push('/gig/${featuredItem['id']}');
                          } else {
                            context.push('/portfolio/${featuredItem['id']}');
                          }
                        },
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).cardColor
                                : Colors.white,
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.transparent
                                  : AppConstants.primaryColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryColor.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              children: [
                                // Imagen superior (60% de la altura)
                                Expanded(
                                  flex: 6,
                                  child: Stack(
                                    children: [
                                      // Background Image
                                      if (!isGig && featuredItem['banner_url'] != null)
                                        Image.network(
                                          featuredItem['banner_url'],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      if (isGig && featuredItem['flyer_url'] != null)
                                        Image.network(
                                          featuredItem['flyer_url'],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      // Placeholder si no hay imagen
                                      if ((isGig && featuredItem['flyer_url'] == null) ||
                                          (!isGig && featuredItem['banner_url'] == null))
                                        Container(
                                          color: AppConstants.primaryColor.withOpacity(0.1),
                                          child: Center(
                                            child: Icon(
                                              isGig ? Icons.event : Icons.person,
                                              size: 60,
                                              color: AppConstants.primaryColor.withOpacity(0.3),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Información inferior (40% de la altura)
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context).cardColor
                                          : Colors.white,
                                      border: Border(
                                        top: BorderSide(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? ThemeColors.divider(context)
                                              : AppConstants.primaryColor.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Title
                                        Text(
                                          isGig
                                              ? (featuredItem['titulo_bolo'] ?? 'Evento')
                                              : (featuredItem['nombre_artistico'] ?? 'Artista'),
                                          style: GoogleFonts.outfit(
                                            color: ThemeColors.primaryText(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Location/Role
                                        Row(
                                          children: [
                                            Icon(
                                              isGig ? Icons.location_on : Icons.music_note,
                                              color: AppConstants.primaryColor,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                isGig
                                                    ? (featuredItem['lugar_nombre'] ?? 'Ubicación')
                                                    : (featuredItem['rol_principal'] ?? 'Músico'),
                                                style: GoogleFonts.outfit(
                                                  color: ThemeColors.secondaryText(context),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Fecha (solo para eventos)
                                        if (isGig && featuredItem['fecha_gig'] != null) ...[
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                color: AppConstants.primaryColor,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                DateFormat('dd MMM yyyy').format(
                                                  DateTime.parse(featuredItem['fecha_gig']),
                                                ),
                                                style: GoogleFonts.outfit(
                                                  color: ThemeColors.secondaryText(context),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),
              _buildPostInput(),
              const SizedBox(height: 30),
              _buildFeedHeader(),
              const SizedBox(height: 15),
              _buildPostList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppConstants.primaryColor.withOpacity(0.15)
              : AppConstants.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postController,
                  maxLines: 2,
                  style: GoogleFonts.outfit(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: '¿Qué estás tocando hoy?',
                    hintStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context)),
                    border: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20, color: ThemeColors.divider(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _isPosting ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                ),
                child: _isPosting 
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('POSTEAR', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Muro de Artistas', 
          style: GoogleFonts.outfit(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: ThemeColors.primaryText(context),
          )
        ),
        Icon(Icons.auto_awesome, color: AppConstants.primaryColor, size: 18),
      ],
    );
  }

  Widget _buildPostList() {
    if (_posts.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.feed_outlined, color: ThemeColors.iconSecondary(context), size: 40),
              const SizedBox(height: 10),
              Text('Aún no hay publicaciones.', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _posts.map((post) => _PostCard(post: post, myId: _supabase.auth.currentUser?.id)).toList(),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final String? myId;
  
  const _PostCard({required this.post, this.myId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              final myId = Supabase.instance.client.auth.currentUser?.id;
              if (post.authorId != myId) {
                context.push('/profile/${post.authorId}');
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                radius: 18,
                backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                child: post.authorAvatar == null ? const Icon(Icons.person, size: 18) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: ThemeColors.primaryText(context))),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(post.createdAt),
                      style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Menú de opciones (solo mostrar si NO es tu propio post)
              if (post.authorId != myId)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: ThemeColors.iconSecondary(context), size: 20),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'report') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportContentScreen(
                            contentType: 'post',
                            contentId: post.id,
                            contentTitle: 'Post de ${post.authorName}',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Text('Reportar post', style: GoogleFonts.outfit(color: Colors.orange)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: GoogleFonts.outfit(
              fontSize: 14, 
              height: 1.4, 
              color: ThemeColors.primaryText(context).withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
