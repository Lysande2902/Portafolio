import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

class LeaveRatingScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const LeaveRatingScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<LeaveRatingScreen> createState() => _LeaveRatingScreenState();
}

class _LeaveRatingScreenState extends State<LeaveRatingScreen> {
  final _supabase = Supabase.instance.client;
  final _commentController = TextEditingController();
  
  int _rating = 0;
  bool _isSubmitting = false;
  bool _hasWorkedTogether = false;
  bool _checkingConnection = true;
  Map<String, dynamic>? _existingRating; // Para almacenar la calificación existente
  bool _isEditMode = false; // Para saber si estamos editando

  @override
  void initState() {
    super.initState();
    _checkIfWorkedTogether();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkIfWorkedTogether() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      if (mounted) setState(() => _checkingConnection = false);
      return;
    }

    // Prevenir auto-calificación
    if (myId == widget.userId) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No puedes calificarte a ti mismo', style: GoogleFonts.outfit()),
            backgroundColor: Colors.orange[700],
          ),
        );
      }
      return;
    }

    try {
      // VERIFICAR SI YA CALIFICÓ A ESTE USUARIO
      final existingRating = await _supabase
          .from('referencias')
          .select()
          .eq('evaluador_id', myId)
          .eq('evaluado_id', widget.userId)
          .maybeSingle();

      if (existingRating != null) {
        // En lugar de cerrar, cargar la calificación existente para editar
        if (mounted) {
          setState(() {
            _existingRating = existingRating;
            _isEditMode = true;
            _rating = existingRating['puntuacion'] ?? 0;
            _commentController.text = existingRating['comentario'] ?? '';
          });
        }
      }

      // NUEVA LÓGICA: Verificar si son conexiones aceptadas
      // Esto es más flexible que solo verificar eventos compartidos
      final connectionData = await _supabase
          .from('conexiones')
          .select()
          .or('and(usuario_id.eq.$myId,conectado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},conectado_id.eq.$myId)')
          .eq('estatus', 'accepted')
          .maybeSingle();

      final areConnected = connectionData != null;

      // OPCIONAL: También verificar si trabajaron juntos en eventos
      // Esto da más peso a la calificación
      bool workedTogether = false;
      if (areConnected) {
        final gigsData = await _supabase
            .from('participantes_evento')
            .select('event_id')
            .eq('user_id', myId);

        if (gigsData.isNotEmpty) {
          final gigIds = gigsData.map((g) => g['event_id']).toList();

          final sharedGigs = await _supabase
              .from('participantes_evento')
              .select('event_id')
              .eq('user_id', widget.userId)
              .inFilter('event_id', gigIds);

          workedTogether = sharedGigs.isNotEmpty;
        }
      }

      if (mounted) {
        setState(() {
          _hasWorkedTogether = areConnected; // Ahora significa "son conexiones"
          _checkingConnection = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('LeaveRatingScreen._checkIfWorkedTogether', e);
      if (mounted) {
        setState(() {
          _hasWorkedTogether = false;
          _checkingConnection = false;
        });
      }
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una calificación', style: GoogleFonts.outfit()),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    setState(() => _isSubmitting = true);

    try {
      if (_isEditMode && _existingRating != null) {
        // ACTUALIZAR calificación existente
        await _supabase.from('referencias').update({
          'puntuacion': _rating,
          'comentario': _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', _existingRating!['id']);
      } else {
        // INSERTAR nueva calificación
        await _supabase.from('referencias').insert({
          'evaluador_id': myId,
          'evaluado_id': widget.userId,
          'puntuacion': _rating,
          'comentario': _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
          'tipo_interaccion': 'evento',
          'verificado': _hasWorkedTogether,
        });
      }

      // Actualizar rating promedio del usuario evaluado
      await _updateUserRating();

      // Crear notificación solo si es nueva calificación
      if (!_isEditMode) {
        try {
          await _supabase.from('notificaciones').insert({
            'user_id': widget.userId,
            'tipo': 'new_rating',
            'titulo': 'Nueva calificación',
            'mensaje': 'Recibiste una calificación de $_rating estrellas',
            'leido': false,
            'data': {'sender_id': myId, 'rating': _rating},
          });
        } catch (notifError) {
          ErrorHandler.logError('LeaveRatingScreen._sendNotification', notifError);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  _isEditMode ? 'Calificación actualizada' : 'Calificación enviada',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ErrorHandler.logError('LeaveRatingScreen._submitRating', e);
      if (mounted) {
        setState(() => _isSubmitting = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al enviar calificación',
          onRetry: _submitRating,
        );
      }
    }
  }

  Future<void> _updateUserRating() async {
    try {
      // Calcular nuevo promedio
      final ratingsData = await _supabase
          .from('referencias')
          .select('puntuacion')
          .eq('evaluado_id', widget.userId);

      if (ratingsData.isEmpty) return;

      final ratings = ratingsData.map((r) => r['puntuacion'] as int).toList();
      // FIX: Prevenir división por cero
      final average = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

      // Actualizar perfil
      await _supabase
          .from('perfiles')
          .update({
            'rating_promedio': average,
            'total_calificaciones': ratings.length,
            'total_referencias': ratings.length,
          })
          .eq('id', widget.userId);
    } catch (e) {
      ErrorHandler.logError('LeaveRatingScreen._updateUserRating', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingConnection) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Calificar Usuario', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: ThemeColors.icon(context)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditMode ? 'Editar Calificación' : 'Calificar Usuario',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: ThemeColors.icon(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usuario a calificar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    child: Text(
                      widget.userName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: AppConstants.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_hasWorkedTogether)
                          Row(
                            children: [
                              Icon(Icons.verified, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Son conexiones',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.green,
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
            const SizedBox(height: 32),
            
            // Calificación
            Text(
              '¿Cómo fue tu experiencia?',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        size: 48,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingText(_rating),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            
            // Comentario
            Text(
              'Comentario (opcional)',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
              decoration: InputDecoration(
                hintText: 'Cuéntanos sobre tu experiencia trabajando con ${widget.userName}...',
                hintStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeColors.divider(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeColors.divider(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Actualizar Calificación' : 'Enviar Calificación',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muy mala';
      case 2:
        return 'Mala';
      case 3:
        return 'Regular';
      case 4:
        return 'Buena';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}
