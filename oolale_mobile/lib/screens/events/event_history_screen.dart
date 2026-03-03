import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import 'package:intl/intl.dart';

class EventHistoryScreen extends StatefulWidget {
  const EventHistoryScreen({super.key});

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  final _supabase = Supabase.instance.client;
  late EventService _eventService;
  List<Evento> _pastEvents = [];
  List<Evento> _filteredEvents = [];
  bool _isLoading = true;
  Map<int, bool> _ratingStatus = {}; // eventId -> hasRated
  String? _selectedFilter; // null = todos, 'concierto', 'ensayo', 'jam', 'otro'
  
  // Pagination
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _limit = 15;

  @override
  void initState() {
    super.initState();
    _eventService = EventService(_supabase);
    _loadPastEvents();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _loadMoreEvents();
      }
    }
  }

  Future<void> _loadPastEvents() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _page = 0;
      _hasMore = true;
    });

    try {
      final events = await _eventService.getEventHistory(userId, limit: _limit, offset: 0);
      
      // Check rating status for each event
      for (final event in events) {
        final participants = await _eventService.getParticipantsToRate(event.id, userId);
        _ratingStatus[event.id] = participants.isEmpty; // true if all rated
      }

      if (mounted) {
        setState(() {
          _pastEvents = events;
          _applyFilter(_selectedFilter);
          _isLoading = false;
          _hasMore = events.length >= _limit;
        });
      }
    } catch (e) {
      debugPrint('Error loading past events: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar historial de eventos')),
        );
      }
    }
  }
  
  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;
    
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoadingMore = true);

    try {
      _page++;
      final events = await _eventService.getEventHistory(
        userId, 
        limit: _limit, 
        offset: _page * _limit
      );
      
      // Check rating status for new events
      for (final event in events) {
        final participants = await _eventService.getParticipantsToRate(event.id, userId);
        _ratingStatus[event.id] = participants.isEmpty;
      }

      if (mounted) {
        setState(() {
          _pastEvents.addAll(events);
          _applyFilter(_selectedFilter);
          _isLoadingMore = false;
          _hasMore = events.length >= _limit;
        });
      }
    } catch (e) {
      debugPrint('Error loading more events: $e');
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }
  
  void _applyFilter(String? filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == null) {
        _filteredEvents = _pastEvents;
      } else {
        _filteredEvents = _pastEvents.where((e) => e.tipo == filter).toList();
      }
    });
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por tipo',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 16),
              _FilterOption(
                label: 'Todos',
                icon: Icons.all_inclusive,
                isSelected: _selectedFilter == null,
                onTap: () {
                  Navigator.pop(context);
                  _applyFilter(null);
                },
              ),
              _FilterOption(
                label: 'Conciertos',
                icon: Icons.music_note,
                isSelected: _selectedFilter == 'concierto',
                onTap: () {
                  Navigator.pop(context);
                  _applyFilter('concierto');
                },
              ),
              _FilterOption(
                label: 'Ensayos',
                icon: Icons.mic,
                isSelected: _selectedFilter == 'ensayo',
                onTap: () {
                  Navigator.pop(context);
                  _applyFilter('ensayo');
                },
              ),
              _FilterOption(
                label: 'Jam Sessions',
                icon: Icons.people,
                isSelected: _selectedFilter == 'jam',
                onTap: () {
                  Navigator.pop(context);
                  _applyFilter('jam');
                },
              ),
              _FilterOption(
                label: 'Otros',
                icon: Icons.event,
                isSelected: _selectedFilter == 'otro',
                onTap: () {
                  Navigator.pop(context);
                  _applyFilter('otro');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Historial de Eventos',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedFilter != null 
                  ? AppConstants.primaryColor 
                  : ThemeColors.icon(context),
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar eventos',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _pastEvents.isEmpty
              ? _buildEmptyState()
              : _buildEventList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: ThemeColors.iconSecondary(context),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin eventos pasados',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aquí aparecerán los eventos en los que has participado',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: ThemeColors.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Column(
      children: [
        if (_selectedFilter != null)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mostrando: ${_getFilterLabel(_selectedFilter!)}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryText(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _applyFilter(null),
                  child: Icon(Icons.close, size: 18, color: ThemeColors.icon(context)),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPastEvents,
            color: AppConstants.primaryColor,
            child: _filteredEvents.isEmpty
                ? _buildEmptyFilterState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredEvents.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredEvents.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(color: AppConstants.primaryColor),
                          ),
                        );
                      }
                      final event = _filteredEvents[index];
                      final hasRated = _ratingStatus[event.id] ?? false;
                      return _EventCard(
                        event: event,
                        hasRated: hasRated,
                        onTap: () => _navigateToEventDetail(event.id),
                        onRateTap: hasRated ? null : () => _navigateToRating(event.id),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'concierto':
        return 'Conciertos';
      case 'ensayo':
        return 'Ensayos';
      case 'jam':
        return 'Jam Sessions';
      case 'otro':
        return 'Otros';
      default:
        return 'Todos';
    }
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: ThemeColors.iconSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin eventos de este tipo',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro filtro',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: ThemeColors.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventDetail(int eventId) {
    Navigator.pushNamed(context, '/gig-detail', arguments: eventId);
  }

  void _navigateToRating(int eventId) {
    Navigator.pushNamed(
      context,
      '/leave-rating',
      arguments: {'eventId': eventId},
    ).then((_) => _loadPastEvents()); // Refresh after rating
  }
}

class _EventCard extends StatelessWidget {
  final Evento event;
  final bool hasRated;
  final VoidCallback onTap;
  final VoidCallback? onRateTap;

  const _EventCard({
    required this.event,
    required this.hasRated,
    required this.onTap,
    this.onRateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.titulo,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: ThemeColors.secondaryText(context),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm', 'es').format(event.fecha),
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: ThemeColors.secondaryText(context),
                                ),
                              ),
                            ],
                          ),
                          if (event.ubicacion.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: ThemeColors.secondaryText(context),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    event.ubicacion,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: ThemeColors.secondaryText(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildRatingBadge(context),
                  ],
                ),
                if (!hasRated && onRateTap != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_outline,
                          size: 20,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Califica a los participantes de este evento',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: ThemeColors.primaryText(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onRateTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Calificar',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasRated
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasRated ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasRated ? Icons.check_circle : Icons.pending,
            size: 14,
            color: hasRated ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            hasRated ? 'Calificado' : 'Pendiente',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: hasRated ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}




class _FilterOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppConstants.primaryColor.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppConstants.primaryColor 
              : ThemeColors.divider(context),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected 
                        ? AppConstants.primaryColor 
                        : ThemeColors.icon(context),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: ThemeColors.primaryText(context),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppConstants.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
