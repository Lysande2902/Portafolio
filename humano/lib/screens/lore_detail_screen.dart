import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:humano/data/models/store_item.dart';
import 'package:humano/providers/theme_provider.dart';

class LoreDetailScreen extends StatefulWidget {
  final StoreItem item;

  const LoreDetailScreen({super.key, required this.item});

  @override
  State<LoreDetailScreen> createState() => _LoreDetailScreenState();
}

class _LoreDetailScreenState extends State<LoreDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHacking = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isHacking = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(appTheme),
            Expanded(
              child: _isHacking 
                  ? _buildHackingEffect(appTheme) 
                  : _buildContent(appTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(appTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appTheme.primaryColor.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: appTheme.secondaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: GoogleFonts.shareTechMono(
                    color: appTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID_ARCHIVO: ${widget.item.id.toUpperCase()}',
                  style: GoogleFonts.shareTechMono(
                    color: appTheme.primaryColor.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackingEffect(appTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: appTheme.primaryColor),
          const SizedBox(height: 20),
          Text(
            'DESCIFRANDO PAQUETES DE DATOS...',
            style: GoogleFonts.shareTechMono(color: appTheme.primaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(appTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del Lore (si existe)
          if (widget.item.loreImages != null && widget.item.loreImages!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: appTheme.primaryColor.withOpacity(0.5)),
                ),
                child: widget.item.loreImages!.first.startsWith('http')
                    ? Image.network(
                        widget.item.loreImages!.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(appTheme),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildLoadingPlaceholder(appTheme, loadingProgress);
                        },
                      )
                    : Image.asset(
                        widget.item.loreImages!.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(appTheme),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Contenido de texto
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              border: Border.all(color: appTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: appTheme.accentColor, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'ESTADO: RECUPERADO',
                      style: GoogleFonts.shareTechMono(
                        color: appTheme.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                Text(
                  widget.item.loreContent ?? 'SIN_DATOS: Contenido no encontrado.',
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '// TRACE_ID: ${DateTime.now().millisecondsSinceEpoch}',
            style: GoogleFonts.shareTechMono(
              color: Colors.white10,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(appTheme) {
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, color: appTheme.primaryColor.withOpacity(0.3), size: 40),
            const SizedBox(height: 8),
            Text(
              'FALLO_EN_RENDER_DE_IMAGEN',
              style: GoogleFonts.shareTechMono(color: appTheme.primaryColor.withOpacity(0.3), fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(appTheme, ImageChunkEvent loadingProgress) {
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          color: appTheme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
