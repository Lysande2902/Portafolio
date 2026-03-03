import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

/// Service for managing events, invitations, and RSVPs
class EventService {
  final SupabaseClient _supabase;

  EventService(this._supabase);

  /// Get event history (past events) for a user
  /// Returns events ordered by date (most recent first)
  Future<List<Evento>> getEventHistory(String userId, {int limit = 15, int offset = 0}) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Get events where user is organizer or in lineup
      final data = await _supabase
          .from('eventos')
          .select()
          .or('organizador_id.eq.$userId,lineup.cs.{$userId}')
          .lt('fecha_gig', now)
          .order('fecha_gig', ascending: false)
          .range(offset, offset + limit - 1);

      return data.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting event history: $e');
      rethrow;
    }
  }

  /// Get upcoming events for a user
  /// Returns events ordered by date (soonest first)
  Future<List<Evento>> getUpcomingEvents(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Get events where user is organizer or in lineup
      final data = await _supabase
          .from('eventos')
          .select()
          .or('organizador_id.eq.$userId,lineup.cs.{$userId}')
          .gte('fecha_gig', now)
          .order('fecha_gig', ascending: true);

      return data.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting upcoming events: $e');
      rethrow;
    }
  }

  /// Get events for a specific date
  Future<List<Evento>> getEventsForDate(DateTime date, String userId) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
      
      final data = await _supabase
          .from('eventos')
          .select()
          .or('organizador_id.eq.$userId,lineup.cs.{$userId}')
          .gte('fecha_gig', startOfDay)
          .lte('fecha_gig', endOfDay)
          .order('fecha_gig', ascending: true);

      return data.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting events for date: $e');
      rethrow;
    }
  }

  /// Send invitations to musicians for an event
  /// Creates invitation records and sends notifications
  Future<void> sendInvitations(int eventId, List<String> musicianIds) async {
    try {
      final organizerId = _supabase.auth.currentUser?.id;
      if (organizerId == null) throw Exception('User not authenticated');

      // Get event details
      final event = await _supabase
          .from('eventos')
          .select()
          .eq('id', eventId)
          .single();

      // Create invitations
      final invitations = musicianIds.map((musicianId) => {
        'event_id': eventId,
        'musician_id': musicianId,
        'organizer_id': organizerId,
        'status': 'pending',
      }).toList();

      await _supabase.from('invitaciones_evento').insert(invitations);

      // Get organizer profile
      final organizerProfile = await _supabase
          .from('perfiles')
          .select('nombre_artistico')
          .eq('id', organizerId)
          .single();

      // Create notifications for each musician
      final notifications = musicianIds.map((musicianId) => {
        'user_id': musicianId,
        'tipo': 'event_invitation',
        'titulo': 'Invitación a evento',
        'mensaje': '${organizerProfile['nombre_artistico']} te invitó a ${event['titulo_bolo']}',
        'leido': false,
        'data': {
          'event_id': eventId,
          'organizer_id': organizerId,
        },
      }).toList();

      await _supabase.from('notificaciones').insert(notifications);

      debugPrint('✅ Invitations sent to ${musicianIds.length} musicians');
    } catch (e) {
      debugPrint('❌ Error sending invitations: $e');
      rethrow;
    }
  }

  /// Respond to an event invitation (accept or decline)
  /// Updates invitation status and modifies event lineup if accepted
  Future<void> respondToInvitation(int invitationId, String status) async {
    try {
      if (status != 'accepted' && status != 'declined') {
        throw Exception('Invalid status. Must be "accepted" or "declined"');
      }

      // Get invitation details
      final invitation = await _supabase
          .from('invitaciones_evento')
          .select()
          .eq('id', invitationId)
          .single();

      // Update invitation status
      await _supabase
          .from('invitaciones_evento')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId);

      // If accepted, add musician to event lineup
      if (status == 'accepted') {
        final event = await _supabase
            .from('eventos')
            .select('lineup')
            .eq('id', invitation['event_id'])
            .single();

        List<String> lineup = [];
        if (event['lineup'] != null) {
          lineup = List<String>.from(event['lineup']);
        }

        if (!lineup.contains(invitation['musician_id'])) {
          lineup.add(invitation['musician_id']);
          
          await _supabase
              .from('eventos')
              .update({'lineup': lineup})
              .eq('id', invitation['event_id']);
        }
      }

      // Notify organizer of response
      final musicianProfile = await _supabase
          .from('perfiles')
          .select('nombre_artistico')
          .eq('id', invitation['musician_id'])
          .single();

      final eventData = await _supabase
          .from('eventos')
          .select('titulo_bolo')
          .eq('id', invitation['event_id'])
          .single();

      await _supabase.from('notificaciones').insert({
        'user_id': invitation['organizer_id'],
        'tipo': 'invitation_response',
        'titulo': status == 'accepted' ? 'Invitación aceptada' : 'Invitación rechazada',
        'mensaje': '${musicianProfile['nombre_artistico']} ${status == 'accepted' ? 'aceptó' : 'rechazó'} tu invitación a ${eventData['titulo_bolo']}',
        'leido': false,
        'data': {
          'event_id': invitation['event_id'],
          'musician_id': invitation['musician_id'],
          'status': status,
        },
      });

      debugPrint('✅ Invitation $status');
    } catch (e) {
      debugPrint('❌ Error responding to invitation: $e');
      rethrow;
    }
  }

  /// Get pending invitations for a user
  Future<List<Map<String, dynamic>>> getPendingInvitations(String userId) async {
    try {
      final data = await _supabase
          .from('invitaciones_evento')
          .select('*, eventos(*), perfiles!invitaciones_evento_organizer_id_fkey(*)')
          .eq('musician_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ Error getting pending invitations: $e');
      rethrow;
    }
  }

  /// Check if user can rate an event
  /// User can rate if event is past and they participated
  Future<bool> canRateEvent(int eventId, String userId) async {
    try {
      final event = await _supabase
          .from('eventos')
          .select('fecha_gig, lineup, organizador_id')
          .eq('id', eventId)
          .single();

      // Check if event is in the past
      final eventDate = DateTime.parse(event['fecha_gig']);
      if (eventDate.isAfter(DateTime.now())) {
        return false;
      }

      // Check if user participated (in lineup or organizer)
      final lineup = event['lineup'] != null ? List<String>.from(event['lineup']) : [];
      final participated = lineup.contains(userId) || event['organizador_id'] == userId;

      return participated;
    } catch (e) {
      debugPrint('❌ Error checking if can rate event: $e');
      return false;
    }
  }

  /// Get list of participants to rate for an event
  /// Returns users who participated but haven't been rated yet by current user
  Future<List<Map<String, dynamic>>> getParticipantsToRate(int eventId, String userId) async {
    try {
      final event = await _supabase
          .from('eventos')
          .select('lineup, organizador_id')
          .eq('id', eventId)
          .single();

      // Get all participants
      final lineup = event['lineup'] != null ? List<String>.from(event['lineup']) : [];
      final allParticipants = [...lineup];
      
      // Add organizer if not current user
      if (event['organizador_id'] != userId) {
        allParticipants.add(event['organizador_id']);
      }

      // Remove current user
      allParticipants.remove(userId);

      if (allParticipants.isEmpty) return [];

      // Get existing ratings from current user for this event
      final existingRatings = await _supabase
          .from('referencias')
          .select('calificado_id')
          .eq('calificador_id', userId)
          .eq('event_id', eventId);

      final ratedUserIds = existingRatings.map((r) => r['calificado_id'].toString()).toSet();

      // Filter out already rated users
      final unratedUserIds = allParticipants.where((id) => !ratedUserIds.contains(id)).toList();

      if (unratedUserIds.isEmpty) return [];

      // Get profiles for unrated users
      final profiles = await _supabase
          .from('perfiles')
          .select()
          .inFilter('id', unratedUserIds);

      return List<Map<String, dynamic>>.from(profiles);
    } catch (e) {
      debugPrint('❌ Error getting participants to rate: $e');
      rethrow;
    }
  }

  /// Check if event is within 24 hours
  bool isEventWithin24Hours(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now);
    return difference.inHours <= 24 && difference.inHours >= 0;
  }

  /// Get events within 24 hours for a user (for reminders)
  Future<List<Evento>> getEventsWithin24Hours(String userId) async {
    try {
      final now = DateTime.now();
      final in24Hours = now.add(const Duration(hours: 24)).toIso8601String();
      
      final data = await _supabase
          .from('eventos')
          .select()
          .or('organizador_id.eq.$userId,lineup.cs.{$userId}')
          .gte('fecha_gig', now.toIso8601String())
          .lte('fecha_gig', in24Hours)
          .order('fecha_gig', ascending: true);

      return data.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting events within 24 hours: $e');
      rethrow;
    }
  }

  /// Get sent invitations for an event (for organizers)
  Future<List<Map<String, dynamic>>> getSentInvitations(int eventId) async {
    try {
      final data = await _supabase
          .from('invitaciones_evento')
          .select('*, perfiles!invitaciones_evento_musician_id_fkey(*)')
          .eq('event_id', eventId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ Error getting sent invitations: $e');
      rethrow;
    }
  }

  /// Cancel an invitation (for organizers)
  Future<void> cancelInvitation(int invitationId) async {
    try {
      await _supabase
          .from('invitaciones_evento')
          .delete()
          .eq('id', invitationId);

      debugPrint('✅ Invitation cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling invitation: $e');
      rethrow;
    }
  }

  /// Get invitation statistics for an event
  Future<Map<String, int>> getInvitationStats(int eventId) async {
    try {
      final data = await _supabase
          .from('invitaciones_evento')
          .select('status')
          .eq('event_id', eventId);

      int pending = 0;
      int accepted = 0;
      int declined = 0;

      for (final invitation in data) {
        final status = invitation['status'];
        if (status == 'pending') pending++;
        else if (status == 'accepted') accepted++;
        else if (status == 'declined') declined++;
      }

      return {
        'pending': pending,
        'accepted': accepted,
        'declined': declined,
        'total': data.length,
      };
    } catch (e) {
      debugPrint('❌ Error getting invitation stats: $e');
      rethrow;
    }
  }

  /// Search musicians by name, location, instrument, or genre
  Future<List<Map<String, dynamic>>> searchMusicians({
    String? query,
    String? instrument,
    String? genre,
    String? excludeUserId,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('perfiles')
          .select('id, nombre_artistico, avatar_url, ubicacion, instrumento_principal');

      // Exclude current user
      if (excludeUserId != null) {
        queryBuilder = queryBuilder.neq('id', excludeUserId);
      }

      // Text search
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'nombre_artistico.ilike.%$query%,ubicacion.ilike.%$query%'
        );
      }

      // Instrument filter
      if (instrument != null) {
        queryBuilder = queryBuilder.eq('instrumento_principal', instrument);
      }

      // Note: genre filter removed as genero_musical column doesn't exist
      // This can be added later when the column is created in Phase 3

      final data = await queryBuilder.limit(50);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ Error searching musicians: $e');
      rethrow;
    }
  }

  /// Get event lineup with participant details
  Future<List<Map<String, dynamic>>> getEventLineup(int eventId) async {
    try {
      final data = await _supabase
          .from('participantes_evento')
          .select('*, perfiles(*)')
          .eq('event_id', eventId)
          .eq('confirmed', true)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ Error getting event lineup: $e');
      rethrow;
    }
  }

  /// Update participant role in event
  Future<void> updateParticipantRole(
    int eventId,
    String userId,
    String role,
  ) async {
    try {
      await _supabase
          .from('participantes_evento')
          .update({'role': role})
          .eq('event_id', eventId)
          .eq('user_id', userId);

      debugPrint('✅ Participant role updated');
    } catch (e) {
      debugPrint('❌ Error updating participant role: $e');
      rethrow;
    }
  }

  /// Remove participant from event
  Future<void> removeParticipant(int eventId, String userId) async {
    try {
      await _supabase
          .from('participantes_evento')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);

      // Also remove from lineup array
      final event = await _supabase
          .from('eventos')
          .select('lineup')
          .eq('id', eventId)
          .single();

      if (event['lineup'] != null) {
        List<String> lineup = List<String>.from(event['lineup']);
        lineup.remove(userId);
        
        await _supabase
            .from('eventos')
            .update({'lineup': lineup})
            .eq('id', eventId);
      }

      debugPrint('✅ Participant removed');
    } catch (e) {
      debugPrint('❌ Error removing participant: $e');
      rethrow;
    }
  }

  /// Get attendance status for a user
  Future<Map<String, dynamic>> getAttendanceStatus(
    int eventId,
    String userId,
  ) async {
    try {
      final data = await _supabase
          .from('participantes_evento')
          .select('confirmed, role')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        return {'confirmed': false, 'role': null};
      }

      return {
        'confirmed': data['confirmed'] ?? false,
        'role': data['role'],
      };
    } catch (e) {
      debugPrint('❌ Error getting attendance status: $e');
      return {'confirmed': false, 'role': null};
    }
  }

  /// Confirm attendance to an event
  Future<void> confirmAttendance(int eventId, String role) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Check if already exists
      final existing = await _supabase
          .from('participantes_evento')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Update existing
        await _supabase
            .from('participantes_evento')
            .update({
              'confirmed': true,
              'role': role,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('event_id', eventId)
            .eq('user_id', userId);
      } else {
        // Create new
        await _supabase.from('participantes_evento').insert({
          'event_id': eventId,
          'user_id': userId,
          'confirmed': true,
          'role': role,
        });
      }

      // Add to lineup array
      final event = await _supabase
          .from('eventos')
          .select('lineup, organizador_id, titulo_bolo')
          .eq('id', eventId)
          .single();

      List<String> lineup = [];
      if (event['lineup'] != null) {
        lineup = List<String>.from(event['lineup']);
      }

      if (!lineup.contains(userId)) {
        lineup.add(userId);
        
        await _supabase
            .from('eventos')
            .update({'lineup': lineup})
            .eq('id', eventId);
      }

      // Notify organizer
      final userProfile = await _supabase
          .from('perfiles')
          .select('nombre_artistico')
          .eq('id', userId)
          .single();

      await _supabase.from('notificaciones').insert({
        'user_id': event['organizador_id'],
        'tipo': 'attendance_confirmed',
        'titulo': 'Asistencia confirmada',
        'mensaje': '${userProfile['nombre_artistico']} confirmó asistencia a ${event['titulo_bolo']}',
        'leido': false,
        'data': {
          'event_id': eventId,
          'user_id': userId,
          'role': role,
        },
      });

      debugPrint('✅ Attendance confirmed');
    } catch (e) {
      debugPrint('❌ Error confirming attendance: $e');
      rethrow;
    }
  }

  /// Cancel attendance to an event
  Future<void> cancelAttendance(int eventId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Delete from participants
      await _supabase
          .from('participantes_evento')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);

      // Remove from lineup array
      final event = await _supabase
          .from('eventos')
          .select('lineup, organizador_id, titulo_bolo')
          .eq('id', eventId)
          .single();

      if (event['lineup'] != null) {
        List<String> lineup = List<String>.from(event['lineup']);
        lineup.remove(userId);
        
        await _supabase
            .from('eventos')
            .update({'lineup': lineup})
            .eq('id', eventId);
      }

      // Notify organizer
      final userProfile = await _supabase
          .from('perfiles')
          .select('nombre_artistico')
          .eq('id', userId)
          .single();

      await _supabase.from('notificaciones').insert({
        'user_id': event['organizador_id'],
        'tipo': 'attendance_cancelled',
        'titulo': 'Asistencia cancelada',
        'mensaje': '${userProfile['nombre_artistico']} canceló su asistencia a ${event['titulo_bolo']}',
        'leido': false,
        'data': {
          'event_id': eventId,
          'user_id': userId,
        },
      });

      debugPrint('✅ Attendance cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling attendance: $e');
      rethrow;
    }
  }
}

