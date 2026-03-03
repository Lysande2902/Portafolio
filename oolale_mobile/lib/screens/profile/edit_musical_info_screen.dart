import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme_colors.dart';
import '../../services/profile_service.dart';
import '../../utils/error_handler.dart';

/// Screen for editing musical information (Phase 3 - Day 8)
/// Includes: genres, experience, skill level, languages
class EditMusicalInfoScreen extends StatefulWidget {
  const EditMusicalInfoScreen({super.key});

  @override
  State<EditMusicalInfoScreen> createState() => _EditMusicalInfoScreenState();
}

class _EditMusicalInfoScreenState extends State<EditMusicalInfoScreen> {
  final _supabase = Supabase.instance.client;
  late final ProfileService _profileService;
  
  bool _isLoading = false;
  bool _isSaving = false;
  
  // Musical information
  List<String> _selectedGenres = [];
  int _yearsExperience = 0;
  String _skillLevel = 'principiante';
  List<String> _selectedLanguages = [];
  
  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(_supabase);
    _loadMusicalInfo();
  }

  Future<void> _loadMusicalInfo() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('perfiles')
          .select('generos_musicales, anos_experiencia, nivel_habilidad, idiomas')
          .eq('id', userId)
          .single();

      setState(() {
        // Load genres
        final genres = data['generos_musicales'] as List<dynamic>?;
        _selectedGenres = genres?.map((g) => g.toString()).toList() ?? [];
        
        // Load experience
        _yearsExperience = data['anos_experiencia'] ?? 0;
        
        // Load skill level
        _skillLevel = data['nivel_habilidad'] ?? 'principiante';
        
        // Load languages
        final languages = data['idiomas'] as List<dynamic>?;
        _selectedLanguages = languages?.map((l) => l.toString()).toList() ?? [];
      });
    } catch (e) {
      ErrorHandler.logError('EditMusicalInfoScreen._loadMusicalInfo', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al cargar información',
          onRetry: _loadMusicalInfo,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMusicalInfo() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      await _profileService.saveMusicalInfo(
        userId: userId,
        genres: _selectedGenres,
        yearsExperience: _yearsExperience,
        skillLevel: _skillLevel,
        languages: _selectedLanguages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Información musical guardada'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate changes
      }
    } catch (e) {
      ErrorHandler.logError('EditMusicalInfoScreen._saveMusicalInfo', e);
      if (mounted) {
        setState(() => _isSaving = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al guardar cambios',
          onRetry: _saveMusicalInfo,
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showGenreSelector() {
    final availableGenres = _profileService.getAvailableGenres();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Selecciona tus géneros',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableGenres.length,
              itemBuilder: (context, index) {
                final genre = availableGenres[index];
                final isSelected = _selectedGenres.contains(genre);
                
                return CheckboxListTile(
                  title: Text(genre),
                  value: isSelected,
                  activeColor: ThemeColors.primary,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Update main screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final availableLanguages = _profileService.getAvailableLanguages();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Selecciona idiomas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableLanguages.length,
              itemBuilder: (context, index) {
                final language = availableLanguages[index];
                final isSelected = _selectedLanguages.contains(language);
                
                return CheckboxListTile(
                  title: Text(language),
                  value: isSelected,
                  activeColor: ThemeColors.primary,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        _selectedLanguages.add(language);
                      } else {
                        _selectedLanguages.remove(language);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Update main screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Información Musical',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ThemeColors.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genres Section
                  _buildSectionTitle('Géneros Musicales'),
                  const SizedBox(height: 8),
                  _buildGenresCard(),
                  const SizedBox(height: 24),

                  // Experience Section
                  _buildSectionTitle('Experiencia'),
                  const SizedBox(height: 8),
                  _buildExperienceCard(),
                  const SizedBox(height: 24),

                  // Skill Level Section
                  _buildSectionTitle('Nivel de Habilidad'),
                  const SizedBox(height: 8),
                  _buildSkillLevelCard(),
                  const SizedBox(height: 24),

                  // Languages Section
                  _buildSectionTitle('Idiomas'),
                  const SizedBox(height: 8),
                  _buildLanguagesCard(),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveMusicalInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Text(
                              'Guardar Cambios',
                              style: GoogleFonts.poppins(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ThemeColors.textPrimary,
      ),
    );
  }

  Widget _buildGenresCard() {
    return Card(
      color: ThemeColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Géneros que tocas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: ThemeColors.textSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showGenreSelector,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedGenres.isEmpty)
              Text(
                'No has seleccionado géneros',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ThemeColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedGenres.map((genre) {
                  return Chip(
                    label: Text(genre),
                    backgroundColor: ThemeColors.primary.withOpacity(0.2),
                    labelStyle: GoogleFonts.poppins(
                      color: ThemeColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedGenres.remove(genre);
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard() {
    return Card(
      color: ThemeColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Años de experiencia musical',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _yearsExperience > 0
                      ? () => setState(() => _yearsExperience--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: ThemeColors.primary,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$_yearsExperience',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primary,
                        ),
                      ),
                      Text(
                        _yearsExperience == 1 ? 'año' : 'años',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: ThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _yearsExperience < 99
                      ? () => setState(() => _yearsExperience++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: ThemeColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _yearsExperience.toDouble(),
              min: 0,
              max: 50,
              divisions: 50,
              activeColor: ThemeColors.primary,
              inactiveColor: ThemeColors.primary.withOpacity(0.2),
              onChanged: (value) {
                setState(() => _yearsExperience = value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillLevelCard() {
    final skillLevels = _profileService.getSkillLevels();
    
    return Card(
      color: ThemeColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona tu nivel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...skillLevels.map((level) {
              final isSelected = _skillLevel == level;
              return RadioListTile<String>(
                title: Text(
                  _profileService.getSkillLevelDisplay(level),
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(_getSkillLevelDescription(level)),
                value: level,
                groupValue: _skillLevel,
                activeColor: ThemeColors.primary,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _skillLevel = value);
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getSkillLevelDescription(String level) {
    switch (level) {
      case 'principiante':
        return 'Estoy aprendiendo los fundamentos';
      case 'intermedio':
        return 'Tengo experiencia y puedo tocar con otros';
      case 'avanzado':
        return 'Domino mi instrumento y técnicas avanzadas';
      case 'profesional':
        return 'Vivo de la música y tengo amplia experiencia';
      default:
        return '';
    }
  }

  Widget _buildLanguagesCard() {
    return Card(
      color: ThemeColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Idiomas que hablas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: ThemeColors.textSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showLanguageSelector,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedLanguages.isEmpty)
              Text(
                'No has seleccionado idiomas',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ThemeColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedLanguages.map((language) {
                  return Chip(
                    label: Text(language),
                    backgroundColor: ThemeColors.primary.withOpacity(0.2),
                    labelStyle: GoogleFonts.poppins(
                      color: ThemeColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedLanguages.remove(language);
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
