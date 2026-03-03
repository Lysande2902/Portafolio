import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  String _profileVisibility = 'public'; // public, connections, private
  String _messagePermissions = 'everyone'; // everyone, connections, nobody
  bool _showActivity = true;
  bool _showOnlineStatus = true;
  bool _showLocation = true;
  bool _allowTagging = true;
  bool _showInSearch = true;

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
          .from('configuracion_privacidad')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _profileVisibility = data['profile_visibility'] ?? 'public';
          _messagePermissions = data['message_permissions'] ?? 'everyone';
          _showActivity = data['show_activity'] ?? true;
          _showOnlineStatus = data['show_online_status'] ?? true;
          _showLocation = data['show_location'] ?? true;
          _allowTagging = data['allow_tagging'] ?? true;
          _showInSearch = data['show_in_search'] ?? true;
          _isLoading = false;
        });
      } else {
        // Crear configuración por defecto
        await _createDefaultSettings(userId).catchError((e) {
             ErrorHandler.logError('PrivacySettingsScreen._loadSettings.createDefault', e);
        });
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      ErrorHandler.logError('PrivacySettingsScreen._loadSettings', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context, 
          e, 
          title: 'Error al cargar privacidad',
          onRetry: _loadSettings
        );
      }
    }
  }

  Future<void> _createDefaultSettings(String userId) async {
    try {
      await _supabase.from('configuracion_privacidad').insert({
        'user_id': userId,
        'profile_visibility': 'public',
        'message_permissions': 'everyone',
        'show_activity': true,
        'show_online_status': true,
        'show_location': true,
        'allow_tagging': true,
        'show_in_search': true,
      });
    } catch (e) {
      ErrorHandler.logError('PrivacySettingsScreen._createDefaultSettings', e);
      rethrow;
    }
  }

  Future<void> _updateSetting(String field, dynamic value) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('configuracion_privacidad')
          .update({field: value})
          .eq('user_id', userId);
    } catch (e) {
      ErrorHandler.logError('PrivacySettingsScreen._updateSetting', e);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e, 
          customMessage: 'Error al actualizar privacidad'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('PRIVACIDAD', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection('VISIBILIDAD DEL PERFIL'),
                _buildRadioTile(
                  'Público',
                  'Cualquiera puede ver tu perfil',
                  Icons.public_rounded,
                  'public',
                  _profileVisibility,
                  (val) {
                    setState(() => _profileVisibility = val!);
                    _updateSetting('profile_visibility', val);
                  },
                ),
                _buildRadioTile(
                  'Solo Conexiones',
                  'Solo tus conexiones pueden ver tu perfil',
                  Icons.people_rounded,
                  'connections',
                  _profileVisibility,
                  (val) {
                    setState(() => _profileVisibility = val!);
                    _updateSetting('profile_visibility', val);
                  },
                ),
                _buildRadioTile(
                  'Privado',
                  'Nadie puede ver tu perfil',
                  Icons.lock_rounded,
                  'private',
                  _profileVisibility,
                  (val) {
                    setState(() => _profileVisibility = val!);
                    _updateSetting('profile_visibility', val);
                  },
                ),

                const SizedBox(height: 30),
                _buildSection('MENSAJES'),
                _buildRadioTile(
                  'Todos',
                  'Cualquiera puede enviarte mensajes',
                  Icons.message_rounded,
                  'everyone',
                  _messagePermissions,
                  (val) {
                    setState(() => _messagePermissions = val!);
                    _updateSetting('message_permissions', val);
                  },
                ),
                _buildRadioTile(
                  'Solo Conexiones',
                  'Solo tus conexiones pueden enviarte mensajes',
                  Icons.people_rounded,
                  'connections',
                  _messagePermissions,
                  (val) {
                    setState(() => _messagePermissions = val!);
                    _updateSetting('message_permissions', val);
                  },
                ),
                _buildRadioTile(
                  'Nadie',
                  'No recibirás mensajes de nadie',
                  Icons.block_rounded,
                  'nobody',
                  _messagePermissions,
                  (val) {
                    setState(() => _messagePermissions = val!);
                    _updateSetting('message_permissions', val);
                  },
                ),

                const SizedBox(height: 30),
                _buildSection('ACTIVIDAD'),
                _buildSwitchTile(
                  'Mostrar Actividad',
                  'Otros pueden ver tu actividad reciente',
                  Icons.timeline_rounded,
                  _showActivity,
                  (val) {
                    setState(() => _showActivity = val);
                    _updateSetting('show_activity', val);
                  },
                ),
                _buildSwitchTile(
                  'Estado en Línea',
                  'Mostrar cuando estás en línea',
                  Icons.circle,
                  _showOnlineStatus,
                  (val) {
                    setState(() => _showOnlineStatus = val);
                    _updateSetting('show_online_status', val);
                  },
                ),
                _buildSwitchTile(
                  'Mostrar Ubicación',
                  'Mostrar tu ciudad en el perfil',
                  Icons.location_on_rounded,
                  _showLocation,
                  (val) {
                    setState(() => _showLocation = val);
                    _updateSetting('show_location', val);
                  },
                ),

                const SizedBox(height: 30),
                _buildSection('INTERACCIONES'),
                _buildSwitchTile(
                  'Permitir Etiquetas',
                  'Otros pueden etiquetarte en publicaciones',
                  Icons.local_offer_rounded,
                  _allowTagging,
                  (val) {
                    setState(() => _allowTagging = val);
                    _updateSetting('allow_tagging', val);
                  },
                ),
                _buildSwitchTile(
                  'Aparecer en Búsquedas',
                  'Tu perfil aparece en resultados de búsqueda',
                  Icons.search_rounded,
                  _showInSearch,
                  (val) {
                    setState(() => _showInSearch = val);
                    _updateSetting('show_in_search', val);
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

  Widget _buildRadioTile(String title, String subtitle, IconData icon, String value, String groupValue, Function(String?) onChanged) {
    final isSelected = value == groupValue;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppConstants.primaryColor : ThemeColors.divider(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isSelected ? AppConstants.primaryColor : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isSelected ? AppConstants.primaryColor : Colors.grey, size: 22),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: ThemeColors.hintText(context), fontSize: 12)),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
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
          Icon(Icons.shield_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu privacidad es importante. Estas configuraciones te ayudan a controlar quién puede ver tu información y cómo interactúan contigo.',
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
