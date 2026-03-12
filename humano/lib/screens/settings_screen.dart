import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'auth_screen.dart';
import 'credits_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _versionTapCount = 0;
  bool _debugModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Cargar configuraciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wineRed = const Color(0xFF8B0000);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.currentUser?.email ?? 'No disponible';
    final userId = authProvider.currentUser?.uid ?? 'N/A';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(wineRed),
            // Content con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECCIÓN 1: AUDIO
                        _buildSettingsPanel('AUDIO', '0x01', wineRed, [
                          _buildSliderSetting(
                            'Volumen General',
                            Icons.volume_up,
                            settingsProvider.masterVolume * 100,
                            'VOL_MASTER',
                            (value) => settingsProvider.setMasterVolume(value / 100),
                          ),
                          _buildSliderSetting(
                            'Volumen Música',
                            Icons.music_note,
                            settingsProvider.musicVolume * 100,
                            'VOL_MUSIC',
                            (value) => settingsProvider.setMusicVolume(value / 100),
                          ),
                          _buildSliderSetting(
                            'Volumen Efectos',
                            Icons.graphic_eq,
                            settingsProvider.sfxVolume * 100,
                            'VOL_SFX',
                            (value) => settingsProvider.setSfxVolume(value / 100),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        
                        // SECCIÓN 2: CONTROLES
                        _buildSettingsPanel('CONTROLES', '0x02', wineRed, [
                          _buildSliderSetting(
                            'Sensibilidad del Toque',
                            Icons.touch_app,
                            (settingsProvider.touchSensitivity - 0.5) / 1.5 * 100,
                            'TOUCH_SENS',
                            (value) => settingsProvider.setTouchSensitivity(value / 100 * 1.5 + 0.5),
                            min: 0,
                            max: 100,
                            showLabels: true,
                            labels: ['LENTA', 'NORMAL', 'RÁPIDA'],
                          ),
                          _buildToggleSetting(
                            'Vibración',
                            Icons.vibration,
                            settingsProvider.vibrationEnabled,
                            'HAPTIC_FB',
                            (value) => settingsProvider.toggleVibration(value),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        
                        // SECCIÓN 3: CUENTA
                        _buildSettingsPanel('CUENTA', '0x03', wineRed, [
                          _buildInfoRow('Email', userEmail, 'USER_MAIL'),
                          _buildInfoRow('ID', userId.substring(0, 12) + '...', 'USER_ID'),
                          const SizedBox(height: 8),
                          _buildButtonSetting(
                            'Cerrar Sesión',
                            Icons.logout,
                            'AUTH_LOGOUT',
                            () => _logout(),
                            isDestructive: true,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        
                        // SECCIÓN 4: INFORMACIÓN
                        _buildSettingsPanel('INFORMACIÓN', '0x04', wineRed, [
                          _buildButtonSetting(
                            'Instituto Eidolon (Web)',
                            Icons.language,
                            'SYS_WEB_PORTAL',
                            () => _openWebsite(),
                          ),
                          _buildButtonSetting(
                            'Créditos',
                            Icons.info_outline,
                            'SYS_CREDITS',
                            () => _showCredits(),
                          ),
                          _buildButtonSetting(
                            'Política de Privacidad',
                            Icons.privacy_tip_outlined,
                            'LEGAL_PRIV',
                            () => _openPrivacyPolicy(),
                          ),
                          _buildButtonSetting(
                            'Términos de Servicio',
                            Icons.description_outlined,
                            'LEGAL_TERMS',
                            () => _openTermsOfService(),
                          ),
                          _buildButtonSetting(
                            'Reportar Bug',
                            Icons.bug_report_outlined,
                            'SUPPORT_BUG',
                            () => _reportBug(),
                          ),
                          _buildButtonSetting(
                            'Contacto',
                            Icons.email_outlined,
                            'SUPPORT_MAIL',
                            () => _contact(),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        
                        // SECCIÓN 5: DESARROLLO
                        _buildSettingsPanel('DESARROLLO', '0x05', wineRed, [
                          _buildButtonSetting(
                            '⚠️ Limpiar Datos Locales',
                            Icons.delete_forever,
                            'DATA_PURGE',
                            () => _clearAllLocalData(),
                            isDestructive: true,
                          ),
                          if (_debugModeEnabled)
                            _buildToggleSetting(
                              'Modo Debug',
                              Icons.developer_mode,
                              false,
                              'DEBUG_MODE',
                              (value) {
                                // TODO: Implementar modo debug
                              },
                            ),
                        ]),
                        const SizedBox(height: 32),
                        
                        // VERSIÓN (con tap secreto para debug)
                        GestureDetector(
                          onTap: _onVersionTap,
                          child: Center(
                            child: Text(
                              'VERSIÓN: v1.0.0',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 10,
                                color: Colors.white10,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _onVersionTap() {
    _versionTapCount++;
    if (_versionTapCount >= 7 && !_debugModeEnabled) {
      setState(() {
        _debugModeEnabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'MODO DEBUG ACTIVADO',
            style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF)),
          ),
          backgroundColor: Colors.black.withOpacity(0.9),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    // Reset counter after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _versionTapCount = 0;
      }
    });
  }

  Widget _buildHeader(Color wineRed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: wineRed.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: wineRed, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Text(
            'CONFIGURACION_SISTEMA',
            style: GoogleFonts.shareTechMono(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel(String title, String id, Color wineRed, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: wineRed.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: wineRed.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.shareTechMono(color: wineRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                Text(id, style: GoogleFonts.shareTechMono(color: Colors.white10, fontSize: 8)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String label,
    IconData icon,
    double value,
    String settingId,
    ValueChanged<double> onChanged, {
    double min = 0,
    double max = 100,
    bool showLabels = false,
    List<String> labels = const [],
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 14),
              const SizedBox(width: 12),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.shareTechMono(
                  fontSize: 12,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                settingId,
                style: GoogleFonts.shareTechMono(color: Colors.white10, fontSize: 7),
              ),
              const SizedBox(width: 8),
              Text(
                '${value.round()}%',
                style: GoogleFonts.shareTechMono(
                  fontSize: 14,
                  color: const Color(0xFFE57373),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF8B0000),
              inactiveTrackColor: Colors.white10,
              thumbColor: const Color(0xFFE57373),
              trackHeight: 1,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayColor: const Color(0xFF8B0000).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          if (showLabels && labels.length == 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels.map((label) => Text(
                  label,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 8,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String label,
    IconData icon,
    bool value,
    String settingId,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  settingId,
                  style: GoogleFonts.shareTechMono(color: Colors.white10, fontSize: 7),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE57373),
            activeTrackColor: const Color(0xFF8B0000).withOpacity(0.5),
            inactiveThumbColor: Colors.grey[800],
            inactiveTrackColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSetting(
    String label,
    IconData icon,
    String settingId,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red[900] : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.shareTechMono(
                      fontSize: 12,
                      color: isDestructive ? Colors.red[900] : Colors.white70,
                    ),
                  ),
                  Text(
                    settingId,
                    style: GoogleFonts.shareTechMono(color: Colors.white10, fontSize: 7),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white10,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String settingId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  settingId,
                  style: GoogleFonts.shareTechMono(color: Colors.white10, fontSize: 7),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.shareTechMono(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllLocalData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          '⚠️ ADVERTENCIA',
          style: GoogleFonts.courierPrime(
            color: Colors.red[400],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Esto borrará TODOS los datos locales:\n\n'
          '• Progreso de arcos\n'
          '• Notificaciones\n'
          '• Configuraciones\n'
          '• Fragmentos recolectados\n'
          '• Evidencias\n\n'
          'Los datos en la nube (Firebase) NO se borrarán.\n\n'
          '¿Estás seguro?',
          style: GoogleFonts.courierPrime(
            color: Colors.grey[400],
            fontSize: 12,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.courierPrime(
                color: Colors.grey[400],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final dialogContext = context;
              Navigator.pop(dialogContext);
              
              final screenContext = this.context;
              
              // Mostrar indicador de carga
              showDialog(
                context: screenContext,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B0000),
                  ),
                ),
              );
              
              try {
                // Limpiar SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                debugPrint('✅ [SETTINGS] Todos los datos locales han sido borrados');
                
                // Cerrar indicador de carga
                Navigator.of(screenContext, rootNavigator: true).pop();
                
                // Mostrar mensaje de éxito
                if (mounted) {
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Datos locales borrados. Reinicia la app para aplicar cambios.',
                        style: GoogleFonts.courierPrime(color: Colors.white),
                      ),
                      backgroundColor: Colors.green[700],
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } catch (e) {
                // Cerrar indicador de carga
                Navigator.of(screenContext, rootNavigator: true).pop();
                
                // Mostrar error
                if (mounted) {
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(
                      content: Text('Error al borrar datos: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'BORRAR TODO',
              style: GoogleFonts.courierPrime(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCredits() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreditsScreen()),
    );
  }

  Future<void> _openWebsite() async {
    final Uri url = Uri.parse('https://eidolon-institute.com/');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se puede abrir el portal web')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al acceder al portal: $e')),
        );
      }
    }
  }

  void _openPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'POLÍTICA DE PRIVACIDAD',
          style: GoogleFonts.shareTechMono(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'WITNESS.ME - EIDOLON CONCEPTS\n\n'
            'Última actualización: 2026\n\n'
            'RECOPILACIÓN DE DATOS:\n'
            '• Email (autenticación)\n'
            '• Progreso del juego\n'
            '• Compras realizadas\n'
            '• Datos de uso anónimos\n\n'
            'USO DE DATOS:\n'
            '• Autenticación de usuario\n'
            '• Sincronización de progreso\n'
            '• Procesamiento de pagos\n'
            '• Mejora de la experiencia\n\n'
            'ALMACENAMIENTO:\n'
            'Los datos se almacenan en Firebase (Google Cloud) con encriptación.\n\n'
            'DERECHOS DEL USUARIO:\n'
            '• Acceso a tus datos\n'
            '• Corrección de datos\n'
            '• Eliminación de cuenta\n\n'
            'Para más información:\n'
            'witnessme.eidolon@gmail.com',
            style: GoogleFonts.shareTechMono(
              color: Colors.grey[400],
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CERRAR',
              style: GoogleFonts.shareTechMono(
                color: const Color(0xFF8B0000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'TÉRMINOS DE SERVICIO',
          style: GoogleFonts.shareTechMono(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'WITNESS.ME - EIDOLON CONCEPTS\n\n'
            'Última actualización: 2026\n\n'
            'ACEPTACIÓN DE TÉRMINOS:\n'
            'Al usar este software, aceptas estos términos.\n\n'
            'LICENCIA DE USO:\n'
            '• Uso personal no comercial\n'
            '• No redistribución\n'
            '• No ingeniería inversa\n'
            '• No modificación del software\n\n'
            'COMPRAS:\n'
            '• Los SEGS son moneda virtual\n'
            '• No reembolsables\n'
            '• Sin valor monetario real\n'
            '• Acceso Total: suscripción no renovable\n\n'
            'CONTENIDO:\n'
            '• Contenido para mayores de 16 años\n'
            '• Temas de horror psicológico\n'
            '• Puede contener contenido perturbador\n\n'
            'RESPONSABILIDAD:\n'
            'El software se proporciona "tal cual" sin garantías.\n\n'
            'Contacto:\n'
            'witnessme.eidolon@gmail.com',
            style: GoogleFonts.shareTechMono(
              color: Colors.grey[400],
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CERRAR',
              style: GoogleFonts.shareTechMono(
                color: const Color(0xFF8B0000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reportBug() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'REPORTAR BUG',
          style: GoogleFonts.shareTechMono(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Envía un reporte de bug a:\n\n'
          'witnessme.eidolon@gmail.com\n\n'
          'Por favor incluye:\n'
          '• Descripción del problema\n'
          '• Pasos para reproducirlo\n'
          '• Capturas de pantalla (si aplica)\n'
          '• Dispositivo y versión de Android/iOS\n\n'
          'Tu testimonio nos ayuda a mejorar el juego.',
          style: GoogleFonts.shareTechMono(
            color: Colors.grey[400],
            fontSize: 11,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.shareTechMono(
                color: Colors.grey[400],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'witnessme.eidolon@gmail.com',
                query: 'subject=Bug Report - WITNESS.ME v1.0.0&body=Describe el bug aquí...',
              );

              try {
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No se puede abrir el cliente de email',
                          style: GoogleFonts.shareTechMono(color: Colors.white),
                        ),
                        backgroundColor: Colors.red[900],
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Email: witnessme.eidolon@gmail.com',
                        style: GoogleFonts.shareTechMono(color: Colors.white),
                      ),
                      backgroundColor: Colors.red[900],
                    ),
                  );
                }
              }
            },
            child: Text(
              'ABRIR EMAIL',
              style: GoogleFonts.shareTechMono(
                color: const Color(0xFF8B0000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contact() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'CONTACTO',
          style: GoogleFonts.shareTechMono(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'EIDOLON CONCEPTS\n\n'
          'Email:\n'
          'witnessme.eidolon@gmail.com\n\n'
          'Horario de respuesta:\n'
          '24-48 horas\n\n'
          'Para consultas sobre:\n'
          '• Soporte técnico\n'
          '• Sugerencias\n'
          '• Colaboraciones\n'
          '• Prensa\n\n'
          'Tu testimonio es importante para nosotros.',
          style: GoogleFonts.shareTechMono(
            color: Colors.grey[400],
            fontSize: 11,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.shareTechMono(
                color: Colors.grey[400],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'witnessme.eidolon@gmail.com',
                query: 'subject=Contacto - WITNESS.ME',
              );

              try {
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No se puede abrir el cliente de email',
                          style: GoogleFonts.shareTechMono(color: Colors.white),
                        ),
                        backgroundColor: Colors.red[900],
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Email: witnessme.eidolon@gmail.com',
                        style: GoogleFonts.shareTechMono(color: Colors.white),
                      ),
                      backgroundColor: Colors.red[900],
                    ),
                  );
                }
              }
            },
            child: Text(
              'ABRIR EMAIL',
              style: GoogleFonts.shareTechMono(
                color: const Color(0xFF8B0000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          '¿Cerrar sesión?',
          style: GoogleFonts.courierPrime(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tu progreso se guardará automáticamente.',
          style: GoogleFonts.courierPrime(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.courierPrime(
                color: Colors.grey[400],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Guardar el contexto del diálogo antes de cerrarlo
              final dialogContext = context;
              Navigator.pop(dialogContext);
              
              // Guardar el contexto de la pantalla
              final screenContext = this.context;
              
              // Mostrar indicador de carga y guardar su contexto
              final loadingDialog = showDialog(
                context: screenContext,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B0000),
                  ),
                ),
              );
              
              try {
                // Cerrar sesión
                await Provider.of<AuthProvider>(screenContext, listen: false).signOut();
                
                // Cerrar indicador de carga
                Navigator.of(screenContext, rootNavigator: true).pop();
                
                // Navegar a pantalla de autenticación
                if (mounted) {
                  Navigator.of(screenContext).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                // Si hay error, cerrar el diálogo de carga
                Navigator.of(screenContext, rootNavigator: true).pop();
                // Mostrar error
                if (mounted) {
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'CERRAR SESIÓN',
              style: GoogleFonts.courierPrime(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
