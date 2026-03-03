import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme_colors.dart';

/// Pantalla para dejar calificación
class LeaveRatingScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onRatingSubmitted;

  const LeaveRatingScreen({super.key, 
    required this.userId,
    required this.onRatingSubmitted,
  });

  @override
  State<LeaveRatingScreen> createState() => _LeaveRatingScreenState();
}

class _LeaveRatingScreenState extends State<LeaveRatingScreen> {
  late SupabaseClient _supabase;
  final _commentController = TextEditingController();
  int selectedStars = 5;
  String selectedInteractionType = 'colaboracion';
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    debugPrint('[OOLALE][LeaveRating] initState userId=${widget.userId}');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    debugPrint('[OOLALE][LeaveRating] Enviar calificación estrellas=$selectedStars tipo=$selectedInteractionType');
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    setState(() => isSubmitting = true);

    try {
      await _supabase.from('referencias').insert({
        'evaluador_id': currentUserId,
        'evaluado_id': widget.userId,
        'puntuacion': selectedStars,
        'comentario': _commentController.text,
        'verificado': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calificación guardada')),
        );
        debugPrint('[OOLALE][LeaveRating] Calificación guardada OK');
        widget.onRatingSubmitted();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('[OOLALE][LeaveRating][Error] $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isSubmitting = false);
      debugPrint('[OOLALE][LeaveRating] Fin envío isSubmitting=$isSubmitting');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dejar calificación'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona tus estrellas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            // Stars selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedStars = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.star,
                      color: index < selectedStars ? Colors.amber : Colors.grey,
                      size: 48,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // Tipo de interacción
            const Text(
              'Tipo de interacción',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedInteractionType,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: ThemeColors.primaryText(context)),
              onChanged: (newValue) {
                setState(() => selectedInteractionType = newValue!);
              },
              items: ['colaboracion', 'evento', 'jam_session', 'clases'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Comentario
            const Text(
              'Comentario (opcional)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: TextStyle(color: ThemeColors.primaryText(context)),
              decoration: InputDecoration(
                hintText: 'Cuéntale más a otros músicos...',
                hintStyle: TextStyle(color: ThemeColors.hintText(context)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Botón de envío
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar calificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
