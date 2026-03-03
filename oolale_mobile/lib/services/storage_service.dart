import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final _supabase = Supabase.instance.client;

  /// Sube un avatar de usuario al bucket 'avatars'
  static Future<String?> uploadAvatar(String userId, File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$userId/$fileName';

      // Subir el archivo
      await _supabase.storage.from('avatars').upload(path, file);

      // Obtener URL pública
      return _supabase.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      print('Error en StorageService.uploadAvatar: $e');
      return null;
    }
  }

  /// Sube un archivo al bucket 'portfolio'
  static Future<String?> uploadPortfolio(String userId, File file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final path = '$userId/$fileName';

      print('📤 Subiendo archivo a portfolio...');
      print('   Path: $path');
      print('   Tamaño: ${await file.length()} bytes');

      // Subir el archivo
      await _supabase.storage.from('portfolio').upload(
        path, 
        file,
        fileOptions: const FileOptions(
          upsert: false,
        ),
      );

      print('✅ Archivo subido exitosamente');

      // Obtener URL pública
      final publicUrl = _supabase.storage.from('portfolio').getPublicUrl(path);
      print('🔗 URL pública: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      print('❌ Error en StorageService.uploadPortfolio: $e');
      return null;
    }
  }

  /// Borra un archivo de cualquier bucket
  static Future<void> deleteFile(String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      print('Error en StorageService.deleteFile: $e');
    }
  }
}
