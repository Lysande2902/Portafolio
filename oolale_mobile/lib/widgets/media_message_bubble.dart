import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../config/theme_colors.dart';
import '../models/message.dart';
import 'package:intl/intl.dart';

class MediaMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onImageTap;
  final VoidCallback? onAudioTap;
  final VoidCallback? onDownload;

  const MediaMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onImageTap,
    this.onAudioTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppConstants.primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: isMe ? null : Border.all(color: ThemeColors.divider(context)),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.mediaType == 'image') _buildImageContent(context),
            if (message.mediaType == 'audio') _buildAudioContent(context),
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  message.content,
                  style: GoogleFonts.outfit(
                    color: isMe ? Colors.black : ThemeColors.primaryText(context),
                    fontSize: 15,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8, top: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFF1C1C1C) // Negro sólido
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isMe ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.sentAt),
                        style: GoogleFonts.outfit(
                          color: isMe ? Colors.white : ThemeColors.primaryText(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        _buildStatusIcon(context),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onImageTap,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              message.mediaUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 40, color: ThemeColors.iconSecondary(context)),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar imagen',
                        style: GoogleFonts.outfit(
                          color: ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (onDownload != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDownload,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download, color: Colors.white, size: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAudioContent(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onAudioTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.black.withOpacity(0.1) : AppConstants.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: isMe ? Colors.black : AppConstants.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mensaje de voz',
                        style: GoogleFonts.outfit(
                          color: isMe ? Colors.black : ThemeColors.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Toca para reproducir',
                        style: GoogleFonts.outfit(
                          color: isMe ? Colors.black.withOpacity(0.6) : ThemeColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onDownload != null)
          IconButton(
            icon: Icon(Icons.download, color: isMe ? Colors.black.withOpacity(0.6) : ThemeColors.secondaryText(context)),
            onPressed: onDownload,
          ),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (message.status == 'pending') {
      return Icon(
        Icons.access_time,
        size: 14,
        color: isMe ? Colors.white70 : Colors.black45,
      );
    }

    final statusColor = isMe ? Colors.white : Colors.black.withOpacity(0.7);
    switch (message.status) {
      case 'read':
        return Icon(
          Icons.done_all,
          size: 14,
          color: isMe ? Colors.white : AppConstants.primaryColor,
        );
      case 'delivered':
        return Icon(
          Icons.done_all,
          size: 14,
          color: statusColor,
        );
      case 'sent':
      default:
        return Icon(
          Icons.done,
          size: 14,
          color: statusColor,
        );
    }
  }
}
