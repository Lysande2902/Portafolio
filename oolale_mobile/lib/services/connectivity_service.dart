import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Service for monitoring network connectivity
/// Shows alerts when internet connection is lost
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;
  bool _hasShownAlert = false;

  /// Initialize connectivity monitoring
  Future<void> initialize(BuildContext context) async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _handleConnectivityChange(context, results);
      },
    );
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(BuildContext context, List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = !results.contains(ConnectivityResult.none);

    // Show alert when connection is lost
    if (wasConnected && !_isConnected && !_hasShownAlert) {
      _hasShownAlert = true;
      _showNoConnectionAlert(context);
    }

    // Reset alert flag when connection is restored
    if (!wasConnected && _isConnected) {
      _hasShownAlert = false;
      _showConnectionRestoredSnackBar(context);
    }
  }

  /// Show no connection alert dialog
  void _showNoConnectionAlert(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.wifi_off,
          color: Colors.red,
          size: 48,
        ),
        title: const Text(
          'Sin conexión a Internet',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Por favor, verifica tu conexión a Internet e intenta nuevamente.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _hasShownAlert = false;
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Show connection restored snackbar
  void _showConnectionRestoredSnackBar(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 12),
            Text('Conexión restaurada'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Check if device is currently connected
  bool get isConnected => _isConnected;

  /// Check connectivity status
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);
    return _isConnected;
  }

  /// Dispose connectivity subscription
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
