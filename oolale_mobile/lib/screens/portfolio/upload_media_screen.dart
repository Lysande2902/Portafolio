import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../../services/storage_service.dart';

class UploadMediaScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onUploadComplete;

  const UploadMediaScreen({super.key, 
    required this.userId,
    required this.onUploadComplete,
  });

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  final _titleController = TextEditingController();
  
  File? _selectedFile;
  String _selectedType = 'imagen'; 
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    try {
      if (type == 'imagen') {
        final picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) setState(() => _selectedFile = File(picked.path));
      } else if (type == 'video') {
        final picked = await _picker.pickVideo(source: ImageSource.gallery);
        if (picked != null) setState(() => _selectedFile = File(picked.path));
      } else if (type == 'audio') {
        final result = await FilePicker.platform.pickFiles(type: FileType.audio);
        if (result != null && result.files.single.path != null) {
          setState(() => _selectedFile = File(result.files.single.path!));
        }
      }
      setState(() => _selectedType = type);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null || _titleController.text.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un archivo y agrega un título')),
      );
      return;
    }

    // Capturar referencias antes de operaciones async
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isUploading = true);

    try {
      debugPrint('Subiendo archivo: ${_selectedFile!.path}');
      debugPrint('Tipo: $_selectedType');
      debugPrint('Usuario: ${widget.userId}');
      
      final publicUrl = await StorageService.uploadPortfolio(widget.userId, _selectedFile!);
      
      if (publicUrl == null) {
        throw Exception('No se pudo obtener la URL del archivo');
      }

      debugPrint('URL obtenida: $publicUrl');

      await _supabase.from('archivos_multimedia').insert({
        'profile_id': widget.userId,
        'tipo': _selectedType,
        'titulo': _titleController.text.trim(),
        'url_recurso': publicUrl,
        'visibilidad': 'publico',
      });

      debugPrint('✅ Insert exitoso en base de datos');

      if (mounted) {
        // Primero cerrar la pantalla
        navigator.pop();
        
        // Luego refrescar la galería
        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onUploadComplete();
          
          // Mostrar SnackBar
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Archivo subido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        });
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('UploadMediaScreen._upload', e, stackTrace);
      if (mounted) {
        setState(() => _isUploading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al subir archivo',
          onRetry: _upload,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Subir Archivo', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Tipo'),
            _buildTypeSelector(),
            const SizedBox(height: 30),
            _buildSectionTitle('Archivo'),
            _buildFileArea(),
            const SizedBox(height: 30),
            _buildSectionTitle('Título'),
            _buildTextField(),
            const SizedBox(height: 50),
            _buildUploadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: ['imagen', 'video', 'audio'].map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    type == 'imagen' ? Icons.image : type == 'video' ? Icons.videocam : Icons.music_note,
                    color: isSelected ? Colors.black : ThemeColors.secondaryText(context),
                  ),
                  const SizedBox(height: 4),
                  Text(type.toUpperCase(), style: GoogleFonts.outfit(color: isSelected ? Colors.black : ThemeColors.secondaryText(context), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFileArea() {
    return GestureDetector(
      onTap: () => _pickFile(_selectedType),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.1), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            if (_selectedFile == null) ...[
              Icon(Icons.cloud_upload_outlined, color: AppConstants.primaryColor, size: 40),
              const SizedBox(height: 12),
              Text('Toca para seleccionar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
            ] else ...[
              const Icon(Icons.check_circle, color: AppConstants.primaryColor, size: 40),
              const SizedBox(height: 12),
              Text(_selectedFile!.path.split('/').last, style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _titleController,
        style: TextStyle(color: ThemeColors.primaryText(context)),
        decoration: InputDecoration(
          hintText: 'Nombre del archivo',
          hintStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _upload,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isUploading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text('Subir', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
