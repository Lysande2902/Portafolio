import 'package:flutter/material.dart';

class SubjectData {
  final String id;
  final String name;
  final String codename;
  final Map<int, String> narrativesByLevel; // Narrativas por nivel de sincronización
  final Map<int, String> statusByLevel; // Estado por nivel
  final Map<int, String> integrityByLevel; // Integridad por nivel
  final String imagePath;
  final Color themeColor;
  final String arcLabel;
  final String sin;
  final int minLevelToShow; // Nivel mínimo para que aparezca este sujeto

  const SubjectData({
    required this.id,
    required this.name,
    required this.codename,
    required this.narrativesByLevel,
    required this.statusByLevel,
    required this.integrityByLevel,
    required this.imagePath,
    required this.arcLabel,
    required this.sin,
    this.themeColor = const Color(0xFF8B0000),
    this.minLevelToShow = 1, // Por defecto, aparece desde nivel 1
  });
  
  String _getFallback(Map<int, String> map, int level, String defaultVal) {
    if (map.containsKey(level)) return map[level]!;
    int bestKey = -1;
    for (int key in map.keys) {
      if (key <= level && key > bestKey) bestKey = key;
    }
    if (bestKey != -1) return map[bestKey]!;
    var allKeys = map.keys.toList()..sort();
    return allKeys.isNotEmpty ? (map[allKeys.last] ?? defaultVal) : defaultVal;
  }

  String getNarrativeForLevel(int level) => _getFallback(narrativesByLevel, level, "");
  String getStatusForLevel(int level) => _getFallback(statusByLevel, level, "DESCONOCIDO");
  String getIntegrityForLevel(int level) => _getFallback(integrityByLevel, level, "█████");
}

