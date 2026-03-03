import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

/// Helper class for connectivity checks
class ConnectivityHelper {
  /// Check connectivity and show alert if offline
  /// Returns true if connected, false if offline
  static Future<bool> checkAndAlert(BuildContext context) async {
    final connectivity = Provider.of<ConnectivityProvider>(context, listen: false);
    final isConnected = await connectivity.checkConnectivity();
    
    if (!isConnected && context.mounted) {
      connectivity.showNoConnectionAlert(context);
    }
    
    return isConnected;
  }

  /// Execute an async function only if connected
  /// Shows alert if offline
  static Future<T?> executeIfConnected<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    final isConnected = await checkAndAlert(context);
    
    if (!isConnected) {
      return null;
    }
    
    try {
      return await action();
    } catch (e) {
      debugPrint('❌ Error executing action: $e');
      rethrow;
    }
  }

  /// Show a simple snackbar for no connection
  static void showNoConnectionSnackBar(BuildContext context) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Text('Sin conexión a Internet'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
