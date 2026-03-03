import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../../models/event.dart';
import '../../services/notification_service.dart';
import '../reports/report_content_screen.dart';

class GigDetailScreen extends StatefulWidget {
  final int gigId;
  const GigDetailScreen({super.key, required this.gigId});

  @override
  State<GigDetailScreen> createState() => _GigDetailScreenState();
}

class _GigDetailScreenState extends State<GigDetailScreen> {
  final _supabase = Supabase.instance.client;
  Evento? _gig;
  Map<String, dynamic>? _organizer;
  List<dynamic> _lineup = [];
  bool _isLoading = true;
  bool _isPostulating = false;
  bool _alreadyInLineup = false;

  @override
  void initState() {
    super.initState();
    _loadGigDetails();
  }

  Future<void> _loadGigDetails() async {
    final myId = _supabase.auth.currentUser?.id;
    try {
      debugPrint('Loading gig with ID: ${widget.gigId}');
      
      final gigData = await _supabase
          .from('eventos')
          .select()
          .eq('id', widget.gigId)
          .maybeSingle();

      if (gigData == null) {
        debugPrint('Gig not found with ID: ${widget.gigId}');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Load organizer separately
      final organizer = await _supabase
          .from('perfiles')
          .select()
          .eq('id', gigData['organizador_id'] ?? '')
          .maybeSingle();

      final lineupData = await _supabase
          .from('participantes_evento')
          .select('*, perfiles(id, nombre_artistico, foto_perfil)')
          .eq('event_id', widget.gigId);

      // Obtener lista de usuarios bloqueados
      List<String> blockedIds = [];
      if (myId != null) {
        final blockedUsers = await _supabase
            .from('usuarios_bloqueados')
            .select('bloqueado_id')
            .eq('usuario_id', myId)
            .eq('activo', true);
        
        blockedIds = blockedUsers.map((b) => b['bloqueado_id'] as String).toList();
      }

      if (mounted) {
        // Filtrar usuarios bloqueados del lineup
        final filteredLineup = (lineupData as List)
            .where((l) => !blockedIds.contains(l['user_id']))
            .toList();

        setState(() {
          _gig = Evento.fromJson(gigData);
          _organizer = organizer;
          _lineup = filteredLineup;
          _alreadyInLineup = filteredLineup.any((l) => l['user_id'] == myId);
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('GigDetailScreen._loadGigDetails', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al cargar detalles',
          onRetry: _loadGigDetails,
        );
      }
    }
  }

  Future<void> _postulate() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    // Capture ScaffoldMessenger before async operations
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isPostulating = true);
    try {
      // Insertar postulación
      await _supabase.from('participantes_evento').insert({
        'event_id': widget.gigId,
        'user_id': myId,
        'role': 'Interesado',
        'confirmed': false,
      });

      // Crear notificación de postulación a evento
      if (_gig?.organizadorId != null) {
        try {
          final myProfile = await _supabase
              .from('perfiles')
              .select('nombre_artistico')
              .eq('id', myId)
              .single();

          await _supabase.from('notificaciones').insert({
            'user_id': _gig!.organizadorId,
            'tipo': 'gig_postulation',
            'titulo': 'Nueva postulación',
            'mensaje': '${myProfile['nombre_artistico']} mostró interés en tu evento "${_gig!.titulo}"',
            'leido': false,
            'data': {'sender_id': myId, 'event_id': widget.gigId},
          });
        } catch (notifError) {
          debugPrint('Error creando notificación: $notifError');
          // No bloquear la funcionalidad principal si falla la notificación
        }
      }

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Interés enviado correctamente'), backgroundColor: AppConstants.primaryColor),
        );
        _loadGigDetails();
      }
    } catch (e) {
      ErrorHandler.logError('GigDetailScreen._postulate', e);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al enviar interés',
          onRetry: _postulate,
        );
      }
    } finally {
      if (mounted) setState(() => _isPostulating = false);
    }
  }

  void _shareGig() {
    if (_gig == null) return;
    Share.share('¡Checa este evento en Óolale! ${_gig!.titulo} @ ${_gig!.ubicacion} - https://oolale.app/gig/${widget.gigId}');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
      );
    }

    if (_gig == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.not_interested, color: ThemeColors.disabledText(context), size: 64),
              const SizedBox(height: 16),
              Text('Evento no encontrado', style: TextStyle(color: ThemeColors.secondaryText(context), fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildHeroImage(),
          _buildDetailContent(),
          _buildAppBar(),
          if (_gig?.organizadorId != _supabase.auth.currentUser?.id)
             _buildStickyAction(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final myId = _supabase.auth.currentUser?.id;
    final isMyEvent = _gig?.organizadorId == myId;

    return Positioned(
      top: 40,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              // Botón de menú (sin opción de reportar si es tu propio evento)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: ThemeColors.icon(context)),
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'report') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportContentScreen(
                          contentType: 'event',
                          contentId: widget.gigId.toString(),
                          contentTitle: _gig!.titulo,
                        ),
                      ),
                    );
                  } else if (value == 'share') {
                    _shareGig();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        const Icon(Icons.share, color: AppConstants.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text('Compartir', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context))),
                      ],
                    ),
                  ),
                  // Solo mostrar opción de reportar si NO es tu evento
                  if (!isMyEvent)
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Text('Reportar evento', style: GoogleFonts.outfit(color: Colors.orange)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConstants.primaryColor.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (_gig!.flyerUrl != null)
            Image.network(_gig!.flyerUrl!, width: double.infinity, height: 400, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 350),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(),
                const SizedBox(height: 30),
                _buildOrganizerRow(),
                const SizedBox(height: 30),
                _buildSectionTitle('Detalles'),
                Text(
                  _gig!.descripcion,
                  style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), height: 1.6, fontSize: 16),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Categoría'),
                _buildBadge(_gig!.tipo.toUpperCase()),
                const SizedBox(height: 30),
                // Requisitos técnicos si existen
                if (_gig!.tipo == 'concierto' || _gig!.tipo == 'ensayo') ...[
                  _buildSectionTitle('Requisitos'),
                  Text('Contacto con el organizador para más detalles.', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 14)),
                  const SizedBox(height: 30),
                ],
                _buildLineupSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _gig!.titulo,
          style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildInfoChip(Icons.calendar_today_rounded, DateFormat('dd MMM, yyyy').format(_gig!.fecha)),
            const SizedBox(width: 15),
            _buildInfoChip(Icons.access_time_rounded, _gig!.hora),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppConstants.primaryColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _gig!.ubicacion,
                style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryColor, size: 14),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOrganizerRow() {
    return GestureDetector(
      onTap: () => context.push('/portfolio/${_organizer?['id']}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.divider(context)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppConstants.bgDarkAlt,
              backgroundImage: _organizer?['foto_perfil'] != null ? NetworkImage(_organizer!['foto_perfil']) : null,
              child: _organizer?['foto_perfil'] == null 
                ? const Icon(Icons.person, color: Colors.grey, size: 20) : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Organizado por', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 11)),
                  Text(
                    _organizer?['nombre_artistico'] ?? 'Artista',
                    style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(Icons.chat_bubble_outline, color: AppConstants.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLineupSection() {
    if (_lineup.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Confirmados'),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _lineup.length,
            itemBuilder: (context, index) {
              final artist = _lineup[index]['profiles'];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => context.push('/portfolio/${artist['id']}'),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppConstants.bgDarkAlt,
                    backgroundImage: artist['foto_perfil'] != null ? NetworkImage(artist['foto_perfil']) : null,
                    child: artist['foto_perfil'] == null 
                      ? const Icon(Icons.person, color: Colors.grey) : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Text(text, style: GoogleFonts.outfit(color: AppConstants.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStickyAction() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de Chat del Evento (solo si ya está en el lineup)
            if (_alreadyInLineup) ...[
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/event-chat/${widget.gigId}', extra: {
                    'eventTitle': _gig!.titulo,
                  });
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(
                  'Chat del Evento',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: AppConstants.primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Botón principal de acción
            ElevatedButton(
              onPressed: (_isPostulating || _alreadyInLineup) ? null : _postulate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isPostulating
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text(
                      _alreadyInLineup ? 'Interés Enviado' : 'Unirme',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
