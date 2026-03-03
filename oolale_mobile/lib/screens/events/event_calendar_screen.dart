import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import 'package:intl/intl.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final _supabase = Supabase.instance.client;
  late EventService _eventService;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Evento>> _events = {};
  List<Evento> _selectedDayEvents = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _eventService = EventService(_supabase);
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Load upcoming events for the next 3 months
      final upcomingEvents = await _eventService.getUpcomingEvents(userId);
      
      // Group events by date
      final Map<DateTime, List<Evento>> eventMap = {};
      for (final event in upcomingEvents) {
        final dateKey = DateTime(event.fecha.year, event.fecha.month, event.fecha.day);
        if (eventMap[dateKey] == null) {
          eventMap[dateKey] = [];
        }
        eventMap[dateKey]!.add(event);
      }

      if (mounted) {
        setState(() {
          _events = eventMap;
          _isLoading = false;
          _updateSelectedDayEvents();
        });
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar eventos')),
        );
      }
    }
  }

  void _updateSelectedDayEvents() {
    if (_selectedDay == null) {
      _selectedDayEvents = [];
      return;
    }
    
    final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final dayEvents = _events[dateKey] ?? [];
    
    _selectedDayEvents = dayEvents;
  }



  List<Evento> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
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
          'Calendario de Eventos',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),

      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 16),
                _buildSelectedDayHeader(),
                Expanded(child: _buildEventList()),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'es_ES',
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColors.primaryText(context),
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: ThemeColors.icon(context)),
          rightChevronIcon: Icon(Icons.chevron_right, color: ThemeColors.icon(context)),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
          todayTextStyle: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          selectedTextStyle: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
          weekendTextStyle: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
          outsideTextStyle: GoogleFonts.outfit(color: ThemeColors.disabledText(context)),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.outfit(
            color: ThemeColors.secondaryText(context),
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: GoogleFonts.outfit(
            color: ThemeColors.secondaryText(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _updateSelectedDayEvents();
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildSelectedDayHeader() {
    if (_selectedDay == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('EEEE, d MMMM', 'es').format(_selectedDay!),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primaryText(context),
                ),
              ),
              const Spacer(),
              if (_selectedDayEvents.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedDayEvents.length} evento${_selectedDayEvents.length != 1 ? 's' : ''}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
            ],
          ),

        ],
      ),
    );
  }



  Widget _buildEventList() {
    if (_selectedDayEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 60,
                color: ThemeColors.iconSecondary(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Sin eventos este día',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: ThemeColors.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _selectedDayEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedDayEvents[index];
        return _EventCard(
          event: event,
          onTap: () => _navigateToEventDetail(event.id),
        );
      },
    );
  }

  void _navigateToEventDetail(int eventId) {
    Navigator.pushNamed(context, '/gig-detail', arguments: eventId);
  }
}

class _EventCard extends StatelessWidget {
  final Evento event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  bool get _isWithin24Hours {
    final now = DateTime.now();
    final difference = event.fecha.difference(now);
    return difference.inHours <= 24 && difference.inHours >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isWithin24Hours 
              ? AppConstants.primaryColor 
              : ThemeColors.divider(context),
          width: _isWithin24Hours ? 2 : 1,
        ),
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
                      child: Text(
                        event.titulo,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primaryText(context),
                        ),
                      ),
                    ),
                    if (_isWithin24Hours)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              'Próximo',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: ThemeColors.secondaryText(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('HH:mm').format(event.fecha),
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
        ),
      ),
    );
  }
}





