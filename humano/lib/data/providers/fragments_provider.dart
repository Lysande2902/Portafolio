import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider para manejar el progreso de fragmentos del jugador
class FragmentsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fragmentos desbloqueados por arco
  // NOTA: Arco 0 tiene 5 fragmentos, Arcos 1-4 tienen 3 fragmentos cada uno
  Map<String, Set<int>> _unlockedFragments = {
    'arc_0_inicio': {},          // Arco 0: El Inicio (Loop)
    'arc_1_envidia_lujuria': {}, // Arco 1: Envidia y Lujuria
    'arc_2_consumo_codicia': {}, // Arco 2: Consumo y Codicia
    'arc_3_soberbia_pereza': {}, // Arco 3: Soberbia y Pereza
    'arc_4_ira': {},             // Arco 4: Ira (Final)
  };

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, Set<int>> get unlockedFragments => Map.unmodifiable(_unlockedFragments);
  
  /// Obtiene los fragmentos desbloqueados para un arco específico
  Set<int> getFragmentsForArc(String arcId) {
    return _unlockedFragments[arcId] ?? {};
  }
  
  /// Verifica si un fragmento específico está desbloqueado
  bool isFragmentUnlocked(String arcId, int fragmentNumber) {
    return _unlockedFragments[arcId]?.contains(fragmentNumber) ?? false;
  }
  
  /// Obtiene el total de fragmentos desbloqueados
  int get totalUnlockedFragments {
    return _unlockedFragments.values
        .map((set) => set.length)
        .fold(0, (sum, count) => sum + count);
  }
  
  /// Obtiene el progreso como porcentaje (0.0 a 1.0)
  double get progress {
    // Arco 0: 5 fragmentos
    // Arcos 1-3: 3 arcos × 3 fragmentos = 9
    // Arco 4: 5 fragmentos
    // Total: 5 + 9 + 5 = 19 fragmentos
    const totalFragments = 19;
    return totalUnlockedFragments / totalFragments;
  }


  /// Desbloquea un fragmento específico
  Future<void> unlockFragment(String arcId, int fragmentNumber) async {
    print('🔓 [unlockFragment] Iniciando...');
    print('   Arc ID: $arcId');
    print('   Fragmento: $fragmentNumber');
    
    if (!_unlockedFragments.containsKey(arcId)) {
      print('   ❌ Arc ID no válido: $arcId');
      return;
    }

    int maxFragments = 3; // Por defecto 3 fragmentos para arcos 1-3
    if (arcId == 'arc_0_inicio' || arcId == 'arc_4_ira') maxFragments = 5;


    if (fragmentNumber < 1 || fragmentNumber > maxFragments) {
      print('   ❌ Número de fragmento inválido: $fragmentNumber (máximo: $maxFragments)');
      return;
    }

    // Agregar a la lista local
    _unlockedFragments[arcId]!.add(fragmentNumber);
    print('   ✅ Fragmento añadido a lista local');
    print('   Fragmentos actuales para $arcId: ${_unlockedFragments[arcId]}');
    
    notifyListeners();
    print('   ✅ Listeners notificados');

    // Guardar en Firebase
    print('   💾 Guardando en Firebase...');
    await _saveToFirebase(arcId, fragmentNumber);
    
    print('✅ [unlockFragment] Fragmento desbloqueado: $arcId - Fragmento $fragmentNumber');
  }

  /// Desbloquea fragmentos basado en el progreso del arco
  Future<void> unlockFragmentsForArcProgress(String arcId, int fragmentsCollected) async {
    print('🔓 [FragmentsProvider] unlockFragmentsForArcProgress llamado');
    print('   Arc ID: $arcId');
    print('   Fragmentos a desbloquear: $fragmentsCollected');
    
    if (!_unlockedFragments.containsKey(arcId)) {
      print('   ❌ Arc ID no válido: $arcId');
      return;
    }

    int maxFragments = 3; // Por defecto 3 fragmentos para arcos 1-3
    if (arcId == 'arc_0_inicio' || arcId == 'arc_4_ira') maxFragments = 5;


    // Desbloquear fragmentos progresivamente
    for (int i = 1; i <= fragmentsCollected && i <= maxFragments; i++) {
      if (!isFragmentUnlocked(arcId, i)) {
        print('   🔓 Desbloqueando fragmento $i...');
        await unlockFragment(arcId, i);
      } else {
        print('   ✓ Fragmento $i ya estaba desbloqueado');
      }
    }
    
    print('   ✅ Total fragmentos desbloqueados para $arcId: ${_unlockedFragments[arcId]!.length}/$maxFragments');
  }

  /// Carga el progreso desde Firebase
  Future<void> loadProgress() async {
    print('═══════════════════════════════════');
    print('🔄 [FragmentsProvider] Iniciando carga de progreso...');
    print('   Provider hashCode: $hashCode');
    _isLoading = true;
    _error = null;
    // Notify listeners safely
    Future.microtask(() => notifyListeners());

    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ Usuario no autenticado, no se puede cargar progreso');
      print('═══════════════════════════════════');
      _isLoading = false;
      notifyListeners();
      return;
    }

    print('   Usuario ID: ${user.uid}');
    print('   Ruta: users/${user.uid}/progress/fragments');

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc('fragments')
          .get();

      print('   Documento existe: ${doc.exists}');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        print('📦 [FragmentsProvider] Datos recibidos de Firebase:');
        print('   Raw data: $data');
        
        // Cargar fragmentos desbloqueados
        for (final arcId in _unlockedFragments.keys) {
          if (data.containsKey(arcId)) {
            final fragmentsList = List<int>.from(data[arcId] ?? []);
            _unlockedFragments[arcId] = fragmentsList.toSet();
            print('   ✓ $arcId: ${_unlockedFragments[arcId]}');
          } else {
            print('   ✗ $arcId: no data');
          }
        }
        
        print('✅ Progreso de fragmentos cargado desde Firebase');
        print('   Total fragmentos: $totalUnlockedFragments');
        
        // Ejecutar limpieza en segundo plano (no esperar)
        _cleanupLegacyData(data);
      } else {
        print('📄 No hay progreso previo de fragmentos en Firebase');
        print('   El documento no existe aún');
      }
    } catch (e) {
      print('❌ Error cargando progreso de fragmentos: $e');
      print('   Stack trace: ${StackTrace.current}');
      _error = 'Error cargando progreso';
    } finally {
      _isLoading = false;
      notifyListeners();
      print('═══════════════════════════════════');
    }
  }

  // IDs de arcos obsoletos que deben ser eliminados de la DB
  static const List<String> _legacyArcIds = [
    'arc_1_gula',
    'arc_2_greed',
    'arc_3_envy',
    'arc_4_lust',
    'arc_5_pride',
    'arc_6_sloth',
    'arc_7_wrath',
  ];

  /// Limpia datos obsoletos de Firebase de forma segura
  Future<void> _cleanupLegacyData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Identificar qué campos legacy existen en los datos actuales
    final legacyFieldsToDelete = <String, dynamic>{};
    bool hasLegacyData = false;

    for (final legacyId in _legacyArcIds) {
      if (data.containsKey(legacyId)) {
        print('🧹 Detectado dato obsoleto: $legacyId');
        legacyFieldsToDelete[legacyId] = FieldValue.delete();
        hasLegacyData = true;
      }
    }

    if (!hasLegacyData) return;

    print('🧹 Iniciando limpieza de datos legacy...');
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc('fragments')
          .update(legacyFieldsToDelete);
      print('✅ Limpieza de legacy completada. Documento actualizado.');
    } catch (e) {
      print('⚠️ Error al limpiar datos legacy (no crítico): $e');
    }
  }

  /// Guarda un fragmento específico en Firebase
  Future<void> _saveToFirebase(String arcId, int fragmentNumber) async {
    print('   💾 [_saveToFirebase] Iniciando guardado...');
    
    final user = _auth.currentUser;
    if (user == null) {
      print('   ❌ Usuario no autenticado');
      return;
    }
    
    print('   Usuario ID: ${user.uid}');

    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc('fragments');

      // Convertir Set a List para Firebase
      final fragmentsList = _unlockedFragments[arcId]!.toList();
      print('   Fragmentos a guardar para $arcId: $fragmentsList');
      
      await docRef.set({
        arcId: fragmentsList,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('   ✅ Fragmento guardado en Firebase: $arcId - $fragmentNumber');
      print('   Ruta: users/${user.uid}/progress/fragments');
    } catch (e) {
      print('   ❌ Error guardando fragmento en Firebase: $e');
      print('   Stack trace: ${StackTrace.current}');
    }
  }

  /// Resetea todo el progreso (para testing)
  Future<void> resetProgress() async {
    _unlockedFragments = {
      'arc_0_inicio': {},
      'arc_1_envidia_lujuria': {},
      'arc_2_consumo_codicia': {},
      'arc_3_soberbia_pereza': {},
      'arc_4_ira': {},
    };
    
    notifyListeners();

    // Eliminar de Firebase
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('progress')
            .doc('fragments')
            .delete();
        print('🗑️ Progreso de fragmentos reseteado');
      } catch (e) {
        print('❌ Error reseteando progreso: $e');
      }
    }
  }

  /// Obtiene información detallada de un fragmento
  Map<String, dynamic>? getFragmentInfo(String arcId, int fragmentNumber) {
    final fragments = _getFragmentDefinitions(arcId);
    if (fragmentNumber < 1 || fragmentNumber > fragments.length) {
      return null;
    }
    
    final fragment = fragments[fragmentNumber - 1];
    return {
      ...fragment,
      'unlocked': isFragmentUnlocked(arcId, fragmentNumber),
    };
  }

  /// Obtiene todos los fragmentos de un arco con su estado
  List<Map<String, dynamic>> getFragmentsWithStatus(String arcId) {
    final fragments = _getFragmentDefinitions(arcId);
    return fragments.asMap().entries.map((entry) {
      final index = entry.key;
      final fragment = entry.value;
      return {
        ...fragment,
        'number': index + 1,
        'unlocked': isFragmentUnlocked(arcId, index + 1),
      };
    }).toList();
  }

  /// Definiciones de fragmentos por arco
  List<Map<String, dynamic>> _getFragmentDefinitions(String arcId) {
    switch (arcId) {
      case 'arc_0_inicio':
        return [
          {
            'id': 'arc_0_inicio_1',
            'title': 'FRAGMENTO 0.1: HANDSHAKE',
            'description': 'ALEX,\n\nBIENVENIDO AL PROTOCOLO DE RECONEXIÓN.\n\nTU CONCIENCIA HA SIDO FRAGMENTADA.\nTU CULPA HA SIDO ARCHIVADA.\nTU JUICIO HA COMENZADO.\n\nNO PUEDES ESCAPAR DE LO QUE YA SABES.\n\nSINCRONIZANDO...\n\n[SISTEMA]',
            'hint': 'Completa la primera fase del Arco 0',
          },
          {
            'id': 'arc_0_inicio_2',
            'title': 'FRAGMENTO 0.2: CONCIENCIA',
            'description': 'ALEX,\n\n¿RECUERDAS EL ÚLTIMO SONIDO QUE ESCUCHASTE?\n\nNO FUE UNA VOZ CONOCIDA.\nNO FUE LA ALARMA DEL HOSPITAL.\n\nFUE EL PITIDO DE UNA NOTIFICACIÓN.\n"NUEVO SEGUIDOR".\n\nMIENTRAS ALGUIEN NECESITABA TU AYUDA.\n\n¿LO RECUERDAS AHORA?\n\n[ANÓNIMO]',
            'hint': 'Completa la segunda fase del Arco 0',
          },
          {
            'id': 'arc_0_inicio_3',
            'title': 'FRAGMENTO 0.3: PURGA',
            'description': 'ALEX,\n\nDICES QUE NO SABÍAS.\nDICES QUE NO VISTE LAS LLAMADAS.\nDICES QUE ESTABAS OCUPADO.\n\nPERO EL TELÉFONO ESTABA EN TU MANO.\nLA PANTALLA ESTABA ENCENDIDA.\nVÍCTOR APARECÍA EN LA PANTALLA.\n\nY TÚ DESLIZASTE PARA IGNORAR.\n\n15 VECES.\n\n[TESTIGO]',
            'hint': 'Completa la tercera fase del Arco 0',
          },
          {
            'id': 'arc_0_inicio_4',
            'title': 'FRAGMENTO 0.4: MEMORIA',
            'description': 'ALEX,\n\n¿CUÁNTO VALE UNA PERSONA?\n\nALGUIEN CERCANO: \$0\nTU EQUIPO DE STREAMING: \$4,500\nTU RING LIGHT: \$350\nTU MICRÓFONO: \$800\n\nTOTAL INVERTIDO EN TU CARRERA: \$12,000\nTOTAL INVERTIDO EN ELLOS: \$0\n\nSOLO PEDÍAN 5 MINUTOS.\n\n[CONTADOR]',
            'hint': 'Completa la cuarta fase del Arco 0',
          },
          {
            'id': 'arc_0_inicio_5',
            'title': 'FRAGMENTO 0.5: ACEPTACIÓN',
            'description': 'ALEX,\n\nESTÁS EN COMA.\nALGUIEN ESPERA EN LA HABITACIÓN 304.\nALGUIEN MÁS YA NO PUEDE ESPERAR.\n\nESTO NO ES UN SUEÑO.\nESTO NO ES UN JUEGO.\nESTO ES EL JUICIO.\n\nY YA CONOCES EL VEREDICTO.\n\nCULPABLE.\n\n[EL SISTEMA]',
            'hint': 'Completa el Arco 0',
          },
        ];
      default:
        // Arcos 1-4 (Contenido narrativo unificado del archivo de evidencias)
        if (arcId == 'arc_1_envidia_lujuria') {
          return [
            {
              'id': 'arc_1_lucia_envidia',
              'title': 'FRAGMENTO 1.1: FOTO DE GRADUACIÓN',
              'description': 'ALEX,\n\nADJUNTO: FOTO_GRADUACION_2019.JPG\n\n¿VES ESA FOTO?\nTU CARA ESTÁ BORROSA.\nLA DE LUCÍA BRILLA.\n\nNO ES EL FILTRO.\nES QUE ELLA SÍ TERMINÓ LA CARRERA.\nELLA SÍ TIENE FUTURO.\n\nTÚ SOLO TIENES SEGUIDORES.\n\n¿CUÁNTOS DE ELLOS FUERON A TU GRADUACIÓN?\nAH, CIERTO. NO HUBO GRADUACIÓN.\n\n[UN COMPAÑERO DE CLASE]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
            {
              'id': 'arc_1_adriana_lujuria',
              'title': 'FRAGMENTO 1.2: CONTRATO TACHADO',
              'description': 'ALEX,\n\nADJUNTO: CONTRATO_PUBLICIDAD_MARCA_X.PDF\n\n"TU CUERPO ME PERTENECE"\n\nESO DICE AL PIE DEL CONTRATO.\nLO FIRMASTE SIN LEER.\n\nVENDISTE TU IMAGEN.\nVENDISTE TU PRIVACIDAD.\nVENDISTE TU DIGNIDAD.\n\nPOR \$500 Y 10,000 IMPRESIONES.\n\nADRIANA TE DIJO QUE ERA BUENA IDEA.\n¿DÓNDE ESTÁ ADRIANA AHØRÅ?\n\n[TU AGENTE (EX)]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
            {
              'id': 'arc_1_revelacion_espejo',
              'title': 'FRAGMENTO 1.3: VIDEO FILTRADO',
              'description': 'ALEX,\n\nADJUNTO: VIDEO_PRIVADO_23_NOV.MP4\n\nTE VEO PØSÅNDØ FR€NT€ ÅŁ €SP€JØ.\nÅJUSTÅNDØ €Ł ÁNGUŁØ.\nPRØBÅNDØ SØNRISÅS.\n\nY ÅŁ FØNDØ...\nS€ €SCUCHÅ UN T€ŁÉFØNØ VIBRÅR.\n\n"ŁŁÅMÅDÅ €NTRÅNT€"\n\nP€RØ TÚ SIGU€S PØSÅNDØ.\nPØRQU€ €Ł R€FŁ€JØ €S MÁS IMPØRTÅNT€.\n\nÅŁGUI€N CØRTÓ ŁÅ S€ÑÅŁ ÅNT€S Đ€ QU€ T€RMINÅRÅS.\nNØ QUI€R€N QU€ V€ÅS €Ł FINÅŁ.\n\n[ÅNÓNIMØ]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
          ];
        } else if (arcId == 'arc_2_consumo_codicia') {
          return [
            {
              'title': 'Fragmento 2.1: Mateo (Gula)',
              'description': 'ADJUNTO: TICKET_PIZZA_FAMILIAR.JPG\n\nPIZZA FAMILIAR - \$25.99 / PARA 4 PERSONAS\nNOTA AL PIE (TU LETRA): "COMER SOLO. GRABAR DESPUÉS."\n\nMateo te preguntó si podía comer contigo.\nLe dijiste que estabas ocupado.\n\nComiste solo frente a la cámara. 12,000 personas te vieron comer.\nMateo comió solo en su casa. Nadie lo vio.\n\n[EL DELIVERY]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
            {
              'title': 'Fragmento 2.2: Valeria (Avaricia)',
              'description': 'ADJUNTO: CONTRATO_COLABORACION_VALERIA.PDF\n\nEl nombre del "socio" ha sido borrado. Con saña. Con rabia.\nValeria te dio la idea. Valeria hizo el trabajo. Valeria editó el video.\n\nTú te quedaste con el 100% de las ganancias.\n\$8,000 en patrocinios. \$0 para Valeria.\n"Es que yo soy la cara del canal"\n\n¿Dónde está Valeria ahora?\n\n[TU EX SOCIA]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
            {
              'title': 'Fragmento 2.3: Audio Filtrado',
              'description': 'ADJUNTO: AUDIO_MENSAJE_15_OCT.MP3\n\n"Alex, dicen que ya no pueden pagar el depósito.\n¿Puedes ayudar? Sé que tienes dinero ahorrado...\nSolo necesitan \$600 para este mes. Por favor, llámame."\n\n3 DÍAS DESPUÉS COMPRASTE:\nNueva cámara: \$1,200 | Luces LED: \$400 | Micrófono: \$350\nTOTAL: \$1,950\n\nAlguien bajó el volumen. Está avergonzado.\n\n[ANÓNIMO]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
          ];
        } else if (arcId == 'arc_3_soberbia_pereza') {
          return [
            {
              'title': 'Fragmento 3.1: Carlos (Soberbia)',
              'description': 'ADJUNTO: VIDEO_DETRAS_CAMARAS.MP4\n\nTe veo llorando frente a la cámara. Lágrimas reales.\nY luego... Respiras hondo. Fuerzas una sonrisa. Y dices:\n"¡Hola a todos! ¿Cómo están?"\n\nCarlos te enseñó eso.\n"Nunca muestres debilidad"\n"El show debe continuar"\n\n¿Cuántas veces lloraste en privado?\n¿Cuántas veces sonreíste en público?\n\n[TU EDITOR]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
            {
              'title': 'Fragmento 3.2: Miguel (Pereza)',
              'description': 'ADJUNTO: RECETA_ANSIOLITICOS.PDF\n\nPACIENTE: [TACHADO]\nMEDICAMENTO: ALPRAZOLAM 2MG\nMOTIVO: TRASTORNO DE ANSIEDAD GENERALIZADA\n\nMiguel te dijo: "Tómalas solo cuando sea necesario"\nPero tú las tomabas todos los días.\nPorque era más fácil que enfrentar la realidad.\n\nLa sobredosis no fue accidental. Fue pereza emocional.\n\n[TU PSIQUIATRA]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
            {
              'title': 'Fragmento 3.3: Audio de Discusión',
              'description': 'ADJUNTO: AUDIO_DISCUSION.MP3\n\nVOZ: "¡NO NECESITABA UN VIDEO EN SU HONOR, ALEX!"\nVOZ: "¡NECESITABA QUE ESTUVIERAS CON ÉL!"\nVOZ: "¡TE NECESITABA!"\n\n[LLANTO]\nVOZ: "¿Por qué no contestaste? ¿Por qué nunca contestas?"\n[RUIDO BLANCO]\n\nAlguien rompió a llorar. La grabación se cortó.\n\n[EL SISTEMA]',
              'hint': 'Continúa avanzando en el arco para desbloquear.',
            },
          ];
        } else if (arcId == 'arc_4_ira') {
          return [
            {
              'title': 'Fragmento 4.1: Informe Médico',
              'description': 'ADJUNTO: INFORME_MEDICO_HOSPITAL_GENERAL.PDF\n\nPACIENTE: ALEX TORRES\nEDAD: 22 AÑOS\nFECHA: 14 DE NOVIEMBRE, 03:47 AM\nMOTIVO DE INGRESO: SOBREDOSIS DE BENZODIACEPINAS\n\nESTADO: INCONSCIENTE. PULSO DÉBIL.\nDIAGNÓSTICO: INTENTO DE SUICIDIO. COMA INDUCIDO.\n\nTu madre firmó los papeles.\nElla no sabe que fue intencional.\n\n[HOSPITAL GENERAL]',
              'hint': 'Completa la primera fase del Arco 4',
            },
            {
              'title': 'Fragmento 4.2: Última Captura',
              'description': 'ADJUNTO: CAPTURA_TELEFONO.JPG\nREGISTRO DE LLAMADAS - 14 DE NOVIEMBRE\n\n02:47 - ALEX (NO CONTESTÓ)\n[13 LLAMADAS OMITIDAS]\n03:15 - ALEX (NO CONTESTÓ)\n\nESTABAS EN VIVO. 12,847 ESPECTADORES.\nTU HERMANO MENOR MURIÓ A LAS 03:15. VÍCTOR TENÍA 17 AÑOS.\n\n[LA POLICÍA] DIJO QUE BUSCARAN SU TELÉFONO.\n[LA POLICÍA] DIJO QUE LA VENTAJA FUE QUE QUEDÓ REGISTRADO.\n[LA POLICÍA] DIJO QUE TÚ FUISTE LA ÚLTIMA PERSONA A LA QUE LLAMÓ.',
              'hint': 'Completa la segunda fase del Arco 4',
            },
            {
              'title': 'Fragmento 4.3: ÚLTIMO VIDEO',
              'description': 'ADJUNTO: ESTADISTICAS_VIDEO.PDF\n\n"EN HONOR A MI HERMANO MENOR VÍCTOR"\nVISTAS: 2,047,583 | MONETIZACIÓN: ✓ ACTIVA\nANUNCIOS: ✓ EN TODOS LOS PUNTOS\nINGRESOS TOTALES: \$12,450 USD\n\nCOMENTARIO MÁS POPULAR:\n"Qué hermano mayor tan valiente. Víctor estaría orgulloso ❤️"\n\n[RISA DEL JUEZ]\nLOS ANUNCIOS SIGUEN ACTIVOS.\n\n[YOUTUBE ANALYTICS]',
              'hint': 'Limpia el ruido para encontrar la verdad',
            },
            {
              'title': 'Fragmento 4.4: Sentencia de Culpa',
              'description': 'ADJUNTO: TRANSCRIPCIÓN_MIND_HACK_V9\n\n"YO LO MATÉ. FUE MI CULPA. LO IGNORÉ."\n\nEstas palabras no fueron escritas por el sistema.\nFueron extraídas de lo más profundo de tu subconsciente.\nPor fin has dejado de culpar al algoritmo.\nPor fin estás aceptando el peso de tus decisiones.\n\n[TU PROPIA VOZ]',
              'hint': 'Acepta tu responsabilidad en la fase 4',
            },
            {
              'title': 'Fragmento 4.5: El Latido Final',
              'description': 'ADJUNTO: REGISTRO_ECG_ESTABLE.LOG\n\nEl monitor ya no pita en un tono constante.\nHay un ritmo. Hay una voluntad.\nHas decidido que no quieres que este sea el final de tu historia.\nNo es por los seguidores. No es por la fama.\nEs por Víctor. Es por volver a ser humano.\n\n[EL DESPERTAR]',
              'hint': 'Sincroniza tu corazón en la fase final',
            },
          ];
        }

        // Default genérico
        return List.generate(10, (index) => {
          'title': 'Fragmento ${index + 1}',
          'description': 'Datos cifrados. Requiere mayor nivel de sincronización.',
          'hint': 'Continúa avanzando en el arco para desbloquear.',
        });
    }
  }
}
