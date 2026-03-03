import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateReportScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;

  const CreateReportScreen({
    super.key, 
    required this.reportedUserId,
    required this.reportedUserName
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _supabase = Supabase.instance.client;
  final _descController = TextEditingController();
  String _selectedReason = 'spam';
  bool _isLoading = false;

  final Map<String, String> _reasons = {
    'spam': 'Spam o Publicidad no deseada',
    'acoso': 'Acoso o Comportamiento ofensivo',
    'contenido_inapropiado': 'Contenido Inapropiado (+18)',
    'estafa': 'Posible Estafa o Fraude',
    'otro': 'Otro motivo'
  };

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_descController.text.isEmpty && _selectedReason == 'otro') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor describe el problema')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId == null) throw Exception('Usuario no autenticado');

      await _supabase.from('reportes').insert({
        'usuario_id': myId,
        'reportado_id': widget.reportedUserId,
        'motivo': _selectedReason,
        'descripcion': _descController.text,
        'estado': 'pendiente',
        'created_at': DateTime.now().toIso8601String(), // Asegurar timestamp
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Reporte Enviado', style: TextStyle(color: ThemeColors.primaryText(context))),
            content: Text('Gracias por alertarnos. Nuestro equipo revisará este caso en breve.', style: TextStyle(color: ThemeColors.secondaryText(context))),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: const Text('Entendido', style: TextStyle(color: AppConstants.primaryColor)),
              )
            ],
          )
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('REPORTAR USUARIO', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Estás reportando a ',
                        style: TextStyle(color: ThemeColors.secondaryText(context)),
                        children: [
                          TextSpan(text: widget.reportedUserName, style: TextStyle(fontWeight: FontWeight.bold, color: ThemeColors.primaryText(context))),
                          const TextSpan(text: '. Esta acción es anónima y confidencial.')
                        ]
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            Text('SELECCIONA UN MOTIVO', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                children: _reasons.entries.map((entry) {
                  final isSelected = _selectedReason == entry.key;
                  return RadioListTile<String>(
                    activeColor: AppConstants.errorColor,
                    tileColor: Colors.transparent,
                    title: Text(entry.value, style: TextStyle(color: isSelected ? ThemeColors.primaryText(context) : ThemeColors.secondaryText(context))),
                    value: entry.key,
                    groupValue: _selectedReason,
                    onChanged: (v) => setState(() => _selectedReason = v!),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),
            Text('DETALLES ADICIONALES', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 15),

            TextField(
              controller: _descController,
              maxLines: 5,
              style: TextStyle(color: ThemeColors.primaryText(context)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                hintText: 'Describe la situación para ayudarnos a entender mejor el contexto...',
                hintStyle: TextStyle(color: ThemeColors.hintText(context)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: ThemeColors.divider(context))),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0
                ),
                onPressed: _isLoading ? null : _submitReport,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text('ENVIAR REPORTE', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
