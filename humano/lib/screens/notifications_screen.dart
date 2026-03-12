import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/auth_provider.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    
    // Forzar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Marcar todas como leídas al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        notificationsProvider.markAllAsRead(authProvider.currentUser!.uid);
      }
    });
  }

  Color _getToneColor(NotificationTone tone) {
    switch (tone) {
      case NotificationTone.neutral:
        return Colors.grey[400]!;
      case NotificationTone.curious:
        return Colors.yellow[700]!;
      case NotificationTone.unsettling:
        return Colors.orange[700]!;
      case NotificationTone.horrifying:
        return Colors.red[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red[300]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOTIFICACIONES',
          style: GoogleFonts.shareTechMono(
            fontSize: 18,
            letterSpacing: 3,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificationsProvider, _) {
          final notifications = notificationsProvider.notifications;
          
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    color: Colors.grey[700],
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SIN NOTIFICACIONES',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final toneColor = _getToneColor(notification.tone);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border.all(
                    color: notification.isRead 
                        ? Colors.grey[800]! 
                        : toneColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: notification.isRead ? [] : [
                    BoxShadow(
                      color: toneColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con indicador de estado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        border: Border(
                          bottom: BorderSide(
                            color: toneColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Indicador de no leído
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: toneColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: toneColor,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          
                          // Título
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.shareTechMono(
                                fontSize: 14,
                                letterSpacing: 2,
                                color: toneColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          // Timestamp
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: GoogleFonts.courierPrime(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Mensaje
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        notification.message,
                        style: GoogleFonts.courierPrime(
                          fontSize: 13,
                          color: Colors.grey[300],
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
