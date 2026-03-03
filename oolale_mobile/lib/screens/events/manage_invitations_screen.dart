import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../services/event_service.dart';
import 'package:intl/intl.dart';

class ManageInvitationsScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const ManageInvitationsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ManageInvitationsScreen> createState() => _ManageInvitationsScreenState();
}

class _ManageInvitationsScreenState extends State<ManageInvitationsScreen> {
  final _supabase = Supabase.instance.client;
  late EventService _eventService;
  
  List<Map<String, dynamic>> _invitations = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  Set<int> _processingInvitations = {};

  @override
  void initState() {
    super.initState();
    _eventService = EventService(_supabase);
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    try {
      final invitations = await _eventService.getSentInvitations(widget.eventId);
      final stats = await _eventService.getInvitationStats(widget.eventId);

      if (mounted) {
        setState(() {
          _invitations = invitations;
          _stats = stats;
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

  Future<void> _cancelInvitation(int invitationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Cancelar invitación', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de que quieres cancelar esta invitación?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: GoogleFonts.outfit()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sí, cancelar', style: GoogleFonts.outfit(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processingInvitations.add(invitationId));

    try {
      await _eventService.cancelInvitation(invitationId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitación cancelada'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadInvitations();
      }
    } catch (e) {
      debugPrint('Error cancelling invitation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cancelar invitación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingInvitations.remove(invitationId));
      }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invitaciones Enviadas',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              widget.eventTitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: ThemeColors.secondaryText(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : Column(
              children: [
                if (_stats.isNotEmpty) _buildStatsCard(),
                Expanded(
                  child: _invitations.isEmpty
                      ? _buildEmptyState()
                      : _buildInvitationsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard() {
    final total = _stats['total'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final accepted = _stats['accepted'] ?? 0;
    final declined = _stats['declined'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total',
                  value: total.toString(),
                  color: AppConstants.primaryColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Pendientes',
                  value: pending.toString(),
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Aceptadas',
                  value: accepted.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Rechazadas',
                  value: declined.toString(),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: ThemeColors.secondaryText(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
              'Sin invitaciones enviadas',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Invita músicos a tu evento para que aparezcan aquí',
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
        padding: const EdgeInsets.all(16),
        itemCount: _invitations.length,
        itemBuilder: (context, index) {
          final invitation = _invitations[index];
          final musician = invitation['perfiles'];
          final invitationId = invitation['id'];
          final status = invitation['status'];
          final createdAt = DateTime.parse(invitation['created_at']);
          final isProcessing = _processingInvitations.contains(invitationId);

          return _InvitationCard(
            musicianName: musician['nombre_artistico'] ?? 'Sin nombre',
            musicianAvatar: musician['avatar_url'],
            musicianLocation: musician['ubicacion'],
            status: status,
            createdAt: createdAt,
            isProcessing: isProcessing,
            onCancel: status == 'pending' 
                ? () => _cancelInvitation(invitationId)
                : null,
          );
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final String musicianName;
  final String? musicianAvatar;
  final String? musicianLocation;
  final String status;
  final DateTime createdAt;
  final bool isProcessing;
  final VoidCallback? onCancel;

  const _InvitationCard({
    required this.musicianName,
    this.musicianAvatar,
    this.musicianLocation,
    required this.status,
    required this.createdAt,
    required this.isProcessing,
    this.onCancel,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case 'accepted':
        return 'Aceptada';
      case 'declined':
        return 'Rechazada';
      default:
        return 'Pendiente';
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
              backgroundImage: musicianAvatar != null ? NetworkImage(musicianAvatar!) : null,
              child: musicianAvatar == null
                  ? Icon(Icons.person, size: 32, color: AppConstants.primaryColor)
                  : null,
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    musicianName,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (musicianLocation != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: ThemeColors.secondaryText(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          musicianLocation!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: ThemeColors.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Enviada ${DateFormat('dd MMM yyyy', 'es').format(createdAt)}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: ThemeColors.disabledText(context),
                    ),
                  ),
                ],
              ),
            ),
            // Status and actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 14,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusLabel(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isProcessing ? null : onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                        : Text(
                            'Cancelar',
                            style: GoogleFonts.outfit(fontSize: 12),
                          ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
