import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

/// Pantalla universal para reportar cualquier tipo de contenido
/// Soporta: usuarios, posts, eventos, mensajes
class ReportContentScreen extends StatefulWidget {
  final String contentType; // 'usuario', 'post', 'evento', 'mensaje'
  final String contentId;
  final String contentTitle; // Nombre del usuario, título del post, etc.
  
  const ReportContentScreen({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
  });

  @override
  State<ReportContentScreen> createState() => _ReportContentScreenState();
}

class _ReportContentScreenState extends State<ReportContentScreen> {
  final _supabase = Supabase.instance.client;
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  // Categorías de reporte según el tipo de contenido
  Map<String, String> get _categories {
    switch (widget.contentType) {
      case 'usuario':
        return {
          'Spam o contenido engañoso': 'spam',
          'Acoso o intimidación': 'acoso',
          'Contenido inapropiado': 'contenido_inapropiado',
          'Suplantación de identidad': 'suplantacion',
          'Estafa o fraude': 'estafa',
          'Otro': 'otro',
        };
      case 'post':
        return {
          'Spam o publicidad': 'spam',
          'Contenido ofensivo': 'contenido_ofensivo',
          'Contenido sexual explícito': 'contenido_sexual',
          'Violencia o contenido gráfico': 'violencia',
          'Información falsa': 'desinformacion',
          'Otro': 'otro',
        };
      case 'evento':
        return {
          'Evento falso o estafa': 'estafa',
          'Información engañosa': 'desinformacion',
          'Contenido inapropiado': 'contenido_inapropiado',
          'Spam': 'spam',
          'Otro': 'otro',
        };
      case 'mensaje':
        return {
          'Acoso o intimidación': 'acoso',
          'Spam': 'spam',
          'Contenido sexual no deseado': 'contenido_sexual',
          'Amenazas': 'amenazas',
          'Estafa': 'estafa',
          'Otro': 'otro',
        };
      default:
        return {'Otro': 'otro'};
    }
  }

  String get _contentTypeLabel {
    switch (widget.contentType) {
      case 'usuario':
        return 'usuario';
      case 'post':
        return 'publicación';
      case 'evento':
        return 'evento';
      case 'mensaje':
        return 'mensaje';
      default:
        return 'contenido';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una categoría', style: GoogleFonts.outfit()),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor describe el problema', style: GoogleFonts.outfit()),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId == null) throw Exception('Usuario no autenticado');

      // PASO 1: Verificar si el usuario puede reportar
      final canReportResult = await _supabase
          .rpc('puede_reportar', params: {'usuario_id_param': myId})
          .single();

      if (canReportResult['puede'] == false) {
        // Usuario no puede reportar
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppConstants.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block, color: Colors.red, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No Puedes Reportar',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                canReportResult['razon'] ?? 'No puedes enviar reportes en este momento.',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Cerrar pantalla de reporte
                  },
                  child: Text(
                    'Entendido',
                    style: GoogleFonts.outfit(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return;
      }

      // PASO 2: Preparar datos del reporte
      final reportData = {
        'reportante_id': myId,
        'contenido_tipo': widget.contentType,
        'categoria': _selectedCategory,
        'descripcion': _descriptionController.text.trim(),
        'urgencia': 'media', // El sistema backend determinará la prioridad real
        'estatus': 'pendiente',
      };

      // Agregar ID del contenido reportado según el tipo
      if (widget.contentType == 'usuario') {
        reportData['usuario_reportado_id'] = widget.contentId;
      } else {
        reportData['contenido_id'] = widget.contentId;
      }

      // PASO 3: Insertar reporte en la base de datos
      await _supabase.from('reportes').insert(reportData);

      // PASO 4: Registrar el reporte en el historial del usuario
      try {
        await _supabase.rpc('registrar_reporte', params: {'usuario_id_param': myId});
      } catch (e) {
        debugPrint('Error registrando historial: $e');
        // No bloqueamos el flujo si falla el historial
      }

      if (mounted) {
        // Mostrar diálogo de éxito
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppConstants.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Reporte Enviado',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gracias por alertarnos. Nuestro equipo revisará este reporte en breve y tomará las medidas necesarias.',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15, height: 1.5),
                ),
                if (canReportResult['reportes_disponibles_hoy'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppConstants.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reportes disponibles hoy: ${canReportResult['reportes_disponibles_hoy'] - 1}',
                            style: GoogleFonts.outfit(
                              color: AppConstants.primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.pop(context, true); // Cerrar pantalla de reporte
                },
                child: Text(
                  'Entendido',
                  style: GoogleFonts.outfit(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ErrorHandler.logError('ReportContentScreen._submitReport', e);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al enviar reporte',
          onRetry: _submitReport,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'REPORTAR ${_contentTypeLabel.toUpperCase()}',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: ThemeColors.icon(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de advertencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reporte Confidencial',
                          style: GoogleFonts.outfit(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            text: 'Estás reportando: ',
                            style: GoogleFonts.outfit(
                              color: ThemeColors.secondaryText(context),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: widget.contentTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: '. Esta acción es anónima y será revisada por nuestro equipo.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Categoría
            Text(
              'CATEGORÍA DEL REPORTE',
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: _categories.entries.map((entry) {
                  final isSelected = _selectedCategory == entry.value;
                  return RadioListTile<String>(
                    activeColor: Colors.orange,
                    title: Text(
                      entry.key,
                      style: GoogleFonts.outfit(
                        color: isSelected
                            ? ThemeColors.primaryText(context)
                            : ThemeColors.secondaryText(context),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    value: entry.value,
                    groupValue: _selectedCategory,
                    onChanged: (value) => setState(() => _selectedCategory = value),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Descripción
            Text(
              'DESCRIPCIÓN DEL PROBLEMA',
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descriptionController,
              maxLines: 6,
              maxLength: 500,
              style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                hintText: 'Describe detalladamente el problema para ayudarnos a entender mejor la situación...',
                hintStyle: GoogleFonts.outfit(
                  color: ThemeColors.hintText(context),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.orange.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                counterStyle: GoogleFonts.outfit(
                  color: ThemeColors.secondaryText(context),
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botón de enviar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[800],
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'ENVIAR REPORTE',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nuestro sistema evaluará automáticamente la prioridad de tu reporte.',
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Los reportes falsos o malintencionados pueden resultar en la suspensión de tu cuenta.',
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
