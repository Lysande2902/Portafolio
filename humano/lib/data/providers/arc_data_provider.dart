import '../models/arc.dart';
import '../models/arc_content.dart';

class ArcDataProvider {
  static final List<Arc> allArcs = [
    Arc(
      id: 'arc_0_inicio',
      number: 0,
      title: 'EL INICIO',
      subtitle: 'Donde todo comenzó antes del ruido',
      description: 'El primer contacto. La primera vez que alguien llamó y no contestaste.',
      thumbnailPath: 'assets/images/arcs/inicio_thumb.png',
      isUnlockedByDefault: true,
      unlockRequirements: [],
    ),
    Arc(
      id: 'arc_1_envidia_lujuria',
      number: 1,
      title: 'ENVIDIA Y LUJURIA',
      subtitle: 'Los espejos mienten cuando decides creerles',
      description: 'Filtros, likes y la identidad que vendiste para parecer álguien más.',
      thumbnailPath: 'assets/images/arcs/envidia_lujuria_thumb.png',
      isUnlockedByDefault: false,
      unlockRequirements: ['arc_0_inicio'],
    ),
    Arc(
      id: 'arc_2_consumo_codicia',
      number: 2,
      title: 'CONSUMO Y CODICIA',
      subtitle: 'El vacío no se llena con cajas',
      description: 'Todo tenía un precio. Lo que no sabías es cuánto costó de verdad.',
      thumbnailPath: 'assets/images/arcs/consumo_codicia_thumb.png',
      isUnlockedByDefault: false,
      unlockRequirements: ['arc_1_envidia_lujuria'],
    ),
    Arc(
      id: 'arc_3_soberbia_pereza',
      number: 3,
      title: 'SOBERBIA Y PEREZA',
      subtitle: 'Cuando el show termina, nadie te espera',
      description: 'El ruido del ego y el silencio del agotamiento. El estudio nunca fue tu hogar.',
      thumbnailPath: 'assets/images/arcs/soberbia_pereza_thumb.png',
      isUnlockedByDefault: false,
      unlockRequirements: ['arc_2_consumo_codicia'],
    ),
    Arc(
      id: 'arc_4_ira',
      number: 4,
      title: 'IRA',
      subtitle: 'El fuego que no se puede editar',
      description: 'La confrontación con Víctor. La llamada que ignoraste. La verdad sin filtros.',
      thumbnailPath: 'assets/images/arcs/ira_thumb.png',
      isUnlockedByDefault: false,
      unlockRequirements: ['arc_3_soberbia_pereza'],
    ),
  ];

