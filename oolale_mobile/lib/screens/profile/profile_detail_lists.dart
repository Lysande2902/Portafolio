import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/constants.dart';
import '../../utils/error_handler.dart';
import 'public_profile_screen.dart';

// -----------------------------------------------------------------------------
// EVENTOS DEL PERFIL
// -----------------------------------------------------------------------------
class ProfileEventsScreen extends StatefulWidget {
  final String userId;
  const ProfileEventsScreen({super.key, required this.userId});

  @override
  State<ProfileEventsScreen> createState() => _ProfileEventsScreenState();
}

class _ProfileEventsScreenState extends State<ProfileEventsScreen> {
  final _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _items = [];
  bool _isLoading = true;
  int _page = 0;
  bool _hasMore = true;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _loadItems(isLoadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore) return;
      _page++;
    } else {
      _page = 0;
      _hasMore = true;
      setState(() => _isLoading = true);
    }

    try {
      final from = _page * _limit;
      final to = from + _limit - 1;

      final response = await _supabase
          .from('eventos')
          .select()
          .eq('organizador_id', widget.userId)
          .order('fecha_gig', ascending: false)
          .range(from, to);

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _items.addAll(response);
          } else {
            _items = response;
          }
          if (response.length < _limit) _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('ProfileEventsScreen._loadItems', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando eventos',
          onRetry: _loadItems,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Eventos', style: GoogleFonts.outfit()),
        backgroundColor: Colors.black,
      ),
      body: _isLoading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _items.isEmpty
              ? Center(child: Text('Sin eventos', style: GoogleFonts.outfit(color: Colors.grey)))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: AppConstants.primaryColor),
                      ));
                    }
                    final item = _items[index];
                    final isMyGig = item['organizador_id'] == widget.userId;
                    
                    return Card(
                      color: AppConstants.bgDarkPanel,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(item['titulo_bolo'] ?? 'Evento', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(item['fecha_gig'] ?? '', style: GoogleFonts.outfit(color: Colors.grey)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(item['estatus_bolo'] ?? '', style: GoogleFonts.outfit(color: AppConstants.primaryColor)),
                            if (isMyGig)
                              Text('Tu evento', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        onTap: () => Navigator.pushNamed(context, '/gig/${item['id']}'),
                      ),
                    );
                  },
                ),
    );
  }
}

// -----------------------------------------------------------------------------
// SEGUIDORES DEL PERFIL
// -----------------------------------------------------------------------------
class ProfileFollowersScreen extends StatefulWidget {
  final String userId;
  const ProfileFollowersScreen({super.key, required this.userId});

  @override
  State<ProfileFollowersScreen> createState() => _ProfileFollowersScreenState();
}

class _ProfileFollowersScreenState extends State<ProfileFollowersScreen> {
  final _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _items = [];
  bool _isLoading = true;
  int _page = 0;
  bool _hasMore = true;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _loadItems(isLoadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore) return;
      _page++;
    } else {
      _page = 0;
      _hasMore = true;
      setState(() => _isLoading = true);
    }

    try {
      final from = _page * _limit;
      final to = from + _limit - 1;

      // Unir con perfiles para obtener info del seguidor
      // En sistema bidireccional: seguidores = conexiones donde usuario_id = este usuario
      final response = await _supabase
          .from('conexiones')
          .select('*, perfiles:conectado_id(*)') 
          .eq('usuario_id', widget.userId)
          .eq('estatus', 'accepted')
          .range(from, to);

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _items.addAll(response);
          } else {
            _items = response;
          }
          if (response.length < _limit) _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('ProfileFollowersScreen._loadItems', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando seguidores',
          onRetry: _loadItems,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Seguidores', style: GoogleFonts.outfit()),
        backgroundColor: Colors.black,
      ),
      body: _isLoading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _items.isEmpty
              ? Center(child: Text('Sin seguidores', style: GoogleFonts.outfit(color: Colors.grey)))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: AppConstants.primaryColor),
                      ));
                    }
                    final item = _items[index];
                    final profile = item['perfiles']; // Relación expandida
                    if (profile == null) return const SizedBox.shrink();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profile['foto_perfil'] != null ? NetworkImage(profile['foto_perfil']) : null,
                        child: profile['foto_perfil'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(profile['nombre_artistico'] ?? 'Usuario', style: GoogleFonts.outfit(color: Colors.white)),
                      subtitle: Text(profile['rol_principal'] ?? 'Musico', style: GoogleFonts.outfit(color: Colors.grey)),
                      onTap: () {
                         context.push('/profile/${profile['id']}');
                      },
                    );
                  },
                ),
    );
  }
}

// -----------------------------------------------------------------------------
// INSTRUMENTOS / GEAR DEL PERFIL
// -----------------------------------------------------------------------------
class ProfileGearScreen extends StatefulWidget {
  final String userId;
  const ProfileGearScreen({super.key, required this.userId});

  @override
  State<ProfileGearScreen> createState() => _ProfileGearScreenState();
}

class _ProfileGearScreenState extends State<ProfileGearScreen> {
  final _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _items = [];
  bool _isLoading = true;
  int _page = 0;
  bool _hasMore = true;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _loadItems(isLoadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore) return;
      _page++;
    } else {
      _page = 0;
      _hasMore = true;
      setState(() => _isLoading = true);
    }

    try {
      final from = _page * _limit;
      final to = from + _limit - 1;

      final response = await _supabase
          .from('perfil_gear')
          .select('*, gear_catalog(nombre, familia)')
          .eq('perfil_id', widget.userId)
          .range(from, to);

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _items.addAll(response);
          } else {
            _items = response;
          }
          if (response.length < _limit) _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('ProfileGearScreen._loadItems', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando equipo',
          onRetry: _loadItems,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Música / Equipo', style: GoogleFonts.outfit()),
        backgroundColor: Colors.black,
      ),
      body: _isLoading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _items.isEmpty
              ? Center(child: Text('Sin equipo registrado', style: GoogleFonts.outfit(color: Colors.grey)))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: AppConstants.primaryColor),
                      ));
                    }
                    final item = _items[index];
                    final gear = item['gear_catalog'];
                    
                    return Card(
                      color: AppConstants.bgDarkPanel,
                      margin: const EdgeInsets.only(bottom: 12),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.music_note, color: AppConstants.primaryColor),
                        title: Text(gear != null ? gear['nombre'] : 'Equipo', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text(gear != null ? (gear['familia'] ?? '') : 'Varios', style: GoogleFonts.outfit(color: Colors.grey)),
                      ),
                    );
                  },
                ),
    );
  }
}
