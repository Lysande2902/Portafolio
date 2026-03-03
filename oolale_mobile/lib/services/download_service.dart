import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  Future<bool> _requestPermissions() async {
    if (Platform.isIOS) return true;
    
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        // En Android 13+ solicitamos permisos específicos de medios si fuera necesario,
        // pero para la carpeta Download común a veces no es requerido o se usa Storage.
        final status = await Permission.photos.request();
        final audioStatus = await Permission.audio.request();
        return status.isGranted || audioStatus.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return false;
  }

  Future<String?> downloadFile(String url, String fileName, {Function(int, int)? onProgress}) async {
    try {
      if (!await _requestPermissions()) {
        debugPrint('Permisos denegados');
        return null;
      }

      Directory? directory;
      if (Platform.isAndroid) {
        // En Android guardamos en la carpeta pública de descargas si es posible,
        // o en el almacenamiento externo.
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return null;

      String savePath = p.join(directory.path, fileName);
      
      // Si el archivo ya existe (mismo nombre), le añadimos un timestamp
      if (await File(savePath).exists()) {
        String name = p.basenameWithoutExtension(fileName);
        String ext = p.extension(fileName);
        savePath = p.join(directory.path, '${name}_${DateTime.now().millisecondsSinceEpoch}$ext');
      }

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );

      return savePath;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }
}
