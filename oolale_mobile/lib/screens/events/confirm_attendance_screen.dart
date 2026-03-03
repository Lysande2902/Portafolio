import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme_colors.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';

/// Screen to confirm or cancel attendance to an event
class ConfirmAttendanceScreen extends StatefulWidget {
  final int eventId;

  const ConfirmAttendanceScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<ConfirmAttendanceScreen> createState() => _ConfirmAttendanceScreenState();
}

class _ConfirmAttendanceScreenState extends State<ConfirmAttendanceScreen> {
  final _eventService = EventService(Supabase.instance.client);
  final _supabase = Supabase.instance.client;
  
  Evento? _event;
  bool _isLoading = true;
  bool _isConfirmed = false;
  String? _currentRole;
  String? _error;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadEventAndStatus();
  }

  Future<void> _loadEventAndStatus() async {
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

      // Check if user is already confirmed
      final status = await _eventService.getAttendanceStatus(
        widget.eventId,
        userId,
      );

      setState(() {
        _isConfirmed = status['confirmed'] ?? false;
        _currentRole = status['role'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAttendance(String role) async {
    setState(() => _isProcessing = true);

    try {
      await _eventService.confirmAttendance(
        widget.eventId,
        role,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Asistencia confirmada'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _cancelAttendance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar asistencia'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar tu asistencia a este evento?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);

      try {
        await _eventService.cancelAttendance(widget.eventId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Asistencia cancelada'),
              backgroundColor: Colors.orange,
            ),
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Asistencia'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEventAndStatus,
              child: const Text('Reintentar'),
            ),
          ],
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
          _buildEventCard(),
          const SizedBox(height: 24),
          if (_isConfirmed) ...[
            _buildConfirmedStatus(),
            const SizedBox(height: 24),
            _buildCancelButton(),
          ] else ...[
            _buildRoleSelection(),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _event!.titulo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_event!.fecha.day}/${_event!.fecha.month}/${_event!.fecha.year}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(_event!.hora),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_event!.ubicacion)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 8),
                Text(_getEventTypeLabel(_event!.tipo)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmedStatus() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Asistencia confirmada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (_currentRole != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Rol: ${_getRoleLabel(_currentRole!)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tu rol en el evento:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          'headliner',
          '🌟 Headliner',
          'Artista principal del evento',
          Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          'support',
          '🎸 Support',
          'Artista de soporte o telonero',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          'guest',
          '🎤 Invitado',
          'Participación especial',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          'crew',
          '🔧 Crew',
          'Equipo técnico o staff',
          Colors.teal,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          'participant',
          '👥 Participante',
          'Asistente general',
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    String roleValue,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: _isProcessing ? null : () => _confirmAttendance(roleValue),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    title.split(' ')[0],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.split(' ').skip(1).join(' '),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _cancelAttendance,
        icon: const Icon(Icons.cancel),
        label: const Text('Cancelar Asistencia'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _getEventTypeLabel(String tipo) {
    switch (tipo) {
      case 'concierto':
        return '🎵 Concierto';
      case 'ensayo':
        return '🎹 Ensayo';
      case 'jam':
        return '🎸 Jam Session';
      default:
        return '📅 Otro';
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'headliner':
        return 'Headliner';
      case 'support':
        return 'Support';
      case 'guest':
        return 'Invitado';
      case 'crew':
        return 'Crew';
      case 'participant':
        return 'Participante';
      default:
        return role;
    }
  }
}
