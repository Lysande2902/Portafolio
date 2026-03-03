import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';
import '../ratings/leave_rating_screen.dart';

/// Screen shown after an event to rate participants
class PostEventScreen extends StatefulWidget {
  final int eventId;

  const PostEventScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<PostEventScreen> createState() => _PostEventScreenState();
}

class _PostEventScreenState extends State<PostEventScreen> {
  final _supabase = Supabase.instance.client;
  late EventService _eventService;
  
  Evento? _event;
  List<Map<String, dynamic>> _participantsToRate = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _eventService = EventService(_supabase);
    _loadEventAndParticipants();
  }

  Future<void> _loadEventAndParticipants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Load event details
      final eventData = await _supabase
          .from('eventos')
          .select()
          .eq('id', widget.eventId)
          .single();

      _event = Evento.fromJson(eventData);

      // Check if user can rate this event
      final canRate = await _eventService.canRateEvent(widget.eventId, userId);
      
      if (!canRate) {
        setState(() {
          _error = 'No puedes calificar este evento';
          _isLoading = false;
        });
        return;
      }

      // Get participants to rate
      final participants = await _eventService.getParticipantsToRate(
        widget.eventId,
        userId,
      );

      setState(() {
        _participantsToRate = participants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _rateParticipant(Map<String, dynamic> participant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveRatingScreen(
          ratedUserId: participant['id'],
          ratedUserName: participant['nombre_artistico'] ?? 'Usuario',
          eventId: widget.eventId,
        ),
      ),
    );

    if (result == true) {
      // Reload participants after rating
      _loadEventAndParticipants();
    }
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
          'Post-Evento',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Error',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: ThemeColors.secondaryText(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                ),
                child: Text('Volver', style: GoogleFonts.outfit()),
              ),
            ],
          ),
        ),
      );
    }

    if (_event == null) {
      return const Center(child: Text('Evento no encontrado'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventSummary(),
          const SizedBox(height: 24),
          _buildRatingSection(),
        ],
      ),
    );
  }

  Widget _buildEventSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_available,
                    color: AppConstants.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evento Finalizado',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: ThemeColors.secondaryText(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _event!.titulo,
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
            const SizedBox(height: 20),
            Divider(color: ThemeColors.divider(context)),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              '${_event!.fecha.day}/${_event!.fecha.month}/${_event!.fecha.year}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Hora',
              _event!.hora,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Ubicación',
              _event!.ubicacion,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.category,
              'Tipo',
              _getEventTypeLabel(_event!.tipo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ThemeColors.secondaryText(context)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: ThemeColors.secondaryText(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ThemeColors.primaryText(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    if (_participantsToRate.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green[300],
              ),
              const SizedBox(height: 16),
              Text(
                '¡Todo listo!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ya calificaste a todos los participantes',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Califica a los participantes',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColors.primaryText(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ayuda a la comunidad compartiendo tu experiencia',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: ThemeColors.secondaryText(context),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _participantsToRate.length,
          (index) => _buildParticipantCard(_participantsToRate[index]),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant) {
    final name = participant['nombre_artistico'] ?? 'Usuario';
    final instrument = participant['instrumento_principal'];
    final avatarUrl = participant['avatar_url'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _rateParticipant(participant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Icon(Icons.person, size: 32, color: AppConstants.primaryColor)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.primaryText(context),
                      ),
                    ),
                    if (instrument != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 14,
                            color: ThemeColors.secondaryText(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            instrument,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: ThemeColors.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      'Calificar',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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

  String _getEventTypeLabel(String tipo) {
    switch (tipo) {
      case 'concierto':
        return 'Concierto';
      case 'ensayo':
        return 'Ensayo';
      case 'jam':
        return 'Jam Session';
      default:
        return 'Otro';
    }
  }
}
