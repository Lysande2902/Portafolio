import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../providers/accessibility_provider.dart';

class FontSizeScreen extends StatelessWidget {
  const FontSizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('TAMAÑO DE FUENTE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AccessibilityProvider>(
        builder: (context, accessibility, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSection('VISTA PREVIA'),
              _buildPreviewCard(accessibility.fontScale),
              
              const SizedBox(height: 30),
              _buildSection('AJUSTAR TAMAÑO'),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ThemeColors.divider(context)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pequeño', style: GoogleFonts.outfit(fontSize: 12)),
                        Text('Grande', style: GoogleFonts.outfit(fontSize: 12)),
                      ],
                    ),
                    Slider(
                      value: accessibility.fontScale,
                      min: 0.8,
                      max: 1.5,
                      divisions: 7,
                      activeColor: AppConstants.primaryColor,
                      label: '${(accessibility.fontScale * 100).round()}%',
                      onChanged: (value) {
                        accessibility.setFontScale(value);
                      },
                    ),
                    Text(
                      '${(accessibility.fontScale * 100).round()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildPresetButtons(context, accessibility),

              const SizedBox(height: 30),
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

  Widget _buildPreviewCard(double fontScale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Título de Ejemplo',
            style: GoogleFonts.outfit(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF222222), // Texto oscuro forzado para fondo blanco
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este es un texto de ejemplo para que puedas ver cómo se verá el tamaño de fuente en la aplicación.',
            style: GoogleFonts.outfit(
              fontSize: 14 * fontScale,
              color: const Color(0xFF444444), // Gris oscuro forzado
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Texto pequeño adicional',
            style: GoogleFonts.outfit(
              fontSize: 12 * fontScale,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons(BuildContext context, AccessibilityProvider accessibility) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => accessibility.setFontScale(0.9),
            style: OutlinedButton.styleFrom(
              foregroundColor: accessibility.fontScale == 0.9 ? AppConstants.primaryColor : Colors.grey,
              side: BorderSide(
                color: accessibility.fontScale == 0.9 ? AppConstants.primaryColor : Colors.grey[300]!,
                width: accessibility.fontScale == 0.9 ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Pequeño', style: GoogleFonts.outfit(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => accessibility.setFontScale(1.0),
            style: OutlinedButton.styleFrom(
              foregroundColor: accessibility.fontScale == 1.0 ? AppConstants.primaryColor : Colors.grey,
              side: BorderSide(
                color: accessibility.fontScale == 1.0 ? AppConstants.primaryColor : Colors.grey[300]!,
                width: accessibility.fontScale == 1.0 ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Normal', style: GoogleFonts.outfit(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => accessibility.setFontScale(1.3),
            style: OutlinedButton.styleFrom(
              foregroundColor: accessibility.fontScale == 1.3 ? AppConstants.primaryColor : Colors.grey,
              side: BorderSide(
                color: accessibility.fontScale == 1.3 ? AppConstants.primaryColor : Colors.grey[300]!,
                width: accessibility.fontScale == 1.3 ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Grande', style: GoogleFonts.outfit(fontSize: 16)),
          ),
        ),
      ],
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
          Icon(Icons.info_outline_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'El tamaño de fuente se aplicará en toda la aplicación para mejorar la legibilidad.',
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
