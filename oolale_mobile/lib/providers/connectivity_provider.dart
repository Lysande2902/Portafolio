import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Provider for managing connectivity state across the app
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;
  bool _hasShownAlert = false;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _initConnectivity();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = !result.contains(ConnectivityResult.none);
      notifyListeners();

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final wasConnected = _isConnected;
          _isConnected = !results.contains(ConnectivityResult.none);
          
          if (wasConnected != _isConnected) {
            notifyListeners();
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Error initializing connectivity: $e');
    }
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = !result.contains(ConnectivityResult.none);
      notifyListeners();
      return _isConnected;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      return false;
    }
  }

  /// Show no connection alert
  void showNoConnectionAlert(BuildContext context) {
    if (_hasShownAlert || !context.mounted) return;
    
    _hasShownAlert = true;
    
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

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
