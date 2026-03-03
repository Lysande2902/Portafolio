import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme_colors.dart';
import '../../services/event_service.dart';

/// Screen to display and manage event lineup
/// Shows confirmed participants with their roles
class EventLineupScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;
  final bool isOrganizer;

  const EventLineupScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    this.isOrganizer = false,
  });

  @override
  State<EventLineupScreen> createState() => _EventLineupScreenState();
}

class _EventLineupScreenState extends State<EventLineupScreen> {
  final _eventService = EventService(Supabase.instance.client);
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _lineup = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLineup();
  }

  Future<void> _loadLineup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lineup = await _eventService.getEventLineup(widget.eventId);
      setState(() {
        _lineup = lineup;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRole(String userId, String newRole) async {
    try {
      await _eventService.updateParticipantRole(
        widget.eventId,
        userId,
        newRole,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rol actualizado'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadLineup();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeParticipant(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover participante'),
        content: Text('¿Remover a $userName del lineup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _eventService.removeParticipant(widget.eventId, userId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participante removido'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadLineup();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRoleDialog(String userId, String currentRole, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar rol de $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleOption('headliner', 'Headliner', currentRole, userId),
            _buildRoleOption('support', 'Support', currentRole, userId),
            _buildRoleOption('guest', 'Invitado', currentRole, userId),
            _buildRoleOption('crew', 'Crew', currentRole, userId),
            _buildRoleOption('participant', 'Participante', currentRole, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    String roleValue,
    String roleLabel,
    String currentRole,
    String userId,
  ) {
    final isSelected = currentRole == roleValue;
    
    return ListTile(
      title: Text(roleLabel),
      leading: Radio<String>(
        value: roleValue,
        groupValue: currentRole,
        onChanged: (value) {
          if (value != null) {
            Navigator.pop(context);
            _updateRole(userId, value);
          }
        },
        activeColor: ThemeColors.primary,
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        _updateRole(userId, roleValue);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lineup'),
            Text(
              widget.eventTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLineup,
          ),
        ],
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
              onPressed: _loadLineup,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_lineup.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay participantes confirmados',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLineup,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildLineupByRole(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalParticipants = _lineup.length;
    final headliners = _lineup.where((p) => p['role'] == 'headliner').length;
    final supports = _lineup.where((p) => p['role'] == 'support').length;
    final guests = _lineup.where((p) => p['role'] == 'guest').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalParticipants, ThemeColors.primary),
                _buildStatItem('Headliners', headliners, Colors.purple),
                _buildStatItem('Supports', supports, Colors.blue),
                _buildStatItem('Invitados', guests, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLineupByRole() {
    // Group by role
    final headliners = _lineup.where((p) => p['role'] == 'headliner').toList();
    final supports = _lineup.where((p) => p['role'] == 'support').toList();
    final guests = _lineup.where((p) => p['role'] == 'guest').toList();
    final crew = _lineup.where((p) => p['role'] == 'crew').toList();
    final participants = _lineup.where((p) => 
      p['role'] == 'participant' || p['role'] == null
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headliners.isNotEmpty) ...[
          _buildRoleSection('🌟 Headliners', headliners, Colors.purple),
          const SizedBox(height: 16),
        ],
        if (supports.isNotEmpty) ...[
          _buildRoleSection('🎸 Supports', supports, Colors.blue),
          const SizedBox(height: 16),
        ],
        if (guests.isNotEmpty) ...[
          _buildRoleSection('🎤 Invitados', guests, Colors.orange),
          const SizedBox(height: 16),
        ],
        if (crew.isNotEmpty) ...[
          _buildRoleSection('🔧 Crew', crew, Colors.teal),
          const SizedBox(height: 16),
        ],
        if (participants.isNotEmpty) ...[
          _buildRoleSection('👥 Participantes', participants, Colors.grey),
        ],
      ],
    );
  }

  Widget _buildRoleSection(
    String title,
    List<Map<String, dynamic>> participants,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...participants.map((participant) => _buildParticipantCard(participant)),
      ],
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant) {
    final profile = participant['profile'] as Map<String, dynamic>?;
    final name = profile?['nombre_artistico'] ?? 'Usuario';
    final instrument = profile?['instrumento_principal'] ?? '';
    final avatarUrl = profile?['avatar_url'];
    final role = participant['role'] ?? 'participant';
    final userId = participant['user_id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? Text(name[0].toUpperCase()) : null,
        ),
        title: Text(name),
        subtitle: instrument.isNotEmpty ? Text(instrument) : null,
        trailing: widget.isOrganizer
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'change_role') {
                    _showRoleDialog(userId, role, name);
                  } else if (value == 'remove') {
                    _removeParticipant(userId, name);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Cambiar rol'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remover', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
