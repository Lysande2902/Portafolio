import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Política de Privacidad', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización: Enero 2026',
              style: GoogleFonts.outfit(
                color: ThemeColors.hintText(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            
            _buildSection(
              context,
              '1. Información que Recopilamos',
              'Recopilamos información que nos proporcionas directamente, como tu nombre, email, foto de perfil, ubicación y contenido que publicas. También recopilamos información sobre tu uso de la aplicación.',
            ),
            
            _buildSection(
              context,
              '2. Cómo Usamos tu Información',
              'Usamos tu información para: proporcionar y mejorar nuestros servicios, personalizar tu experiencia, comunicarnos contigo, y garantizar la seguridad de la plataforma.',
            ),
            
            _buildSection(
              context,
              '3. Compartir Información',
              'No vendemos tu información personal. Podemos compartir información con proveedores de servicios que nos ayudan a operar la plataforma, siempre bajo estrictos acuerdos de confidencialidad.',
            ),
            
            _buildSection(
              context,
              '4. Seguridad',
              'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información contra acceso no autorizado, pérdida o alteración.',
            ),
            
            _buildSection(
              context,
              '5. Tus Derechos',
              'Tienes derecho a acceder, corregir o eliminar tu información personal. Puedes ejercer estos derechos desde la configuración de tu cuenta o contactándonos.',
            ),
            
            _buildSection(
              context,
              '6. Cookies y Tecnologías Similares',
              'Usamos cookies y tecnologías similares para mejorar tu experiencia, analizar el uso de la aplicación y personalizar el contenido.',
            ),
            
            _buildSection(
              context,
              '7. Retención de Datos',
              'Conservamos tu información mientras tu cuenta esté activa o según sea necesario para proporcionar servicios. Puedes solicitar la eliminación de tu cuenta en cualquier momento.',
            ),
            
            _buildSection(
              context,
              '8. Menores de Edad',
              'Óolale está diseñado para usuarios mayores de 13 años. No recopilamos intencionalmente información de menores de 13 años.',
            ),
            
            _buildSection(
              context,
              '9. Cambios a esta Política',
              'Podemos actualizar esta política de privacidad ocasionalmente. Te notificaremos sobre cambios significativos a través de la aplicación o por email.',
            ),
            
            _buildSection(
              context,
              '10. Contacto',
              'Si tienes preguntas sobre esta política de privacidad, contáctanos en privacidad@oolale.app',
            ),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu privacidad es importante para nosotros',
                      style: GoogleFonts.outfit(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: ThemeColors.secondaryText(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
