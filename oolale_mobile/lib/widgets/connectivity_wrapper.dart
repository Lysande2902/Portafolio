import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

/// Wrapper widget that monitors connectivity and shows alerts
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _hasShownAlert = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        // Show alert when connection is lost
        if (!connectivity.isConnected && !_hasShownAlert) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasShownAlert) {
              _hasShownAlert = true;
              connectivity.showNoConnectionAlert(context);
            }
          });
        }

        // Reset flag when connection is restored
        if (connectivity.isConnected && _hasShownAlert) {
          _hasShownAlert = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
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
          });
        }

        return child!;
      },
      child: widget.child,
    );
  }
}
