import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../providers/accessibility_provider.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('ACCESIBILIDAD', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AccessibilityProvider>(
        builder: (context, accessibility, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSection('VISUALES'),
              _buildSettingTile(
                context,
                'Tamaño de Fuente',
                'Ajusta el tamaño del texto',
                Icons.text_fields_rounded,
                onTap: () => context.push('/settings/font-size'),
              ),
              _buildSwitchTile(
                context,
                'Alto Contraste',
                'Mejora la visibilidad del texto',
                Icons.contrast_rounded,
                accessibility.highContrast,
                (val) => accessibility.setHighContrast(val),
              ),
              
              const SizedBox(height: 30),
              _buildSection('MODO ACCESIBILIDAD'),
              _buildSwitchTile(
                context,
                'Modo de Accesibilidad',
                'Activa todas las opciones de accesibilidad',
                Icons.accessibility_new_rounded,
                accessibility.accessibilityMode,
                (val) {
                  accessibility.setAccessibilityMode(val);
                  if (val) {
                    accessibility.setFontScale(1.3);
                    accessibility.setHighContrast(true);
                  }
                },
              ),

              const SizedBox(height: 20),
              _buildInfoCard(context),
            ],
          );
        },
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

  Widget _buildSettingTile(BuildContext context, String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
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
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: ThemeColors.hintText(context), fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: ThemeColors.divider(context)),
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
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

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.accessibility_new_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Las opciones de accesibilidad ayudan a que la app sea más fácil de usar para todos.',
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
