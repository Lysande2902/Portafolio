import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../services/event_service.dart';

class InviteMusiciansScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const InviteMusiciansScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<InviteMusiciansScreen> createState() => _InviteMusiciansScreenState();
}

class _InviteMusiciansScreenState extends State<InviteMusiciansScreen> {
  final _supabase = Supabase.instance.client;
  late EventService _eventService;
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allMusicians = [];
  List<Map<String, dynamic>> _filteredMusicians = [];
  Set<String> _selectedMusicianIds = {};
  bool _isLoading = true;
  bool _isSending = false;
  String? _filterInstrument;
  // Note: Genre filter removed - will be added in Phase 3

  @override
  void initState() {
    super.initState();
    _eventService = EventService(_supabase);
    _loadMusicians();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMusicians() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      // Get all musicians except current user and already invited
      final data = await _supabase
          .from('perfiles')
          .select('id, nombre_artistico, avatar_url, ubicacion, instrumento_principal')
          .neq('id', currentUserId);

      // Get already invited musicians
      final invitations = await _supabase
          .from('invitaciones_evento')
          .select('musician_id')
          .eq('event_id', widget.eventId);

      final invitedIds = invitations.map((inv) => inv['musician_id'].toString()).toSet();

      // Filter out already invited
      final musicians = data.where((m) => !invitedIds.contains(m['id'].toString())).toList();

      if (mounted) {
        setState(() {
          _allMusicians = musicians;
          _filteredMusicians = musicians;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading musicians: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar músicos')),
        );
      }
    }
  }

  void _filterMusicians() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredMusicians = _allMusicians.where((musician) {
        final name = (musician['nombre_artistico'] ?? '').toLowerCase();
        final location = (musician['ubicacion'] ?? '').toLowerCase();
        final instrument = musician['instrumento_principal']?.toString().toLowerCase();

        // Text search
        final matchesSearch = query.isEmpty || 
            name.contains(query) || 
            location.contains(query);

        // Instrument filter
        final matchesInstrument = _filterInstrument == null || 
            instrument == _filterInstrument?.toLowerCase();

        // Note: Genre filter removed as genero_musical column doesn't exist yet
        // Will be added in Phase 3 when profile fields are expanded

        return matchesSearch && matchesInstrument;
      }).toList();
    });
  }
  
  // Alias para _filterMusicians (usado en el diálogo de filtros)
  void _applyFilters() => _filterMusicians();

  void _toggleSelection(String musicianId) {
    setState(() {
      if (_selectedMusicianIds.contains(musicianId)) {
        _selectedMusicianIds.remove(musicianId);
      } else {
        _selectedMusicianIds.add(musicianId);
      }
    });
  }

  Future<void> _sendInvitations() async {
    if (_selectedMusicianIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un músico')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await _eventService.sendInvitations(
        widget.eventId,
        _selectedMusicianIds.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedMusicianIds.length} invitación${_selectedMusicianIds.length != 1 ? 'es' : ''} enviada${_selectedMusicianIds.length != 1 ? 's' : ''}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      debugPrint('Error sending invitations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar invitaciones'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invitar Músicos',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              widget.eventTitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: ThemeColors.secondaryText(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          if (_selectedMusicianIds.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedMusicianIds.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_filterInstrument != null)
            _buildActiveFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : _filteredMusicians.isEmpty
                    ? _buildEmptyState()
                    : _buildMusiciansList(),
          ),
        ],
      ),
      bottomNavigationBar: _selectedMusicianIds.isNotEmpty
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _filterMusicians(),
            style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o ubicación...',
              hintStyle: GoogleFonts.outfit(color: ThemeColors.disabledText(context)),
              prefixIcon: Icon(Icons.search, color: ThemeColors.icon(context)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: ThemeColors.icon(context)),
                      onPressed: () {
                        _searchController.clear();
                        _filterMusicians();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showInstrumentFilter,
                  icon: Icon(
                    Icons.music_note,
                    size: 18,
                    color: _filterInstrument != null 
                        ? AppConstants.primaryColor 
                        : ThemeColors.icon(context),
                  ),
                  label: Text(
                    _filterInstrument ?? 'Instrumento',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: _filterInstrument != null 
                          ? AppConstants.primaryColor 
                          : ThemeColors.primaryText(context),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _filterInstrument != null 
                          ? AppConstants.primaryColor 
                          : ThemeColors.divider(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // Genre filter removed - will be added in Phase 3
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_filterInstrument != null)
            _buildFilterChip(
              label: _filterInstrument!,
              onRemove: () {
                setState(() => _filterInstrument = null);
                _filterMusicians();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: ThemeColors.icon(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: ThemeColors.iconSecondary(context),
            ),
            const SizedBox(height: 24),
            Text(
              'No se encontraron músicos',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Intenta con otros filtros de búsqueda',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: ThemeColors.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusiciansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMusicians.length,
      itemBuilder: (context, index) {
        final musician = _filteredMusicians[index];
        final musicianId = musician['id'].toString();
        final isSelected = _selectedMusicianIds.contains(musicianId);

        return _MusicianCard(
          musician: musician,
          isSelected: isSelected,
          onTap: () => _toggleSelection(musicianId),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSending ? null : _sendInvitations,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Text(
                  'Enviar ${_selectedMusicianIds.length} invitación${_selectedMusicianIds.length != 1 ? 'es' : ''}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _showInstrumentFilter() {
    final instruments = ['Guitarra', 'Bajo', 'Batería', 'Teclado', 'Voz', 'Saxofón', 'Trompeta', 'Violín', 'Todos'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Filtrar por instrumento',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: ThemeColors.primaryText(context),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: instruments.length,
            itemBuilder: (context, index) {
              final instrument = instruments[index];
              final isSelected = instrument == 'Todos' 
                  ? _filterInstrument == null 
                  : _filterInstrument == instrument;
              
              return ListTile(
                title: Text(
                  instrument,
                  style: GoogleFonts.outfit(
                    color: isSelected ? AppConstants.primaryColor : ThemeColors.primaryText(context),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppConstants.primaryColor : ThemeColors.iconSecondary(context),
                ),
                onTap: () {
                  setState(() {
                    _filterInstrument = instrument == 'Todos' ? null : instrument;
                    _applyFilters();
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: GoogleFonts.outfit(color: AppConstants.primaryColor)),
          ),
        ],
      ),
    );
  }
}

class _MusicianCard extends StatelessWidget {
  final Map<String, dynamic> musician;
  final bool isSelected;
  final VoidCallback onTap;

  const _MusicianCard({
    required this.musician,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = musician['nombre_artistico'] ?? 'Sin nombre';
    final location = musician['ubicacion'] ?? 'Ubicación no especificada';
    final avatarUrl = musician['avatar_url'];
    final instrument = musician['instrumento_principal'];
    // Note: genre removed - will be added in Phase 3

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? AppConstants.primaryColor 
              : ThemeColors.divider(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person, size: 32, color: AppConstants.primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: ThemeColors.secondaryText(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: ThemeColors.secondaryText(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (instrument != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 14,
                              color: ThemeColors.secondaryText(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              instrument,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: ThemeColors.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? AppConstants.primaryColor 
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? AppConstants.primaryColor 
                          : ThemeColors.divider(context),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
