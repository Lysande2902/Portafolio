import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _instrumentController = TextEditingController(); 
  final _gearController = TextEditingController();
  final _experienceController = TextEditingController();
  final _rateController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _spotifyController = TextEditingController();
  
  List<String> _gearList = [];
  List<String> _selectedGenres = [];
  Map<String, bool> _availability = {
    'lunes': false,
    'martes': false,
    'miercoles': false,
    'jueves': false,
    'viernes': false,
    'sabado': false,
    'domingo': false,
  };
  String? _avatarUrl;
  File? _imageFile;
  bool _isMusician = true; // Default
  bool _isLoading = true;
  bool _isSaving = false;
  static const int MAX_GEAR = 8;
  
  final List<String> _availableGenres = [
    'Rock', 'Pop', 'Jazz', 'Blues', 'Metal', 'Punk', 'Indie', 'Alternative',
    'Electronic', 'Hip Hop', 'Rap', 'Reggae', 'Ska', 'Funk', 'Soul', 'R&B',
    'Country', 'Folk', 'Latin', 'Salsa', 'Cumbia', 'Reggaeton', 'Classical',
    'Experimental', 'Ambient', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('perfiles')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _nameController.text = data['nombre_artistico'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _locationController.text = data['ubicacion'] ?? '';
        _instrumentController.text = data['instrumento_principal'] ?? '';
        _experienceController.text = (data['years_experience'] ?? 0).toString();
        _rateController.text = (data['base_rate'] ?? 0).toString();
        _avatarUrl = data['foto_perfil'];
        
        // Inferir si es músico
        if ((_instrumentController.text.isEmpty) && 
            (_experienceController.text == '0') && 
            (data['base_rate'] == 0)) {
           _isMusician = false;
        } else {
           _isMusician = true;
        }

        // Cargar redes sociales
        if (data['social_links'] != null) {
          final socialLinks = data['social_links'] as Map<String, dynamic>;
          _instagramController.text = socialLinks['instagram'] ?? '';
          _youtubeController.text = socialLinks['youtube'] ?? '';
          _spotifyController.text = socialLinks['spotify'] ?? '';
        }
        
        // Cargar disponibilidad
        if (data['availability'] != null) {
          final avail = data['availability'] as Map<String, dynamic>;
          _availability = {
            'lunes': avail['lunes'] ?? false,
            'martes': avail['martes'] ?? false,
            'miercoles': avail['miercoles'] ?? false,
            'jueves': avail['jueves'] ?? false,
            'viernes': avail['viernes'] ?? false,
            'sabado': avail['sabado'] ?? false,
            'domingo': avail['domingo'] ?? false,
          };
        }
        
        _isLoading = false;
      });

      // Cargar géneros musicales
      try {
        final genresData = await _supabase
            .from('generos_perfil')
            .select('genre')
            .eq('profile_id', userId);
        
        setState(() {
          _selectedGenres = (genresData as List).map((g) => g['genre'].toString()).toList();
          if (_selectedGenres.isNotEmpty) _isMusician = true;
        });
      } catch (e) {
        ErrorHandler.logError('EditProfileScreen._loadGenres', e);
      }

      // Cargar Gear (Mi Equipo)
      try {
        final gearData = await _supabase
            .from('perfil_gear')
            .select('gear_catalog(nombre)')
            .eq('perfil_id', userId);
        
        final gearNames = (gearData as List).map((g) => g['gear_catalog']['nombre'].toString()).toList();
        setState(() {
          _gearList = gearNames;
          _gearController.text = gearNames.join(', ');
          if (_gearList.isNotEmpty) _isMusician = true;
        });
      } catch (e) {
        ErrorHandler.logError('EditProfileScreen._loadGear', e);
      }
    } catch (e) {
      ErrorHandler.logError('EditProfileScreen._loadProfile', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando perfil',
          onRetry: _loadProfile,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _addGear() {
    final newGear = _gearController.text.trim();
    if (newGear.isEmpty) return;
    
    if (_gearList.length >= MAX_GEAR) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Máximo $MAX_GEAR instrumentos permitidos', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    if (!_gearList.contains(newGear)) {
      setState(() {
        _gearList.add(newGear);
        _gearController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Este instrumento ya está agregado', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: AppConstants.warningColor,
        ),
      );
    }
  }

  Future<void> _save() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('ERROR: No user ID');
      return;
    }

    debugPrint('SAVE: Starting save for user $userId');
    setState(() => _isSaving = true);
    try {
      String? finalAvatarUrl = _avatarUrl;

      // 1. Subir imagen si se seleccionó una nueva
      if (_imageFile != null) {
        debugPrint('SAVE: Uploading avatar...');
        finalAvatarUrl = await StorageService.uploadAvatar(userId, _imageFile!);
        debugPrint('SAVE: Avatar uploaded: $finalAvatarUrl');
      }

      // Si NO es músico, limpiar datos irrelevantes
      if (!_isMusician) {
        _instrumentController.clear();
        _experienceController.text = '0';
        _rateController.text = '0';
        _gearController.clear();
        _gearList.clear();
        _selectedGenres.clear();
        _availability.updateAll((key, value) => false);
      } else {
         // Auto-agregar texto de equipo pendiente si existe y es músico
         final pendingGear = _gearController.text.trim();
         if (pendingGear.isNotEmpty && !_gearList.contains(pendingGear) && _gearList.length < MAX_GEAR) {
           _gearList.add(pendingGear);
         }
      }

      // 2. Preparar social links
      final socialLinks = {
        'instagram': _instagramController.text.trim(),
        'youtube': _youtubeController.text.trim(),
        'spotify': _spotifyController.text.trim(),
      };
      
      // Remover links vacíos
      socialLinks.removeWhere((key, value) => value.isEmpty);

      // 3. Actualizar perfil
      debugPrint('SAVE: Updating profile...');
      final yearsExp = int.tryParse(_experienceController.text.trim()) ?? 0;
      final baseRate = double.tryParse(_rateController.text.trim()) ?? 0.0;
      
      final response = await _supabase.from('perfiles').update({
        'nombre_artistico': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'ubicacion': _locationController.text.trim(),
        'instrumento_principal': _instrumentController.text.trim(), // Será vacío si !isMusician
        'foto_perfil': finalAvatarUrl,
        'years_experience': yearsExp,
        'base_rate': baseRate,
        'currency': 'MXN',
        'availability': _availability,
        'social_links': socialLinks,
        'open_to_work': _isMusician, // Si no es músico, no está open to work por defecto
      }).eq('id', userId).select();

      debugPrint('SAVE: Profile updated successfully: $response');

      // 4. Actualizar géneros musicales
      // Siempre borramos, y si es músico insertamos los nuevos
       debugPrint('SAVE: Updating genres...');
       await _supabase.from('generos_perfil').delete().eq('profile_id', userId);
       
      if (_isMusician && _selectedGenres.isNotEmpty) {
        final genreRecords = _selectedGenres.map((genre) => {
          'profile_id': userId,
          'genre': genre,
        }).toList();
        
        await _supabase.from('generos_perfil').insert(genreRecords);
        debugPrint('SAVE: Genres updated successfully');
      }

      // 5. Actualizar Gear
      debugPrint('SAVE: Updating gear list...');
      await _supabase.from('perfil_gear').delete().eq('perfil_id', userId);

      if (_isMusician && _gearList.isNotEmpty) {
        if (_gearList.length > MAX_GEAR) {
          throw Exception('Máximo $MAX_GEAR instrumentos permitidos');
        }
        
        for (var name in _gearList) {
          var catalogItem = await _supabase
              .from('gear_catalog')
              .select()
              .ilike('nombre', name)
              .limit(1)
              .maybeSingle();
          
          Object gearId;
          if (catalogItem == null) {
            final newItem = await _supabase.from('gear_catalog').insert({'nombre': name}).select().single();
            gearId = newItem['id'];
          } else {
            gearId = catalogItem['id'];
          }
          
          await _supabase.from('perfil_gear').insert({
            'perfil_id': userId,
            'gear_id': gearId,
          });
        }
        debugPrint('SAVE: Gear updated successfully');
      }

      debugPrint('SAVE: All updates completed successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Perfil actualizado correctamente', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ErrorHandler.logError('EditProfileScreen._save', e);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error guardando perfil',
          onRetry: _save,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Editar Perfil', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 30),
                _buildSectionTitle('Información Básica'),
                _buildTextField(_nameController, 'Nombre Artístico', Icons.person_outline),
                const SizedBox(height: 10),
                
                // Toggle Músico vs Fan
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                  ),
                  child: SwitchListTile(
                    title: Text('¿Eres Músico / Banda?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('Activa esto si buscas toquines o quieres mostrar tu equipo.', style: GoogleFonts.outfit(fontSize: 12)),
                    value: _isMusician,
                    activeColor: AppConstants.primaryColor,
                    onChanged: (val) {
                      setState(() => _isMusician = val);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                if (_isMusician) ...[
                  _buildTextField(_instrumentController, '¿Qué tocas?', Icons.music_note_outlined),
                  const SizedBox(height: 20),
                ],
                
                _buildTextField(_locationController, 'Ubicación', Icons.location_on_outlined),
                const SizedBox(height: 30),
                _buildSectionTitle('Bio ${!_isMusician ? 'e Intereses' : 'y Requisitos'}'),
                _buildTextField(_bioController, 'Sobre ti...', Icons.notes, maxLines: 3),
                const SizedBox(height: 30),

                if (_isMusician) ...[
                  _buildSectionTitle('Géneros Musicales'),
                  _buildGenresSection(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Experiencia y Disponibilidad'),
                  _buildTextField(_experienceController, 'Años de experiencia', Icons.work_outline),
                  const SizedBox(height: 20),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Tarifa Base (MXN)'),
                  _buildTextField(_rateController, 'Precio por evento', Icons.attach_money),
                  const SizedBox(height: 30),
                ],

                _buildSectionTitle('Redes Sociales'),
                _buildTextField(_instagramController, 'Instagram (URL)', Icons.camera_alt),
                const SizedBox(height: 20),
                _buildTextField(_youtubeController, 'YouTube (URL)', Icons.play_circle_outline),
                const SizedBox(height: 20),
                _buildTextField(_spotifyController, 'Spotify (URL)', Icons.music_note),
                const SizedBox(height: 30),

                if (_isMusician) ...[
                  _buildSectionTitle('Mis Instrumentos (Máx. 8)'),
                  _buildGearSection(),
                  const SizedBox(height: 40),
                ],
                _buildSaveButton(),
              ],
            ),
          ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppConstants.primaryColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppConstants.bgDarkAlt,
              backgroundImage: _imageFile != null 
                  ? FileImage(_imageFile!) 
                  : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null) as ImageProvider?,
              child: (_imageFile == null && _avatarUrl == null)
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGenresSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona los géneros que tocas',
            style: GoogleFonts.outfit(
              color: ThemeColors.secondaryText(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableGenres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGenres.remove(genre);
                    } else {
                      _selectedGenres.add(genre);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppConstants.primaryColor 
                        : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppConstants.primaryColor 
                          : ThemeColors.divider(context),
                    ),
                  ),
                  child: Text(
                    genre,
                    style: GoogleFonts.outfit(
                      color: isSelected 
                          ? Colors.black 
                          : ThemeColors.primaryText(context),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Días disponibles',
            style: GoogleFonts.outfit(
              color: ThemeColors.secondaryText(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ..._availability.keys.map((day) {
            return CheckboxListTile(
              title: Text(
                day.substring(0, 1).toUpperCase() + day.substring(1),
                style: GoogleFonts.outfit(
                  color: ThemeColors.primaryText(context),
                  fontSize: 14,
                ),
              ),
              value: _availability[day],
              activeColor: AppConstants.primaryColor,
              onChanged: (value) {
                setState(() {
                  _availability[day] = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGearSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input para agregar instrumentos
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _gearController,
                  style: TextStyle(color: ThemeColors.primaryText(context)),
                  decoration: InputDecoration(
                    labelText: 'Nuevo instrumento (${_gearList.length}/$MAX_GEAR)',
                    labelStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 14),
                    prefixIcon: Icon(Icons.high_quality_outlined, color: AppConstants.primaryColor, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onSubmitted: (_) => _addGear(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _gearList.length >= MAX_GEAR ? null : _addGear,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.add, color: _gearList.length >= MAX_GEAR ? Colors.grey : Colors.black, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Lista de instrumentos
        if (_gearList.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gearList.map((gear) {
                  return Chip(
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                    label: Text(gear, style: GoogleFonts.outfit(color: AppConstants.primaryColor, fontSize: 12)),
                    onDeleted: () {
                      setState(() {
                        _gearList.remove(gear);
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                  );
                }).toList(),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Sin instrumentos agregados', 
              style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: ThemeColors.primaryText(context)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 14),
          prefixIcon: Icon(icon, color: AppConstants.primaryColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.black)
          : Text('Guardar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
