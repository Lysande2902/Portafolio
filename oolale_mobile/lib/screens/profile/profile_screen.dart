import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import 'edit_profile_screen.dart';
import 'profile_detail_lists.dart';
import 'public_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profileData;
  List<dynamic> _instrumentos = [];
  List<String> _genres = [];
  int _eventosCount = 0;
  int _seguidoresCount = 0;
  int _musicCount = 0;
  int _ratingsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtistProfile();
  }

  Future<void> _loadArtistProfile() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    debugPrint('PROFILE: Cargando perfil para ${user.id}');
    
    try {
      final profile = await _supabase
          .from('perfiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      debugPrint('PROFILE: Perfil cargado: $profile');

      if (profile == null) {
        if (mounted) setState(() { _profileData = null; _isLoading = false; });
        return;
      }

      final gear = await _supabase
          .from('perfil_gear')
          .select('gear_catalog(nombre)')
          .eq('perfil_id', user.id);

      // Cargar géneros musicales
      final genresData = await _supabase
          .from('generos_perfil')
          .select('genre')
          .eq('profile_id', user.id);

      // Cargar contadores
      final eventosData = await _supabase
          .from('participantes_evento')
          .select()
          .eq('user_id', user.id);

      final seguidoresData = await _supabase
          .from('conexiones')
          .select()
          .eq('usuario_id', user.id)
          .eq('estatus', 'accepted');

      final musicData = await _supabase
          .from('perfil_gear')
          .select()
          .eq('perfil_id', user.id);

      // Cargar ratings count
      final ratingsCount = profile['total_calificaciones'] ?? 0;

      if (mounted) {
        setState(() {
          _profileData = profile;
          _instrumentos = gear;
          _genres = (genresData as List).map((g) => g['genre'].toString()).toList();
          _eventosCount = (eventosData as List).length;
          _seguidoresCount = (seguidoresData as List).length;
          _musicCount = (musicData as List).length;
          _ratingsCount = ratingsCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando Perfil: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro que quieres salir?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: AppConstants.errorColor)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
    }
  }

  void _shareProfile() {
    if (_profileData == null) return;
    final slug = _profileData!['slug_url'] ?? "u/${_profileData!['id']}";
    Share.share('¡Checa mi perfil en Óolale! ${_profileData!['nombre_artistico']} - https://oolale.app/$slug');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  // Instrumento Principal
                  if (_profileData?['instrumento_principal'] != null && 
                      _profileData!['instrumento_principal'].toString().trim().isNotEmpty) ...[
                    _buildInstrumentCard(),
                    const SizedBox(height: 30),
                  ],
                  _buildSectionTitle('Bio'),
                  const SizedBox(height: 10),
                  _buildBioCard(),
                  const SizedBox(height: 30),
                  
                  // Géneros musicales
                  if (_genres.isNotEmpty) ...[
                    _buildSectionTitle('Géneros Musicales'),
                    const SizedBox(height: 10),
                    _buildGenresCard(),
                    const SizedBox(height: 30),
                  ],
                  
                  // Años de experiencia y tarifa
                  if ((_profileData?['years_experience'] != null && _profileData!['years_experience'] > 0) ||
                      (_profileData?['base_rate'] != null && _profileData!['base_rate'] > 0)) ...[
                    _buildExperienceAndRateRow(),
                    const SizedBox(height: 30),
                  ],
                  
                  // Disponibilidad
                  if (_profileData?['availability'] != null && 
                      _profileData!['availability'].toString() != '{}' &&
                      _profileData!['availability'].values.any((e) => e == true)) ...[
                    _buildSectionTitle('Disponibilidad'),
                    const SizedBox(height: 10),
                    _buildAvailabilityCard(),
                    const SizedBox(height: 30),
                  ],
                  
                  // Redes sociales
                  if (_profileData?['social_links'] != null && 
                      _profileData!['social_links'].toString() != '{}' &&
                      (_profileData!['social_links'] as Map).isNotEmpty) ...[
                    _buildSectionTitle('Redes Sociales'),
                    const SizedBox(height: 10),
                    _buildSocialLinksCard(),
                    const SizedBox(height: 30),
                  ],
                  
                  _buildPortfolioButton(),
                  const SizedBox(height: 30),
                  
                  // Mi Equipo
                  if (_instrumentos.isNotEmpty) ...[
                    _buildSectionTitle('Mi Equipo'),
                    const SizedBox(height: 10),
                    _buildGearSection(),
                    const SizedBox(height: 100),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppConstants.primaryColor.withOpacity(0.2),
                  Colors.black,
                ]
              : [
                  AppConstants.primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Header Buttons
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                onPressed: () => context.push('/settings'),
              ),
            ),
            // Profile content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeInDown(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppConstants.primaryColor, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: _profileData?['foto_perfil'] != null 
                            ? NetworkImage(_profileData!['foto_perfil']) 
                            : null,
                        child: _profileData?['foto_perfil'] == null
                            ? Icon(Icons.person, size: 60, color: ThemeColors.iconSecondary(context))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _profileData?['nombre_artistico'] ?? 'Artista',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_profileData?['verificado'] == true) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: AppConstants.primaryColor, size: 24),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Ubicación
                  if (_profileData?['ubicacion'] != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: ThemeColors.secondaryText(context)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _profileData!['ubicacion'],
                              style: GoogleFonts.outfit(
                                color: ThemeColors.secondaryText(context),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Calificación
                  if (_profileData?['rating_promedio'] != null && _profileData!['rating_promedio'] > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          final rating = _profileData!['rating_promedio'] ?? 0.0;
                          return Icon(
                            index < rating.floor() ? Icons.star : Icons.star_border,
                            color: AppConstants.primaryColor,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${_profileData!['rating_promedio'].toStringAsFixed(1)} (${_profileData!['total_calificaciones'] ?? 0})',
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Badges
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_profileData?['open_to_work'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.work_outline, size: 12, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Disponible',
                                style: GoogleFonts.outfit(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_profileData?['ranking_tipo'] == 'premium') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.black),
                              const SizedBox(width: 4),
                              Text(
                                'PREMIUM',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ThemeColors.divider(context).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(
            _eventosCount.toString(), 'Eventos',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEventsScreen(userId: _profileData!['id']))),
          ),
          _buildStatDivider(),
          _buildStat(
            _seguidoresCount.toString(), 'Seguidores',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileFollowersScreen(userId: _profileData!['id']))),
          ),
          _buildStatDivider(),
          _buildStat(
            _musicCount.toString(), 'Equipo',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileGearScreen(userId: _profileData!['id']))),
          ),
          _buildStatDivider(),
          _buildStat(
            _ratingsCount.toString(), 'Ratings',
            () {
              final myId = _supabase.auth.currentUser?.id;
              if (myId != null) context.push('/ratings/$myId');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: ThemeColors.divider(context).withOpacity(0.08),
    );
  }

  Widget _buildStat(String value, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ThemeColors.primaryText(context),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context).withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              _loadArtistProfile();
            },
            icon: const Icon(Icons.edit_outlined),
            label: Text('Editar Perfil', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeColors.divider(context)),
          ),
          child: IconButton(
            onPressed: () {
              final myId = Supabase.instance.client.auth.currentUser?.id;
              if (myId != null) {
                // Navegar a public_profile_screen para ver cómo te ven otros usuarios
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicProfileScreen(userId: myId),
                  ),
                );
              }
            },
            icon: Icon(Icons.remove_red_eye_outlined, color: ThemeColors.icon(context)),
            tooltip: 'Ver cómo me ven otros usuarios',
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeColors.divider(context)),
          ),
          child: IconButton(
            onPressed: _shareProfile,
            icon: Icon(Icons.share_outlined, color: ThemeColors.icon(context)),
            tooltip: 'Compartir perfil',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: ThemeColors.primaryText(context),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInstrumentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              color: AppConstants.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instrumento Principal',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: ThemeColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profileData!['instrumento_principal'],
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Text(
        _profileData?['bio'] ?? 'Sin biografía. Cuéntale al mundo quién eres.',
        style: GoogleFonts.outfit(
          color: ThemeColors.secondaryText(context),
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildGenresCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _genres.map((genre) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.primaryColor),
            ),
            child: Text(
              genre,
              style: GoogleFonts.outfit(
                color: AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperienceAndRateRow() {
    final yearsExp = _profileData?['years_experience'] ?? 0;
    final baseRate = _profileData?['base_rate'] ?? 0.0;
    final currency = _profileData?['currency'] ?? 'MXN';
    
    return Row(
      children: [
        if (yearsExp > 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work_outline, color: AppConstants.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Experiencia',
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$yearsExp ${yearsExp == 1 ? 'año' : 'años'}',
                    style: GoogleFonts.outfit(
                      color: ThemeColors.primaryText(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (yearsExp > 0 && baseRate > 0) const SizedBox(width: 12),
        if (baseRate > 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: AppConstants.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tarifa Base',
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$$baseRate $currency',
                    style: GoogleFonts.outfit(
                      color: ThemeColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    final availability = _profileData?['availability'] as Map<String, dynamic>?;
    if (availability == null || availability.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.divider(context)),
        ),
        child: Center(
          child: Text(
            'Sin disponibilidad configurada',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
          ),
        ),
      );
    }

    final days = {
      'lunes': 'Lun',
      'martes': 'Mar',
      'miercoles': 'Mié',
      'jueves': 'Jue',
      'viernes': 'Vie',
      'sabado': 'Sáb',
      'domingo': 'Dom',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: days.entries.map((entry) {
          final isAvailable = availability[entry.key] == true;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isAvailable 
                  ? AppConstants.primaryColor.withOpacity(0.2) 
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAvailable 
                    ? AppConstants.primaryColor 
                    : ThemeColors.divider(context),
              ),
            ),
            child: Text(
              entry.value,
              style: GoogleFonts.outfit(
                color: isAvailable 
                    ? AppConstants.primaryColor 
                    : ThemeColors.secondaryText(context),
                fontSize: 12,
                fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSocialLinksCard() {
    final socialLinks = _profileData?['social_links'] as Map<String, dynamic>?;
    if (socialLinks == null || socialLinks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.divider(context)),
        ),
        child: Center(
          child: Text(
            'Sin redes sociales configuradas',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
          ),
        ),
      );
    }

    final platforms = {
      'instagram': {'icon': Icons.camera_alt, 'label': 'Instagram'},
      'youtube': {'icon': Icons.play_circle_outline, 'label': 'YouTube'},
      'spotify': {'icon': Icons.music_note, 'label': 'Spotify'},
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Column(
        children: platforms.entries.where((entry) {
          return socialLinks.containsKey(entry.key) && 
                 socialLinks[entry.key] != null && 
                 socialLinks[entry.key].toString().isNotEmpty;
        }).map((entry) {
          final url = socialLinks[entry.key].toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                // Aquí podrías abrir el URL con url_launcher
                debugPrint('Opening: $url');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.divider(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.value['icon'] as IconData,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value['label'] as String,
                            style: GoogleFonts.outfit(
                              color: ThemeColors.primaryText(context),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            url,
                            style: GoogleFonts.outfit(
                              color: ThemeColors.secondaryText(context),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: ThemeColors.iconSecondary(context),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGearSection() {
    if (_instrumentos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.divider(context)),
        ),
        child: Center(
          child: Text(
            'No has agregado equipo aún',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _instrumentos.map((i) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            i['gear_catalog']['nombre'],
            style: GoogleFonts.outfit(
              color: ThemeColors.primaryText(context),
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPortfolioButton() {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/portfolio/$myId'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor.withOpacity(0.2),
              AppConstants.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: AppConstants.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Galería',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sube imágenes, videos y audios',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: ThemeColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.primaryColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
