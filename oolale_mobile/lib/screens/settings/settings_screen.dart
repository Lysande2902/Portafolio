import 'package:flutter/material.dart';
import '../../config/constants.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import 'wallet_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Está seguro que desea salir de su cuenta?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
             onPressed: () {
               Navigator.pop(ctx);
               Provider.of<AuthProvider>(context, listen: false).logout();
               context.go('/login');
             },
             child: const Text('SALIR', style: TextStyle(color: AppConstants.errorColor)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('ENTORNO PROFESIONAL'),
          _buildSettingsTile(Icons.lock_outline, 'Seguridad y Credenciales', () {
             _showDemoNotice(context, 'Gestión de Seguridad', 'La actualización de credenciales está restringida en el entorno Demo por seguridad de red.');
          }),
          _buildSettingsTile(Icons.privacy_tip_outlined, 'Privacidad de Sinergias', () {
             _showDemoNotice(context, 'Privacidad', 'Tu perfil está configurado actualmente como "Elite Public" para maximizar el alcance en la demo.');
          }),
          _buildSettingsTile(Icons.notifications_outlined, 'Alertas Inteligentes', () {
             _showDemoNotice(context, 'Notificaciones', 'Las notificaciones push están activas para nuevos mensajes y matches de sinergia.');
          }),
          _buildSettingsTile(Icons.account_balance_wallet_outlined, 'Óolale Pay & Historial', () {
             Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen()));
          }),
          
          _buildSectionHeader('PREFERENCIAS DE SISTEMA'),
          _buildSettingsTile(Icons.language, 'Idioma (Español)', () {}),
          _buildSettingsTile(Icons.auto_awesome_mosaic_outlined, 'Óolale Boost Engine', () {
             _showDemoNotice(context, 'Boost Engine', 'El motor de visibilidad está operando al 124% para tu perfil actual.');
          }),
          
          _buildSectionHeader('ESTRATEGIA Y SOPORTE'),
          _buildSettingsTile(Icons.help_outline, 'Base de Conocimiento', () {
             _showDemoNotice(context, 'Soporte', 'Accediendo al terminal de ayuda... (Simulado)');
          }),
          _buildSettingsTile(Icons.flag_outlined, 'Auditoría de Conflictos', () {}),
          _buildSettingsTile(Icons.info_outline, 'Arquitectura Óolale v2.0', () {
            showAboutDialog(
              context: context, 
              applicationName: 'Óolale Premium',
              applicationVersion: '2.0.0-PRO-DEMO',
              applicationLegalese: 'Copyright © 2026 Óolale Network. Todos los derechos reservados para la escena musical.',
            );
          }),
          
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: AppConstants.errorColor),
              label: const Text('CERRAR SESIÓN', style: TextStyle(color: AppConstants.errorColor)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppConstants.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 15)
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showDemoNotice(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppConstants.primaryColor),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ENTENDIDO', style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
      onTap: onTap,
    );
  }
}
