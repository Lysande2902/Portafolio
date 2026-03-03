import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oolale_mobile/models/portfolio_media.dart';
import 'package:oolale_mobile/config/constants.dart';
import 'package:oolale_mobile/services/media_service.dart';
import 'package:oolale_mobile/utils/connectivity_helper.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../../widgets/enhanced_image_viewer.dart';
import 'upload_media_screen.dart';
import 'media_detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  final String userId;
  const PortfolioScreen({super.key, required this.userId});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _supabase = Supabase.instance.client;
  late final MediaService _mediaService;
  List<PortfolioMedia> _mediaList = [];
  bool _isLoading = true;
  String _selectedFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _mediaService = MediaService(_supabase);
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    // Check connectivity first
    if (!await ConnectivityHelper.checkAndAlert(context)) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      debugPrint('🔄 Cargando media para usuario: ${widget.userId}');
      
      final response = await _supabase
          .from('archivos_multimedia')
          .select()
          .eq('profile_id', widget.userId)
          .order('created_at', ascending: false);

      debugPrint('📦 Media cargada: ${response.length} archivos');
      
      if (mounted) {
        setState(() {
          _mediaList = List<PortfolioMedia>.from(response.map((x) => PortfolioMedia.fromJson(x)));
          _isLoading = false;
        });
        
        debugPrint('✅ Lista actualizada con ${_mediaList.length} archivos');
      }
    } catch (e) {
      ErrorHandler.logError('PortfolioScreen._loadMedia', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al cargar portfolio',
          onRetry: _loadMedia,
        );
      }
    }
  }

  List<PortfolioMedia> get _filteredMedia {
    if (_selectedFilter == 'todos') return _mediaList;
    return _mediaList.where((m) => m.tipo.toLowerCase() == _selectedFilter).toList();
  }

  Future<void> _showMediaOptions(PortfolioMedia media) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColors.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppConstants.primaryColor),
              title: Text('Editar título', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context))),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (result == 'edit') {
      _showEditDialog(media);
    } else if (result == 'delete') {
      _showDeleteConfirmation(media);
    }
  }

  Future<void> _showEditDialog(PortfolioMedia media) async {
    final controller = TextEditingController(text: media.titulo);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Editar título', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context))),
        content: TextField(
          controller: controller,
          style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
          decoration: InputDecoration(
            hintText: 'Nuevo título',
            hintStyle: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ThemeColors.divider(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.primaryColor),
            ),
          ),
          maxLength: 100,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Guardar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      await _updateMedia(media.id, controller.text);
    }
  }

  Future<void> _showDeleteConfirmation(PortfolioMedia media) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('¿Eliminar archivo?', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context))),
        content: Text(
          'Esta acción no se puede deshacer. El archivo "${media.titulo}" será eliminado permanentemente.',
          style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Eliminar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteMedia(media);
    }
  }

  Future<void> _updateMedia(int mediaId, String newTitle) async {
    try {
      await _mediaService.updatePortfolioMedia(mediaId, newTitle);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Título actualizado', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
          ),
        );
        await _loadMedia();
      }
    } catch (e) {
      ErrorHandler.logError('PortfolioScreen._updateMedia', e);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al actualizar título');
      }
    }
  }

  Future<void> _deleteMedia(PortfolioMedia media) async {
    // Check connectivity first
    if (!await ConnectivityHelper.checkAndAlert(context)) {
      return;
    }

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('Eliminando...', style: GoogleFonts.outfit()),
              ],
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }

      await _mediaService.deletePortfolioMedia(media.id, media.url);
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo eliminado', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
          ),
        );
        await _loadMedia();
      }
    } catch (e) {
      ErrorHandler.logError('PortfolioScreen._deleteMedia', e);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al eliminar archivo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = _supabase.auth.currentUser?.id;
    final isMe = widget.userId == myId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isMe ? 'Mi Galería' : 'Galería', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontWeight: FontWeight.bold)),
        actions: [
          if (isMe)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppConstants.primaryColor),
              onPressed: () => context.push('/upload-media', extra: {'userId': widget.userId, 'onUploadComplete': _loadMedia}),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : _filteredMedia.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadMedia,
                        color: AppConstants.primaryColor,
                        child: _buildGrid(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: ['todos', 'imagen', 'video', 'audio'].map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppConstants.primaryColor : ThemeColors.divider(context)),
              ),
              child: Center(
                child: Text(
                  filter.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.black : ThemeColors.secondaryText(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid() {
    final myId = _supabase.auth.currentUser?.id;
    final isMe = widget.userId == myId;
    final images = _filteredMedia.where((m) => m.tipo == 'imagen').toList();

    return MasonryGridView.count(
      crossAxisCount: 2,
      itemCount: _filteredMedia.length,
      padding: const EdgeInsets.all(12),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemBuilder: (context, index) {
        final media = _filteredMedia[index];
        return GestureDetector(
          onTap: () {
            // If it's an image, open enhanced viewer with gallery
            if (media.tipo == 'imagen') {
              final imageIndex = images.indexOf(media);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnhancedImageViewer(
                    images: images,
                    initialIndex: imageIndex,
                    onDelete: isMe ? () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(media);
                    } : null,
                    onEdit: isMe ? (currentTitle) {
                      Navigator.pop(context);
                      _showEditDialog(media);
                    } : null,
                  ),
                ),
              );
            } else {
              // For video/audio, use the detail screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MediaDetailScreen(media: media)),
              );
            }
          },
          onLongPress: isMe ? () => _showMediaOptions(media) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColors.divider(context)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: media.tipo == 'imagen' ? 0.8 : 1.2,
                        child: media.tipo == 'imagen' 
                            ? Image.network(
                                media.url, 
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Theme.of(context).cardColor,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: AppConstants.primaryColor,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Theme.of(context).cardColor,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: ThemeColors.iconSecondary(context),
                                      size: 40,
                                    ),
                                  );
                                },
                                // Enable caching
                                cacheWidth: 400,
                              )
                            : Container(
                                color: Theme.of(context).cardColor,
                                child: Icon(
                                  media.tipo == 'video' ? Icons.play_circle_outline : Icons.music_note,
                                  color: AppConstants.primaryColor,
                                  size: 40,
                                ),
                              ),
                      ),
                      if (isMe)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _showMediaOptions(media),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      media.titulo,
                      style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.collections_outlined, size: 60, color: ThemeColors.disabledText(context)),
          const SizedBox(height: 16),
          Text('Sin archivos', style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context))),
        ],
      ),
    );
  }
}
