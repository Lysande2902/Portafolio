import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _api = ApiService();
  List<Notificacion> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      // Endpoint simulado, ajustar según backend real si existe /api/notificaciones
      // Si no existe, usamos mock o lo agregamos al backend
      final response = await _api.get('/notificaciones'); 
      if (response is List) {
        setState(() {
          _notifications = response.map((n) => Notificacion.fromJson(n)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Mock data for demo if endpoint fails (common in WIP)
      setState(() {
        _notifications = [
          Notificacion(id: 1, titulo: 'Bienvenido', mensaje: 'Gracias por unirte a Óolale', tipo: 'info', leida: false, fecha: DateTime.now()),
          Notificacion(id: 2, titulo: 'Completa tu perfil', mensaje: 'Agrega instrumentos para conectar.', tipo: 'warning', leida: false, fecha: DateTime.now().subtract(Duration(hours: 2))),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notif = _notifications[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: notif.leida ? Colors.transparent : AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  leading: Icon(
                    notif.tipo == 'warning' ? Icons.warning_amber_rounded : Icons.info_outline,
                    color: notif.tipo == 'warning' ? AppConstants.accentColor : AppConstants.primaryColor,
                  ),
                  title: Text(notif.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(notif.mensaje, style: const TextStyle(color: Colors.white70)),
                  trailing: Text(
                    '${notif.fecha.hour}:${notif.fecha.minute}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              );
            },
          ),
    );
  }
}
