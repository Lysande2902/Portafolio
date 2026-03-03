import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Direct DB
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final _supabase = Supabase.instance.client; // Direct connection
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;
  String _activeFilter = 'todos';
  
  // Filtros avanzados
  List<String> _selectedInstruments = [];
  List<String> _selectedGenres = [];
  String? _selectedLocation; 

  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool _hasMore = true;
  static const int _limit = 20;
  static const int _minRatingsForTopRated = 5; // Mínimo de calificaciones para aparecer en "Mejor Valorados"

  @override
  void initState() {
    super.initState();
    _performSearch('');
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasMore) {
          _performSearch(_searchController.text, isLoadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query, {bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore) return;
      _page++;
    } else {
      _page = 0;
      _hasMore = true;
      setState(() => _isLoading = true);
    }
    
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
      
      var queryBuilder = _supabase.from('perfiles').select();
      
      if (query.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('nombre_artistico', '%$query%');
      }

      // Aplicar filtros
      if (_activeFilter == 'open_to_work') {
        queryBuilder = queryBuilder.eq('open_to_work', true);
      } else if (_activeFilter == 'top_rated') {
        // Solo mostrar músicos con mínimo de calificaciones
        queryBuilder = queryBuilder.gte('total_calificaciones', _minRatingsForTopRated);
      }
      
      // Aplicar filtros avanzados
      if (_selectedLocation != null) {
        queryBuilder = queryBuilder.eq('ubicacion_base', _selectedLocation!);
      }
      
      // Filtros de instrumentos (array)
      if (_selectedInstruments.isNotEmpty) {
        // Filtrar músicos que tengan AL MENOS UNO de los instrumentos seleccionados
        for (final instrument in _selectedInstruments) {
          queryBuilder = queryBuilder.contains('instrumentos', [instrument]);
        }
      }
      
      // Filtros de géneros (array)
      if (_selectedGenres.isNotEmpty) {
        // Filtrar músicos que tengan AL MENOS UNO de los géneros seleccionados
        for (final genre in _selectedGenres) {
          queryBuilder = queryBuilder.contains('generos_musicales', [genre]);
        }
      }

      // No mostrarse a uno mismo en búsquedas
      if (myId != null) {
        queryBuilder = queryBuilder.neq('id', myId);
      }
      if (blockedIds.isNotEmpty) {
        queryBuilder = queryBuilder.filter('id', 'not.in', '(${blockedIds.join(',')})');
      }

      final from = _page * _limit;
      final to = from + _limit - 1;
      
      // Aplicar ordenamiento según filtro activo
      final response = _activeFilter == 'top_rated'
          ? await queryBuilder.order('promedio_calificacion', ascending: false).range(from, to)
          : await queryBuilder.range(from, to);
      
      if (mounted) {
        // Filtrar usuarios bloqueados y a uno mismo
        final filteredResponse = response.where((u) => 
          u['id'] != myId && 
          !blockedIds.contains(u['id'])
        ).toList();
        
        setState(() {
          if (isLoadMore) {
            _results.addAll(filteredResponse);
          } else {
            _results = filteredResponse;
          }
          
          if (response.length < _limit) {
            _hasMore = false;
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error Discovery: $e');
      if(mounted) {
        setState(() {
         _isLoading = false; 
         if (_results.isEmpty) _loadDummyDiscovery();
      });
      }
    }
  }

  void _loadDummyDiscovery() {
      _results = [
          {'id': '1', 'nombre_artistico': 'Leo Fender', 'ubicacion_base': 'CDMX', 'nivel_badge': 'pro', 'instrumento_principal': 'Guitarra'},
          {'id': '2', 'nombre_artistico': 'Ringo Starr', 'ubicacion_base': 'Liverpool', 'nivel_badge': 'maestro', 'instrumento_principal': 'Batería'},
          {'id': '3', 'nombre_artistico': 'Flea', 'ubicacion_base': 'LA', 'nivel_badge': 'pro', 'instrumento_principal': 'Bajo'},
          {'id': '4', 'nombre_artistico': 'Miles Davis', 'ubicacion_base': 'NY', 'nivel_badge': 'leyenda', 'instrumento_principal': 'Trompeta'},
      ];
  }

  Future<void> _sendConnectionRequest(String targetId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    try {
      // Verificar si hay bloqueo (en cualquier dirección)
      final blockData = await _supabase
          .from('usuarios_bloqueados')
          .select()
          .or('and(usuario_id.eq.$myId,bloqueado_id.eq.$targetId),and(usuario_id.eq.$targetId,bloqueado_id.eq.$myId)')
          .eq('activo', true)
          .maybeSingle();

      if (blockData != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No puedes conectar con este usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Verificar si ya existe una conexión
      final existing = await _supabase
          .from('conexiones')
          .select()
          .eq('usuario_id', myId)
          .eq('conectado_id', targetId)
          .maybeSingle();

      if (existing != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ya tienes una conexión con este usuario')),
          );
        }
        return;
      }

      // Crear nueva solicitud
      await _supabase.from('conexiones').insert({
        'usuario_id': myId,
        'conectado_id': targetId,
        'estatus': 'pending',
      });

      // Notificar al usuario objetivo
      await _supabase.from('notificaciones').insert({
        'user_id': targetId,
        'tipo': 'connection_request',
        'titulo': 'Nueva solicitud de conexión',
        'mensaje': 'Un músico quiere conectar contigo',
        'leido': false,
        'data': {'sender_id': myId},
        // 'created_at': DateTime.now().toIso8601String(), // Supabase usa default now()
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Solicitud enviada!'),
            backgroundColor: AppConstants.primaryColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending connection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar solicitud')),
        );
      }
    }
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtros Avanzados',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.primaryText(context),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedInstruments.clear();
                          _selectedGenres.clear();
                          _selectedLocation = null;
                        });
                        setModalState(() {});
                        _performSearch(_searchController.text);
                      },
                      child: Text('Limpiar', style: GoogleFonts.outfit(color: AppConstants.primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Instrumentos
                Text('Instrumentos', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Guitarra', 'Bajo', 'Batería', 'Teclado', 'Voz', 'Saxofón', 'Trompeta', 'Violín']
                      .map((instrument) => _buildModalChip(
                            label: instrument,
                            isSelected: _selectedInstruments.contains(instrument),
                            onTap: () {
                              setModalState(() {
                                if (_selectedInstruments.contains(instrument)) {
                                  _selectedInstruments.remove(instrument);
                                } else {
                                  _selectedInstruments.add(instrument);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),

                // Géneros
                Text('Géneros Musicales', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Rock', 'Jazz', 'Blues', 'Pop', 'Metal', 'Funk', 'Reggae', 'Clásica']
                      .map((genre) => _buildModalChip(
                            label: genre,
                            isSelected: _selectedGenres.contains(genre),
                            onTap: () {
                              setModalState(() {
                                if (_selectedGenres.contains(genre)) {
                                  _selectedGenres.remove(genre);
                                } else {
                                  _selectedGenres.add(genre);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),

                // Ubicación
                Text('Ubicación', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['CDMX', 'Guadalajara', 'Monterrey', 'Puebla', 'Querétaro', 'Tijuana']
                      .map((location) => _buildModalChip(
                            label: location,
                            isSelected: _selectedLocation == location,
                            onTap: () {
                              setModalState(() {
                                _selectedLocation = _selectedLocation == location ? null : location;
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 32),

                // Botón Aplicar
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch(_searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Aplicar Filtros',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
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
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label, style: GoogleFonts.outfit(fontSize: 12)),
        backgroundColor: isSelected ? AppConstants.primaryColor : Colors.transparent,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : ThemeColors.secondaryText(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(color: isSelected ? AppConstants.primaryColor : ThemeColors.divider(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header & Search
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text('Explorar', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12)
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: ThemeColors.primaryText(context)),
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Músico, banda o instrumento...',
                        hintStyle: TextStyle(color: ThemeColors.hintText(context)),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: ThemeColors.icon(context)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.filter_list, color: AppConstants.accentColor),
                          onPressed: _showAdvancedFilters,
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Filters / Chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                children: [
                  _buildFilterChip('Todos', 'todos'),
                  _buildFilterChip('Mejor Valorados', 'top_rated'),
                  _buildFilterChip('Open To Work', 'open_to_work'),
                ],
              ),
            ),

            // 3. Grid Results
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _page = 0;
                  _hasMore = true;
                  await _performSearch(_searchController.text);
                },
                color: AppConstants.primaryColor,
                backgroundColor: AppConstants.bgDarkPanel,
                child: _results.isEmpty && !_isLoading
                  ? Stack(
                      children: [
                        ListView(), // Para que el RefreshIndicator funcione
                        Center(child: Text('No se encontraron resultados', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)))),
                      ],
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15
                      ),
                      itemCount: _results.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _results.length) {
                          return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                        }
                        return _buildArtistCard(_results[index], index);
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final bool isActive = _activeFilter == id;
    return GestureDetector(
      onTap: () {
        setState(() => _activeFilter = id);
        _performSearch(_searchController.text); // Trigger search with filter
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.primaryColor : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isActive ? Colors.black : ThemeColors.secondaryText(context),
            fontWeight: FontWeight.bold,
            fontSize: 12
          )
        ),
      ),
    );
  }

  Widget _buildArtistCard(dynamic item, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    item['nivel_badge'] == 'pro' || item['nivel_badge'] == 'maestro' ? AppConstants.accentColor : Colors.transparent,
                    AppConstants.primaryColor
                  ]
                )
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Text(
                   (item['nombre_artistico'] ?? 'A')[0].toUpperCase(),
                   style: TextStyle(fontSize: 24, color: ThemeColors.primaryText(context), fontWeight: FontWeight.bold)
                ),
                // backgroundImage: NetworkImage(item['foto_url']) // Si hubiera foto
              ),
            ),
            const SizedBox(height: 12),
            
            // Info
            Text(
              item['nombre_artistico'] ?? 'Artista',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              (item['instrumento_principal'] ?? 'Músico General').toUpperCase(),
              style: const TextStyle(color: AppConstants.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 12, color: ThemeColors.secondaryText(context)),
                const SizedBox(width: 4),
                Text(item['ubicacion_base'] ?? 'Mundo', style: TextStyle(color: ThemeColors.secondaryText(context), fontSize: 12)),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Action Button
            SizedBox(
              height: 36,
              width: 110,
              child: ElevatedButton(
                onPressed: () => _sendConnectionRequest(item['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: Text('Conectar', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
