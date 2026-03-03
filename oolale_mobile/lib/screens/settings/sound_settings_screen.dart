import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  bool _isLoading = true;
  bool _messageSounds = true;
  bool _notificationSounds = true;
  bool _eventSounds = true;
  bool _connectionSounds = true;
  bool _vibration = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _messageSounds = prefs.getBool('message_sounds') ?? true;
        _notificationSounds = prefs.getBool('notification_sounds') ?? true;
        _eventSounds = prefs.getBool('event_sounds') ?? true;
        _connectionSounds = prefs.getBool('connection_sounds') ?? true;
        _vibration = prefs.getBool('vibration') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sound settings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('SONIDOS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection('SONIDOS DE NOTIFICACIÓN'),
                _buildSwitchTile(
                  'Mensajes',
                  'Sonido al recibir mensajes',
                  Icons.message_rounded,
                  _messageSounds,
                  (val) {
                    setState(() => _messageSounds = val);
                    _updateSetting('message_sounds', val);
                  },
                ),
                _buildSwitchTile(
                  'Notificaciones',
                  'Sonido para notificaciones generales',
                  Icons.notifications_rounded,
                  _notificationSounds,
                  (val) {
                    setState(() => _notificationSounds = val);
                    _updateSetting('notification_sounds', val);
                  },
                ),
                _buildSwitchTile(
                  'Eventos',
                  'Sonido para invitaciones a eventos',
                  Icons.event_rounded,
                  _eventSounds,
                  (val) {
                    setState(() => _eventSounds = val);
                    _updateSetting('event_sounds', val);
                  },
                ),
                _buildSwitchTile(
                  'Conexiones',
                  'Sonido para nuevas conexiones',
                  Icons.people_rounded,
                  _connectionSounds,
                  (val) {
                    setState(() => _connectionSounds = val);
                    _updateSetting('connection_sounds', val);
                  },
                ),

                const SizedBox(height: 30),
                _buildSection('VIBRACIÓN'),
                _buildSwitchTile(
                  'Vibración',
                  'Vibrar con notificaciones',
                  Icons.vibration_rounded,
                  _vibration,
                  (val) {
                    setState(() => _vibration = val);
                    _updateSetting('vibration', val);
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
          Icon(Icons.volume_up_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Personaliza los sonidos de la aplicación según tus preferencias.',
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
