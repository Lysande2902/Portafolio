import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _supabase = Supabase.instance.client;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _userEmail = _supabase.auth.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('AJUSTES DE CUENTA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection('INFORMACIÓN DE ACCESO'),
          _buildInfoTile(
            'Email',
            _userEmail,
            Icons.email_outlined,
            onTap: () => context.push('/settings/change-email'),
          ),
          _buildInfoTile(
            'Contraseña',
            '••••••••••••',
            Icons.lock_outline_rounded,
            onTap: () => context.push('/settings/change-password'),
          ),

          const SizedBox(height: 40),
          _buildSection('ESTADO DE LA CUENTA'),
          _buildActionTile(
            'Suspender Cuenta',
            'Desactiva tu perfil temporalmente',
            Icons.pause_circle_outline_rounded,
            color: Colors.orangeAccent,
            onTap: () => context.push('/settings/suspend-account'),
          ),
          _buildActionTile(
            'Eliminar Cuenta',
            'Borra permanentemente tus datos',
            Icons.delete_forever_rounded,
            color: AppConstants.errorColor,
            onTap: () => context.push('/settings/delete-account'),
          ),
          
          const SizedBox(height: 30),
          _buildHelpCard(),
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

  Widget _buildInfoTile(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 22),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 12, color: ThemeColors.secondaryText(context))),
        subtitle: Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeColors.primaryText(context))),
        trailing: Icon(Icons.chevron_right_rounded, color: ThemeColors.divider(context)),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, {VoidCallback? onTap, Color? color, bool isComingSoon = false}) {
    final effectiveColor = color ?? AppConstants.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: ListTile(
        onTap: isComingSoon ? null : onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: effectiveColor, size: 22),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: isComingSoon ? ThemeColors.hintText(context) : ThemeColors.primaryText(context))),
        subtitle: Text(subtitle, style: TextStyle(color: ThemeColors.hintText(context), fontSize: 12)),
        trailing: isComingSoon 
          ? Icon(Icons.lock_outline_rounded, size: 18, color: ThemeColors.divider(context))
          : Icon(Icons.chevron_right_rounded, color: ThemeColors.divider(context)),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.security_rounded, color: AppConstants.primaryColor, size: 32),
          const SizedBox(height: 12),
          Text(
            '¿Necesitas ayuda con tu seguridad?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Visita nuestro centro de ayuda para aprender cómo proteger mejor tu cuenta.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/settings/help'),
            child: Text(
              'IR AL CENTRO DE AYUDA',
              style: GoogleFonts.outfit(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
