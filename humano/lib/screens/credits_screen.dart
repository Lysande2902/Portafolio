import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> with SingleTickerProviderStateMixin {
  AnimationController? _cursorController;
  bool _showFinalMessage = false;
  
  @override
  void initState() {
    super.initState();
    // Forzar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Cursor parpadeante
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wineRed = const Color(0xFF8B0000);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.currentUser?.email?.split('@')[0] ?? 'USUARIO_DESCONOCIDO';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header minimalista
            _buildHeader(wineRed),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clasificación del documento
                    _buildClassification(wineRed),
                    
                    const SizedBox(height: 32),
                    
                    // Título del expediente
                    _buildDocumentTitle(wineRed),
                    
                    const SizedBox(height: 40),
                    
                    // El Tribunal
                    _buildSection('EL TRIBUNAL', wineRed, [
                      _buildCourtLine('PRESIDENTE DEL JURADO / JUEZ DE HECHO', 'A. MARLOWE', isJudge: true),
                      _buildCourtLine('', '(Fundador, Eidolon Concepts)', isSubtitle: true),
                      const SizedBox(height: 16),
                      _buildCourtLine('FISCALÍA (Diseño y Narrativa)', 'A. MARLOWE'),
                      _buildCourtLine('', 'Director Creativo', isSubtitle: true),
                      _buildCourtLine('', 'Diseño de Juego', isSubtitle: true),
                      _buildCourtLine('', 'Escritura y Narrativa', isSubtitle: true),
                      const SizedBox(height: 16),
                      _buildCourtLine('DEFENSA (Programación y Sistemas)', 'A. MARLOWE'),
                      _buildCourtLine('', 'Programación Principal', isSubtitle: true),
                      _buildCourtLine('', 'Arquitectura de Sistemas', isSubtitle: true),
                      _buildCourtLine('', 'Implementación de Gameplay', isSubtitle: true),
                      const SizedBox(height: 16),
                      _buildCourtLine('TESTIGOS EXPERTOS (Arte y Sonido)', 'A. MARLOWE'),
                      _buildCourtLine('', 'Dirección de Arte', isSubtitle: true),
                      _buildCourtLine('', 'Diseño de UI/UX', isSubtitle: true),
                      const SizedBox(height: 8),
                      _buildCourtLine('', 'J. CIPHER'),
                      _buildCourtLine('', 'Composición Musical', isSubtitle: true),
                      _buildCourtLine('', 'Diseño de Audio', isSubtitle: true),
                      const SizedBox(height: 16),
                      _buildCourtLine('RECOPILACIÓN DE TESTIMONIOS (QA y Soporte)', 'A. MARLOWE'),
                      _buildCourtLine('', 'Testing y Control de Calidad', isSubtitle: true),
                      _buildCourtLine('', 'Soporte Técnico', isSubtitle: true),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    // Evidencia Admitida
                    _buildSection('EVIDENCIA ADMITIDA', wineRed, [
                      _buildEvidenceLine('MOTOR DE JUICIO', 'Flutter SDK 3.9.2 (Dart 3.x)'),
                      _buildEvidenceLine('BACKEND DE TESTIMONIOS', 'Firebase Suite (Auth, Firestore, Storage)'),
                      _buildEvidenceLine('SISTEMA DE PAGOS', 'Stripe Payment Gateway'),
                      _buildEvidenceLine('ENGINE DE GAMEPLAY', 'Flame Engine 1.18.0'),
                      _buildEvidenceLine('REPRODUCCIÓN DE AUDIO', 'Just Audio 0.9.x, AudioPlayers 5.2.x'),
                      _buildEvidenceLine('FUENTES TIPOGRÁFICAS', 'Share Tech Mono, Courier Prime (Google Fonts)'),
                      _buildEvidenceLine('CONTROL DE VERSIONES', 'Git + GitHub'),
                      _buildEvidenceLine('PLATAFORMAS OBJETIVO', 'Android, iOS'),
                      const SizedBox(height: 8),
                      _buildTestimonyText('Todas las herramientas utilizadas bajo sus respectivas licencias.'),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    // Agradecimientos del Testigo
                    _buildSection('AGRADECIMIENTOS DEL TESTIGO', wineRed, [
                      _buildTestimonyText('El testimonio de las siguientes personas fue crucial'),
                      _buildTestimonyText('para la deposición de este caso:'),
                      const SizedBox(height: 12),
                      _buildTestimonyText('• Familia Marlowe'),
                      _buildTestimonyText('• Comunidad de desarrollo indie'),
                      _buildTestimonyText('• Jugadores de horror psicológico'),
                      _buildTestimonyText('• Colaboradores de OpenGameArt'),
                      const SizedBox(height: 12),
                      _buildTestimonyText('Su testimonio permanecerá en el expediente.'),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    // Casos Especiales
                    _buildSection('CASOS ESPECIALES', wineRed, [
                      _buildSpecialCase('TESTIGOS NO IDENTIFICADOS', '(Beta Testers)'),
                      const SizedBox(height: 8),
                      _buildTestimonyText('Usuarios que depositaron su testimonio en fase previa:'),
                      const SizedBox(height: 8),
                      _buildTestimonyText('• Usuario_████████ - [REDACTADO]'),
                      _buildTestimonyText('• Usuario_████████ - [REDACTADO]'),
                      _buildTestimonyText('• Usuario_████████ - [REDACTADO]'),
                      _buildTestimonyText('• Usuario_████████ - [REDACTADO]'),
                      _buildTestimonyText('• Usuario_████████ - [REDACTADO]'),
                      const SizedBox(height: 12),
                      _buildTestimonyText('Sus identidades permanecen protegidas bajo'),
                      _buildTestimonyText('el Acuerdo de No Divulgación EC-2025-NDA.'),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    // Recursos de Terceros
                    _buildSection('RECURSOS DE TERCEROS ADMITIDOS', wineRed, [
                      _buildTestimonyText('ACTIVOS VISUALES:'),
                      _buildTestimonyText('• LPC Character Generator - CC-BY-SA 3.0'),
                      _buildTestimonyText('  (Autores: Varios contribuidores de OpenGameArt)'),
                      _buildTestimonyText('• OpenGameArt.org - Sprites y texturas'),
                      const SizedBox(height: 8),
                      _buildTestimonyText('EFECTOS DE AUDIO:'),
                      _buildTestimonyText('• Freesound.org - Efectos bajo licencia CC'),
                      _buildTestimonyText('• Sonidos ambientales de dominio público'),
                      const SizedBox(height: 8),
                      _buildTestimonyText('HERRAMIENTAS DE DESARROLLO:'),
                      _buildTestimonyText('• Flutter SDK - Google LLC'),
                      _buildTestimonyText('• Firebase - Google LLC'),
                      _buildTestimonyText('• Flame Engine - Blue Fire Team'),
                      const SizedBox(height: 8),
                      _buildTestimonyText('Todos los créditos completos y licencias disponibles en:'),
                      _buildTestimonyText('witnessme.eidolon@gmail.com'),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    // Información Corporativa
                    _buildSection('INFORMACIÓN CORPORATIVA', wineRed, [
                      _buildInfoLine('RAZÓN SOCIAL', 'EIDOLON CONCEPTS'),
                      _buildInfoLine('TIPO', 'Estudio Independiente'),
                      _buildInfoLine('FUNDACIÓN', '2025'),
                      _buildInfoLine('SEDE', '[CLASIFICADO]'),
                      _buildInfoLine('ESPECIALIDAD', 'Horror Psicológico Interactivo'),
                      const SizedBox(height: 8),
                      _buildTestimonyText('Registro de marca en proceso.'),
                    ]),
                    
                    const SizedBox(height: 40),
                    
                    // Veredicto Final
                    _buildVerdict(wineRed),
                    
                    const SizedBox(height: 40),
                    
                    // Footer Legal
                    _buildLegalFooter(wineRed),
                    
                    const SizedBox(height: 60),
                    
                    // Mensaje final perturbador
                    if (_showFinalMessage)
                      _buildFinalMessage(userName, wineRed)
                    else
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showFinalMessage = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              '[TOQUE PARA FINALIZAR EXPEDIENTE]',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 10,
                                color: Colors.white10,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            'EXPEDIENTE_JUDICIAL',
            style: GoogleFonts.shareTechMono(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassification(Color wineRed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: wineRed.withOpacity(0.05),
        border: Border.all(color: wineRed, width: 2),
        boxShadow: [
          BoxShadow(
            color: wineRed.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '⚠',
                style: TextStyle(fontSize: 16, color: wineRed),
              ),
              const SizedBox(width: 8),
              Text(
                'CLASIFICADO',
                style: GoogleFonts.shareTechMono(
                  fontSize: 14,
                  color: wineRed,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '⚠',
                style: TextStyle(fontSize: 16, color: wineRed),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            width: 200,
            color: wineRed.withOpacity(0.3),
          ),
          const SizedBox(height: 6),
          Text(
            'ACCESO RESTRINGIDO - SOLO TESTIGOS',
            style: GoogleFonts.shareTechMono(
              fontSize: 8,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTitle(Color wineRed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: wineRed.withOpacity(0.1),
            border: Border(
              left: BorderSide(color: wineRed, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPEDIENTE EIDOLON',
                style: GoogleFonts.shareTechMono(
                  fontSize: 20,
                  color: wineRed,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'CASO: WITNESS.ME',
                style: GoogleFonts.shareTechMono(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoLine('FECHA DE JUICIO', '2026'),
        _buildInfoLine('JURISDICCIÓN', 'DESARROLLO INTERACTIVO'),
        _buildInfoLine('NÚMERO DE CASO', 'EC-2026-WITNESS-001'),
        _buildInfoLine('ESTADO', 'SENTENCIADO'),
      ],
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Color wineRed, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: wineRed.withOpacity(0.3), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: wineRed.withOpacity(0.15),
              border: Border(
                bottom: BorderSide(color: wineRed.withOpacity(0.5), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 12,
                  color: wineRed,
                  margin: const EdgeInsets.only(right: 8),
                ),
                Text(
                  title,
                  style: GoogleFonts.shareTechMono(
                    color: wineRed,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtLine(String role, String name, {bool isJudge = false, bool isSubtitle = false}) {
    if (isSubtitle) {
      return Padding(
        padding: const EdgeInsets.only(left: 32, bottom: 2),
        child: Text(
          '└─ $name',
          style: GoogleFonts.shareTechMono(
            fontSize: 9,
            color: Colors.grey[700],
            letterSpacing: 0.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    if (role.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 4),
        child: Text(
          name,
          style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: GoogleFonts.shareTechMono(
              fontSize: 9,
              color: isJudge ? const Color(0xFFB22222) : Colors.grey[700],
              letterSpacing: 1,
              fontWeight: isJudge ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              name,
              style: GoogleFonts.shareTechMono(
                fontSize: 11,
                color: isJudge ? Colors.white : Colors.white70,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.shareTechMono(
              fontSize: 9,
              color: Colors.grey[700],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              value,
              style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.shareTechMono(
          fontSize: 10,
          color: Colors.grey[600],
          letterSpacing: 0.5,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSpecialCase(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: Colors.grey[700],
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.shareTechMono(
            fontSize: 9,
            color: Colors.grey[800],
            letterSpacing: 0.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildVerdict(Color wineRed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: wineRed.withOpacity(0.08),
        border: Border.all(color: wineRed, width: 2),
        boxShadow: [
          BoxShadow(
            color: wineRed.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 1,
                color: wineRed,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'VEREDICTO FINAL',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    color: wineRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 1,
                color: wineRed,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Este software fue encontrado...',
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: wineRed, width: 1),
            ),
            child: Text(
              '[CULPABLE DE EXISTIR]',
              style: GoogleFonts.shareTechMono(
                fontSize: 16,
                color: wineRed,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sentencia: Ser jugado.',
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalFooter(Color wineRed) {
    return Column(
      children: [
        Container(
          height: 1,
          color: wineRed.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2026 EIDOLON CONCEPTS',
          style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: Colors.grey[700],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'TODOS LOS TESTIGOS RESERVADOS',
          style: GoogleFonts.shareTechMono(
            fontSize: 8,
            color: Colors.grey[800],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'El jurado agradece su participación en este juicio.',
          style: GoogleFonts.shareTechMono(
            fontSize: 9,
            color: Colors.grey[700],
            letterSpacing: 0.5,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'witnessme.eidolon@gmail.com',
          style: GoogleFonts.shareTechMono(
            fontSize: 9,
            color: wineRed.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalMessage(String userName, Color wineRed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: wineRed.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: wineRed.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            height: 1,
            width: double.infinity,
            color: wineRed.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'El testimonio del usuario',
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: wineRed.withOpacity(0.1),
              border: Border.all(color: wineRed.withOpacity(0.5), width: 1),
            ),
            child: Text(
              userName.toUpperCase(),
              style: GoogleFonts.shareTechMono(
                fontSize: 14,
                color: wineRed,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ha sido agregado al expediente.',
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            width: double.infinity,
            color: wineRed.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          // Cursor parpadeante
          if (_cursorController != null)
            AnimatedBuilder(
              animation: _cursorController!,
              builder: (context, child) {
                return Opacity(
                  opacity: _cursorController!.value,
                  child: Text(
                    '█',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 18,
                      color: wineRed,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