  Arc? getArcById(String id) {
    try {
      return allArcs.firstWhere((arc) => arc.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Arc> getAllArcs() {
    return List.unmodifiable(allArcs);
  }

  // Arc-specific content for briefings, game over, and victory screens
  static final Map<String, ArcContent> _arcContent = {
    'arc_0_inicio': ArcContent(
      arcId: 'arc_0_inicio',
      arcNumber: '0',
      title: 'EL INICIO',
      subtitle: 'Donde todo comenzó antes del ruido',
      briefing: BriefingContent(
        objective: 'ESTADO: COMA PROFUNDO\nRE CONEXIÓN NEURONAL\n\nNo es una investigación externa. Es el acceso al núcleo de tu propia culpa. Sincroniza los pedazos antes de que el olvido sea definitivo.',
        mechanicTitle: 'EL JUICIO',
        mechanicDescription: 
          '5 Etapas de estabilización: Handshake, Tono de Conciencia, Purga de Negación, Paquetes de Memoria y Aceptación.\n\n'
          'El sistema registrará cada momento en que decidiste no ver la verdad.',
        controls: 'Pantalla táctil: pulsa y desliza',
        tip: 'Si escuchas su voz, no te detengas. Magnolia es lo único que nos ata a la superficie.',
        phaseNames: ['Handshake', 'Conciencia', 'Purga', 'Memoria', 'Aceptación'],
      ),
      gameOver: GameOverContent(
        messages: [
          "SINCRONIZACIÓN FALLIDA. NÚcleo de culpa inestable.",
          "NO ESTÁS AQUÍ PARA GANAR. ESTÁS AQUÍ PARA SER JUZGADO.",
          "EL SISTEMA NO PERDONA. MAGNOLIA TAMPOCO.",
          "VÍCTOR SÍ RECUERDA EL SONIDO DE LA ALARMA.",
          "NO PUEDES DOCUMENTAR TU PROPIA MUERTE.",
          "MAGNOLIA TE ESTÁ PERDIENDO. OTRA VEZ.",
          "NADIE ESPERA EN EL OTRO LADO SI SIGUES HUYENDO.",
          "TU INTEGRIDAD ES TAN FRÁGIL COMO TUS PROMESAS.",
        ],
        flavorTexts: [
          "Tu persistencia es adorablemente inútil.",
          "El hospital no cobra por intentos fallidos.",
          "Magnolia no puede detenerse a llorar cada vez que fallas.",
          "El sistema tiene paciencia infinita. Tú no.",
        ],
      ),
      victory: VictoryContent(
        cinematicLines: [
          'ÅL€X.\n\n€STÁS €N CØMÅ.\n\n€STØ NØ €S UN SU€ÑØ.\n\n€STØ €S €Ł JU_#_ICIØ.',
        ],
        stats: [
          StatConfig(key: 'evidenceCollected', label: 'FRAGMENTOS RECOLECTADOS', formatter: (v) => '$v de 5'),
          StatConfig(key: 'sanity', label: 'CORDURA AL FINAL', formatter: (v) => '${(v * 100).toInt()}%'),
          StatConfig(key: 'playTime', label: 'TIEMPO EN EL JUICIO', formatter: (v) {
            final seconds = v as double;
            final minutes = (seconds / 60).floor();
            final secs = (seconds % 60).floor();
            return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
          }),
          StatConfig(key: 'followersEarned', label: 'SEGUIDORES GANADOS', formatter: (v) => '+$v'),
        ],
      ),
    ),
    'arc_1_envidia_lujuria': ArcContent(
      arcId: 'arc_1_envidia_lujuria',
      arcNumber: '1',
      title: 'ENVIDIA Y LUJURIA',
      subtitle: 'Los espejos mienten cuando decides creerles',
      briefing: BriefingContent(
        objective: 'LECTURA DE MEMORIA: REFLEJOS\nEL JUICIO DE LA IMAGEN\n\nIdentifica las mentiras en el feed y limpia la validación falsa antes de que el espejo te devore. Lucía y Adriana te esperan.',
        mechanicTitle: 'IDENTIDAD EN FRAGMENTOS',
        mechanicDescription: 
          '3 Fases: Filtro de Identidad, Red de Validación y Espejo Roto.\n\n'
          'La obsesión por la imagen genera fallos. Mantén el foco en quién eres de verdad.',
        controls: 'Pantalla táctil: toca, desliza, elimina',
        tip: 'Magnolia solía verte sin filtros. Estos reflejos son parásitos de tu propia voz. Rómpelos todos.',
        phaseNames: ['Identidad', 'Validación', 'Espejo Roto'],
      ),
      gameOver: GameOverContent(
        messages: [
          "INCLUSO AQUÍ, LUCÍA SE VE MEJOR QUE TÚ. ELLA NO ES UN CADÁVER EN COMA.",
          "ADRIANA DEJÓ DE BUSCARTE CUANDO DEJASTE DE BRILLAR PARA EL ALGORITMO.",
          "NADIE TE ESTÁ MIRANDO AHORA, ALEX. SOLO MAGNOLIA... Y ELLA ESTÁ LLORANDO.",
          "¿CUÁNTOS LIKES VALE TU ALMA HOY? EL SISTEMA DICE: CERO.",
          "LUCÍA TERMINÓ LA CARRERA. TÚ TERMINASTE EN COMA.",
          "ADRIANA VENDIÓ SU CUERPO. TÚ VENDISTE TU ALMA. ¿QUIÉN GANÓ?",
          "EL ESPEJO ESTÁ ROTO. TÚ TAMBIÉN.",
          "MAGNOLIA NO RECONOCE TU ROSTRO. DEMASIADOS FILTROS.",
        ],
        flavorTexts: [
          "Tu reflejo tiene más seguidores que tú.",
          "El gimnasio cerró. Tú nunca saliste.",
          "Lucía se cortó la cara para parecerse a ti. Irónico.",
          "Adriana cobra por hora. Tú regalaste tu dignidad.",
        ],
      ),
      victory: VictoryContent(
        cinematicLines: [
          'LUCÍÅ S€ CØRTÓ ŁÅ CÅRÅ PÅRÅ PÅR€C€RS€ Å TI.',
          'ÅĐRIÅNÅ V€NĐIÓ SU CU€RPØ PØR TU ÅŁGØRITM_#_Ø.',
          'TÚ CØMPRÅST€ €Ł R€CIBØ Đ€ SU Đ€STRUCCI_#_ÓN.',
          '¿QUIÉN MI_#_RÅ R€ÅŁM€NT€?',
          'VÍCTØR ĐIĐ NØT ŁI_#_K€ ĐIS.',
        ],
        stats: [
          StatConfig(key: 'evidenceCollected', label: 'FRAGMENTOS DE EGO', formatter: (v) => '$v de 3'),
          StatConfig(key: 'sanity', label: 'AUTOESTIMA REAL', formatter: (v) => '${(v * 100).toInt()}%'),
          StatConfig(key: 'playTime', label: 'TIEMPO EN EL JUICIO', formatter: (v) {
            final seconds = v as double;
            final minutes = (seconds / 60).floor();
            final secs = (seconds % 60).floor();
            return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
          }),
          StatConfig(key: 'followersEarned', label: 'SEGUIDORES GANADOS', formatter: (v) => '+$v'),
        ],
      ),
    ),
    'arc_2_consumo_codicia': ArcContent(
      arcId: 'arc_2_consumo_codicia',
      arcNumber: '2',
      title: 'CONSUMO Y CODICIA',
      subtitle: 'El vacío no se llena con cajas',
      briefing: BriefingContent(
        objective: 'MEMORIA: EL ALMACÉN\nEL JUICIO DEL OBJETO\n\nEl vacío no se llena con cajas. Clasifica el exceso y equilibra las cuentas antes de que el peso de tus posesiones te entierre.',
        mechanicTitle: 'LO QUE TOMASTE',
        mechanicDescription: 
          '3 Fases: Intercepción de Carga, Balance de Cuentas y Purga de Exceso.\n\n'
          'Los objetos acumulados ralentizan el sistema. Mantén el equilibrio para sobrevivir.',
        controls: 'Pantalla táctil: clasifica, balancea, purga',
        tip: 'Magnolia recuerda estas cajas. Eran el ataúd de tu autenticidad. No dejes que se acumulen.',
        phaseNames: ['Carga', 'Balance', 'Purga'],
      ),
      gameOver: GameOverContent(
        messages: [
          "MATEO SE AHOGÓ EN TU UNBOXING. ¿TE GUSTÓ EL RING LIGHT QUE COMPRASTE CON SU AIRE?",
          "VALERIA TE DIO LA IDEA. TÚ LE DISTE EL OLVIDO. BUEN TRATO.",
          "TU CUENTA ESTÁ EN ROJO, ALEX. TU ALMA TAMBIÉN.",
          "¿AÚN CREES QUE PUEDES COMPRAR TU SALIDA DEL COMA?",
          "MAGNOLIA ESTÁ VENDIENDO LO QUE QUEDA DE TI PARA PAGAR TUS DEUDAS.",
          "MATEO COMIÓ SOLO. TÚ COMISTE FRENTE A 12,000 PERSONAS. ¿QUIÉN ESTABA MÁS SOLO?",
          "VALERIA HIZO EL TRABAJO. TÚ TE QUEDASTE CON EL 100%. MATEMÁTICA SIMPLE.",
          "EL ALMACÉN ESTÁ LLENO. TU ALMA ESTÁ VACÍA.",
        ],
        flavorTexts: [
          "El cartero dejó de sonreír. Las cajas no paraban de llegar.",
          "Compraste 3 micrófonos. Ninguno grabó la verdad.",
          "Valeria te perdonó. El sistema no.",
          "Mateo murió de hambre emocional. Tú de gula digital.",
        ],
      ),
      victory: VictoryContent(
        cinematicLines: [
          'MÅT€Ø CØMÍÅ SØŁØ MI€NTRÅS TÚ GRÅBÅS.',
          'VÅŁ€RIÅ T€ ĐIØ IĐ€ÅS. TÚ Ł€ ĐIST€ ØŁVIĐØ.',
          'TØĐØ TI€N€ UN PR€_#_CIØ.',
          '¿CUÁNTØ VÅŁ€ UNÅ ŁŁÅMÅĐÅ?',
        ],
        stats: [
          StatConfig(key: 'evidenceCollected', label: 'EVIDENCIAS DE CONSUMO', formatter: (v) => '$v de 3'),
          StatConfig(key: 'sanity', label: 'CORDURA AL FINAL', formatter: (v) => '${(v * 100).toInt()}%'),
          StatConfig(key: 'playTime', label: 'TIEMPO EN EL JUICIO', formatter: (v) {
            final seconds = v as double;
            final minutes = (seconds / 60).floor();
            final secs = (seconds % 60).floor();
            return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
          }),
          StatConfig(key: 'followersEarned', label: 'SEGUIDORES GANADOS', formatter: (v) => '+$v'),
        ],
      ),
    ),
    'arc_3_soberbia_pereza': ArcContent(
      arcId: 'arc_3_soberbia_pereza',
      arcNumber: '3',
      title: 'SOBERBIA Y PEREZA',
      subtitle: 'Cuando el show termina, nadie te espera',
      briefing: BriefingContent(
        objective: 'MEMORIA: ECHO MEDIA\nEL JUICIO DEL EGO\n\nTu ego es una jaula de diamantes. Ajusta el foco, calla el ruido y enfrenta lo que queda cuando las luces se apagan.',
        mechanicTitle: 'EL PESO DEL EGO',
        mechanicDescription: 
          '3 Fases: Sobreexposición, Aislamiento de Eco y Sintaxis del Ego.\n\n'
          'La soberbia quema la señal. Mantén el foco en lo que queda de tu yo real.',
        controls: 'Pantalla táctil: ajusta, toca, elimina',
        tip: 'Magnolia solía verte aquí a través de una pantalla. Ahora ella es lo único real que te queda.',
        phaseNames: ['Sobreexposición', 'Eco', 'Ego'],
      ),
      gameOver: GameOverContent(
        messages: [
          "TU EGO ES TAN GRANDE QUE NO CABE EN ESTE HOSPITAL.",
          "MIGUEL POR FIN DESCANSA. ¿POR QUÉ TÚ NO PUEDES DEJAR DE PRODUCIR RUIDO?",
          "CARLOS RUGE A UN ESTADIO DE SOMBRAS VACÍAS. ESTÁS SOLO.",
          "GLORIFICASTE EL CANSANCIO Y MIRA... POR FIN LOGRASTE DORMIR PARA SIEMPRE.",
          "MAGNOLIA ESTÁ APAGANDO LAS LUCES, ALEX. EL SHOW SE HA CANCELADO.",
          "CARLOS TE ENSEÑÓ A MENTIR CON UNA SONRISA. ¿DÓNDE ESTÁ AHORA?",
          "MIGUEL TE DIJO QUE DESCANSARAS. TOMASTE PASTILLAS EN SU LUGAR.",
          "EL ESTUDIO ESTÁ VACÍO. TU ECO SIGUE REBOTANDO.",
        ],
        flavorTexts: [
          "16 horas de grabación. 0 horas de vida real.",
          "Las luces nunca se apagaban. Tú cada vez estabas más a oscuras.",
          "Carlos murió de soberbia. Tú de pereza emocional.",
          "Miguel te recetó paz. Tú elegiste coma.",
        ],
      ),
      victory: VictoryContent(
        cinematicLines: [
          'CÅRŁØS RUGÍÅ Å UN €STÅĐIØ VÅCÍØ.',
          'MIGU€Ł GŁØRIFICÓ €Ł CÅNSÅNCIØ.',
          '16 HØRÅS Đ€ GRÅBÅCIÓN.',
          '0 HØRÅS CØN TU FÅMI_#_ŁIÅ.',
        ],
        stats: [
          StatConfig(key: 'evidenceCollected', label: 'FRAGMENTOS DE SOBERBIA', formatter: (v) => '$v de 3'),
          StatConfig(key: 'sanity', label: 'CORDURA AL FINAL', formatter: (v) => '${(v * 100).toInt()}%'),
          StatConfig(key: 'playTime', label: 'TIEMPO EN EL JUICIO', formatter: (v) {
            final seconds = v as double;
            final minutes = (seconds / 60).floor();
            final secs = (seconds % 60).floor();
            return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
          }),
          StatConfig(key: 'followersEarned', label: 'SEGUIDORES GANADOS', formatter: (v) => '+$v'),
        ],
      ),
    ),
    'arc_4_ira': ArcContent(
      arcId: 'arc_4_ira',
      arcNumber: '4',
      title: 'IRA (LA VERDAD)',
      subtitle: 'El fuego que no se puede editar',
      briefing: BriefingContent(
        objective: 'MEMORIA: CASA DE VÍCTOR   HOSPITAL\nEL JUICIO FINAL\n\nNo hay más máscaras. Encuentra a Víctor entre las llamas antes de que tu corazón deje de latir.',
        mechanicTitle: 'LA VERDAD SIN FILTROS',
        mechanicDescription: 
          '5 Actos: Fuego, Llamadas Perdidas, Claridad, Sentencia de Culpa y Latido Final.\n\n'
          'VÍCTOR TIENE EL CONTROL. No quiere tu dinero ni tus likes. Quiere que sientas el fuego.',
        controls: 'Pantalla táctil: apaga, contesta, limpia, acepta, sincroniza',
        tip: 'EL JUICIO NO SE PUEDE POSPONER. Si escuchas a Magnolia llorar, significa que el tiempo se agota.',
        phaseNames: ['Fuego', 'Llamadas', 'Claridad', 'Culpa', 'Latido'],
      ),
      gameOver: GameOverContent(
        messages: [
          "ESTABAS EDITANDO EL VIDEO MIENTRAS ME ENCONTRABAS COLGADO, ALEX.",
          "¿CUÁNTOS SEGUIDORES VALE MI VIDA AHORA?",
          "MAMÁ ESTÁ AL OTRO LADO. ELLA NO SABE QUE YO ESTOY AQUÍ CONTIGO.",
          "NO PUEDES ESCAPAR DE ESTE FUEGO, PORQUE EL FUEGO ERES TÚ.",
          "ATESTIGÚAME, HERMANO. MIRA LO QUE HICISTE.",
          "LLAMÉ 15 VECES. ESTABAS EN VIVO. 12,847 ESPECTADORES.",
          "EL VIDEO TIENE 2 MILLONES DE VISTAS. YO TENGO UNA TUMBA.",
          "MAMÁ FIRMÓ LOS PAPELES. ELLA NO SABE QUE FUE INTENCIONAL.",
        ],
        flavorTexts: [
          "Los anuncios siguen activos, Alex.",
          "Monetizaste mi muerte. ¿Cuánto ganaste?",
          "Tenía 17 años. Tú tenías 12,847 espectadores.",
          "El fuego no se apaga con una edición.",
        ],
      ),
      victory: VictoryContent(
        cinematicLines: [
          'ŁØS PRIM€RØS 6 P€CÅĐØS €RÅN TÚ.',
          'VÍCTØR €RÅ R€ÅŁ.',
          '17 ÅÑØS. TU H€RMÅNØ M€NØR.',
          'ŁÅ IRÅ NØ €S RÅBIÅ. €S V€RĐÅĐ.',
        ],
        stats: [
          StatConfig(key: 'evidenceCollected', label: 'FRAGMENTOS DE CULPA', formatter: (v) => '$v de 5'),
          StatConfig(key: 'sanity', label: 'VERDAD ACEPTADA', formatter: (v) => '${(v * 100).toInt()}%'),
          StatConfig(key: 'playTime', label: 'TIEMPO HASTA EL FINAL', formatter: (v) {
            final seconds = v as double;
            final minutes = (seconds / 60).floor();
            final secs = (seconds % 60).floor();
            return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
          }),
          StatConfig(key: 'followersEarned', label: 'VISTAS FINALES', formatter: (v) => '+$v'),
        ],
      ),
    ),
  };

  ArcContent? getArcContent(String arcId) {
    final content = _arcContent[arcId];
    if (content == null) {
      print('⚠️ No content found for arc: $arcId, using default');
      return _getDefaultContent(arcId);
    }
    return content;
  }

  ArcContent _getDefaultContent(String arcId) {
    final arc = getArcById(arcId);
    return ArcContent(
      arcId: arcId,
      arcNumber: arc?.number.toString() ?? '0',
      title: arc?.title ?? 'DESCONOCIDO',
      subtitle: arc?.subtitle ?? 'Arco en desarrollo',
      briefing: const BriefingContent(
        objective: 'Inyectar secuencia de restauración neuronal.',
        mechanicTitle: 'HACKEO DE CONCIENCIA',
        mechanicDescription: 'Intervención procedural en tiempo real.',
        controls: 'Interfaz Táctil: Disparadores de Pulso / Terminal',
        tip: 'Mantén la coherencia de datos para evitar la corrupción del núcleo.',
      ),
      gameOver: const GameOverContent(
        messages: ['Game Over', 'Inténtalo de nuevo'],
        flavorTexts: [],
      ),
      victory: const VictoryContent(
        cinematicLines: ['Victoria'],
        stats: [],
      ),
    );
  }
}
