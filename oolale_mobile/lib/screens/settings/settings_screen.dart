import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'blocked_users_screen.dart';
import '../../utils/error_handler.dart';
import '../../services/seed_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  bool _pushEnabled = true;
  bool _dataSaver = false;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser?.id;
    
    try {
      // 1. Cargar Notificaciones desde Supabase
      if (userId != null) {
        final pushData = await _supabase
            .from('configuracion_notificaciones')
            .select('push_enabled')
            .eq('user_id', userId)
            .maybeSingle();
        
        if (pushData != null) {
          _pushEnabled = pushData['push_enabled'] ?? true;
        }
      }

      // 2. Cargar Ahorro de Datos desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _dataSaver = prefs.getBool('data_saver_enabled') ?? false;

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ErrorHandler.logError('SettingsScreen._loadAllSettings', e);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePush(bool value) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _pushEnabled = value);

    try {
      await _supabase
          .from('configuracion_notificaciones')
          .update({'push_enabled': value})
          .eq('user_id', userId);
    } catch (e) {
      ErrorHandler.logError('SettingsScreen._togglePush', e);
      // Revertir si hay error
      setState(() => _pushEnabled = !value);
    }
  }

  Future<void> _toggleDataSaver(bool value) async {
    setState(() => _dataSaver = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('data_saver_enabled', value);
    } catch (e) {
      ErrorHandler.logError('SettingsScreen._toggleDataSaver', e);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar Sesión', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro que quieres salir de tu cuenta?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Salir', style: GoogleFonts.outfit(color: AppConstants.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) context.go('/login');
    }
  }

  void _showDeveloperOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.cardColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Developer Tools', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: ThemeColors.primaryText(context))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.people_alt_outlined, color: AppConstants.primaryColor),
              title: Text('Poblar Base de Datos (Seed Users)', style: TextStyle(color: ThemeColors.primaryText(context))),
              subtitle: const Text('Crear 20 usuarios falsos + perfiles', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Creando usuarios... espera...')));
                SeedService().seedUsers(count: 20).then((_) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuarios creados!')));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note, color: Colors.orange),
              title: Text('Poblar Eventos (Seed Events)', style: TextStyle(color: ThemeColors.primaryText(context))),
              subtitle: const Text('Crear 10 eventos aleatorios', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Creando eventos... espera...')));
                SeedService().seedEvents(count: 10).then((_) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eventos creados!')));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('CONFIGURACIÓN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('CUENTA'),
                _buildSettingTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Editar Perfil',
                  subtitle: 'Información personal y avatar',
                  onTap: () => context.push('/edit-profile'),
                ),
                _buildSettingTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Billetera',
                  subtitle: 'Balance y transacciones',
                  onTap: () => context.push('/wallet'),
                ),
                _buildSettingTile(
                  icon: Icons.security_rounded,
                  title: 'Seguridad y Privacidad',
                  subtitle: 'Contraseña, bloqueos y visibilidad',
                  onTap: () => context.push('/settings/privacy-settings'),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('PREFERENCIAS'),
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Modo Oscuro',
                  value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
                  onChanged: (val) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(val),
                ),
                _buildSettingTile(
                  icon: Icons.text_fields_rounded,
                  title: 'Tamaño de Fuente',
                  subtitle: 'Ajusta la legibilidad',
                  onTap: () => context.push('/settings/font-size'),
                ),
                _buildSettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notificaciones',
                  subtitle: 'Gestionar alertas push',
                  onTap: () => context.push('/settings/notifications'),
                ),
                _buildSettingTile(
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: 'Seleccionar idioma de la app',
                  onTap: () => context.push('/language'),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('SOPORTE Y AYUDA'),
                _buildSettingTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Centro de Ayuda',
                  subtitle: 'Preguntas frecuentes y soporte',
                  onTap: () => context.push('/settings/help'),
                  iconColor: Colors.blueAccent,
                ),
                _buildSettingTile(
                  icon: Icons.bug_report_rounded,
                  title: 'Reportar un Problema',
                  subtitle: 'Informa sobre errores o fallos',
                  onTap: () {
                     // TODO: Llevar a pantalla de reporte general o abrir email
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Función de reporte directo en construcción')),
                     );
                  },
                  iconColor: Colors.orange,
                ),

                const SizedBox(height: 32),
                _buildDangerZone(),
                
                const SizedBox(height: 20),
                GestureDetector(
                  onLongPress: _showDeveloperOptions, 
                  onTap: _showDeveloperOptions, 
                  child: Center(
                    child: Text(
                      'Opciones de Desarrollador (Tap)', 
                      style: GoogleFonts.outfit(color: Colors.grey.withOpacity(0.5), fontSize: 12)
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildVersionInfo(),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppConstants.primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppConstants.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppConstants.primaryColor, size: 22),
        ),
        title: Text(
          title, 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle, 
          style: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: ThemeColors.hintText(context), size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 22),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('CERRAR SESIÓN'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppConstants.errorColor.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'ÓOLALE CONNECT',
            style: GoogleFonts.poppins(
              color: AppConstants.primaryColor.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Versión 1.0.0 Stable',
            style: GoogleFonts.outfit(color: ThemeColors.hintText(context).withOpacity(0.3), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
