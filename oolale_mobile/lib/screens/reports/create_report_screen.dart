import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _reasonController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReport() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor indica un motivo')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final api = ApiService();
      // POST /api/reportes
      // Mock payload
      await api.post('/reportes', {
        'motivo': _reasonController.text,
        'descripcion_adicional': _detailsController.text,
        'fecha_reporte': DateTime.now().toIso8601String(),
        // 'id_reportado': ... (This would come from args usually)
      });
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado. Gracias por ayudar a mantener segura la comunidad.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar reporte: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Crear Reporte'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Si has encontrado contenido inapropiado o comportamiento abusivo, por favor repórtalo aquí.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Motivo del reporte',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _detailsController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Detalles adicionales (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: _isLoading ? const CircularProgressIndicator() : const Text('ENVIAR REPORTE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
