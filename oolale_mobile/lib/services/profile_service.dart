import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user profiles with enhanced features
class ProfileService {
  final SupabaseClient _supabase;

  ProfileService(this._supabase);

  /// Save musical genres for a user (using array column)
  Future<void> saveGenres(String userId, List<String> genres) async {
    try {
      await _supabase.from('perfiles').update({
        'generos_musicales': genres,
      }).eq('id', userId);

      debugPrint('✅ Genres saved: ${genres.length}');
    } catch (e) {
      debugPrint('❌ Error saving genres: $e');
      rethrow;
    }
  }

  /// Get available genres (hardcoded list)
  List<String> getAvailableGenres() {
    return [
      'Rock',
      'Pop',
      'Jazz',
      'Blues',
      'Metal',
      'Reggae',
      'Salsa',
      'Cumbia',
      'Electrónica',
      'Hip Hop',
      'R&B',
      'Country',
      'Folk',
      'Clásica',
      'Latina',
      'Funk',
      'Soul',
      'Disco',
      'House',
      'Techno',
      'Trap',
      'Reggaeton',
      'Bachata',
      'Merengue',
      'Tango',
      'Flamenco',
      'Bossa Nova',
      'Samba',
      'Ska',
      'Punk',
      'Indie',
      'Alternative',
      'Grunge',
      'Gospel',
      'Bolero',
      'Ranchera',
      'Norteña',
      'Banda',
      'Mariachi',
      'Vallenato',
      'Otro',
    ];
  }

  /// Get user's selected genres (from array column)
  Future<List<String>> getUserGenres(String userId) async {
    try {
      final data = await _supabase
          .from('perfiles')
          .select('generos_musicales')
          .eq('id', userId)
          .single();

      final genres = data['generos_musicales'] as List<dynamic>?;
      return genres?.map((g) => g.toString()).toList() ?? [];
    } catch (e) {
      debugPrint('❌ Error getting user genres: $e');
      return [];
    }
  }

  /// Save musical information (genres, experience, skill level, languages)
  Future<void> saveMusicalInfo({
    required String userId,
    List<String>? genres,
    int? yearsExperience,
    String? skillLevel,
    List<String>? languages,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (genres != null) updates['generos_musicales'] = genres;
      if (yearsExperience != null) updates['anos_experiencia'] = yearsExperience;
      if (skillLevel != null) updates['nivel_habilidad'] = skillLevel;
      if (languages != null) updates['idiomas'] = languages;

      if (updates.isNotEmpty) {
        await _supabase.from('perfiles').update(updates).eq('id', userId);
        debugPrint('✅ Musical info saved: ${updates.keys.join(", ")}');
      }
    } catch (e) {
      debugPrint('❌ Error saving musical info: $e');
      rethrow;
    }
  }

  /// Get available skill levels
  List<String> getSkillLevels() {
    return ['principiante', 'intermedio', 'avanzado', 'profesional'];
  }

  /// Get skill level display name
  String getSkillLevelDisplay(String level) {
    switch (level) {
      case 'principiante':
        return 'Principiante';
      case 'intermedio':
        return 'Intermedio';
      case 'avanzado':
        return 'Avanzado';
      case 'profesional':
        return 'Profesional';
      default:
        return level;
    }
  }

  /// Get available languages
  List<String> getAvailableLanguages() {
    return [
      'Español',
      'Inglés',
      'Portugués',
      'Francés',
      'Italiano',
      'Alemán',
      'Catalán',
      'Gallego',
      'Euskera',
      'Quechua',
      'Guaraní',
      'Otro',
    ];
  }

  /// Save experience and availability
  Future<void> saveExperienceAndAvailability(
    String userId,
    int yearsExperience,
    Map<String, dynamic> availability,
  ) async {
    try {
      await _supabase.from('perfiles').update({
        'years_experience': yearsExperience,
        'availability': availability,
      }).eq('id', userId);

      debugPrint('✅ Experience and availability saved');
    } catch (e) {
      debugPrint('❌ Error saving experience and availability: $e');
      rethrow;
    }
  }

