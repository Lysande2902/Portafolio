import 'package:flutter/material.dart';

/// Abstract base class for social media platform themes
/// Each arc will have its own theme based on a specific social media platform
abstract class SocialMediaTheme {
  /// Platform name (e.g., "Instagram", "Facebook")
  String get platformName;

  /// Primary brand color (darkened for game aesthetic)
  Color get primaryColor;

  /// Secondary brand color
  Color get secondaryColor;

  /// Accent color for highlights
  Color get accentColor;

  /// Background color for cards
  Color get backgroundColor;

  /// Text color
  Color get textColor;

  /// Secondary text color (for metadata, timestamps, etc.)
  Color get secondaryTextColor;

  /// Font family similar to the platform
  String get fontFamily;

  /// Title font size
  double get titleFontSize => 20.0;

  /// Body font size
  double get bodyFontSize => 14.0;

  /// Metadata font size (timestamps, counts, etc.)
  double get metadataFontSize => 12.0;

  /// Platform logo/icon widget
  Widget buildPlatformLogo({double size = 24.0});

  /// Build interaction bar (likes, comments, shares, etc.)
  Widget buildInteractionBar({
    required BuildContext context,
    required VoidCallback onLike,
    required VoidCallback onComment,
    required VoidCallback onShare,
    bool isLiked = false,
  });

  /// Build statistics widget (view counts, like counts, etc.)
  Widget buildStatistics({
    required BuildContext context,
    required Map<String, dynamic> stats,
  });

  /// Get text style for title
  TextStyle getTitleStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: titleFontSize,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: 0.5,
    );
  }

  /// Get text style for body text
  TextStyle getBodyStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      color: textColor,
      height: 1.4,
    );
  }

  /// Get text style for metadata (timestamps, counts)
  TextStyle getMetadataStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: metadataFontSize,
      color: secondaryTextColor,
      letterSpacing: 0.3,
    );
  }

  /// Format large numbers (e.g., 1000 -> "1K", 1000000 -> "1M")
  String formatCount(int count) {
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
