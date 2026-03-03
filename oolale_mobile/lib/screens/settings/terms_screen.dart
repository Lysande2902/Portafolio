import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Términos y Condiciones', 
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
              '1. Aceptación de Términos',
              'Al acceder y usar Óolale, aceptas estar sujeto a estos Términos y Condiciones. Si no estás de acuerdo con alguna parte de estos términos, no debes usar nuestra aplicación.',
            ),
            
            _buildSection(
              context,
              '2. Uso de la Plataforma',
              'Óolale es una plataforma diseñada para conectar músicos, bandas y profesionales de la industria musical. Te comprometes a usar la plataforma de manera responsable y respetuosa.',
            ),
            
            _buildSection(
              context,
              '3. Cuenta de Usuario',
              'Eres responsable de mantener la confidencialidad de tu cuenta y contraseña. Debes notificarnos inmediatamente sobre cualquier uso no autorizado de tu cuenta.',
            ),
            
            _buildSection(
              context,
              '4. Contenido del Usuario',
              'Eres responsable del contenido que publicas en Óolale. No debes publicar contenido que sea ilegal, ofensivo, difamatorio o que viole los derechos de terceros.',
            ),
            
            _buildSection(
              context,
              '5. Propiedad Intelectual',
              'Todo el contenido de Óolale, incluyendo diseño, logos y código, es propiedad de Óolale o sus licenciantes. No puedes copiar, modificar o distribuir nuestro contenido sin permiso.',
            ),
            
            _buildSection(
              context,
              '6. Privacidad',
              'Tu privacidad es importante para nosotros. Consulta nuestra Política de Privacidad para entender cómo recopilamos, usamos y protegemos tu información personal.',
            ),
            
            _buildSection(
              context,
              '7. Pagos y Suscripciones',
              'Los pagos por servicios premium son procesados de forma segura. Las suscripciones se renuevan automáticamente a menos que las canceles antes de la fecha de renovación.',
            ),
            
            _buildSection(
              context,
              '8. Terminación',
              'Podemos suspender o terminar tu cuenta si violas estos términos o si determinamos que tu uso de la plataforma es perjudicial para otros usuarios.',
            ),
            
            _buildSection(
              context,
              '9. Limitación de Responsabilidad',
              'Óolale se proporciona "tal cual" sin garantías de ningún tipo. No somos responsables de daños indirectos, incidentales o consecuentes que surjan del uso de la plataforma.',
            ),
            
            _buildSection(
              context,
              '10. Cambios a los Términos',
              'Nos reservamos el derecho de modificar estos términos en cualquier momento. Te notificaremos sobre cambios significativos a través de la aplicación o por email.',
            ),
            
            _buildSection(
              context,
              '11. Contacto',
              'Si tienes preguntas sobre estos términos, contáctanos en legal@oolale.app',
            ),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppConstants.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Al usar Óolale, aceptas estos términos y condiciones',
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
              color: AppConstants.primaryColor,
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
