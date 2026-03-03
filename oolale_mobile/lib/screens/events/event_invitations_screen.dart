import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../services/event_service.dart';
import 'package:intl/intl.dart';

class EventInvitationsScreen extends StatefulWidget {
  const EventInvitationsScreen({super.key});

  @override
  State<EventInvitationsScreen> createState() => _EventInvitationsScreenState();
}

class _EventInvitationsScreenState extends State<EventInvitationsScreen> {
  final _supabase = Supabase.instance.client;
  late EventService _eventService;
  List<Map<String, dynamic>> _invitations = [];
  bool _isLoading = true;
  Set<int> _processingInvitations = {};

  @override
  void initState() {
    super.initState();
    _eventService = EventService(_supabase);
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final invitations = await _eventService.getPendingInvitations(userId);
      
      if (mounted) {
        setState(() {
          _invitations = invitations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading invitations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar invitaciones')),
        );
      }
    }
  }

  Future<void> _respondToInvitation(int invitationId, String status) async {
    if (_processingInvitations.contains(invitationId)) return;

    setState(() {
      _processingInvitations.add(invitationId);
    });

    try {
      await _eventService.respondToInvitation(invitationId, status);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'accepted' 
                  ? 'Invitación aceptada' 
                  : 'Invitación rechazada',
            ),
          ),
        );
        
        // Reload invitations
        await _loadInvitations();
      }
    } catch (e) {
      debugPrint('Error responding to invitation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al responder invitación')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingInvitations.remove(invitationId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _invitations.length;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invitaciones a Eventos',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (pendingCount > 0)
              Text(
                '$pendingCount pendiente${pendingCount != 1 ? 's' : ''}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _invitations.isEmpty
              ? _buildEmptyState()
              : _buildInvitationsList(),
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
              Icons.mail_outline,
              size: 80,
              color: ThemeColors.iconSecondary(context),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin invitaciones pendientes',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aquí aparecerán las invitaciones a eventos que recibas',
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

  Widget _buildInvitationsList() {
    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _invitations.length,
        itemBuilder: (context, index) {
          final invitation = _invitations[index];
          final event = invitation['eventos'];
          final organizer = invitation['perfiles'];
          final invitationId = invitation['id'];
          final isProcessing = _processingInvitations.contains(invitationId);

          return _InvitationCard(
            eventTitle: event['titulo'] ?? 'Sin título',
            eventDate: DateTime.parse(event['fecha']),
            eventLocation: event['ubicacion'] ?? '',
            organizerName: organizer['nombre_artistico'] ?? 'Desconocido',
            isProcessing: isProcessing,
            onAccept: () => _respondToInvitation(invitationId, 'accepted'),
            onDecline: () => _respondToInvitation(invitationId, 'declined'),
            onTap: () => _navigateToEventDetail(event['id']),
          );
        },
      ),
    );
  }

  void _navigateToEventDetail(int eventId) {
    Navigator.pushNamed(context, '/gig-detail', arguments: eventId);
  }
}

class _InvitationCard extends StatelessWidget {
  final String eventTitle;
  final DateTime eventDate;
  final String eventLocation;
  final String organizerName;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onTap;

  const _InvitationCard({
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
    required this.organizerName,
    required this.isProcessing,
    required this.onAccept,
    required this.onDecline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3), width: 2),
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
                // Header with invitation badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mail,
                            size: 12,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Nueva invitación',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Event title
                Text(
                  eventTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Organizer
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: ThemeColors.secondaryText(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Organizado por $organizerName',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: ThemeColors.secondaryText(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: ThemeColors.secondaryText(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm', 'es').format(eventDate),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: ThemeColors.secondaryText(context),
                      ),
                    ),
                  ],
                ),
                
                // Location
                if (eventLocation.isNotEmpty) ...[
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
                          eventLocation,
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
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isProcessing ? null : onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                ),
                              )
                            : Text(
                                'Rechazar',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : Text(
                                'Aceptar',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
