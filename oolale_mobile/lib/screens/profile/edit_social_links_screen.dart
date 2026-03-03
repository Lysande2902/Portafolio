import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

/// Screen for editing social media links
class EditSocialLinksScreen extends StatefulWidget {
  const EditSocialLinksScreen({super.key});

  @override
  State<EditSocialLinksScreen> createState() => _EditSocialLinksScreenState();
}

class _EditSocialLinksScreenState extends State<EditSocialLinksScreen> {
  final _supabase = Supabase.instance.client;
  late final ProfileService _profileService;

  bool _isLoading = true;
  bool _isSaving = false;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(_supabase);
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    final platforms = _profileService.getAvailableSocialPlatforms();
    for (final platform in platforms) {
      _controllers[platform['key']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      final links = await _profileService.getSocialMediaLinks(userId);

      for (final entry in links.entries) {
        if (_controllers.containsKey(entry.key)) {
          _controllers[entry.key]!.text = entry.value;
        }
      }
    } catch (e) {
      ErrorHandler.logError('EditSocialLinksScreen._loadData', e);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al cargar datos',
          onRetry: _loadData,
        );
      }
    } finally {
      if (mounted && _isLoading) { // Ensure _isLoading is set to false if not already handled by catch
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateLinks() {
    _errors.clear();
    bool isValid = true;

    for (final entry in _controllers.entries) {
      final platform = entry.key;
      final url = entry.value.text.trim();

      if (url.isNotEmpty) {
        if (!_profileService.isValidSocialMediaUrl(platform, url)) {
          _errors[platform] = 'URL inválida para $platform';
          isValid = false;
        }
      }
    }

    setState(() {});
    return isValid;
  }

  Future<void> _saveData() async {
    if (!_validateLinks()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor corrige los errores'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      // Build links map
      final Map<String, String> links = {};
      for (final entry in _controllers.entries) {
        final url = entry.value.text.trim();
        if (url.isNotEmpty) {
          links[entry.key] = url;
        }
      }

      await _profileService.saveSocialMediaLinks(userId, links);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Redes sociales guardadas'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ErrorHandler.logError('EditSocialLinksScreen._saveData', e);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al guardar enlaces',
          onRetry: _saveData,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Redes Sociales'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final platforms = _profileService.getAvailableSocialPlatforms();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redes Sociales'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveData,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: ThemeColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: ThemeColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Agrega tus redes sociales para que otros músicos puedan conocer tu trabajo',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Social media fields
            ...platforms.map((platform) {
              final key = platform['key']!;
              final name = platform['name']!;
              final icon = platform['icon']!;
              final placeholder = platform['placeholder']!;
              final controller = _controllers[key]!;
              final hasError = _errors.containsKey(key);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: '$icon $name',
                    hintText: placeholder,
                    border: const OutlineInputBorder(),
                    errorText: hasError ? _errors[key] : null,
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) {
                    if (hasError) {
                      setState(() => _errors.remove(key));
                    }
                  },
                ),
              );
            }),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(
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
}
