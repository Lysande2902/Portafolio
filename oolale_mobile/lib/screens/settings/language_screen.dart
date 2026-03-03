import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'es';
  bool _isLoading = true;

  final List<Map<String, String>> _languages = [
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'es';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading language: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeLanguage(String code) async {
    setState(() => _selectedLanguage = code);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', code);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Idioma cambiado a ${_languages.firstWhere((l) => l['code'] == code)['name']}'),
            backgroundColor: AppConstants.primaryColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('IDIOMA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection('SELECCIONA TU IDIOMA'),
                ..._languages.map((lang) => _buildLanguageTile(
                  lang['name']!,
                  lang['flag']!,
                  lang['code']!,
                )),
                
                const SizedBox(height: 20),
                _buildInfoCard(),
              ],
            ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppConstants.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String name, String flag, String code) {
    final isSelected = _selectedLanguage == code;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppConstants.primaryColor : ThemeColors.divider(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: code,
        groupValue: _selectedLanguage,
        onChanged: (value) => _changeLanguage(value!),
        secondary: Text(flag, style: const TextStyle(fontSize: 32)),
        title: Text(
          name,
          style: GoogleFonts.outfit(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        activeColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nota: La traducción completa de la app estará disponible próximamente. Actualmente solo está disponible en español.',
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
