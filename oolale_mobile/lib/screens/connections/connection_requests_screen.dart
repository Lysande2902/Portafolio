import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../profile/public_profile_screen.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  State<ConnectionRequestsScreen> createState() => _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;
  RealtimeChannel? _requestsChannel;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    _setupRealtime();
  }

  @override
  void dispose() {
    _requestsChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    _requestsChannel = _supabase
        .channel('public:conexiones:requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conexiones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conectado_id',
            value: myId,
          ),
          callback: (payload) {
            debugPrint('🔔 REALTIME: Connection update received');
            _loadPendingRequests();
          },
        )
        .subscribe();
  }

  Future<void> _loadPendingRequests() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      // Obtener solicitudes pendientes donde YO soy el receptor
      final data = await _supabase
          .from('conexiones')
          .select('*, perfiles!conexiones_usuario_id_fkey(id, nombre_artistico, foto_perfil, rol_principal, ubicacion, rating_promedio)')
          .eq('conectado_id', myId)
          .eq('estatus', 'pending')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _pendingRequests = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('ConnectionRequestsScreen._loadPendingRequests', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando solicitudes',
          onRetry: _loadPendingRequests,
        );
      }
    }
  }

  Future<void> _acceptRequest(String connectionId, String userId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      // Actualizar estatus de la conexión
      await _supabase
          .from('conexiones')
          .update({'estatus': 'accepted', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', connectionId);

      // Obtener mi nombre artístico para la notificación
      try {
        final myProfile = await _supabase
            .from('perfiles')
            .select('nombre_artistico')
            .eq('id', myId)
            .single();

        // Crear notificación de conexión aceptada
        await _supabase.from('notificaciones').insert({
          'user_id': userId, // El que envió la solicitud
          'tipo': 'connection_accepted',
          'titulo': 'Solicitud aceptada',
          'mensaje': '${myProfile['nombre_artistico']} aceptó tu solicitud de conexión',
          'leido': false,
          'data': {'sender_id': myId},
        });
      } catch (notifError) {
        debugPrint('Error creando notificación: $notifError');
        // No bloquear la funcionalidad principal si falla la notificación
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Solicitud aceptada', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _loadPendingRequests(); // Recargar lista
      }
    } catch (e) {
      debugPrint('Error aceptando solicitud: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aceptar solicitud', style: GoogleFonts.outfit()),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(String connectionId) async {
    try {
      await _supabase
          .from('conexiones')
          .update({'estatus': 'rejected', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', connectionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.close, color: Colors.white),
                const SizedBox(width: 12),
                Text('Solicitud rechazada', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _loadPendingRequests(); // Recargar lista
      }
    } catch (e) {
      debugPrint('Error rechazando solicitud: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Solicitudes de Conexión',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: ThemeColors.icon(context)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _pendingRequests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPendingRequests,
                  color: AppConstants.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingRequests.length,
                    itemBuilder: (context, index) {
                      final request = _pendingRequests[index];
                      final profile = request['perfiles'];
                      return _buildRequestCard(request, profile);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: ThemeColors.iconSecondary(context),
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes solicitudes pendientes',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las solicitudes de conexión aparecerán aquí',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: ThemeColors.secondaryText(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, Map<String, dynamic> profile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => context.push('/profile/${profile['id']}'),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.primaryColor, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConstants.bgDarkAlt,
                    backgroundImage: profile['foto_perfil'] != null
                        ? NetworkImage(profile['foto_perfil'])
                        : null,
                    child: profile['foto_perfil'] == null
                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/profile/${profile['id']}'),
                      child: Text(
                        profile['nombre_artistico'] ?? 'Artista',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primaryText(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (profile['rol_principal'] ?? 'musico').toString().toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile['ubicacion'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: ThemeColors.secondaryText(context)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              profile['ubicacion'],
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: ThemeColors.secondaryText(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (profile['rating_promedio'] != null && profile['rating_promedio'] > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            final rating = profile['rating_promedio'] ?? 0.0;
                            return Icon(
                              index < rating.floor() ? Icons.star : Icons.star_border,
                              color: AppConstants.primaryColor,
                              size: 12,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            profile['rating_promedio'].toStringAsFixed(1),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: ThemeColors.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _acceptRequest(request['id'], profile['id']),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text('Aceptar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectRequest(request['id']),
                  icon: const Icon(Icons.close, size: 18),
                  label: Text('Rechazar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
