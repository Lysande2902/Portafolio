import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../profile/public_profile_screen.dart';
import '../../utils/error_handler.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('🔍 Cargando usuarios bloqueados para: $myId');
      
      final data = await _supabase
          .from('usuarios_bloqueados')
          .select('*, bloqueado:perfiles!usuarios_bloqueados_bloqueado_id_fkey(id, nombre_artistico, foto_perfil, rol_principal, ubicacion)')
          .eq('usuario_id', myId)
          .eq('activo', true)
          .order('created_at', ascending: false);

      debugPrint('📦 Usuarios bloqueados encontrados: ${data.length}');

      if (mounted) {
        setState(() {
          _blockedUsers = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('BlockedUsersScreen._loadBlockedUsers', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context, 
          e, 
          title: 'Error al cargar bloqueados',
          onRetry: _loadBlockedUsers
        );
      }
    }
  }

  Future<void> _unblockUser(dynamic blockId, String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Desbloquear usuario', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro que quieres desbloquear a $userName?',
          style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
            ),
            child: Text('Desbloquear', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      debugPrint('🔓 Desbloqueando usuario: $blockId');
      
      // Marcar como inactivo en lugar de eliminar
      await _supabase
          .from('usuarios_bloqueados')
          .update({
            'activo': false,
            'desbloqueado_en': DateTime.now().toIso8601String(),
          })
          .eq('id', blockId);

      debugPrint('✅ Usuario desbloqueado exitosamente');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Usuario desbloqueado', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _loadBlockedUsers(); // Recargar lista
      }
    } catch (e) {
      ErrorHandler.logError('BlockedUsersScreen._unblockUser', e);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e, 
          customMessage: 'No se pudo desbloquear al usuario'
        );
      }
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
          'Usuarios Bloqueados',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: ThemeColors.icon(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _blockedUsers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadBlockedUsers,
                  color: AppConstants.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _blockedUsers.length,
                    itemBuilder: (context, index) {
                      final block = _blockedUsers[index];
                      final user = block['bloqueado'];
                      return _buildBlockedUserCard(block, user);
                    },
                  ),
                ),
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
              Icons.block_outlined,
              size: 80,
              color: ThemeColors.iconSecondary(context),
            ),
            const SizedBox(height: 20),
            Text(
              'No has bloqueado a nadie',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los usuarios bloqueados aparecerán aquí',
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

  Widget _buildBlockedUserCard(Map<String, dynamic> block, Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push('/profile/${user['id']}'),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppConstants.bgDarkAlt,
                backgroundImage: user['foto_perfil'] != null
                    ? NetworkImage(user['foto_perfil'])
                    : null,
                child: user['foto_perfil'] == null
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
                  onTap: () => context.push('/profile/${user['id']}'),
                  child: Text(
                    user['nombre_artistico'] ?? 'Artista',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryText(context),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (user['rol_principal'] ?? 'musico').toString().toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user['ubicacion'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: ThemeColors.secondaryText(context)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          user['ubicacion'],
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
              ],
            ),
          ),
          // Botón desbloquear
          IconButton(
            onPressed: () => _unblockUser(
              block['id'],
              user['id'].toString(),
              user['nombre_artistico'] ?? 'Artista',
            ),
            icon: const Icon(Icons.block, color: Colors.red),
            tooltip: 'Desbloquear',
          ),
        ],
      ),
    );
  }
}
