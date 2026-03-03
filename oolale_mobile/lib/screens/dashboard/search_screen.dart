import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../profile/public_profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _artists = [];
  List<dynamic> _featured = [];
  List<dynamic> _verified = [];
  List<dynamic> _nearby = [];
  bool _isLoading = false;
  bool _showSearch = false;
  
  // Filtros
  String? _selectedInstrument;
  String? _selectedLocation;
  bool _onlyOpenToWork = false;
  bool _onlyVerified = false;
  String _sortBy = 'recent'; // recent, rating, connections
  RealtimeChannel? _profilesChannel;
  RealtimeChannel? _connectionsChannel;

  // Nuevos filtros (Simplificados)
  List<String> _selectedGenres = [];
  
  final List<String> _allGenres = [
    'Rock', 'Pop', 'Jazz', 'Blues', 'Metal', 'Reggae',
    'Salsa', 'Cumbia', 'Electrónica', 'Funk',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupRealtime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _profilesChannel?.unsubscribe();
    _connectionsChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    // 1. Escuchar cambios en perfiles (estado online, bio, etc)
    _profilesChannel = _supabase
        .channel('public:perfiles:search')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'perfiles',
          callback: (payload) {
            final updated = payload.newRecord;
            if (mounted) {
              setState(() {
                _updateListWithProfile(_artists, updated);
                _updateListWithProfile(_featured, updated);
                _updateListWithProfile(_verified, updated);
              });
            }
          },
        )
        .subscribe();

    // 2. Escuchar cambios en conexiones (para botones de solicitud)
    _connectionsChannel = _supabase
        .channel('public:conexiones:search')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conexiones',
          callback: (payload) {
            // Recargar datos iniciales o búsqueda actual para refrescar estados de conexión
            if (_searchController.text.isEmpty) {
              _loadInitialData();
            } else {
              _performSearch(_searchController.text);
            }
          },
        )
        .subscribe();
  }

  void _updateListWithProfile(List<dynamic> list, Map<String, dynamic> updated) {
    final index = list.indexWhere((p) => p['id'] == updated['id']);
    if (index != -1) {
      list[index] = {...list[index], ...updated};
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      final myId = _supabase.auth.currentUser?.id;
      
      // Obtener lista de usuarios bloqueados (Mutual: mis bloqueados + quienes me bloquearon)
      List<String> blockedIds = [];
      if (myId != null) {
        final blockedUsers = await _supabase
            .from('usuarios_bloqueados')
            .select('usuario_id, bloqueado_id')
            .or('usuario_id.eq.$myId,bloqueado_id.eq.$myId')
            .eq('activo', true);
        
        blockedIds = blockedUsers.map((b) => 
          b['usuario_id'] == myId ? b['bloqueado_id'].toString() : b['usuario_id'].toString()
        ).toList();
        
        debugPrint('SEARCH: Usuarios bloqueados (mutual): ${blockedIds.length}');
      }
      
      // 1. Destacados (Los 10 con mejor puntuación general)
      var featuredQuery = _supabase.from('perfiles').select();
      if (myId != null) featuredQuery = featuredQuery.neq('id', myId);
      if (blockedIds.isNotEmpty) featuredQuery = featuredQuery.filter('id', 'not.in', '(${blockedIds.join(',')})');
      
      final featuredData = await featuredQuery
          .not('rating_promedio', 'is', null) // Solo perfiles con rating
          .order('rating_promedio', ascending: false)
          .limit(20);
      
      // 2. Verificados
      var verifiedQuery = _supabase.from('perfiles').select();
      if (myId != null) verifiedQuery = verifiedQuery.neq('id', myId);
      if (blockedIds.isNotEmpty) verifiedQuery = verifiedQuery.filter('id', 'not.in', '(${blockedIds.join(',')})');
      
      final verifiedData = await verifiedQuery
          .eq('verificado', true)
          .order('created_at', ascending: false)
          .limit(20);
      
      // 3. Variados (mezcla de nuevos y antiguos) - EXCLUYENDO VERIFICADOS
      var mixedQuery = _supabase.from('perfiles').select();
      if (myId != null) mixedQuery = mixedQuery.neq('id', myId);
      if (blockedIds.isNotEmpty) mixedQuery = mixedQuery.filter('id', 'not.in', '(${blockedIds.join(',')})');
      
      final mixedData = await mixedQuery
          .eq('verificado', false) // Solo NO verificados para evitar duplicados
          .order('created_at', ascending: false)
          .limit(30);
      
      // Mezclar para variedad
      final List<dynamic> varied = List.from(mixedData)..shuffle();
      
      if (mounted) {
        setState(() {
          // Filtrar usuarios bloqueados y a uno mismo
          _featured = featuredData.where((u) => u['id'] != myId && !blockedIds.contains(u['id'])).toList();
          _verified = verifiedData.where((u) => u['id'] != myId && !blockedIds.contains(u['id'])).toList();
          // Descubre: solo músicos NO verificados
          _artists = varied.where((u) => u['id'] != myId && !blockedIds.contains(u['id'])).take(20).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('UserSearchScreen._loadInitialData', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando artistas',
          onRetry: _loadInitialData,
        );
      }
    }
  }

  Future<void> _performSearch(String query) async {
    final hasActiveFilters = query.isNotEmpty || 
                            _selectedInstrument != null || 
                            _selectedLocation != null || 
                            _selectedGenres.isNotEmpty || 
                            _onlyVerified || 
                            _onlyOpenToWork;

    if (!hasActiveFilters) {
      setState(() {
        _artists = List.from(_featured)..shuffle();
        _artists = _artists.take(10).toList();
        _showSearch = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSearch = true;
    });
    
    try {
      final myId = _supabase.auth.currentUser?.id;
      
      // Obtener lista de usuarios bloqueados (Mutual: mis bloqueados + quienes me bloquearon)
      List<String> blockedIds = [];
      if (myId != null) {
        final blockedUsers = await _supabase
            .from('usuarios_bloqueados')
            .select('usuario_id, bloqueado_id')
            .or('usuario_id.eq.$myId,bloqueado_id.eq.$myId')
            .eq('activo', true);
        
        blockedIds = blockedUsers.map((b) => 
          b['usuario_id'] == myId ? b['bloqueado_id'].toString() : b['usuario_id'].toString()
        ).toList();
      }
      
      // Buscar en múltiples campos o filtrar
      var queryBuilder = _supabase.from('perfiles').select('''
        *,
        perfil_gear(gear_catalog(nombre, familia))
        ${_selectedGenres.isNotEmpty ? ', generos_perfil!inner(genre)' : ''}
      ''');
      
      // Búsqueda amplia
      queryBuilder = queryBuilder.or(
        'nombre_artistico.ilike.%$query%,'
        'ubicacion_base.ilike.%$query%,'
        'instrumento_principal.ilike.%$query%'
      );
      
      if (myId != null) {
        queryBuilder = queryBuilder.neq('id', myId);
      }
      if (blockedIds.isNotEmpty) {
        queryBuilder = queryBuilder.filter('id', 'not.in', '(${blockedIds.join(',')})');
      }
      
      // Aplicar filtros
      if (_selectedInstrument != null && _selectedInstrument!.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('instrumento_principal', '%$_selectedInstrument%');
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('ubicacion_base', '%$_selectedLocation%');
      }
      if (_onlyOpenToWork) {
        queryBuilder = queryBuilder.eq('open_to_work', true);
      }
      if (_onlyVerified) {
        queryBuilder = queryBuilder.eq('verificado', true);
      }
      
      // Filtros nuevos
      if (_selectedGenres.isNotEmpty) {
        queryBuilder = queryBuilder.filter('generos_perfil.genre', 'in', _selectedGenres);
      }

      // Aplicar límite y ordenar resultados
      final data = await (() {
        switch (_sortBy) {
          case 'rating':
            return queryBuilder.order('rating_promedio', ascending: false).limit(60);
          case 'connections':
            return queryBuilder.order('total_conexiones', ascending: false).limit(60);
          case 'recent':
          default:
            return queryBuilder.order('created_at', ascending: false).limit(60);
        }
      })();
      
      if (mounted) {
        setState(() {
          // Filtrar usuarios bloqueados y a uno mismo
          _artists = data.where((u) => u['id'] != myId && !blockedIds.contains(u['id'])).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('UserSearchScreen._performSearch', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error en la búsqueda');
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedInstrument = null;
      _selectedLocation = null;
      _onlyOpenToWork = false;
      _onlyVerified = false;
      _sortBy = 'recent';
      _selectedGenres = [];
    });
    _performSearch(_searchController.text);
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ThemeColors.divider(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtros de Artistas',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.primaryText(context),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Limpiar', style: GoogleFonts.outfit(color: AppConstants.primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Ordenar por
                Text('Priorizar resultados por:', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildModalChip(
                      label: 'Nuevos Miembros', 
                      isSelected: _sortBy == 'recent',
                      onTap: () => setModalState(() => _sortBy = 'recent'),
                    ),
                    _buildModalChip(
                      label: 'Mejor Valorados', 
                      isSelected: _sortBy == 'rating',
                      onTap: () => setModalState(() => _sortBy = 'rating'),
                    ),
                    _buildModalChip(
                      label: 'Más Populares', 
                      isSelected: _sortBy == 'connections',
                      onTap: () => setModalState(() => _sortBy = 'connections'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Inputs
                _buildModalInput(
                  label: 'Instrumento',
                  hint: 'Bajo, Batería, Piano...',
                  initialValue: _selectedInstrument,
                  onChanged: (v) => _selectedInstrument = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 16),
                _buildModalInput(
                  label: 'Ubicación',
                  hint: 'Ciudad o País',
                  initialValue: _selectedLocation,
                  onChanged: (v) => _selectedLocation = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 24),

                // Géneros
                Text('¿Qué música buscas?', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allGenres.map((genre) => _buildModalChip(
                    label: genre,
                    isSelected: _selectedGenres.contains(genre),
                    onTap: () => setModalState(() {
                      if (_selectedGenres.contains(genre)) {
                        _selectedGenres.remove(genre);
                      } else {
                        _selectedGenres.add(genre);
                      }
                    }),
                  )).toList(),
                ),
                const SizedBox(height: 24),

                // Switches rápidos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Solo Verificados', style: GoogleFonts.outfit(fontSize: 15)),
                    Switch(
                      value: _onlyVerified,
                      onChanged: (v) => setModalState(() => _onlyVerified = v),
                      activeColor: AppConstants.primaryColor,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Disponible (Open to work)', style: GoogleFonts.outfit(fontSize: 15)),
                    Switch(
                      value: _onlyOpenToWork,
                      onChanged: (v) => setModalState(() => _onlyOpenToWork = v),
                      activeColor: AppConstants.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botón Aplicar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch(_searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shadowColor: AppConstants.primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'Ver Resultados',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : (isDark ? AppConstants.bgDarkTertiary : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : ThemeColors.divider(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? AppConstants.primaryColor.withOpacity(0.3) 
                : Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: isSelected ? 10 : 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? Colors.black : ThemeColors.secondaryText(context),
          ),
        ),
      ),
    );
  }

  Widget _buildModalInput({required String label, required String hint, String? initialValue, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.5)),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          style: GoogleFonts.outfit(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: false,
            fillColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading && _artists.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explorar',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: AppConstants.primaryColor),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: AppConstants.primaryColor),
            hintText: 'Nombre, instrumento, ubicación...',
            filled: false,
            fillColor: Colors.transparent,
            suffixIcon: _searchController.text.isNotEmpty 
              ? IconButton(
                  icon: Icon(Icons.clear, color: ThemeColors.iconSecondary(context), size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ) 
              : null,
          ),
        ),
      ),
    );
  }



  Widget _buildContent() {
    if (_showSearch) {
      return _buildSearchResults();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_featured.isNotEmpty) ...[
            _buildSectionTitle('Destacados'),
            _buildHorizontalList(_featured),
            const SizedBox(height: 20),
          ],
          if (_verified.isNotEmpty) ...[
            _buildSectionTitle('Verificados'),
            _buildHorizontalList(_verified),
            const SizedBox(height: 20),
          ],
          _buildSectionTitle('Descubre'),
          _buildVerticalList(_artists),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: ThemeColors.primaryText(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> artists) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          return _buildHorizontalCard(artists[index]);
        },
      ),
    );
  }

  Widget _buildHorizontalCard(dynamic artist) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => context.push('/profile/${artist['id']}'),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16, bottom: 10, top: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ThemeColors.divider(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    artist['foto_perfil'] != null
                        ? Image.network(
                            artist['foto_perfil'],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: isDark ? AppConstants.bgDarkTertiary : AppConstants.bgLightSecondary,
                            child: const Center(child: Icon(Icons.person, size: 40)),
                          ),
                    if (artist['verificado'] == true)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(Icons.verified, color: AppConstants.primaryColor, size: 20),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist['nombre_artistico'] ?? 'Artista',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ThemeColors.primaryText(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist['instrumento_principal'] ?? 'Músico',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_artists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: ThemeColors.iconSecondary(context)),
            const SizedBox(height: 20),
            Text('Sin resultados', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16)),
          ],
        ),
      );
    }

    return _buildVerticalList(_artists);
  }

  Widget _buildVerticalList(List<dynamic> artists) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          duration: const Duration(milliseconds: 250),
          delay: Duration(milliseconds: index * 20),
          child: _ArtistCard(
            artist: artists[index],
            onTap: () {
              if (!mounted) return;
              context.push('/profile/${artists[index]['id']}');
            },
          ),
        );
      },
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final dynamic artist;
  final VoidCallback onTap;

  const _ArtistCard({required this.artist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = (artist['rating_promedio'] ?? 0.0).toDouble();
    final hasRating = rating > 0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.divider(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Foto con rating overlay
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    image: artist['foto_perfil'] != null
                        ? DecorationImage(
                            image: NetworkImage(artist['foto_perfil']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: artist['foto_perfil'] == null
                      ? Center(
                          child: Icon(
                            Icons.person,
                            size: 35,
                            color: AppConstants.primaryColor.withOpacity(0.3),
                          ),
                        )
                      : null,
                ),
                // Rating badge
                if (hasRating)
                   Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: AppConstants.primaryColor, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Estado Online
                if (artist['en_linea'] == true)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre y verificado
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          artist['nombre_artistico'] ?? 'Artista',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.primaryText(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (artist['verificado'] == true) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified, color: AppConstants.primaryColor, size: 18),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Instrumento
                  if (artist['instrumento_principal'] != null)
                    Text(
                      artist['instrumento_principal'],
                      style: GoogleFonts.outfit(
                        color: ThemeColors.primaryText(context).withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  // Rol y ubicación
                  Row(
                    children: [
                      if (artist['ubicacion_base'] != null) ...[
                        Icon(Icons.location_on, color: AppConstants.primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            artist['ubicacion_base'],
                            style: GoogleFonts.outfit(
                              color: ThemeColors.primaryText(context).withOpacity(0.8),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: ThemeColors.iconSecondary(context), size: 22),
          ],
        ),
      ),
    );
  }
}
