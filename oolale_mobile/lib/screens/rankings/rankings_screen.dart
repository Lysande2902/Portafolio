import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../profile/public_profile_screen.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;
  
  List<dynamic> _topRated = [];
  List<dynamic> _mostConnected = [];
  List<dynamic> _mostActive = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRankings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    
    try {
      final myId = _supabase.auth.currentUser?.id;
      
      // Obtener lista de usuarios bloqueados (Mutual: mis bloqueados + quienes me bloquearon)
      List<String> blockedIds = [];
      if (myId != null) {
        final blockedUsers = await _supabase
            .from('usuarios_bloqueados')
            .select('usuario_id, bloqueado_id')
            .or('usuario_id.eq.$myId,bloqueado_id.eq.$myId')
            .eq('activo', true);
        
        blockedIds = blockedUsers.map((b) => 
          b['usuario_id'] == myId ? b['bloqueado_id'].toString() : b['usuario_id'].toString()
        ).toList();
      }
      
      // 1. Cargando rankings por total_conexiones (Más Populares)
      var popularesQuery = _supabase.from('perfiles').select();
      if (myId != null) {
        popularesQuery = popularesQuery.neq('id', myId);
      }
      if (blockedIds.isNotEmpty) {
        popularesQuery = popularesQuery.filter('id', 'not.in', '(${blockedIds.join(',')})');
      }
      
      final popularesData = await popularesQuery
          .order('total_conexiones', ascending: false)
          .limit(20);

      // 2. Cargando rankings por rating_promedio (Mejor Valorerados)
      var mejorValoradosQuery = _supabase.from('perfiles').select();
      if (myId != null) {
        mejorValoradosQuery = mejorValoradosQuery.neq('id', myId);
      }
      if (blockedIds.isNotEmpty) {
        mejorValoradosQuery = mejorValoradosQuery.filter('id', 'not.in', '(${blockedIds.join(',')})');
      }
      
      final mejorValoradosData = await mejorValoradosQuery
          .not('rating_promedio', 'is', null)
          .order('rating_promedio', ascending: false)
          .limit(20);
      
      // Top por actividad (eventos + posts)
      var activeQuery = _supabase.from('perfiles').select();
      if (myId != null) activeQuery = activeQuery.neq('id', myId);
      if (blockedIds.isNotEmpty) {
        activeQuery = activeQuery.filter('id', 'not.in', '(${blockedIds.join(',')})');
      }
      
      final activeData = await activeQuery
          .order('total_eventos', ascending: false)
          .limit(50);
      
      if (mounted) {
        setState(() {
          _topRated = mejorValoradosData;
          _mostConnected = popularesData;
          _mostActive = activeData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando rankings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'RANKINGS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryColor,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: ThemeColors.secondaryText(context),
          labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'TOP RATED'),
            Tab(text: 'CONECTADOS'),
            Tab(text: 'ACTIVOS'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRankingList(_topRated, 'rating'),
                _buildRankingList(_mostConnected, 'connections'),
                _buildRankingList(_mostActive, 'events'),
              ],
            ),
    );
  }

  Widget _buildRankingList(List<dynamic> users, String type) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: ThemeColors.iconSecondary(context)),
            const SizedBox(height: 20),
            Text(
              'No hay datos disponibles',
              style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRankings,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            duration: const Duration(milliseconds: 250),
            delay: Duration(milliseconds: index * 30),
            child: _RankingCard(
              user: users[index],
              position: index + 1,
              type: type,
              onTap: () {
                context.push('/profile/${users[index]['id']}');
              },
            ),
          );
        },
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final dynamic user;
  final int position;
  final String type;
  final VoidCallback onTap;

  const _RankingCard({
    required this.user,
    required this.position,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = position <= 3;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTopThree 
                ? _getMedalColor(position).withOpacity(0.5)
                : ThemeColors.divider(context),
            width: isTopThree ? 2 : 1,
          ),
          gradient: isTopThree
              ? LinearGradient(
                  colors: [
                    _getMedalColor(position).withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          children: [
            // Posición
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isTopThree 
                    ? _getMedalColor(position).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isTopThree
                    ? Text(
                        _getMedalEmoji(position),
                        style: const TextStyle(fontSize: 20),
                      )
                    : Text(
                        '#$position',
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor.withOpacity(0.3),
                    AppConstants.primaryColor.withOpacity(0.05),
                  ],
                ),
                image: user['foto_perfil'] != null
                    ? DecorationImage(
                        image: NetworkImage(user['foto_perfil']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user['foto_perfil'] == null
                  ? Center(
                      child: Icon(
                        Icons.person,
                        size: 25,
                        color: ThemeColors.icon(context).withOpacity(0.3),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user['nombre_artistico'] ?? 'Artista',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.primaryText(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user['verificado'] == true)
                        Icon(Icons.verified, color: AppConstants.primaryColor, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (user['ranking_tipo'] == 'premium') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: GoogleFonts.outfit(
                              color: Colors.amber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        user['instrumento_principal'] ?? 'Músico',
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Estadística
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getStatValue(type),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                Text(
                  _getStatLabel(type),
                  style: GoogleFonts.outfit(
                    color: ThemeColors.secondaryText(context),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMedalColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }

  String _getMedalEmoji(int position) {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$position';
    }
  }

  String _getStatValue(String type) {
    switch (type) {
      case 'rating':
        final rating = user['rating_promedio'] ?? 0.0;
        return rating.toStringAsFixed(1);
      case 'connections':
        return (user['total_conexiones'] ?? 0).toString();
      case 'events':
        return (user['total_eventos'] ?? 0).toString();
      default:
        return '0';
    }
  }

  String _getStatLabel(String type) {
    switch (type) {
      case 'rating':
        return '⭐ rating';
      case 'connections':
        return 'conexiones';
      case 'events':
        return 'eventos';
      default:
        return '';
    }
  }
}
