import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo oscuro con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.grey[900]!,
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '// THE QUIESCENT HEART //',
                            style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 16,
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          if (user?.email != null)
                            Text(
                              'USER: ${user!.email!.split('@')[0].toUpperCase()}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.power_settings_new, color: Colors.red[900]),
                        onPressed: () {
                          authProvider.signOut();
                        },
                        tooltip: 'DESCONECTAR',
                      ),
                    ],
                  ),
                ),
                
                // Menú principal
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Icono
                          Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red[900]!, width: 3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: Colors.red[900],
                            ),
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Título
                          Text(
                            '[ MENÚ PRINCIPAL ]',
                            style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 24,
                              fontFamily: 'monospace',
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          SizedBox(height: 50),
                          
                          // Opciones del menú
                          _buildMenuOption(context, 'NUEVA PARTIDA', Icons.play_arrow),
                          SizedBox(height: 15),
                          _buildMenuOption(context, 'CONTINUAR', Icons.refresh),
                          SizedBox(height: 15),
                          _buildMenuOption(context, 'CONFIGURACIÓN', Icons.settings),
                          SizedBox(height: 15),
                          _buildMenuOption(context, 'CRÉDITOS', Icons.info_outline),
                          SizedBox(height: 30),
                          _buildMenuOption(
                            context,
                            'SALIR',
                            Icons.exit_to_app,
                            onTap: () => authProvider.signOut(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Footer
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'v1.0.0 | SISTEMA ACTIVO',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuOption(BuildContext context, String text, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        // Placeholder para futuras pantallas
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$text - Próximamente'),
            backgroundColor: Colors.red[900],
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 300,
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.red[900]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red[900]!.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red[900], size: 20),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.red[900], size: 20),
          ],
        ),
      ),
    );
  }
}
