import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/evidence.dart';

class EvidenceDetailView extends StatelessWidget {
  final Evidence evidence;

  const EvidenceDetailView({
    super.key,
    required this.evidence,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          border: Border.all(
            color: Colors.red.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Type icon
                  Text(
                    evidence.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 15),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evidence.title,
                          style: GoogleFonts.courierPrime(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getArcName(evidence.arcId),
                          style: GoogleFonts.courierPrime(
                            fontSize: 12,
                            color: Colors.grey[500],
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      evidence.description,
                      style: GoogleFonts.courierPrime(
                        fontSize: 14,
                        color: Colors.grey[300],
                        height: 1.6,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Content placeholder
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          border: Border.all(
                            color: Colors.grey[800]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              evidence.type.icon,
                              style: const TextStyle(fontSize: 60),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '[CONTENIDO EN DESARROLLO]',
                              style: GoogleFonts.courierPrime(
                                fontSize: 12,
                                color: Colors.grey[600],
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getContentTypeText(),
                              style: GoogleFonts.courierPrime(
                                fontSize: 10,
                                color: Colors.grey[700],
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getArcName(String arcId) {
    final arcNames = {
      'arc_1_gula': 'ARCO 1: GULA',
      'arc_2_avaricia': 'ARCO 2: AVARICIA',
      'arc_3_pereza': 'ARCO 3: PEREZA',
      'arc_4_lujuria': 'ARCO 4: LUJURIA',
      'arc_5_soberbia': 'ARCO 5: SOBERBIA',
      'arc_6_envidia': 'ARCO 6: ENVIDIA',
      'arc_7_ira': 'ARCO 7: IRA',
    };
    return arcNames[arcId] ?? arcId;
  }

  String _getContentTypeText() {
    switch (evidence.type) {
      case EvidenceType.screenshot:
        return 'Imagen / Screenshot';
      case EvidenceType.message:
        return 'Mensaje / Conversación';
      case EvidenceType.video:
        return 'Video / Grabación';
      case EvidenceType.audio:
        return 'Audio / Llamada';
      case EvidenceType.document:
        return 'Documento / Texto';
    }
  }
}