  /// Save base rate with currency
  Future<void> saveBaseRate(String userId, double amount, String currency) async {
    try {
      await _supabase.from('perfiles').update({
        'base_rate': amount,
        'currency': currency,
      }).eq('id', userId);

      debugPrint('✅ Base rate saved: $amount $currency');
    } catch (e) {
      debugPrint('❌ Error saving base rate: $e');
      rethrow;
    }
  }

  /// Save social links
  Future<void> saveSocialLinks(String userId, Map<String, String> links) async {
    try {
      // Filter out empty links
      final filteredLinks = Map<String, String>.from(links)
        ..removeWhere((key, value) => value.trim().isEmpty);

      await _supabase.from('perfiles').update({
        'social_links': filteredLinks,
      }).eq('id', userId);

      debugPrint('✅ Social links saved: ${filteredLinks.length}');
    } catch (e) {
      debugPrint('❌ Error saving social links: $e');
      rethrow;
    }
  }

  /// Calculate profile completion percentage
  /// Based on 15 required fields
  int calculateProfileCompletion(Map<String, dynamic> profile) {
    int completedFields = 0;
    const int totalFields = 15;

    // Basic required fields
    if (profile['nombre_artistico'] != null && profile['nombre_artistico'].toString().isNotEmpty) completedFields++;
    if (profile['foto_perfil'] != null && profile['foto_perfil'].toString().isNotEmpty) completedFields++;
    if (profile['avatar_url'] != null && profile['avatar_url'].toString().isNotEmpty) completedFields++;
    if (profile['bio'] != null && profile['bio'].toString().isNotEmpty) completedFields++;
    if (profile['instrumento_principal'] != null && profile['instrumento_principal'].toString().isNotEmpty) completedFields++;
    if (profile['ubicacion'] != null && profile['ubicacion'].toString().isNotEmpty) completedFields++;
    if (profile['pais'] != null && profile['pais'].toString().isNotEmpty) completedFields++;
    
    // Musical information fields (Phase 3 - Day 8)
    if (profile['generos_musicales'] != null && (profile['generos_musicales'] as List?)?.isNotEmpty == true) completedFields++;
    if (profile['anos_experiencia'] != null && profile['anos_experiencia'] > 0) completedFields++;
    if (profile['nivel_habilidad'] != null && profile['nivel_habilidad'].toString().isNotEmpty) completedFields++;
    if (profile['idiomas'] != null && (profile['idiomas'] as List?)?.isNotEmpty == true) completedFields++;
    
    // Optional fields
    if (profile['years_experience'] != null && profile['years_experience'] > 0) completedFields++;
    if (profile['availability'] != null && (profile['availability'] as Map).isNotEmpty) completedFields++;
    if (profile['base_rate'] != null && profile['base_rate'] > 0) completedFields++;
    if (profile['social_links'] != null && (profile['social_links'] as Map).isNotEmpty) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  /// Get list of missing fields for profile completion
  List<String> getMissingFields(Map<String, dynamic> profile) {
    final List<String> missing = [];

    if (profile['nombre_artistico'] == null || profile['nombre_artistico'].toString().isEmpty) {
      missing.add('Nombre artístico');
    }
    if (profile['foto_perfil'] == null || profile['foto_perfil'].toString().isEmpty) {
      if (profile['avatar_url'] == null || profile['avatar_url'].toString().isEmpty) {
        missing.add('Foto de perfil');
      }
    }
    if (profile['bio'] == null || profile['bio'].toString().isEmpty) {
      missing.add('Biografía');
    }
    if (profile['instrumento_principal'] == null || profile['instrumento_principal'].toString().isEmpty) {
      missing.add('Instrumento principal');
    }
    if (profile['ubicacion'] == null || profile['ubicacion'].toString().isEmpty) {
      missing.add('Ubicación');
    }
    if (profile['pais'] == null || profile['pais'].toString().isEmpty) {
      missing.add('País');
    }
    if (profile['generos_musicales'] == null || (profile['generos_musicales'] as List?)?.isEmpty != false) {
      missing.add('Géneros musicales');
    }
    if (profile['anos_experiencia'] == null || profile['anos_experiencia'] == 0) {
      missing.add('Años de experiencia');
    }
    if (profile['nivel_habilidad'] == null || profile['nivel_habilidad'].toString().isEmpty) {
      missing.add('Nivel de habilidad');
    }
    if (profile['idiomas'] == null || (profile['idiomas'] as List?)?.isEmpty != false) {
      missing.add('Idiomas');
    }
    if (profile['years_experience'] == null || profile['years_experience'] == 0) {
      missing.add('Años de experiencia (legacy)');
    }
    if (profile['availability'] == null || (profile['availability'] as Map?)?.isEmpty != false) {
      missing.add('Disponibilidad');
    }
    if (profile['base_rate'] == null || profile['base_rate'] == 0) {
      missing.add('Tarifa base');
    }
    if (profile['social_links'] == null || (profile['social_links'] as Map?)?.isEmpty != false) {
      missing.add('Redes sociales');
    }

    return missing;
  }

  /// Validate URL format
  bool isValidUrl(String url) {
    if (url.trim().isEmpty) return true; // Empty is valid (optional)
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Validate social media URL for specific platform
  bool isValidSocialUrl(String platform, String url) {
    if (url.trim().isEmpty) return true;
    
    if (!isValidUrl(url)) return false;

    final lowerUrl = url.toLowerCase();
    switch (platform.toLowerCase()) {
      case 'instagram':
        return lowerUrl.contains('instagram.com');
      case 'youtube':
        return lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be');
      case 'spotify':
        return lowerUrl.contains('spotify.com');
      case 'soundcloud':
        return lowerUrl.contains('soundcloud.com');
      default:
        return true;
    }
  }

  /// Update profile completion in database
  Future<void> updateProfileCompletion(String userId) async {
    try {
      final profile = await _supabase
          .from('perfiles')
          .select()
          .eq('id', userId)
          .single();

      final completion = calculateProfileCompletion(profile);

      await _supabase
          .from('perfiles')
          .update({'profile_completion': completion})
          .eq('id', userId);

      debugPrint('✅ Profile completion updated: $completion%');
    } catch (e) {
      debugPrint('❌ Error updating profile completion: $e');
      rethrow;
    }
  }

  // ============================================
  // AVAILABILITY AND RATES (Phase 3 - Day 9)
  // ============================================

  /// Save weekly availability
  Future<void> saveWeeklyAvailability(
    String userId,
    Map<String, dynamic> availability,
  ) async {
    try {
      await _supabase.from('perfiles').update({
        'disponibilidad_semanal': availability,
      }).eq('id', userId);

      debugPrint('✅ Weekly availability saved');
    } catch (e) {
      debugPrint('❌ Error saving weekly availability: $e');
      rethrow;
    }
  }

  /// Get user's weekly availability
  Future<Map<String, dynamic>> getWeeklyAvailability(String userId) async {
    try {
      final data = await _supabase
          .from('perfiles')
          .select('disponibilidad_semanal')
          .eq('id', userId)
          .single();

      return data['disponibilidad_semanal'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      debugPrint('❌ Error getting weekly availability: $e');
      return {};
    }
  }

  /// Save rates (base, min, max) and currency
  Future<void> saveRates({
    required String userId,
    double? baseRate,
    double? minRate,
    double? maxRate,
    String? currency,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (baseRate != null) updates['tarifa_base'] = baseRate;
      if (minRate != null) updates['tarifa_minima'] = minRate;
      if (maxRate != null) updates['tarifa_maxima'] = maxRate;
      if (currency != null) updates['moneda'] = currency;

      if (updates.isNotEmpty) {
        await _supabase.from('perfiles').update(updates).eq('id', userId);
        debugPrint('✅ Rates saved: ${updates.keys.join(", ")}');
      }
    } catch (e) {
      debugPrint('❌ Error saving rates: $e');
      rethrow;
    }
  }

  /// Get user's rates
  Future<Map<String, dynamic>> getUserRates(String userId) async {
    try {
      final data = await _supabase
          .from('perfiles')
          .select('tarifa_base, tarifa_minima, tarifa_maxima, moneda')
          .eq('id', userId)
          .single();

      return {
        'tarifa_base': data['tarifa_base'],
        'tarifa_minima': data['tarifa_minima'],
        'tarifa_maxima': data['tarifa_maxima'],
        'moneda': data['moneda'] ?? 'MXN',
      };
    } catch (e) {
      debugPrint('❌ Error getting user rates: $e');
      return {'moneda': 'MXN'};
    }
  }

  /// Save event types accepted
  Future<void> saveEventTypes(String userId, List<String> eventTypes) async {
    try {
      await _supabase.from('perfiles').update({
        'tipos_eventos_acepta': eventTypes,
      }).eq('id', userId);

      debugPrint('✅ Event types saved: ${eventTypes.length}');
    } catch (e) {
      debugPrint('❌ Error saving event types: $e');
      rethrow;
    }
  }

  /// Get available event types
  List<String> getAvailableEventTypes() {
    return [
      'Concierto',
      'Ensayo',
      'Jam Session',
      'Sesión de Estudio',
      'Boda',
      'Evento Corporativo',
      'Festival',
      'Bar/Restaurante',
      'Fiesta Privada',
      'Grabación',
      'Clase/Taller',
      'Otro',
    ];
  }

  /// Get event type display name
  String getEventTypeDisplay(String type) {
    return type; // Already in display format
  }

  /// Save event preferences (paid/practice)
  Future<void> saveEventPreferences({
    required String userId,
    bool? acceptsPaid,
    bool? acceptsPractice,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (acceptsPaid != null) updates['acepta_eventos_pagados'] = acceptsPaid;
      if (acceptsPractice != null) updates['acepta_eventos_practica'] = acceptsPractice;
      if (notes != null) updates['notas_disponibilidad'] = notes;

      if (updates.isNotEmpty) {
        await _supabase.from('perfiles').update(updates).eq('id', userId);
        debugPrint('✅ Event preferences saved');
      }
    } catch (e) {
      debugPrint('❌ Error saving event preferences: $e');
      rethrow;
    }
  }

  /// Get user's event preferences
  Future<Map<String, dynamic>> getEventPreferences(String userId) async {
    try {
      final data = await _supabase
          .from('perfiles')
          .select('acepta_eventos_pagados, acepta_eventos_practica, notas_disponibilidad, tipos_eventos_acepta')
          .eq('id', userId)
          .single();

      return {
        'acepta_eventos_pagados': data['acepta_eventos_pagados'] ?? true,
        'acepta_eventos_practica': data['acepta_eventos_practica'] ?? true,
        'notas_disponibilidad': data['notas_disponibilidad'],
        'tipos_eventos_acepta': data['tipos_eventos_acepta'] ?? [],
      };
    } catch (e) {
      debugPrint('❌ Error getting event preferences: $e');
      return {
        'acepta_eventos_pagados': true,
        'acepta_eventos_practica': true,
        'notas_disponibilidad': null,
        'tipos_eventos_acepta': [],
      };
    }
  }

  /// Get available currencies
  List<String> getAvailableCurrencies() {
    return ['MXN', 'USD', 'EUR', 'GBP', 'CAD', 'ARS', 'COP', 'CLP', 'PEN', 'BRL'];
  }

  /// Get currency symbol
  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'MXN':
        return '\$';
      case 'USD':
        return 'US\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'CAD':
        return 'C\$';
      case 'ARS':
        return 'AR\$';
      case 'COP':
        return 'CO\$';
      case 'CLP':
        return 'CL\$';
      case 'PEN':
        return 'S/';
      case 'BRL':
        return 'R\$';
      default:
        return currency;
    }
  }

  /// Get days of week in Spanish
  List<String> getDaysOfWeek() {
    return ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
  }

  /// Get day display name
  String getDayDisplay(String day) {
    switch (day) {
      case 'lunes':
        return 'Lunes';
      case 'martes':
        return 'Martes';
      case 'miercoles':
        return 'Miércoles';
      case 'jueves':
        return 'Jueves';
      case 'viernes':
        return 'Viernes';
      case 'sabado':
        return 'Sábado';
      case 'domingo':
        return 'Domingo';
      default:
        return day;
    }
  }

  /// Save complete availability and rates info
  Future<void> saveAvailabilityAndRates({
    required String userId,
    Map<String, dynamic>? availability,
    double? baseRate,
    double? minRate,
    double? maxRate,
    String? currency,
    List<String>? eventTypes,
    bool? acceptsPaid,
    bool? acceptsPractice,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (availability != null) updates['disponibilidad_semanal'] = availability;
      if (baseRate != null) updates['tarifa_base'] = baseRate;
      if (minRate != null) updates['tarifa_minima'] = minRate;
      if (maxRate != null) updates['tarifa_maxima'] = maxRate;
      if (currency != null) updates['moneda'] = currency;
      if (eventTypes != null) updates['tipos_eventos_acepta'] = eventTypes;
      if (acceptsPaid != null) updates['acepta_eventos_pagados'] = acceptsPaid;
      if (acceptsPractice != null) updates['acepta_eventos_practica'] = acceptsPractice;
      if (notes != null) updates['notas_disponibilidad'] = notes;

      if (updates.isNotEmpty) {
        await _supabase.from('perfiles').update(updates).eq('id', userId);
        debugPrint('✅ Availability and rates saved: ${updates.keys.length} fields');
      }
    } catch (e) {
      debugPrint('❌ Error saving availability and rates: $e');
      rethrow;
    }
  }

  // ============================================
  // SOCIAL LINKS AND COMPLETION (Phase 3 - Day 10)
  // ============================================

  /// Save social media links
  Future<void> saveSocialMediaLinks(
    String userId,
    Map<String, String> links,
  ) async {
    try {
      // Filter out empty links
      final filteredLinks = Map<String, String>.from(links)
        ..removeWhere((key, value) => value.trim().isEmpty);

      await _supabase.from('perfiles').update({
        'redes_sociales': filteredLinks,
      }).eq('id', userId);

      debugPrint('✅ Social media links saved: ${filteredLinks.length}');
    } catch (e) {
      debugPrint('❌ Error saving social media links: $e');
      rethrow;
    }
  }

  /// Get user's social media links
  Future<Map<String, String>> getSocialMediaLinks(String userId) async {
    try {
      final data = await _supabase
          .from('perfiles')
          .select('redes_sociales')
          .eq('id', userId)
          .single();

      final links = data['redes_sociales'] as Map<String, dynamic>?;
      if (links == null) return {};

      return links.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      debugPrint('❌ Error getting social media links: $e');
      return {};
    }
  }

  /// Get available social media platforms
  List<Map<String, String>> getAvailableSocialPlatforms() {
    return [
      {'key': 'instagram', 'name': 'Instagram', 'icon': '📷', 'placeholder': 'https://instagram.com/tu_usuario'},
      {'key': 'youtube', 'name': 'YouTube', 'icon': '🎥', 'placeholder': 'https://youtube.com/@tu_canal'},
      {'key': 'spotify', 'name': 'Spotify', 'icon': '🎵', 'placeholder': 'https://open.spotify.com/artist/...'},
      {'key': 'soundcloud', 'name': 'SoundCloud', 'icon': '🔊', 'placeholder': 'https://soundcloud.com/tu_usuario'},
      {'key': 'facebook', 'name': 'Facebook', 'icon': '👥', 'placeholder': 'https://facebook.com/tu_pagina'},
      {'key': 'twitter', 'name': 'Twitter/X', 'icon': '🐦', 'placeholder': 'https://twitter.com/tu_usuario'},
      {'key': 'tiktok', 'name': 'TikTok', 'icon': '🎬', 'placeholder': 'https://tiktok.com/@tu_usuario'},
      {'key': 'bandcamp', 'name': 'Bandcamp', 'icon': '🎸', 'placeholder': 'https://tu_banda.bandcamp.com'},
      {'key': 'website', 'name': 'Sitio Web', 'icon': '🌐', 'placeholder': 'https://tu-sitio.com'},
      {'key': 'otro', 'name': 'Otro', 'icon': '🔗', 'placeholder': 'https://...'},
    ];
  }

  /// Get profile completion percentage
  Future<int> getProfileCompletion(String userId) async {
    try {
      final data = await _supabase
          .from('perfiles')
          .select('completitud_perfil')
          .eq('id', userId)
          .single();

      return data['completitud_perfil'] as int? ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting profile completion: $e');
      return 0;
    }
  }

  /// Get missing profile fields
  Future<List<Map<String, String>>> getMissingProfileFields(String userId) async {
    try {
      final result = await _supabase
          .rpc('get_missing_profile_fields', params: {'user_id_param': userId});

      if (result == null) return [];

      return (result as List<dynamic>).map((item) {
        return {
          'campo': item['campo'].toString(),
          'categoria': item['categoria'].toString(),
          'prioridad': item['prioridad'].toString(),
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting missing fields: $e');
      return [];
    }
  }

  /// Get completion category (for UI display)
  String getCompletionCategory(int completion) {
    if (completion >= 90) return 'Excelente';
    if (completion >= 70) return 'Muy Bueno';
    if (completion >= 50) return 'Bueno';
    if (completion >= 30) return 'Regular';
    return 'Incompleto';
  }

  /// Get completion color (for UI display)
  String getCompletionColor(int completion) {
    if (completion >= 90) return 'green';
    if (completion >= 70) return 'lightGreen';
    if (completion >= 50) return 'yellow';
    if (completion >= 30) return 'orange';
    return 'red';
  }

  /// Validate social media URL
  bool isValidSocialMediaUrl(String platform, String url) {
    if (url.trim().isEmpty) return true; // Empty is valid (optional)
    
    if (!isValidUrl(url)) return false;

    final lowerUrl = url.toLowerCase();
    final lowerPlatform = platform.toLowerCase();

    switch (lowerPlatform) {
      case 'instagram':
        return lowerUrl.contains('instagram.com');
      case 'youtube':
        return lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be');
      case 'spotify':
        return lowerUrl.contains('spotify.com');
      case 'soundcloud':
        return lowerUrl.contains('soundcloud.com');
      case 'facebook':
        return lowerUrl.contains('facebook.com') || lowerUrl.contains('fb.com');
      case 'twitter':
        return lowerUrl.contains('twitter.com') || lowerUrl.contains('x.com');
      case 'tiktok':
        return lowerUrl.contains('tiktok.com');
      case 'bandcamp':
        return lowerUrl.contains('bandcamp.com');
      case 'website':
      case 'otro':
        return true; // Any valid URL is acceptable
      default:
        return true;
    }
  }

  /// Get social media icon
  String getSocialMediaIcon(String platform) {
    final platforms = getAvailableSocialPlatforms();
    final found = platforms.firstWhere(
      (p) => p['key'] == platform,
      orElse: () => {'icon': '🔗'},
    );
    return found['icon'] ?? '🔗';
  }

  /// Get social media display name
  String getSocialMediaDisplayName(String platform) {
    final platforms = getAvailableSocialPlatforms();
    final found = platforms.firstWhere(
      (p) => p['key'] == platform,
      orElse: () => {'name': platform},
    );
    return found['name'] ?? platform;
  }
}
