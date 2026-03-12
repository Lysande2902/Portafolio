import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/providers/fragments_provider.dart';

class CaseFileScreen extends StatefulWidget {
  final String evidenceId;

  const CaseFileScreen({
    super.key,
    required this.evidenceId,
  });

  @override
  State<CaseFileScreen> createState() => _CaseFileScreenState();
}

class _CaseFileScreenState extends State<CaseFileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildDocumentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final arcId = _getArcIdFromEvidenceId(widget.evidenceId);
    final title = _getArcTitle(arcId);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.shareTechMono(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Progreso
          Consumer<FragmentsProvider>(
            builder: (context, fragmentsProvider, child) {
              final unlockedFragments = fragmentsProvider.getFragmentsForArc(arcId);
              final total = _getTotalFragments(arcId);
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${unlockedFragments.length}/$total',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    color: const Color(0xFF8B0000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    final arcId = _getArcIdFromEvidenceId(widget.evidenceId);
    final totalFragments = _getTotalFragments(arcId);

    return Consumer<FragmentsProvider>(
      builder: (context, fragmentsProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: totalFragments,
          itemBuilder: (context, index) {
            final fragmentNumber = index + 1;
            final isUnlocked = fragmentsProvider.isFragmentUnlocked(arcId, fragmentNumber);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: isUnlocked
                  ? _buildUnlockedDocument(arcId, fragmentNumber)
                  : _buildLockedDocument(fragmentNumber),
            );
          },
        );
      },
    );
  }

  Widget _buildLockedDocument(int documentNumber) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock,
            size: 32,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'DOCUMENTO $documentNumber',
            style: GoogleFonts.shareTechMono(
              fontSize: 14,
              color: Colors.white30,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              '█ CLASIFICADO █',
              style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: Colors.white24,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedDocument(String arcId, int fragmentNumber) {
    // Obtener información real del fragmento, o usar fallback
    final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
    final info = fragmentsProvider.getFragmentInfo(arcId, fragmentNumber);
    final description = info?['description'] ?? 'DATOS_CORRUPTOS: No se pudo recuperar el fragmento de memoria.';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F), // Negro muy oscuro pero no absoluto
        border: Border.all(
          color: const Color(0xFF8B0000).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B0000).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del documento (Barra superior)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000).withOpacity(0.15),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF8B0000).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, size: 14, color: Color(0xFF8B0000)),
                    const SizedBox(width: 8),
                    Text(
                      'LOG_$fragmentNumber.TXT',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        color: const Color(0xFF8B0000),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF8B0000).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'DESCLASIFICADO',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 10,
                      color: const Color(0xFF8B0000),
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido del documento
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Línea decorativa superior
                Container(
                  width: 40,
                  height: 2,
                  color: const Color(0xFF8B0000).withOpacity(0.3),
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                
                Text(
                  description,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 16,
                    color: Colors.grey[300],
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
                
                // Pie de página decorativo
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '// FIN_DEL_REGISTRO',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.grey[700],
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getArcIdFromEvidenceId(String evidenceId) {
    final mapping = {
      'arc_0_inicio_evidence':         'arc_0_inicio',
      'arc_1_envidia_lujuria_evidence': 'arc_1_envidia_lujuria',
      'arc_2_consumo_codicia_evidence': 'arc_2_consumo_codicia',
      'arc_3_soberbia_pereza_evidence': 'arc_3_soberbia_pereza',
      'arc_4_ira_evidence':             'arc_4_ira',
      // Legado
      'arc1_gluttony_evidence':         'arc_1_gula',
      'arc2_greed_evidence':            'arc_2_greed',
      'arc3_envy_evidence':             'arc_3_envy',
      'arc1_envidia_lujuria_evidence':  'arc_1_envidia_lujuria',
      'arc2_consumo_codicia_evidence':  'arc_2_consumo_codicia',
    };
    return mapping[evidenceId] ?? 'arc_1_envidia_lujuria';
  }

  String _getArcTitle(String arcId) {
    final titles = {
      'arc_0_inicio':          'P-0: EL INICIO',
      'arc_1_envidia_lujuria': 'P-1: ENVIDIA Y LUJURIA',
      'arc_2_consumo_codicia': 'P-2: CONSUMO Y CODICIA',
      'arc_3_soberbia_pereza': 'P-3: SOBERBIA Y PEREZA',
      'arc_4_ira':             'P-4: IRA',
      // Legado
      'arc_1_gula':  'P-1: GULA',
      'arc_2_greed': 'P-2: AVARICIA',
      'arc_3_envy':  'P-3: ENVIDIA',
    };
    return titles[arcId] ?? 'P-??';
  }

  int _getTotalFragments(String arcId) {
    if (arcId == 'arc_0_inicio' || arcId == 'arc_4_ira') return 5;
    return 3;
  }


  Map<String, dynamic> _getFragmentContent(String arcId, int fragmentNumber) {
    // Intentar obtener contenido real del provider
    final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
    final info = fragmentsProvider.getFragmentInfo(arcId, fragmentNumber);
    
    if (info != null) {
      return info;
    }
    
    // Fallback si no hay info
    return {
      'title': 'Fragmento $fragmentNumber',
      'description': 'Información clasificada no disponible.\nError de recuperación del servidor: 404',
    };
  }
}
