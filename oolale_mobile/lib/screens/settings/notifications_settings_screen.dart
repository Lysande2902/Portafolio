import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _connectionRequests = true;
  bool _eventInvitations = true;
  bool _messages = true;
  bool _ratings = true;
  bool _eventReminders = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('configuracion_notificaciones')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _pushEnabled = data['push_enabled'] ?? true;
          _emailEnabled = data['email_enabled'] ?? true;
          _connectionRequests = data['connection_requests'] ?? true;
          _eventInvitations = data['event_invitations'] ?? true;
          _messages = data['messages'] ?? true;
          _ratings = data['ratings'] ?? true;
          _eventReminders = data['event_reminders'] ?? true;
          _soundEnabled = data['sound_enabled'] ?? true;
          _vibrationEnabled = data['vibration_enabled'] ?? true;
          _isLoading = false;
        });
      } else {
        // Crear configuración por defecto
        await _createDefaultSettings(userId).catchError((e) {
             ErrorHandler.logError('NotificationsSettingsScreen._loadSettings.createDefault', e);
        });
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      ErrorHandler.logError('NotificationsSettingsScreen._loadSettings', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context, 
          e, 
          title: 'Error al cargar notificaciones',
          onRetry: _loadSettings
        );
      }
    }
  }

  Future<void> _createDefaultSettings(String userId) async {
    try {
      await _supabase.from('configuracion_notificaciones').insert({
        'user_id': userId,
        'push_enabled': true,
        'email_enabled': true,
        'connection_requests': true,
        'event_invitations': true,
        'messages': true,
        'ratings': true,
        'event_reminders': true,
        'sound_enabled': true,
        'vibration_enabled': true,
      });
    } catch (e) {
      ErrorHandler.logError('NotificationsSettingsScreen._createDefaultSettings', e);
      rethrow;
    }
  }

  Future<void> _updateSetting(String field, bool value) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('configuracion_notificaciones')
          .update({field: value})
          .eq('user_id', userId);
    } catch (e) {
      ErrorHandler.logError('NotificationsSettingsScreen._updateSetting', e);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e, 
          customMessage: 'Error al actualizar notificaciones'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('NOTIFICACIONES', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection('CANALES'),
                _buildSwitchTile(
                  'Notificaciones Push',
                  'Recibe alertas en tu dispositivo',
                  Icons.notifications_active_rounded,
                  _pushEnabled,
                  (val) {
                    setState(() => _pushEnabled = val);
                    _updateSetting('push_enabled', val);
                  },
                ),
                _buildSwitchTile(
                  'Notificaciones por Email',
                  'Recibe alertas en tu correo',
                  Icons.email_rounded,
                  _emailEnabled,
                  (val) {
                    setState(() => _emailEnabled = val);
                    _updateSetting('email_enabled', val);
                  },
                ),

                const SizedBox(height: 30),
                _buildSection('TIPOS DE NOTIFICACIONES'),
                _buildSwitchTile(
                  'Solicitudes de Conexión',
                  'Cuando alguien quiere conectar contigo',
                  Icons.person_add_rounded,
                  _connectionRequests,
                  (val) {
                    setState(() => _connectionRequests = val);
                    _updateSetting('connection_requests', val);
                  },
                ),
                _buildSwitchTile(
                  'Invitaciones a Eventos',
                  'Cuando te invitan a un evento',
                  Icons.event_rounded,
                  _eventInvitations,
                  (val) {
                    setState(() => _eventInvitations = val);
                    _updateSetting('event_invitations', val);
                  },
                ),
                _buildSwitchTile(
                  'Mensajes',
                  'Cuando recibes un mensaje nuevo',
                  Icons.message_rounded,
                  _messages,
                  (val) {
                    setState(() => _messages = val);
                    _updateSetting('messages', val);
                  },
                ),
                _buildSwitchTile(
                  'Calificaciones',
                  'Cuando recibes una nueva calificación',
                  Icons.star_rounded,
                  _ratings,
                  (val) {
                    setState(() => _ratings = val);
                    _updateSetting('ratings', val);
                  },
                ),
                _buildSwitchTile(
                  'Recordatorios de Eventos',
                  'Recordatorios de eventos próximos',
                  Icons.alarm_rounded,
                  _eventReminders,
                  (val) {
                    setState(() => _eventReminders = val);
                    _updateSetting('event_reminders', val);
                  },
                ),

                const SizedBox(height: 30),
                _buildSection('PREFERENCIAS'),
                _buildSwitchTile(
                  'Sonido',
                  'Reproducir sonido con notificaciones',
                  Icons.volume_up_rounded,
                  _soundEnabled,
                  (val) {
                    setState(() => _soundEnabled = val);
                    _updateSetting('sound_enabled', val);
                  },
                ),
                _buildSwitchTile(
                  'Vibración',
                  'Vibrar con notificaciones',
                  Icons.vibration_rounded,
                  _vibrationEnabled,
                  (val) {
                    setState(() => _vibrationEnabled = val);
                    _updateSetting('vibration_enabled', val);
                  },
                ),

                const SizedBox(height: 20),
                _buildInfoCard(),
              ],
            ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppConstants.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 22),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: ThemeColors.hintText(context), fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Puedes cambiar estas configuraciones en cualquier momento. Las notificaciones te ayudan a estar al día con tu red musical.',
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
