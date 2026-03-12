import '../models/evidence.dart';

class EvidenceDataProvider {
  static final List<Evidence> allEvidences = [
    // ARCO 1: GULA (7 evidencias)
    Evidence(
      id: 'evidence_1_gula_1',
      arcId: 'arc_1_gula',
      type: EvidenceType.screenshot,
      title: 'El Meme Viral',
      description: 'Screenshot del meme que se volvió viral burlándose del peso de Mateo',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 1: Gula',
    ),
    Evidence(
      id: 'evidence_1_gula_2',
      arcId: 'arc_1_gula',
      type: EvidenceType.message,
      title: 'Comentarios Crueles',
      description: 'Captura de los comentarios que dejaste en sus fotos',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra la primera evidencia en Gula',
    ),
    Evidence(
      id: 'evidence_1_gula_3',
      arcId: 'arc_1_gula',
      type: EvidenceType.screenshot,
      title: 'Perfil Destruido',
      description: 'Su perfil profesional antes y después del meme',
      contentPath: 'placeholder',
      unlockHint: 'Explora el restaurante completamente',
    ),
    Evidence(
      id: 'evidence_1_gula_4',
      arcId: 'arc_1_gula',
      type: EvidenceType.message,
      title: 'Mensaje de Despido',
      description: 'Email donde lo despiden de su trabajo como chef',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra todas las evidencias de Gula',
    ),
    Evidence(
      id: 'evidence_1_gula_5',
      arcId: 'arc_1_gula',
      type: EvidenceType.video,
      title: 'Video Original',
      description: 'El video que grabaste y compartiste sin su permiso',
      contentPath: 'placeholder',
      unlockHint: 'Completa Gula sin ser detectado',
    ),
    Evidence(
      id: 'evidence_1_gula_6',
      arcId: 'arc_1_gula',
      type: EvidenceType.document,
      title: 'Historial de Shares',
      description: 'Registro de cuántas veces compartiste el contenido',
      contentPath: 'placeholder',
      unlockHint: 'Colecciona 5 evidencias de Gula',
    ),
    Evidence(
      id: 'evidence_1_gula_7',
      arcId: 'arc_1_gula',
      type: EvidenceType.audio,
      title: 'Llamada de Súplica',
      description: 'Audio donde Mateo te pide que borres el contenido',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 1 perfectamente',
    ),

    // ARCO 2: AVARICIA (5 evidencias - greed theme)
    Evidence(
      id: 'greed_evidence_1',
      arcId: 'arc_2_greed',
      type: EvidenceType.screenshot,
      title: 'Post de Doxing',
      description: 'Captura del post donde compartiste su información bancaria',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 2: Avaricia',
    ),
    Evidence(
      id: 'greed_evidence_2',
      arcId: 'arc_2_greed',
      type: EvidenceType.message,
      title: 'Mensajes Desesperados',
      description: 'Conversación donde Valeria te pide ayuda',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra la primera evidencia en Avaricia',
    ),
    Evidence(
      id: 'greed_evidence_3',
      arcId: 'arc_2_greed',
      type: EvidenceType.document,
      title: 'Reporte Bancario',
      description: 'Documento mostrando el fraude que sufrió',
      contentPath: 'placeholder',
      unlockHint: 'Explora el nivel completamente',
    ),
    Evidence(
      id: 'greed_evidence_4',
      arcId: 'arc_2_greed',
      type: EvidenceType.screenshot,
      title: 'Fotos de sus Hijos',
      description: 'Imágenes que también expusiste sin pensar',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra todas las evidencias de Avaricia',
    ),
    Evidence(
      id: 'greed_evidence_5',
      arcId: 'arc_2_greed',
      type: EvidenceType.message,
      title: 'Notificación de Desalojo',
      description: 'Mensaje donde pierde su casa',
      contentPath: 'placeholder',
      unlockHint: 'Completa Avaricia sin ser detectado',
    ),
    Evidence(
      id: 'evidence_2_avaricia_6',
      arcId: 'arc_2_avaricia',
      type: EvidenceType.video,
      title: 'Video Viral',
      description: 'El video que hiciste "para concientizar"',
      contentPath: 'placeholder',
      unlockHint: 'Colecciona 5 evidencias de Avaricia',
    ),
    Evidence(
      id: 'evidence_2_avaricia_7',
      arcId: 'arc_2_avaricia',
      type: EvidenceType.audio,
      title: 'Llanto de sus Hijos',
      description: 'Audio grabado sin permiso en su peor momento',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 2 perfectamente',
    ),

    // ARCO 6: PEREZA (5 evidencias - sloth theme)
    Evidence(
      id: 'sloth_evidence_1',
      arcId: 'arc_6_sloth',
      type: EvidenceType.screenshot,
      title: 'Notificaciones Ignoradas',
      description: 'Cientos de mensajes sin leer de amigos preocupados',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 6: Pereza',
    ),
    Evidence(
      id: 'sloth_evidence_2',
      arcId: 'arc_6_sloth',
      type: EvidenceType.document,
      title: 'Proyectos Abandonados',
      description: 'Carpetas llenas de ideas que nunca se completaron',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra la primera evidencia en Pereza',
    ),
    Evidence(
      id: 'sloth_evidence_3',
      arcId: 'arc_6_sloth',
      type: EvidenceType.screenshot,
      title: 'Alarmas Desactivadas',
      description: 'Historial de alarmas pospuestas infinitamente',
      contentPath: 'placeholder',
      unlockHint: 'Explora el nivel completamente',
    ),
    Evidence(
      id: 'sloth_evidence_4',
      arcId: 'arc_6_sloth',
      type: EvidenceType.message,
      title: 'Oportunidades Perdidas',
      description: 'Emails de trabajos y becas que expiraron sin respuesta',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra todas las evidencias de Pereza',
    ),
    Evidence(
      id: 'sloth_evidence_5',
      arcId: 'arc_6_sloth',
      type: EvidenceType.document,
      title: 'Promesas Rotas',
      description: 'Lista de "mañana lo hago" que nunca se cumplieron',
      contentPath: 'placeholder',
      unlockHint: 'Completa Pereza sin ser detectado',
    ),

    // ARCO 4: LUJURIA (4 evidencias - lust theme)
    Evidence(
      id: 'lust_evidence_1',
      arcId: 'arc_4_lust',
      type: EvidenceType.video,
      title: 'Contenido Íntimo',
      description: 'El video privado que distribuiste sin consentimiento',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 4: Lujuria',
    ),
    Evidence(
      id: 'lust_evidence_2',
      arcId: 'arc_4_lust',
      type: EvidenceType.message,
      title: 'Conversación Privada',
      description: 'Chat íntimo que hiciste público',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra la primera evidencia en Lujuria',
    ),
    Evidence(
      id: 'lust_evidence_3',
      arcId: 'arc_4_lust',
      type: EvidenceType.screenshot,
      title: 'Reacciones Virales',
      description: 'Capturas de cómo se compartió masivamente',
      contentPath: 'placeholder',
      unlockHint: 'Explora el nivel completamente',
    ),
    Evidence(
      id: 'lust_evidence_4',
      arcId: 'arc_4_lust',
      type: EvidenceType.document,
      title: 'Carta de Despido',
      description: 'Documento donde pierde su trabajo por tu acción',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra todas las evidencias de Lujuria',
    ),

    // ARCO 5: SOBERBIA (4 evidencias - pride theme)
    Evidence(
      id: 'pride_evidence_1',
      arcId: 'arc_5_pride',
      type: EvidenceType.screenshot,
      title: 'Thread de Acusaciones',
      description: 'El hilo de Twitter donde iniciaste la cancelación',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 5: Soberbia',
    ),
    Evidence(
      id: 'pride_evidence_2',
      arcId: 'arc_5_pride',
      type: EvidenceType.message,
      title: 'Mensajes Manipulados',
      description: 'Conversaciones que editaste para hacerlo ver mal',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra la primera evidencia en Soberbia',
    ),
    Evidence(
      id: 'pride_evidence_3',
      arcId: 'arc_5_pride',
      type: EvidenceType.video,
      title: 'Video Fuera de Contexto',
      description: 'Clip editado que distorsionó la verdad',
      contentPath: 'placeholder',
      unlockHint: 'Explora el nivel completamente',
    ),
    Evidence(
      id: 'pride_evidence_4',
      arcId: 'arc_5_pride',
      type: EvidenceType.document,
      title: 'Artículo Difamatorio',
      description: 'Texto que escribiste lleno de mentiras',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra todas las evidencias de Soberbia',
    ),

    // ARCO 3: ENVIDIA (4 evidencias - envy theme)
    Evidence(
      id: 'envy_evidence_1',
      arcId: 'arc_3_envy',
      type: EvidenceType.message,
      title: 'Comparaciones Constantes',
      description: 'Historial de comentarios comparándola con otros',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 3: Envidia',
    ),
    Evidence(
      id: 'envy_evidence_2',
      arcId: 'arc_3_envy',
      type: EvidenceType.screenshot,
      title: 'Fotos Editadas',
      description: 'Imágenes que modificaste para burlarte',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra la primera evidencia en Envidia',
    ),
    Evidence(
      id: 'envy_evidence_3',
      arcId: 'arc_3_envy',
      type: EvidenceType.video,
      title: 'Video de Burla',
      description: 'Compilación de momentos vergonzosos que hiciste',
      contentPath: 'placeholder',
      unlockHint: 'Explora el nivel completamente',
    ),
    Evidence(
      id: 'envy_evidence_4',
      arcId: 'arc_3_envy',
      type: EvidenceType.message,
      title: 'Mensajes de Amistad',
      description: 'Conversaciones cuando aún confiaba en ti',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra todas las evidencias de Envidia',
    ),
    Evidence(
      id: 'evidence_6_envidia_5',
      arcId: 'arc_6_envidia',
      type: EvidenceType.document,
      title: 'Diario Personal',
      description: 'Páginas de su diario que compartiste públicamente',
      contentPath: 'placeholder',
      unlockHint: 'Completa Envidia sin ser detectado',
    ),
    Evidence(
      id: 'evidence_6_envidia_6',
      arcId: 'arc_6_envidia',
      type: EvidenceType.screenshot,
      title: 'Memes Crueles',
      description: 'Colección de memes que creaste sobre ella',
      contentPath: 'placeholder',
      unlockHint: 'Colecciona 5 evidencias de Envidia',
    ),
    Evidence(
      id: 'evidence_6_envidia_7',
      arcId: 'arc_6_envidia',
      type: EvidenceType.audio,
      title: 'Última Conversación',
      description: 'Audio donde te confronta antes de convertirse en esto',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 6 perfectamente',
    ),

    // ARCO 7: IRA (4 evidencias - wrath theme)
    Evidence(
      id: 'wrath_evidence_1',
      arcId: 'arc_7_wrath',
      type: EvidenceType.message,
      title: 'Mensajes de Odio',
      description: 'Capturas de comentarios violentos enviados en un momento de furia',
      contentPath: 'placeholder',
      unlockHint: 'Completa el Arco 7: Ira',
    ),
    Evidence(
      id: 'wrath_evidence_2',
      arcId: 'arc_7_wrath',
      type: EvidenceType.screenshot,
      title: 'Relaciones Destruidas',
      description: 'Conversaciones donde la ira arruinó amistades de años',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra la primera evidencia en Ira',
    ),
    Evidence(
      id: 'wrath_evidence_3',
      arcId: 'arc_7_wrath',
      type: EvidenceType.video,
      title: 'Consecuencias Físicas',
      description: 'Fotos de objetos rotos en ataques de rabia',
      contentPath: 'placeholder',
      unlockHint: 'Explora el nivel completamente',
    ),
    Evidence(
      id: 'wrath_evidence_4',
      arcId: 'arc_7_wrath',
      type: EvidenceType.message,
      title: 'Arrepentimiento Tardío',
      description: 'Disculpas que llegaron demasiado tarde',
      contentPath: 'placeholder',
      unlockHint: 'Encuentra todas las evidencias de Ira',
    ),

  ];

  /// Get all evidences for a specific arc
  List<Evidence> getEvidencesByArc(String arcId) {
    return allEvidences.where((e) => e.arcId == arcId).toList();
  }

  /// Get all evidences of a specific type
  List<Evidence> getEvidencesByType(EvidenceType type) {
    return allEvidences.where((e) => e.type == type).toList();
  }

  /// Get evidence by ID
  Evidence? getEvidenceById(String id) {
    try {
      return allEvidences.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total count of evidences
  int getTotalCount() {
    return allEvidences.length;
  }

  /// Get count of evidences by type
  int getCountByType(EvidenceType type) {
    return allEvidences.where((e) => e.type == type).length;
  }
}
