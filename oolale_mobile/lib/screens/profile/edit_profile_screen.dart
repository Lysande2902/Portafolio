import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../models/profile.dart'; // Import Profile model
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  final Perfil? profile; // Accept optional profile to edit
  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Populate if profile exists
    if (widget.profile != null) {
      _nameController.text = widget.profile!.nombreArtistico;
      _bioController.text = widget.profile!.bio;
      _locationController.text = widget.profile!.ubicacion;
      _experienceController.text = widget.profile!.nivelExperiencia;
      
      // Pre-select existing if possible (assuming strings or IDs)
      // For demo, we might need a mapping or just assume names
      // _selectedInstruments = ...
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      // Using generic /perfiles endpoint logic. 
      // If we are editing, we usually PUT to /perfiles/usuario/{id} or /perfiles/{id}
      // Depending on backend availability. 
      // user-dashboard.js snippet didn't show the exact endpoint for saving, but likely /perfiles/usuario/:id
      // Let's try to assume we are updating the CURRENT user's profile.
      // If the backend has a '/me' endpoint or similar logic, that's best.
      // If not, we might need the user ID. 
      // However, usually POST/PUT to /perfiles implies "my" profile in a simple REST API or the body contains ID.
      // Given the dashboard loads via /perfiles/usuario/${currentUser.id}, let's try targeting that if possible.
      // But we don't have user ID in this widget easily unless passed.
      // Let's assume there is a generic update or we need to pass user ID.
      // For now, I'll assume we can PUT to /perfiles/usuario/${widget.profile!.userId} if profile exists.
      
      final endpoint = widget.profile != null 
          ? '/perfiles/${widget.profile!.id}' // Targeted update if we have profile ID
          : '/perfiles'; // Create?

      // Note: The fields in dashboard 'guardarPerfil' were: bio, experiencia, objetivos.
      // The mobile view has 'nombre_artistico', 'ubicacion', 'experiencia', 'bio'.
      // Mapping:
      // nombre_artistico -> nombre_artistico
      // descripcion_breve -> bio (mapped in model)
      // ubicacion -> ubicacion
      // experiencia -> experiencia
      
      final data = {
        'nombre_artistico': _nameController.text,
        'descripcion_breve': _bioController.text,
        'ubicacion': _locationController.text,
        'experiencia': _experienceController.text,
        'instrumentos': _selectedInstruments, // Include list for backend processing
        'generos': _selectedGenres,
      };

      if (widget.profile != null) {
          // Update
          await api.put(endpoint, data);
      } else {
          // Create (POST)
          await api.post('/perfiles', data);
      }

      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil guardado correctamente')));
         Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
       debugPrint('Error saving profile: $e');
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo actualizar el perfil. Intente nuevamente.')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.profile == null ? 'Crear Perfil Pro' : 'Estrategia de Perfil',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             GestureDetector(
               onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subida de imagen: Próximamente')));
               },
               child: CircleAvatar(
                 radius: 50,
                 backgroundColor: Colors.white10,
                 backgroundImage: widget.profile?.avatarUrl != null ? NetworkImage(widget.profile!.avatarUrl!) : null,
                 child: widget.profile?.avatarUrl == null 
                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
               ),
             ),
             const SizedBox(height: 20),
             TextField(
               controller: _nameController,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(labelText: 'Nombre Artístico'),
             ),
             const SizedBox(height: 15),
             TextField(
               controller: _locationController,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(labelText: 'Ubicación'),
             ),
             const SizedBox(height: 15),
             TextField(
               controller: _experienceController,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(labelText: 'Experiencia (ej. "Intermedio", "5 años")'),
             ),
             const SizedBox(height: 15),
             TextField(
               controller: _bioController,
               style: const TextStyle(color: Colors.white),
               maxLines: 4,
               decoration: const InputDecoration(labelText: 'Biografía'),
             ),
             const SizedBox(height: 30),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 onPressed: _isLoading ? null : _saveProfile,
                 style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
                 child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white)),
               ),
             ),
              
              const SizedBox(height: 30),
              const Divider(color: Colors.white24),
              const Text('Gestión de Habilidades', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Instruments
              _buildChipsSelection('Instrumentos', ['Guitarra', 'Bajo', 'Batería', 'Voz', 'Teclado', 'Saxofón'], _selectedInstruments, (val) {
                 setState(() {
                   if(_selectedInstruments.contains(val)) {
                     _selectedInstruments.remove(val);
                   } else {
                     _selectedInstruments.add(val);
                   }
                 });
              }),
              const SizedBox(height: 15),
               // Genres
              _buildChipsSelection('Géneros', ['Rock', 'Jazz', 'Pop', 'Metal', 'Blues', 'Latino'], _selectedGenres, (val) {
                 setState(() {
                   if(_selectedGenres.contains(val)) {
                     _selectedGenres.remove(val);
                   } else {
                     _selectedGenres.add(val);
                   }
                 });
              }),

              const SizedBox(height: 30),
              const Divider(color: Colors.white24),
              const Text('Mi Portafolio de Audio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _uploadAudio,
                icon: const Icon(Icons.upload_file),
                label: const Text('SUBIR NUEVA MUESTRA'),
                style: OutlinedButton.styleFrom(foregroundColor: AppConstants.accentColor), 
              ),
               
          ],
        ),
      ),
    );
  }
  // Demo lists - in real app fetch from API
  final List<String> _selectedInstruments = [];
  final List<String> _selectedGenres = [];

  Widget _buildChipsSelection(String title, List<String> options, List<String> selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            return FilterChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onSelect(opt),
              backgroundColor: Colors.white10,
              selectedColor: AppConstants.primaryColor.withOpacity(0.5),
              checkmarkColor: AppConstants.accentColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _uploadAudio() async {
     try {
       FilePickerResult? result = await FilePicker.platform.pickFiles(
         type: FileType.audio,
         allowMultiple: false,
       );

       if (result != null) {
          setState(() => _isLoading = true);
          final file = result.files.first;
          
          // In web we use bytes, mobile path. file_picker handles both but bytes is safer for universal
          final bytes = file.bytes ?? (await _readFileBytes(file.path!)); 
          
          final api = ApiService();
          // POST /muestras/subir (Mock)
          // Adjust endpoint to real one if 'guardarMuestra' uses /muestras or similar
          await api.uploadFile('/muestras/subir', 'archivo', bytes.toList(), file.name);
          
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio subido correctamente')));
       }
     } catch (e) {
       debugPrint('Error uploading: $e');
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al subir audio')));
     } finally {
       if(mounted) setState(() => _isLoading = false);
     }
  }

  Future<List<int>> _readFileBytes(String path) async {
     return await File(path).readAsBytes();
  }
}