final List<SubjectData> subjectsRegistry = [

  // === ALEX: EL SUJETO ===
  const SubjectData(
    id: 'AL_00',
    name: 'ALEX',
    codename: 'EL SUJETO',
    arcLabel: 'PROTOCOLO: ORIGEN',
    sin: 'TODOS',
    imagePath: 'assets/images/Alex.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 1,
    statusByLevel: {
      1: 'DESC█N█CID█',
      2: 'C█MA_PR█FUND█',
      3: 'COMA_PROFUNDO',
      5: 'COMA_PROFUNDO',
    },
    integrityByLevel: {
      1: '█0%_FR█GM█NT█D█',
      2: '100%_FR█GM█NT█D█',
      3: '100%_FRAGMENTADO',
      5: '100%_FRAGMENTADO',
    },
    narrativesByLevel: {
      1:
          'Alguien está mirando.\n\n'
          'Siempre ha habido alguien mirando.\n\n'
          'Los datos están fragmentados. Corruptos. Incompletos.\n\n'
          'No recuerdas quién eres. Tampoco importa.\n'
          'Lo que importa es lo que hiciste cuando nadie... miraba.\n\n'
          'O cuando todos miraban.\n\n'
          '[ERR SYNC INSUFFICIENT]\n'
          '[LIBRE_ALBEDRIO: DETECTADO]\n'
          '[ADVERTENCIA: No intentes recordar todavía]',
      
      2:
          'Empiezas a entender.\n\n'
          'Hay una cama. Hay monitores. Hay silencio.\n\n'
          'Esto no es un sueño. Nunca lo fue.\n\n'
          'Eres el juicio y el crimen en el mismo cuerpo.\n'
          'Cada arco que juegas es una excusa que construiste.\n'
          'Cada puzzle es una verdad que bloqueaste.\n\n'
          '[ANOMALÍA: Señal externa detectada]\n'
          '[ORIGEN: V DE █████]\n'
          '[TIPO: Llamadas sin respuesta]\n'
          '[NOTA: Esto no debería estar aquí]',
      
      3:
          'Llevas 72 horas aquí.\n\n'
          'Hay una pantalla en tu mano. Rota.\n'
          'Los médicos intentaron quitártela.\n'
          'Tu corazón casi se detiene cada vez.\n\n'
          'Los humanos no son ángeles.\n'
          'Tampoco demonios.\n'
          'Son testigos con libre albedrío.\n\n'
          'Tú elegiste ser testigo de 12,847 desconocidos.\n'
          'Y no ser testigo de uno solo.\n\n'
          '[ANOMALÍA: V DE VÍCTOR]\n'
          '[ESTADO: Sin respuesta]\n'
          '[PREGUNTA: ¿Por qué no contestaste?]',
      
      5:
          '72 horas.\n\n'
          'Una nota de voz. 9 segundos. Sin abrir.\n\n'
          'Cuando llegue el final,\n'
          'cuando todo arda y nadie mire…\n\n'
          'La pregunta no es si les temes.\n\n'
          'La pregunta es:\n'
          '¿qué parte de ti querrás que sea vista?\n\n'
          '12,847 personas te miraban esa noche.\n'
          'Ninguna sabe tu apellido.\n\n'
          'Él sí lo sabía. Y ya no puede decírtelo.\n\n'
          '[ANOMALÍA: V DE VÍCTOR - RESUELTO]\n'
          '[15 llamadas sin respuesta]\n'
          '["Esta semana no puedo, tengo grabaciones"]',
    },
  ),

  // === LOS 6 PECADOS ABSTRACTOS ===
  // Estos NO son personas reales, son facetas de Alex
  // Sus fotos están PERMANENTEMENTE CENSURADAS
  
  // === LUCÍA: EL CAMALEÓN (ENVIDIA) ===
  const SubjectData(
    id: 'LU_01',
    name: 'LUCÍA',
    codename: 'EL CAMALEÓN',
    arcLabel: 'PROTOCOLO 1: ENVIDIA',
    sin: 'ENVIDIA',
    imagePath: 'assets/images/censored_image.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 2,
    statusByLevel: {
      2: 'FRAGMENTO',
      3: 'FRAGMENTO',
      4: 'FRAGMENTO',
    },
    integrityByLevel: {
      2: '0%_ILUSIÓN',
      3: '0%_ILUSIÓN',
      4: '0%_ILUSIÓN',
    },
    narrativesByLevel: {
      2:
          'Lucía no existe.\n\n'
          'Es una parte de ti que eligió ser otra persona.\n\n'
          'Los humanos no son ángeles.\n'
          'Tampoco demonios.\n'
          'Son testigos con libre albedrío.\n\n'
          'Tú elegiste mirar a otros en lugar de mirarte a ti mismo.\n'
          'Querías lo que tenían. La fama. Los seguidores. La pantalla brillante.\n\n'
          '¿Quién eres cuando nadie te mira?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[LIBRE_ALBEDRIO: EJERCIDO — CONSECUENCIA: IRREVERSIBLE]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
      3:
          'Lucía no existe.\n\n'
          'Es una parte de ti que eligió ser otra persona.\n\n'
          'Los humanos no son ángeles.\n'
          'Tampoco demonios.\n'
          'Son testigos con libre albedrío.\n\n'
          'Tú elegiste mirar a otros en lugar de mirarte a ti mismo.\n'
          'Querías lo que tenían. La fama. Los seguidores. La pantalla brillante.\n\n'
          '¿Quién eres cuando nadie te mira?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[LIBRE_ALBEDRIO: EJERCIDO — CONSECUENCIA: IRREVERSIBLE]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
      4:
          'Lucía no existe.\n\n'
          'Es una parte de ti que eligió ser otra persona.\n\n'
          'Los humanos no son ángeles.\n'
          'Tampoco demonios.\n'
          'Son testigos con libre albedrío.\n\n'
          'Tú elegiste mirar a otros en lugar de mirarte a ti mismo.\n'
          'Querías lo que tenían. La fama. Los seguidores. La pantalla brillante.\n\n'
          '¿Quién eres cuando nadie te mira?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[LIBRE_ALBEDRIO: EJERCIDO — CONSECUENCIA: IRREVERSIBLE]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
    },
  ),

  // === ADRIANA: LA ARAÑA (LUJURIA) ===
  const SubjectData(
    id: 'AD_02',
    name: 'ADRIANA',
    codename: 'LA ARAÑA',
    arcLabel: 'PROTOCOLO 2: LUJURIA',
    sin: 'LUJURIA',
    imagePath: 'assets/images/censored_image.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 2,
    statusByLevel: {
      2: 'FRAGMENTO',
      3: 'FRAGMENTO',
      4: 'FRAGMENTO',
    },
    integrityByLevel: {
      2: '0%_ILUSIÓN',
      3: '0%_ILUSIÓN',
      4: '0%_ILUSIÓN',
    },
    narrativesByLevel: {
      2:
          'Adriana es tu juicio disfrazado de deseo.\n\n'
          'No quieres a una persona. Quieres que te vean.\n\n'
          'Son el juicio y el crimen en el mismo cuerpo.\n\n'
          'Tú eres el juicio: exiges atención.\n'
          'Tú eres el crimen: la consumes y la descartas.\n\n'
          'Cada like es un veredicto.\n'
          'Cada view es un testigo pasivo.\n\n'
          '¿Cuánto vale tu dignidad en suscriptores?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[JUICIO: DICTADO — CRIMEN: REGISTRADO]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
      3:
          'Adriana es tu juicio disfrazado de deseo.\n\n'
          'No quieres a una persona. Quieres que te vean.\n\n'
          'Son el juicio y el crimen en el mismo cuerpo.\n\n'
          'Tú eres el juicio: exiges atención.\n'
          'Tú eres el crimen: la consumes y la descartas.\n\n'
          'Cada like es un veredicto.\n'
          'Cada view es un testigo pasivo.\n\n'
          '¿Cuánto vale tu dignidad en suscriptores?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[JUICIO: DICTADO — CRIMEN: REGISTRADO]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
      4:
          'Adriana es tu juicio disfrazado de deseo.\n\n'
          'No quieres a una persona. Quieres que te vean.\n\n'
          'Son el juicio y el crimen en el mismo cuerpo.\n\n'
          'Tú eres el juicio: exiges atención.\n'
          'Tú eres el crimen: la consumes y la descartas.\n\n'
          'Cada like es un veredicto.\n'
          'Cada view es un testigo pasivo.\n\n'
          '¿Cuánto vale tu dignidad en suscriptores?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[JUICIO: DICTADO — CRIMEN: REGISTRADO]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
    },
  ),

  // === MATEO: EL CERDO (GULA) ===
  const SubjectData(
    id: 'MA_03',
    name: 'MATEO',
    codename: 'EL CERDO',
    arcLabel: 'PROTOCOLO 3: GULA',
    sin: 'GULA',
    imagePath: 'assets/images/censored_image.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 3,
    statusByLevel: {
      3: 'FRAGMENTO',
      4: 'FRAGMENTO',
    },
    integrityByLevel: {
      3: '0%_ILUSIÓN',
      4: '0%_ILUSIÓN',
    },
    narrativesByLevel: {
      3:
          'Mateo es tu nunca es suficiente.\n\n'
          'No de comida. De más.\n\n'
          'La pregunta no es si les temes.\n\n'
          'La pregunta es:\n'
          'cuando llegue el final,\n'
          'cuando todo arda y nadie mire…\n\n'
          '¿habrá valido la pena consumirlo todo?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[CONSUMO: TOTAL — QUEDA: NADA]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
      4:
          'Mateo es tu nunca es suficiente.\n\n'
          'No de comida. De más.\n\n'
          'La pregunta no es si les temes.\n\n'
          'La pregunta es:\n'
          'cuando llegue el final,\n'
          'cuando todo arda y nadie mire…\n\n'
          '¿habrá valido la pena consumirlo todo?\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[CONSUMO: TOTAL — QUEDA: NADA]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
    },
  ),

  // === VALERIA: LA RATA (CODICIA) ===
  const SubjectData(
    id: 'VA_04',
    name: 'VALERIA',
    codename: 'LA RATA',
    arcLabel: 'PROTOCOLO 4: CODICIA',
    sin: 'CODICIA',
    imagePath: 'assets/images/censored_image.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 3,
    statusByLevel: {
      3: 'FRAGMENTO',
      4: 'FRAGMENTO',
    },
    integrityByLevel: {
      3: '0%_ILUSIÓN',
      4: '0%_ILUSIÓN',
    },
    narrativesByLevel: {
      3:
          'Valeria es tu precio.\n\n'
          'Todo tiene un costo.\n'
          'Incluso las personas.\n\n'
          '¿qué parte de ti querrás que sea vista?\n\n'
          'La que puso una donación por encima de una llamada.\n'
          'La que eligió un sponsor sobre su hermano.\n\n'
          'No eres malvado.\n'
          'Solo elegiste. Cada día. Con libre albedrío.\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[PRECIO_PAGADO: IRRECUPERABLE]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
      4:
          'Valeria es tu precio.\n\n'
          'Todo tiene un costo.\n'
          'Incluso las personas.\n\n'
          '¿qué parte de ti querrás que sea vista?\n\n'
          'La que puso una donación por encima de una llamada.\n'
          'La que eligió un sponsor sobre su hermano.\n\n'
          'No eres malvado.\n'
          'Solo elegiste. Cada día. Con libre albedrío.\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[PRECIO_PAGADO: IRRECUPERABLE]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
    },
  ),

  // === CARLOS: EL LEÓN (SOBERBIA) ===
  const SubjectData(
    id: 'CA_05',
    name: 'CARLOS',
    codename: 'EL LEÓN',
    arcLabel: 'PROTOCOLO 5: SOBERBIA',
    sin: 'SOBERBIA',
    imagePath: 'assets/images/censored_image.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 4,
    statusByLevel: {
      4: 'FRAGMENTO',
    },
    integrityByLevel: {
      4: '0%_ILUSIÓN',
    },
    narrativesByLevel: {
      4:
          'Carlos es tu voz interna.\n\n'
          'La que dice: "Ellos no entienden."\n'
          'La que dice: "Yo soy más importante."\n'
          'La que dice: "Puedo hacerlo después."\n\n'
          'Los humanos no son ángeles. Tampoco demonios.\n\n'
          'Son testigos con libre albedrío.\n\n'
          'Tú fuiste testigo de 12,847 desconocidos.\n'
          'No fuiste testigo de uno solo.\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[ELECCION: DOCUMENTADA — VEREDICTO: PENDIENTE]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
    },
  ),

  // === MIGUEL: LA BABOSA (PEREZA) ===
  const SubjectData(
    id: 'MI_06',
    name: 'MIGUEL',
    codename: 'LA BABOSA',
    arcLabel: 'PROTOCOLO 6: PEREZA',
    sin: 'PEREZA',
    imagePath: 'assets/images/censored_image.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 4,
    statusByLevel: {
      4: 'FRAGMENTO',
    },
    integrityByLevel: {
      4: '0%_ILUSIÓN',
    },
    narrativesByLevel: {
      4:
          'Miguel es tu silencio activo.\n\n'
          'No es no hacer nada.\n'
          'Es elegir, conscientemente, no hacer.\n\n'
          'Libre albedrío.\n\n'
          '15 llamadas. 9 segundos de voz. Cero respuestas.\n\n'
          'Cuando llegue el final,\n'
          'cuando todo arda y nadie mire…\n\n'
          'el silencio que elegiste seguirá ardiendo.\n\n'
          '[FRAGMENTO PSICOLÓGICO]\n'
          '[ACCION: OMISION — CONSECUENCIA: PERMANENTE]\n'
          '[NOTA: Este testigo no es real. Tú sí.]',
    },
  ),

  // === VÍCTOR: LA VERDAD (7MO PECADO - IRA) ===
  // IMPORTANTE: Víctor ES el 7mo pecado capital (IRA)
  // A diferencia de los otros 6 pecados (abstractos), Víctor es REAL
  // Es el hermano menor de Alex (17 años) que murió
  // Representa la IRA de la VERDAD que no puede ser ignorada
  const SubjectData(
    id: 'VI_07',
    name: 'VÍCTOR',
    codename: 'LA VERDAD',
    arcLabel: 'PROTOCOLO 4: IRA — LA CASA EN LLAMAS',
    sin: 'IRA',
    imagePath: 'assets/images/Victor_template.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 2, // Aparece desde nivel 2
    statusByLevel: {
      2: 'IRR█CUP█R█BL█',
      3: 'IRRECUPERABLE',
      5: 'IRRECUPERABLE',
    },
    integrityByLevel: {
      2: '█00%_R█AL',
      3: '100%_REAL',
      5: '100%_REAL',
    },
    narrativesByLevel: {
      2: // NIVEL 2: Después de Arco 1 - ALTAMENTE CORRUPTO
          '█████ no es un pecado.\n\n'
          'No es un reflejo. No es una metáfora.\n\n'
          'Es tu h█rm█n█.\n\n'
          'Y hay algo que no cuadra.\n\n'
          '[ERR MEMORIA BLOQUEADA]\n'
          '[ACCESO DENEGADO: Requiere Protocolo 4]\n'
          '[NOTA: Algunos datos no deberían estar aquí]',
      
      3: // NIVEL 3: Después de Arcos 2-3 - PARCIALMENTE VISIBLE
          'Víctor.\n\n'
          'No es un pecado. No es un símbolo. No es parte de tu psique fragmentada.\n\n'
          'Es real. O lo fue.\n\n'
          'Te llamó ████████ veces. Entre las ██:██ y las ██:██.\n\n'
          'Tú estabas ████████████.\n\n'
          '¿Por qué no contestaste?\n\n'
          '[MEMORIA BLOQUEADA]\n'
          '[ACCESO PARCIAL: 70%]\n'
          '[ADVERTENCIA: Protocolo 4 revelará consecuencias]',
      
      5: // NIVEL 5: Después de Arco 4 - REVELACIÓN COMPLETA
          'Víctor.\n\n'
          '17 años. Tu hermano menor.\n\n'
          'Quince llamadas. 02:47 a 03:15. Madrugada del 14 de noviembre.\n\n'
          'Tú: En vivo. 12,847 espectadores. Ninguno sabe tu apellido.\n\n'
          'Él: Dejó una nota de voz. 9 segundos. Sin abrir. Azul.\n\n'
          'Tus mensajes del lunes: "Esta semana no puedo, tengo grabaciones."\n\n'
          'Él los leyó. Todos.\n\n'
          'Magnolia lleva 72 horas sentada junto a ti. '
          'No espera para perdonarte. '
          'Espera para decirte que Víctor ya no está.\n\n'
          'La Casa en Llamas no ardió por rabia.\n'
          'Ardió por silencio.\n\n'
          'El tuyo.\n\n'
          '[PREGUNTA FINAL:]\n'
          '[Cuando despiertes, ¿qué harás primero?]\n'
          '[¿Encender la cámara?]\n'
          '[¿O llamar a quien te quiere de verdad?]',
    },
  ),

  // === MAGNOLIA: EL ANCLA ===
  const SubjectData(
    id: 'MA_08',
    name: 'MAGNOLIA',
    codename: 'EL ANCLA',
    arcLabel: 'PROTOCOLO: DESPERTAR',
    sin: 'NINGUNO',
    imagePath: 'assets/images/Magnolia_template.png',
    themeColor: Color(0xFF8B0000),
    minLevelToShow: 3, // Aparece desde nivel 3
    statusByLevel: {
      3: 'PR█S█NT█',
      5: 'PRESENTE',
    },
    integrityByLevel: {
      3: '█00%_█NT█CT█',
      5: '100%_INTACTA',
    },
    narrativesByLevel: {
      3: // NIVEL 3: Después de Arcos 2-3 - IDENTIDAD CLASIFICADA
          '████████.\n\n'
          'No está en tu simulación. Está en la habitación 304.\n\n'
          '72 horas. Sin dormir. Con tu teléfono en la mano.\n\n'
          'Lo leyó todo.\n\n'
          'No te odia.\n\n'
          'Debería.\n\n'
          '[IDENTIDAD: CLASIFICADO]\n'
          '[RELACIÓN: CLASIFICADO]\n'
          '[ACCESO DENEGADO: Requiere Protocolo 4]\n'
          '[NOTA: Ella sabe quién eres realmente]',
      
      5: // NIVEL 5: Después de Arco 4 - REVELACIÓN FINAL: ES LA MADRE
          'Magnolia Torres.\n\n'
          'Habitación 304. Silla de plástico verde que rechina. '
          '72 horas. 20 minutos de sueño.\n\n'
          'Desbloqueó tu teléfono. Con tu huella. Mientras dormías.\n\n'
          'Leyó los quince mensajes de Víctor.\n'
          'Escuchó la nota de voz que nunca abriste.\n'
          'Vio tu calendario: "STREAM - 8PM" marcado en rojo.\n\n'
          'El mismo día.\n\n'
          'No te odia. Eso sería más simple.\n\n'
          'Espera. Porque alguien tiene que decirte la verdad.\n'
          'Alguien tiene que ser testigo.\n\n'
          'Magnolia es la única persona aquí que sabe exactamente quién eres.\n\n'
          'Y sigue aquí.\n\n'
          '[REGISTRO MÉDICO: VISITANTE #1]\n'
          '[NOMBRE: Magnolia Torres]\n'
          '[RELACIÓN: Madre]\n'
          '[TIEMPO EN SALA: 72h continuas]\n'
          '[NOTA: Perdió un hijo. Espera al otro.]',
    },
  ),
];
