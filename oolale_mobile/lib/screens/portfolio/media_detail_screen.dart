import 'package:flutter/material.dart';
import '../../models/portfolio_media.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/audio_player_widget.dart';

class MediaDetailScreen extends StatelessWidget {
  final PortfolioMedia media;

  const MediaDetailScreen({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    // Use dedicated player widgets for video and audio
    if (media.tipo == 'video') {
      return VideoPlayerWidget(
        videoUrl: media.url,
        title: media.titulo,
      );
    } else if (media.tipo == 'audio') {
      return AudioPlayerWidget(
        audioUrl: media.url,
        title: media.titulo,
      );
    } else if (media.tipo == 'imagen') {
      // Simple image viewer
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(media.titulo),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              media.url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    
    // Unsupported format
    return Scaffold(
      appBar: AppBar(title: const Text('Formato no soportado')),
      body: const Center(
        child: Text('Este formato de archivo no es compatible'),
      ),
    );
  }
}
