import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'social_media_theme.dart';

/// Instagram theme for Arc 1 - Gluttony
/// Uses Instagram's gradient colors (purple, pink, orange) darkened for game aesthetic
class InstagramTheme extends SocialMediaTheme {
  @override
  String get platformName => 'Instagram';

  @override
  Color get primaryColor => const Color(0xFF833AB4).withValues(alpha: 0.6); // Purple darkened

  @override
  Color get secondaryColor => const Color(0xFFFD1D1D).withValues(alpha: 0.6); // Pink darkened

  @override
  Color get accentColor => const Color(0xFFF77737).withValues(alpha: 0.6); // Orange darkened

  @override
  Color get backgroundColor => const Color(0xFF1A1A1A);

  @override
  Color get textColor => const Color(0xFFFFFFFF);

  @override
  Color get secondaryTextColor => const Color(0xFFB0B0B0);

  @override
  String get fontFamily => GoogleFonts.roboto().fontFamily ?? 'Roboto';

  /// Instagram gradient colors
  LinearGradient get instagramGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          secondaryColor,
          accentColor,
        ],
      );

  @override
  Widget buildPlatformLogo({double size = 24.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: instagramGradient,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.camera_alt_outlined,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  @override
  Widget buildInteractionBar({
    required BuildContext context,
    required VoidCallback onLike,
    required VoidCallback onComment,
    required VoidCallback onShare,
    bool isLiked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Like button
          _InstagramActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : textColor,
            onTap: onLike,
          ),
          const SizedBox(width: 16),
          // Comment button
          _InstagramActionButton(
            icon: Icons.mode_comment_outlined,
            color: textColor,
            onTap: onComment,
          ),
          const SizedBox(width: 16),
          // Share button
          _InstagramActionButton(
            icon: Icons.send_outlined,
            color: textColor,
            onTap: onShare,
          ),
          const Spacer(),
          // Bookmark button
          _InstagramActionButton(
            icon: Icons.bookmark_border,
            color: textColor,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget buildStatistics({
    required BuildContext context,
    required Map<String, dynamic> stats,
  }) {
    final likes = stats['likes'] as int? ?? 666000;
    final comments = stats['comments'] as int? ?? 13;
    final username = stats['username'] as String? ?? '@gluttony_arc';
    final caption = stats['caption'] as String? ??
        'El hambre nunca termina... 🍔';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Likes count
          Text(
            '${formatCount(likes)} likes',
            style: getBodyStyle().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Caption
          RichText(
            text: TextSpan(
              style: getBodyStyle(),
              children: [
                TextSpan(
                  text: username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' '),
                TextSpan(text: caption),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // View comments
          Text(
            'Ver los $comments comentarios',
            style: getMetadataStyle(),
          ),
          const SizedBox(height: 4),
          // Timestamp
          Text(
            'Hace 3 horas',
            style: getMetadataStyle().copyWith(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Instagram-style action button
class _InstagramActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InstagramActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_InstagramActionButton> createState() => _InstagramActionButtonState();
}

class _InstagramActionButtonState extends State<_InstagramActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.icon,
          color: widget.color,
          size: 28,
        ),
      ),
    );
  }
}
