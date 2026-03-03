import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling media file uploads and validation
/// Supports images and audio files with compression and validation
class MediaService {
  final SupabaseClient _supabase;

  MediaService(this._supabase);

  /// Upload image with automatic compression
  /// [imageFile] - Image file to upload
  /// [userId] - User ID for organizing storage
  /// Returns URL of uploaded image
  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      // Compress image if needed
      final compressedFile = await compressImage(imageFile, 2);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'image_${userId}_$timestamp$extension';
      final filePath = 'messages/$userId/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage.from('media').upload(
            filePath,
            compressedFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final url = _supabase.storage.from('media').getPublicUrl(filePath);

      return url;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload audio file
  /// [audioFile] - Audio file to upload
  /// [userId] - User ID for organizing storage
  /// Returns URL of uploaded audio
  Future<String> uploadAudio(File audioFile, String userId) async {
    try {
      // Validate file size (max 10MB)
      if (!validateFileSize(audioFile, 10)) {
        throw Exception('Audio file exceeds 10MB limit');
      }

      // Validate file type
      final allowedExtensions = ['mp3', 'wav', 'm4a'];
      if (!validateFileType(audioFile, allowedExtensions)) {
        throw Exception('Unsupported audio format. Use mp3, wav, or m4a');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(audioFile.path);
      final fileName = 'audio_${userId}_$timestamp$extension';
      final filePath = 'messages/$userId/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage.from('media').upload(
            filePath,
            audioFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final url = _supabase.storage.from('media').getPublicUrl(filePath);

      return url;
    } catch (e) {
      debugPrint('❌ Error uploading audio: $e');
      rethrow;
    }
  }

  /// Validate file type by extension
  /// [file] - File to validate
  /// [allowedExtensions] - List of allowed extensions (without dot)
  /// Returns true if file type is allowed
  bool validateFileType(File file, List<String> allowedExtensions) {
    final extension = path.extension(file.path).toLowerCase().replaceAll('.', '');
    return allowedExtensions.contains(extension);
  }

  /// Validate file size
  /// [file] - File to validate
  /// [maxSizeInMB] - Maximum allowed size in megabytes
  /// Returns true if file size is within limit
  bool validateFileSize(File file, int maxSizeInMB) {
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB <= maxSizeInMB;
  }

  /// Compress image to target size
  /// [imageFile] - Image file to compress
  /// [maxSizeInMB] - Target maximum size in megabytes
  /// Returns compressed image file
  Future<File> compressImage(File imageFile, int maxSizeInMB) async {
    try {
      // Check if compression is needed
      if (validateFileSize(imageFile, maxSizeInMB)) {
        return imageFile;
      }

      // Calculate target quality based on current size
      final currentSizeInMB = imageFile.lengthSync() / (1024 * 1024);
      final compressionRatio = maxSizeInMB / currentSizeInMB;
      final quality = (compressionRatio * 100).clamp(10, 95).toInt();

      // Generate output path
      final outputPath = imageFile.path.replaceAll(
        path.extension(imageFile.path),
        '_compressed${path.extension(imageFile.path)}',
      );

      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        outputPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1080,
      );

      if (compressedFile == null) {
        throw Exception('Image compression failed');
      }

      // Verify compressed size
      final compressedSize = File(compressedFile.path).lengthSync() / (1024 * 1024);
      debugPrint('✅ Image compressed: ${currentSizeInMB.toStringAsFixed(2)}MB → ${compressedSize.toStringAsFixed(2)}MB');

      return File(compressedFile.path);
    } catch (e) {
      debugPrint('❌ Error compressing image: $e');
      // Return original file if compression fails
      return imageFile;
    }
  }

