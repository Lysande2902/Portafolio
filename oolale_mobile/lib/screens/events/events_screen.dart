import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../../models/event.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<Evento> _allEvents = [];
  bool _isLoading = true;
  String _selectedView = 'upcoming'; // upcoming, past, today, week, month
  String _sortBy = 'date'; // date, proximity, popularity
  RealtimeChannel? _eventsChannel;
  
  // Filtros consolidados
  DateTime? _startDate;
  DateTime? _endDate;
  
  int _page = 0;
  bool _hasMore = true;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadGigs();
    _setupRealtime();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore && _selectedView == 'upcoming') {
          _loadGigs(isLoadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _eventsChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    _eventsChannel = _supabase
        .channel('public:eventos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'eventos',
          callback: (payload) {
            debugPrint('🔔 REALTIME: Cambio en eventos detectado');
            _loadGigs();
          },
        )
        .subscribe();
  }

  Future<void> _loadGigs({bool isLoadMore = false}) async {
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

      var queryBuilder = _supabase.from('eventos').select();
      
      // Aplicar filtro de bloqueados a nivel de DB
      if (blockedIds.isNotEmpty) {
        queryBuilder = queryBuilder.filter('organizador_id', 'not.in', '(${blockedIds.join(',')})');
      }
      
      // Búsqueda amplia
      final query = _searchController.text;
      if (query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'titulo_bolo.ilike.%$query%,'
          'lugar_nombre.ilike.%$query%,'
          'lugar_ciudad.ilike.%$query%'
        );
      }
      
      // Filtros por Categoría de Tiempo (DB Level) - Solo si no hay rango manual
      if (_startDate == null && _endDate == null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day).toIso8601String();
        
        switch (_selectedView) {
          case 'today':
            queryBuilder = queryBuilder.eq('fecha_gig', today);
            break;
          case 'week':
            final nextWeek = now.add(const Duration(days: 7)).toIso8601String();
            queryBuilder = queryBuilder.gte('fecha_gig', today).lte('fecha_gig', nextWeek);
            break;
          case 'month':
            final nextMonth = DateTime(now.year, now.month + 1, now.day).toIso8601String();
            queryBuilder = queryBuilder.gte('fecha_gig', today).lte('fecha_gig', nextMonth);
            break;
          case 'past':
            queryBuilder = queryBuilder.lt('fecha_gig', today);
            break;
          case 'upcoming':
          default:
            queryBuilder = queryBuilder.gte('fecha_gig', today);
            break;
        }
      }
      
      // Filtros Avanzados
      if (_startDate != null) {
        queryBuilder = queryBuilder.gte('fecha_gig', _startDate!.toIso8601String().split('T')[0]);
      }
      if (_endDate != null) {
        queryBuilder = queryBuilder.lte('fecha_gig', _endDate!.toIso8601String().split('T')[0]);
      }

      // Ordenamiento y paginación
      final from = _page * _limit;
      final to = from + _limit - 1;
      
      final List<dynamic> data;
      if (_sortBy == 'date') {
        data = await queryBuilder.order('fecha_gig', ascending: true).range(from, to);
      } else if (_sortBy == 'popularity') {
        data = await queryBuilder.order('created_at', ascending: false).range(from, to);
      } else {
        data = await queryBuilder.order('fecha_gig', ascending: true).range(from, to);
      }
          
      if (mounted) {
        final newEvents = (data as List).map((e) => Evento.fromJson(e)).toList();
        
        if (isLoadMore) {
          _allEvents.addAll(newEvents);
        } else {
          _allEvents = newEvents;
        }
        
        if (newEvents.length < _limit) {
          _hasMore = false;
        }
        
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error cargando gigs: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _performSearch(String query) {
    _page = 0;
    _hasMore = true;
    _loadGigs();
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedView = 'upcoming';
    });
    _loadGigs();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppConstants.bgDarkTertiary 
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppConstants.primaryColor.withOpacity(0.2)
                : AppConstants.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Buscar eventos, lugares, ciudades...',
                  hintStyle: GoogleFonts.outfit(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white38 
                        : Colors.black45,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: ThemeColors.iconSecondary(context), size: 18),
                onPressed: () {
                  _searchController.clear();
                  _performSearch('');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10), // Aumentado el padding superior de 10 a 16
      child: Row(
        children: [
          _buildCategoryChip('Próximos', 'upcoming'),
          const SizedBox(width: 8),
          _buildCategoryChip('Hoy', 'today'),
          const SizedBox(width: 8),
          _buildCategoryChip('Esta Semana', 'week'),
          const SizedBox(width: 8),
          _buildCategoryChip('Este Mes', 'month'),
          const SizedBox(width: 8),
          _buildCategoryChip('Pasados', 'past'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedView == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedView = value);
        _loadGigs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : ThemeColors.divider(context),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? AppConstants.primaryColor : ThemeColors.secondaryText(context),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            Expanded(
              child: _isLoading && _allEvents.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                  : _allEvents.isEmpty
                      ? _buildEmptyState()
                      : _buildEventList(_allEvents),
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
            'Eventos',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.tune, color: AppConstants.primaryColor),
                onPressed: _showFilterOptions,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppConstants.primaryColor),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                  );
                  if (result == true) _loadGigs();
                },
              ),
            ],
          ),
        ],
      ),
    );
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
                      'Filtros y Orden',
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
                      child: Text('Limpiar todos', style: GoogleFonts.outfit(color: AppConstants.primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Ordenamiento
                Text('Ordenar por', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildModalChip(
                      label: 'Fecha', 
                      isSelected: _sortBy == 'date',
                      onTap: () => setModalState(() => _sortBy = 'date'),
                    ),
                    _buildModalChip(
                      label: 'Popularidad', 
                      isSelected: _sortBy == 'popularity',
                      onTap: () => setModalState(() => _sortBy = 'popularity'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón Aplicar
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadGigs();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Ver Eventos',
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

  Widget _buildDateButton({required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: ThemeColors.divider(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: GoogleFonts.outfit(color: ThemeColors.primaryText(context))),
    );
  }

  Widget _buildEventList(List<Evento> events) {
    return RefreshIndicator(
      onRefresh: () async {
        _page = 0;
        _hasMore = true;
        await _loadGigs();
      },
      color: AppConstants.primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: events.length + (_hasMore && _selectedView == 'upcoming' ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == events.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppConstants.primaryColor),
              ),
            );
          }
          return FadeInUp(
            duration: const Duration(milliseconds: 250),
            delay: Duration(milliseconds: index * 20),
            child: _EventCard(
              event: events[index],
              isPast: _selectedView == 'past',
              isToday: _selectedView == 'today',
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedView == 'past' ? Icons.history : Icons.event_available,
            size: 80,
            color: ThemeColors.iconSecondary(context),
          ),
          const SizedBox(height: 20),
          Text(
            _getEmptyMessage(),
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
          ),
          if (_selectedView == 'upcoming' && _searchController.text.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Toca + para crear uno',
              style: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedView) {
      case 'today':
        return 'No hay eventos hoy';
      case 'week':
        return 'No hay eventos esta semana';
      case 'month':
        return 'No hay eventos este mes';
      case 'past':
        return 'No hay eventos pasados';
      default:
        return 'No hay eventos próximos';
    }
  }
}

class _EventCard extends StatelessWidget {
  final Evento event;
  final bool isPast;
  final bool isToday;

  const _EventCard({
    required this.event,
    this.isPast = false,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final day = event.fecha.day.toString();
    final month = DateFormat.MMM('es_ES').format(event.fecha).toUpperCase();
    final hasImage = event.flyerUrl != null && event.flyerUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push('/gig/${event.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
              ? Colors.red.withOpacity(0.3)
              : isPast 
                ? Colors.grey.withOpacity(0.1) 
                : AppConstants.primaryColor.withOpacity(0.15),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen o fecha
                if (hasImage)
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(event.flyerUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    // Overlay con fecha
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isToday
                            ? Colors.red
                            : isPast 
                              ? Colors.grey[800]
                              : AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1,
                              ),
                            ),
                            Text(
                              month,
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      width: 100,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Theme.of(context).cardColor.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: 80,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isToday
                      ? Colors.red.withOpacity(0.1)
                      : isPast 
                        ? Colors.grey.withOpacity(0.1)
                        : AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isToday
                            ? Colors.red
                            : isPast 
                              ? Colors.grey[700] 
                              : AppConstants.primaryColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        month,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isToday
                            ? Colors.red
                            : isPast 
                              ? Colors.grey[800] 
                              : ThemeColors.primaryText(context).withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.titulo,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.primaryText(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isToday
                            ? Colors.red.withOpacity(0.15)
                            : isPast 
                              ? Colors.grey.withOpacity(0.15)
                              : AppConstants.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.tipo.replaceAll('_', ' ').toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: isToday
                              ? Colors.red
                              : isPast 
                                ? Colors.grey[700] 
                                : AppConstants.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on, 
                            color: isToday
                              ? Colors.red
                              : isPast 
                                ? Colors.grey[700] 
                                : AppConstants.primaryColor, 
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.ubicacion,
                              style: GoogleFonts.outfit(
                                color: ThemeColors.primaryText(context).withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time, 
                            color: ThemeColors.primaryText(context).withOpacity(0.7), 
                            size: 14
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.hora,
                            style: GoogleFonts.outfit(
                              color: ThemeColors.primaryText(context).withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: ThemeColors.iconSecondary(context), size: 20),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
