import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _channel = _supabase
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notificaciones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            debugPrint('🔔 Nueva notificación recibida');
            _loadNotifications();
          },
        )
        .subscribe();
  }

  Future<void> _loadNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (!_isLoading) setState(() => _isLoading = true);
    
    try {
      debugPrint('📥 Cargando notificaciones para: $userId');
      
      final data = await _supabase
          .from('notificaciones')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('📦 Notificaciones cargadas: ${data.length}');

      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('NotificationsScreen._loadNotifications', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando notificaciones',
          onRetry: _loadNotifications,
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notificaciones')
          .update({'leido': true})
          .eq('id', notificationId);
      _loadNotifications();
    } catch (e) {
      ErrorHandler.logError('NotificationsScreen._markAsRead', e);
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notificaciones')
          .delete()
          .eq('id', notificationId);
      _loadNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notificación eliminada', style: GoogleFonts.outfit()),
            backgroundColor: Colors.grey.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ErrorHandler.logError('NotificationsScreen._deleteNotification', e);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al eliminar notificación');
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('notificaciones').update({'leido': true}).eq('user_id', userId);
      _loadNotifications();
    } catch (e) {
      ErrorHandler.logError('NotificationsScreen._markAllAsRead', e);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al marcar notificaciones');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['leido'] == false).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Alertas', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (unreadCount > 0)
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: AppConstants.primaryColor),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading && _notifications.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
            : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: AppConstants.primaryColor,
                    child: _buildNotificationsList(),
                  ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onDelete: () => _deleteNotification(notification['id']),
          onMarkAsRead: () => _markAsRead(notification['id']),
        );
      },
    );
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    // Marcar como leída
    if (notification['leido'] == false) {
      try {
        await _supabase
            .from('notificaciones')
            .update({'leido': true})
            .eq('id', notification['id']);
        _loadNotifications();
      } catch (e) {
        debugPrint('Error marcando notificación: $e');
      }
    }

    // Navegar según el tipo
    final tipo = notification['tipo'] as String?;
    final data = notification['data'] as Map<String, dynamic>?;

    if (data == null) return;
    
    try {
      switch (tipo) {
        case 'gig_postulation':
          if (data['event_id'] != null) {
            context.push('/gig/${data['event_id']}');
          }
          break;
        case 'connection_request':
          context.push('/connection-requests');
          break;
        case 'connection_accepted':
          context.push('/connections');
          break;
        case 'message':
        case 'new_message':
          // La ruta correcta es /messages/:id, no /chat/:id
          if (data['sender_id'] != null) {
            context.push('/messages/${data['sender_id']}');
          } else if (data['user_id'] != null) {
            context.push('/messages/${data['user_id']}');
          } else {
            context.push('/messages');
          }
          break;
        default:
          debugPrint('Tipo de notificación no manejado: $tipo');
      }
    } catch (e) {
      debugPrint('Error navegando desde notificación: $e');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: ThemeColors.iconSecondary(context)),
          const SizedBox(height: 16),
          Text(
            'Sin alertas pendientes',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = notification['leido'] == false;
    final createdAt = DateTime.parse(notification['created_at']);
    final tipo = notification['tipo'] as String?;

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? AppConstants.primaryColor.withOpacity(0.3) : ThemeColors.divider(context),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).cardColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUnread)
                      ListTile(
                        leading: const Icon(Icons.done, color: AppConstants.primaryColor),
                        title: Text('Marcar como leída', style: GoogleFonts.outfit()),
                        onTap: () {
                          Navigator.pop(context);
                          onMarkAsRead();
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text('Eliminar', style: GoogleFonts.outfit()),
                      onTap: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getIconColor(tipo).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(tipo), color: _getIconColor(tipo), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['titulo'] ?? 'Alerta',
                        style: GoogleFonts.outfit(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['mensaje'] ?? '',
                        style: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeago(createdAt),
                        style: GoogleFonts.outfit(color: ThemeColors.iconSecondary(context), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? tipo) {
    switch (tipo) {
      case 'gig_postulation':
        return Icons.event;
      case 'connection_request':
        return Icons.person_add;
      case 'connection_accepted':
        return Icons.check_circle_rounded;
      case 'message':
      case 'new_message':
        return Icons.message;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String? tipo) {
    switch (tipo) {
      case 'gig_postulation':
        return AppConstants.primaryColor;
      case 'connection_request':
        return Colors.blue;
      case 'connection_accepted':
        return Colors.green;
      case 'message':
      case 'new_message':
        return Colors.green;
      case 'payment':
        return Colors.orange;
      default:
        return AppConstants.primaryColor;
    }
  }

  String timeago(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