  /// Upload multiple images at once
  /// [imageFiles] - List of image files to upload
  /// [userId] - User ID for organizing storage
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  /// Returns list of URLs of uploaded images
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String userId, {
    Function(double)? onProgress,
  }) async {
    final urls = <String>[];
    
    try {
      for (var i = 0; i < imageFiles.length; i++) {
        final url = await uploadImage(imageFiles[i], userId);
        urls.add(url);
        
        // Report progress
        if (onProgress != null) {
          final progress = (i + 1) / imageFiles.length;
          onProgress(progress);
        }
      }
      
      return urls;
    } catch (e) {
      debugPrint('❌ Error uploading multiple images: $e');
      rethrow;
    }
  }

  /// Upload document file (PDF, DOC, etc.)
  /// [documentFile] - Document file to upload
  /// [userId] - User ID for organizing storage
  /// Returns URL of uploaded document
  Future<String> uploadDocument(File documentFile, String userId) async {
    try {
      // Validate file size (max 10MB)
      if (!validateFileSize(documentFile, 10)) {
        throw Exception('Document file exceeds 10MB limit');
      }

      // Validate file type
      final allowedExtensions = ['pdf', 'doc', 'docx', 'txt'];
      if (!validateFileType(documentFile, allowedExtensions)) {
        throw Exception('Unsupported document format. Use pdf, doc, docx, or txt');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(documentFile.path);
      final fileName = 'doc_${userId}_$timestamp$extension';
      final filePath = 'messages/$userId/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage.from('media').upload(
            filePath,
            documentFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final url = _supabase.storage.from('media').getPublicUrl(filePath);

      return url;
    } catch (e) {
      debugPrint('❌ Error uploading document: $e');
      rethrow;
    }
  }

  /// Get human-readable file size
  /// [file] - File to check
  /// Returns formatted size string (e.g., "2.5 MB", "150 KB")
  String getFormattedFileSize(File file) {
    final sizeInBytes = file.lengthSync();
    
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      final sizeInKB = sizeInBytes / 1024;
      return '${sizeInKB.toStringAsFixed(1)} KB';
    } else {
      final sizeInMB = sizeInBytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  /// Check if file is an image
  /// [file] - File to check
  /// Returns true if file is an image
  bool isImage(File file) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return validateFileType(file, imageExtensions);
  }

  /// Check if file is an audio
  /// [file] - File to check
  /// Returns true if file is audio
  bool isAudio(File file) {
    final audioExtensions = ['mp3', 'wav', 'm4a', 'aac', 'ogg'];
    return validateFileType(file, audioExtensions);
  }

  /// Check if file is a video
  /// [file] - File to check
  /// Returns true if file is video
  bool isVideo(File file) {
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
    return validateFileType(file, videoExtensions);
  }

  /// Check if file is a document
  /// [file] - File to check
  /// Returns true if file is a document
  bool isDocument(File file) {
    final docExtensions = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'];
    return validateFileType(file, docExtensions);
  }

  /// Upload video file (for portfolio)
  /// [videoFile] - Video file to upload
  /// [userId] - User ID for organizing storage
  /// Returns URL of uploaded video
  Future<String> uploadVideo(File videoFile, String userId) async {
    try {
      // Validate file size (max 50MB)
      if (!validateFileSize(videoFile, 50)) {
        throw Exception('Video file exceeds 50MB limit');
      }

      // Validate file type
      if (!validateFileType(videoFile, ['mp4'])) {
        throw Exception('Unsupported video format. Use mp4');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(videoFile.path);
      final fileName = 'video_${userId}_$timestamp$extension';
      final filePath = 'portfolio/$userId/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage.from('media').upload(
            filePath,
            videoFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final url = _supabase.storage.from('media').getPublicUrl(filePath);

      return url;
    } catch (e) {
      debugPrint('❌ Error uploading video: $e');
      rethrow;
    }
  }

  /// Delete media file from storage
  /// [fileUrl] - Public URL of the file to delete
  Future<void> deleteMedia(String fileUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the path after 'media' bucket
      final mediaIndex = pathSegments.indexOf('media');
      if (mediaIndex == -1 || mediaIndex == pathSegments.length - 1) {
        throw Exception('Invalid media URL');
      }

      final filePath = pathSegments.sublist(mediaIndex + 1).join('/');

      // Delete from storage
      await _supabase.storage.from('media').remove([filePath]);

      debugPrint('✅ Media deleted: $filePath');
    } catch (e) {
      debugPrint('❌ Error deleting media: $e');
      rethrow;
    }
  }

  /// Get file size in MB
  /// [file] - File to check
  /// Returns size in megabytes
  double getFileSizeInMB(File file) {
    final sizeInBytes = file.lengthSync();
    return sizeInBytes / (1024 * 1024);
  }

  /// Get file extension
  /// [file] - File to check
  /// Returns extension without dot
  String getFileExtension(File file) {
    return path.extension(file.path).toLowerCase().replaceAll('.', '');
  }

  /// Delete portfolio media from database and storage
  /// [mediaId] - ID of the media record
  /// [fileUrl] - Public URL of the file to delete
  Future<void> deletePortfolioMedia(int mediaId, String fileUrl) async {
    try {
      // Delete from storage first
      await deleteMedia(fileUrl);

      // Delete from database
      await _supabase
          .from('archivos_multimedia')
          .delete()
          .eq('id', mediaId);

      debugPrint('✅ Portfolio media deleted: ID $mediaId');
    } catch (e) {
      debugPrint('❌ Error deleting portfolio media: $e');
      rethrow;
    }
  }

  /// Update portfolio media title and description
  /// [mediaId] - ID of the media record
  /// [titulo] - New title
  Future<void> updatePortfolioMedia(int mediaId, String titulo) async {
    try {
      await _supabase
          .from('archivos_multimedia')
          .update({'titulo': titulo})
          .eq('id', mediaId);

      debugPrint('✅ Portfolio media updated: ID $mediaId');
    } catch (e) {
      debugPrint('❌ Error updating portfolio media: $e');
      rethrow;
    }
  }
}
