import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/arc.dart';
import '../data/models/arc_progress.dart';
import '../game/ui/themes/instagram_theme.dart';

/// Instagram-style card for Arc 1 - Gluttony
class InstagramArcCard extends StatefulWidget {
  final Arc arc;
  final ArcProgress? progress;
  final bool isLocked;
  final VoidCallback onTap;

  const InstagramArcCard({
    super.key,
    required this.arc,
    this.progress,
    required this.isLocked,
    required this.onTap,
  });

  @override
  State<InstagramArcCard> createState() => _InstagramArcCardState();
}

class _InstagramArcCardState extends State<InstagramArcCard>
    with SingleTickerProviderStateMixin {
  final InstagramTheme _theme = InstagramTheme();
  bool _isLiked = false;
  int _likeCount = 666000;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    _likeAnimationController.forward(from: 0);
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _handleLike();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLocked ? null : widget.onTap,
      onDoubleTap: widget.isLocked ? null : _handleDoubleTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _theme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _theme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(),
            _buildInteractionBar(),
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Profile picture with gradient border
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: _theme.instagramGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _theme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${widget.arc.number}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _theme.textColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@gluttony_arc',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _theme.textColor,
                  ),
                ),
                if (widget.isLocked)
                  Text(
                    'Bloqueado',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: _theme.secondaryTextColor,
                    ),
                  ),
              ],
            ),
          ),
          // More options
          Icon(
            Icons.more_vert,
            color: _theme.textColor,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        // Main image/content
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _theme.primaryColor.withValues(alpha: 0.3),
                _theme.secondaryColor.withValues(alpha: 0.3),
                _theme.accentColor.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLocked)
                  Icon(
                    Icons.lock,
                    size: 60,
                    color: _theme.secondaryTextColor,
                  )
                else
                  Icon(
                    Icons.restaurant,
                    size: 60,
                    color: _theme.textColor.withValues(alpha: 0.7),
                  ),
                const SizedBox(height: 16),
                Text(
                  'ARCO ${widget.arc.number}',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _theme.textColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.arc.title.toUpperCase(),
                  style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: _theme.textColor,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.arc.subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: _theme.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.progress != null &&
                    widget.progress!.status == ArcStatus.inProgress) ...[
                  const SizedBox(height: 16),
                  _buildProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
        // Double-tap heart animation
        if (_isLiked)
          Positioned.fill(
            child: Center(
              child: ScaleTransition(
                scale: _likeScaleAnimation,
                child: Icon(
                  Icons.favorite,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = widget.progress!.progressPercent;
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: _theme.textColor,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(_theme.secondaryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionBar() {
    if (widget.isLocked) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.favorite_border, color: _theme.secondaryTextColor),
            const SizedBox(width: 16),
            Icon(Icons.mode_comment_outlined, color: _theme.secondaryTextColor),
            const SizedBox(width: 16),
            Icon(Icons.send_outlined, color: _theme.secondaryTextColor),
          ],
        ),
      );
    }

    return _theme.buildInteractionBar(
      context: context,
      onLike: _handleLike,
      onComment: () {},
      onShare: () {},
      isLiked: _isLiked,
    );
  }

  Widget _buildStatistics() {
    if (widget.isLocked) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Completa los arcos anteriores para desbloquear',
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: _theme.secondaryTextColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return _theme.buildStatistics(
      context: context,
      stats: {
        'likes': _likeCount,
        'comments': 13,
        'username': '@gluttony_arc',
        'caption': 'El hambre nunca termina... 🍔 #Gula #CondicionHumano',
      },
    );
  }
}
