import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/puzzle_evidence.dart';
import '../models/puzzle_fragment.dart';

class EvidenceDefinitions {
  static List<PuzzleEvidence> getAllEvidences() {
    return [
      _createArc1Evidence(),
      _createArc2Evidence(),
      _createArc3Evidence(),
      _createArc4Evidence(),
      _createArc5Evidence(),
      _createArc6Evidence(),
      _createArc7Evidence(),
    ];
  }

  // Arc 1: Envidia y Lujuria - Lucía y Adriana
  static PuzzleEvidence _createArc1Evidence() {
    const evidenceId = 'arc_1_envidia_lujuria_evidence';
    const arcId = 'arc_1_envidia_lujuria';

    // Grid 4x3 positions for 10 fragments
    final List<Map<String, int>> gridPositions = [
      {'x': 0, 'y': 0}, {'x': 1, 'y': 0}, {'x': 2, 'y': 0}, {'x': 3, 'y': 0},
      {'x': 0, 'y': 1}, {'x': 1, 'y': 1}, {'x': 2, 'y': 1}, {'x': 3, 'y': 1},
      {'x': 0, 'y': 2}, {'x': 1, 'y': 2},
    ];

    final List<vm.Vector2> correctPositions = [
      vm.Vector2(100, 100), vm.Vector2(300, 100), vm.Vector2(500, 100), vm.Vector2(700, 100),
      vm.Vector2(100, 300), vm.Vector2(300, 300), vm.Vector2(500, 300), vm.Vector2(700, 300),
      vm.Vector2(100, 500), vm.Vector2(300, 500),
    ];

    // Create fragments
    final fragments = List.generate(10, (i) {
      return PuzzleFragment(
        id: '${evidenceId}_frag_$i',
        evidenceId: evidenceId,
        fragmentNumber: i + 1,
        gridX: gridPositions[i]['x']!,
        gridY: gridPositions[i]['y']!,
        correctPosition: correctPositions[i],
        correctRotation: 0,
        arcId: arcId,
        narrativeSnippet: _getArc1NarrativeSnippet(i + 1),
      );
    });

    return PuzzleEvidence(
      id: evidenceId,
      arcId: arcId,
      title: 'Expediente: Espejos Rotos',
      narrativeDescription:
          'Documentación del Juicio de la Imagen. Registros de cómo Alex sacrificó su identidad '
          'auténtica por la validación externa. El expediente contiene la verdad sobre Lucía y Adriana, '
          'revelando que no son víctimas externas, sino reflejos de lo que Alex destruyó en sí mismo.',
      completeImagePath: 'assets/evidences/arc1_complete.png',
      fragments: fragments,
    );
  }

  static String _getArc1NarrativeSnippet(int fragmentNumber) {
    switch (fragmentNumber) {
      case 1:
        return 'EVIDENCIA_01: FOTO DE GRADUACIÓN\n\n'
            'Descripción: Una fotografía grupal. Lucía aparece en el centro, sonriendo con una luz natural y vibrante. '
            'Alex está a su lado, pero su rostro está distorsionado por un efecto de "blur" digital, como si el sistema no pudiera renderizar su identidad original.\n\n'
            'Nota al pie: "Ese día dejaste de admirarme para empezar a envidiar que yo aún podía ser real."';
      case 2:
        return 'EVIDENCIA_02: CONTRATO PUBLICITARIO "ARAÑA"\n\n'
            'Descripción: Documento legal manchado de café. Varias cláusulas están subrayadas en rojo sangre.\n\n'
            'EXTRACTO: "El cedente (Adriana) entrega la propiedad absoluta de su imagen íntima al Algoritmo a cambio de 5,000 interacciones garantizadas por post."\n\n'
            'Nota al pie: "Tu cuerpo me pertenece. Los likes son el único calor que vas a sentir."';
      case 3:
        return 'EVIDENCIA_03: VIDEO DE ARCHIVO "ESPEJO_REFLX"\n\n'
            'Descripción: Metraje grabado con un teléfono. Alex posa frente a un espejo de gimnasio, ajustando su ángulo para esconder el cansancio.\n\n'
            'AUDIO: Se escucha la voz de un niño (Víctor) llamando: "¡Alex! ¡Mamá dice que vengas a cenar! ¡Alex!". Alex lo ignora y sigue grabando.\n\n'
            'ESTADO: Magnolia corta la señal antes de que el video termine. "No querías oírlo", susurra ella.';
      case 4:
        return 'REGISTRO DE BÚSQUEDA: "CÓMO PARECER ALGUIEN QUE NO SOY"\n\n'
            'Historial de Alex - 02:15 AM\n'
            '- Mejores filtros para ocultar ojeras\n'
            '- Cómo imitar la risa de Carlos\n'
            '- Por qué el feed de Lucía tiene más engagement que el mío\n'
            '- Comprar seguidores reales baratos\n\n'
            'Nota: La envidia no es querer lo que el otro tiene, es querer que el otro deje de tenerlo.';
      case 5:
        return 'MENSAJE DE VOZ ELIMINADO - ADRIANA\n\n'
            '"Alex, por favor... deja de subir esas fotos nuestras. El mundo no tiene por qué ver esto. '
            '¿Cuándo dejó de ser sobre nosotros y empezó a ser sobre lo que ellos piensan?"\n\n'
            'ESTADO: Mensaje ignorado. Post publicado 10 minutos después.';
      case 6:
        return 'REPORTE PSICOLÓGICO: DISMORFIA DIGITAL\n\n'
            'Sujeto: Alex. Presenta rechazo severo a su imagen sin procesar. '
            'Identifica su "Yo real" como una falla del sistema y su "Yo filtrado" como la única versión válida.\n\n'
            'DIAGNÓSTICO: Envidia de sí mismo. Obsesionado con un avatar que no puede existir fuera de la pantalla.';
      case 7:
        return 'SCRIPT DE VIDEO POSADO\n\n'
            '"Hola chicos, hoy me siento super auténtico y sin filtros..."\n\n'
            'Nota: El script tiene 5 revisiones. La palabra "auténtico" fue ensayada frente al espejo durante 3 horas.';
      case 8:
        return 'FRAGMENTO DE CHAT: LUCÍA\n\n'
            '"Ya no te reconozco, Alex. Hablas como un anuncio publicitario. '
            'Echo de menos al chico que no necesitaba que 2,000 extraños le dijeran que era guapo."';
      case 9:
        return 'CONTRATO DE ADRIANA (REVERSO)\n\n'
            '"Si el engagement baja del 2%, el sujeto perderá el derecho a la privacidad definitiva."\n\n'
            'Alex firmó por ella. Adriana nunca lo supo.';
      case 10:
        return 'LA REVELACIÓN DEL ESPEJO\n\n'
            'No hay dos víctimas. Solo hay una máscara rota.\n\n'
            'Lucía es tu admiración perdida. Adriana es tu intimidad vendida.\n\n'
            'ALEX, EL ESPEJO NO ESTÁ ROTO. TÚ LO ESTÁS.';
      default:
        return '';
    }
  }

  // Arc 2: Avaricia - Valeria
  static PuzzleEvidence _createArc2Evidence() {
    const evidenceId = 'arc_2_consumo_codicia_evidence';
    const arcId = 'arc_2_consumo_codicia';

    final List<Map<String, int>> gridPositions = [
      {'x': 0, 'y': 0}, // Fragment 1
      {'x': 1, 'y': 0}, // Fragment 2
      {'x': 2, 'y': 0}, // Fragment 3
      {'x': 0, 'y': 1}, // Fragment 4
      {'x': 1, 'y': 1}, // Fragment 5
    ];

    final List<vm.Vector2> correctPositions = [
      vm.Vector2(100, 100),
      vm.Vector2(300, 100),
      vm.Vector2(500, 100),
      vm.Vector2(100, 300),
      vm.Vector2(300, 300),
    ];

    final fragments = List.generate(5, (i) {
      return PuzzleFragment(
        id: '${evidenceId}_frag_$i',
        evidenceId: evidenceId,
        fragmentNumber: i + 1,
        gridX: gridPositions[i]['x']!,
        gridY: gridPositions[i]['y']!,
        correctPosition: correctPositions[i],
        correctRotation: 0,
        arcId: arcId,
        narrativeSnippet: _getArc2NarrativeSnippet(i + 1),
      );
    });

    return PuzzleEvidence(
      id: evidenceId,
      arcId: arcId,
      title: 'Expediente: Almacén de Sobras',
      narrativeDescription:
          'Documentación del Juicio del Objeto. Este expediente detalla '
          'cómo Alex intentó llenar el vacío existencial con posesiones y ambición. '
          'Mateo fue consumido por el espectáculo del unboxing, cada bocado convertido en contenido. '
          'Valeria vio sus ideas robadas y su nombre borrado de los créditos. '
          'El expediente documenta la acumulación compulsiva y el costo humano de la avaricia digital.',
      completeImagePath: 'assets/evidences/arc2_complete.png',
      fragments: fragments,
    );
  }

  static String _getArc2NarrativeSnippet(int fragmentNumber) {
    switch (fragmentNumber) {
      case 1:
        return 'TRANSCRIPCIÓN DE LLAMADA AL 911 - 02:34 AM\n\n'
            'OPERADOR: 911, ¿cuál es su emergencia?\n\n'
            'VALERIA: [Voz temblorosa] Hay alguien afuera de mi casa. Otra vez. '
            'Es la tercera vez esta semana. Mis hijos están aterrorizados.\n\n'
            'OPERADOR: ¿Puede ver a la persona? ¿Está intentando entrar?\n\n'
            'VALERIA: No, pero dejaron algo en la puerta. Es... es una foto. '
            'Una foto de mis hijos saliendo de la escuela. Con sus nombres escritos atrás.\n\n'
            '[Sonido de llanto de niños en el fondo]\n\n'
            'VALERIA: Saben dónde vivo. Saben dónde van mis hijos a la escuela. '
            'Saben sus nombres, sus horarios. Todo porque alguien en internet '
            'decidió que sería "divertido" encontrar mi información.\n\n'
            '[Sonido de sirenas aproximándose]\n\n'
            'OPERADOR: La patrulla está llegando, señora. Manténgase dentro con las puertas cerradas.\n\n'
            'VALERIA: [Sollozando] ¿Por qué nos hacen esto? Solo subí una foto...';
      case 2:
        return 'EXTRACTO DE COMENTARIOS EN REDES SOCIALES\n\n'
            '@detective_wannabe: "Encontré el banco donde trabaja. Aquí está la dirección completa 📍"\n'
            '↳ 2,847 likes · 1,234 compartidos\n\n'
            '@zoom_master: "Amplié la foto. Se puede ver el número de cuenta en el reflejo lol"\n'
            '↳ 3,421 likes\n\n'
            '@doxxer_pro: "Ya tengo su dirección. La casa azul en la esquina. Google Maps es tu amigo 😎"\n'
            '↳ 5,678 likes\n\n'
            '@creepy_stalker: "Sus hijos van a la Primaria Lincoln. Encontré sus nombres en el directorio"\n'
            '↳ 8,234 likes\n\n'
            '[El hilo fue compartido 12,847 veces antes de ser eliminado]\n\n'
            'Nota: Toda esta información fue recopilada en menos de 3 horas.';
      case 3:
        return 'INFORME POLICIAL - UNIDAD DE DELITOS CIBERNÉTICOS\n\n'
            'VÍCTIMA: Valeria M., 34 años\n'
            'FECHA PRIMER INCIDENTE: 18/02/2024\n\n'
            'INCIDENTES DOCUMENTADOS:\n'
            '- 47 llamadas amenazantes de números desconocidos\n'
            '- 3 intentos de intrusión en domicilio\n'
            '- 12 intentos de robo de identidad\n'
            '- Fotos de menores tomadas sin consentimiento\n'
            '- Acoso sistemático en redes sociales\n\n'
            'HALLAZGOS ADICIONALES:\n'
            'La información personal de la víctima fue compartida en 47 foros diferentes. '
            'Incluye: dirección completa, lugar de trabajo, escuela de los hijos, '
            'rutinas diarias, números de cuenta bancaria.\n\n'
            'EVALUACIÓN: Familia en riesgo extremo. Reubicación urgente recomendada.';
      case 4:
        return 'EVALUACIÓN PSICOLÓGICA - MENORES AFECTADOS\n\n'
            'PACIENTE: Sofía M., 7 años\n\n'
            'La menor dibujó a su familia dentro de una casa con las ventanas tapadas. '
            'Cuando se le preguntó por qué, respondió: "Para que la gente mala no nos vea".\n\n'
            'Presenta enuresis nocturna (regresión). Se niega a ir a la escuela. '
            'Pesadillas recurrentes sobre "gente mirándola". Ataques de pánico al ver cámaras.\n\n'
            'PACIENTE: Lucas M., 9 años\n\n'
            'El menor preguntó si "la gente de internet" puede entrar a su cuarto. '
            'Ha dejado de usar su nombre real, pide que lo llamen por un apodo.\n\n'
            'Comportamiento hipervigilante. Duerme con la luz encendida. '
            'Revisa constantemente las ventanas.\n\n'
            'DIAGNÓSTICO: Ambos menores presentan TEPT severo. '
            'Daño psicológico a largo plazo altamente probable.';
      case 5:
        return 'REGISTRO DE SESIÓN DE TERAPIA - DÍA 21\n\n'
            'TERAPEUTA: Valeria, ¿cómo están manejando la situación los niños?\n\n'
            '[Silencio prolongado - 2 minutos]\n\n'
            'VALERIA: [Voz quebrada] Sofía me preguntó ayer si podíamos cambiar de familia. '
            'Dijo que tal vez si tuviéramos otros nombres, la gente nos dejaría en paz.\n\n'
            'TERAPEUTA: ¿Cómo respondiste a eso?\n\n'
            'VALERIA: [Sollozando] No pude. ¿Qué le digo? ¿Que tiene razón? '
            'Tiene 7 años. SIETE. Y ya sabe lo que es vivir con miedo constante.\n\n'
            '[Valeria se abraza a sí misma]\n\n'
            'VALERIA: Lucas dejó de sonreír. Literalmente. No lo he visto sonreír en semanas. '
            'Revisa las ventanas cada cinco minutos. Pregunta si estamos seguros. '
            'Tiene 9 años y vive como si estuviera en una zona de guerra.\n\n'
            'Todo porque subí una foto. UNA FOTO. Y alguien decidió que sería entretenido '
            'jugar a ser detective. Y luego otra persona lo compartió. Y otra. Y otra.\n\n'
            'Nadie pensó en mis hijos. Nadie pensó que detrás de esa "investigación divertida" '
            'había niños reales que ahora tienen miedo de existir.\n\n'
            '[Sesión terminada prematuramente - paciente en crisis]';
      default:
        return '';
    }
  }

  // Arc 3: Envidia - Lucía
  static PuzzleEvidence _createArc3Evidence() {
    const evidenceId = 'arc_3_soberbia_pereza_evidence';
    const arcId = 'arc_3_soberbia_pereza';

    final List<Map<String, int>> gridPositions = [
      {'x': 0, 'y': 0}, // Fragment 1
      {'x': 1, 'y': 0}, // Fragment 2
      {'x': 2, 'y': 0}, // Fragment 3
      {'x': 0, 'y': 1}, // Fragment 4
      {'x': 1, 'y': 1}, // Fragment 5
    ];

    final List<vm.Vector2> correctPositions = [
      vm.Vector2(100, 100),
      vm.Vector2(300, 100),
      vm.Vector2(500, 100),
      vm.Vector2(100, 300),
      vm.Vector2(300, 300),
    ];

    final fragments = List.generate(5, (i) {
      return PuzzleFragment(
        id: '${evidenceId}_frag_$i',
        evidenceId: evidenceId,
        fragmentNumber: i + 1,
        gridX: gridPositions[i]['x']!,
        gridY: gridPositions[i]['y']!,
        correctPosition: correctPositions[i],
        correctRotation: 0,
        arcId: arcId,
        narrativeSnippet: _getArc3NarrativeSnippet(i + 1),
      );
    });

    return PuzzleEvidence(
      id: evidenceId,
      arcId: arcId,
      title: 'Expediente: Echo Media',
      narrativeDescription:
          'Documentación del Juicio del Ego y la Inacción. Este expediente detalla '
          'el ruido ensordecedor de la soberbia de Alex y la parálisis del alma por el agotamiento. '
          'Carlos representa la autoestima asfixiada por un ego inflado, mientras Miguel es '
          'el derecho a la paz enterrado bajo la grind culture. '
          'El expediente documenta el colapso mental (Burnout) y la ceguera ante los vínculos reales.',
      completeImagePath: 'assets/evidences/arc3_complete.png',
      fragments: fragments,
    );
  }

  static String _getArc3NarrativeSnippet(int fragmentNumber) {
    switch (fragmentNumber) {
      case 1:
        return 'METADATA DE VIDEO - "RAW_TRUTH_V8.MP4"\\n\\n'
            'DURACIÓN TOTAL: 00:15:32\\n'
            'DURACIÓN FINAL: 00:00:15 (Solo intro)\\n\\n'
            '[Descripción de los primeros 10 minutos]\\n'
            'Alex está sentado frente a la cámara. Está llorando en silencio. No hay luces, solo el brillo de la pantalla. '
            'Se abraza las manos. Murmura: "No sé quién soy si no me miran".\\n\\n'
            '[Marca de tiempo: 12:45]\\n'
            'Alex se limpia las lágrimas frenéticamente. Aplica corrector de ojeras. '
            'Enciende los focos. La luz quema la imagen por un segundo.\\n\\n'
            '[Voz de Alex en la grabación final]\\n'
            '"¡Hola a todos! ¡Hoy me siento increíble! No olviden que la disciplina es libertad."\\n\\n'
            'Nota: La sonrisa tardó 14 tomas en parecer "auténtica".';
      case 2:
        return 'RECETA MÉDICA - CENTRO DE SALUD MENTAL "PASIVAS"\\n\\n'
            'FECHA: 15/10/2024\\n'
            'PACIENTE: [NOMBRE TACHADO - Alex R.]\\n\\n'
            'TRATAMIENTO:\\n'
            '- Sertralina 100mg (1 cada 24h)\\n'
            '- Alprazolam 0.5mg (Si hay ataque de pánico)\\n'
            '- REPOSO ABSOLUTO (Nota: El paciente se niega)\\n\\n'
            '[Observaciones del Dr. Miguel]\\n'
            '"El paciente presenta signos claros de burnout extremo. Cree que descansar es morir. '
            'Dice que "su audiencia lo necesita". No duerme más de 4 horas por las luces del estudio. '
            'Su ego está devorando su sistema nervioso periférico."\\n\\n'
            '[Anotación al reverso con caligrafía de Alex]\\n'
            '"Miguel es débil. Descansar es para los que no tienen visión. '
            'Grabaré 3 videos hoy para compensar la consulta."';
      case 3:
        return 'MEMORANDO DE AUDIO - GRABACIÓN ACCIDENTAL\\n\\n'
            'REMITENTE: Magnolia R.\\n'
            'TEMA: Discusión en el set de Echo Media\\n\\n'
            '[Transcripción]\\n\\n'
            'MAGNOLIA: ¡Ya basta, Alex! ¡Apaga esas malditas luces!\\n'
            'ALEX: ¡Es mi trabajo, mamá! ¡Hago todo esto por ustedes! ¡Por Víctor!\\n\\n'
            'MAGNOLIA: [Grito ahogado] ¡Víctor no necesita un video en su honor, Alex! '
            '¡Necesitaba que estuvieras con él en su cumpleaños! ¡Necesitaba a su hermano, no a un "storyteller"!\\n\\n'
            'ALEX: ¡Ese storytelling pagará su operación!\\n'
            'MAGNOLIA: [Voz quebrada, susurro] Su operación ya fue hace una semana, Alex. '
            'Ni siquiera viniste. Estabas aquí, grabando sobre "la importancia de la resiliencia"...\\n\\n'
            '[Sonido de algo rompiéndose - Magnolia rompe a llorar]\\n'
            '[Silencio sepulcral de Alex - Ruido blanco - Fin de la grabación]';
      case 4:
        return 'REGISTRO DE USO DE CPU - TERMINAL "ALEX_MAIN"\\n\\n'
            'ESTADO DEL SISTEMA: CRÍTICO\\n\\n'
            'PROCESOS ACTIVOS:\\n'
            '- GrindCulture.exe (98% CPU)\\n'
            '- ValidationFalsa.service (95% CPU)\\n'
            '- EgoFilter_v4.dll (Hilos: Infinitos)\\n\\n'
            'PROCESOS EN PAUSA (ERROR 404):\\n'
            '- Empatía_Víctor.sh\\n'
            '- SaludMental.exe\\n'
            '- Magnolia_Connection.link\\n\\n'
            'MENSAJE DEL SISTEMA: "El núcleo neuronal ha dejado de responder a estímulos reales. '
            'Aceptando solo validación externa de baja latencia. El sujeto está colapsando."';
      case 5:
        return 'GUION DE VIDEO: "MI ÚLTIMA VERDAD" (BORRADOR)\\n\\n'
            '[Anotación al margen: Hacerlo llorar en el minuto 4:00 para engagement]\\n\\n'
            '"Siento que les debo una explicación. He estado trabajando tan duro que me olvidé de vivir. '
            'Pero Víctor, mi hermano, es mi mayor inspiración..."\\n\\n'
            '[Tachón violento en el papel]\\n\\n'
            'Nota: "Mierda, esto suena falso. Tengo que volver a grabarlo. Quizás si menciono a Magnolia... '
            'A la gente le gustan las madres sufridas. Sí, eso funcionará."\\n\\n'
            '[Al final de la página, una nota temblorosa]\\n'
            '"¿Por qué no siento nada cuando lo escribo?"';
      default:
        return '';
    }
  }

  // Arc 4: Lujuria - Adriana
  static PuzzleEvidence _createArc4Evidence() {
    const evidenceId = 'arc_4_ira_evidence';
    const arcId = 'arc_4_ira';

    final List<Map<String, int>> gridPositions = [
      {'x': 0, 'y': 0},
      {'x': 1, 'y': 0},
      {'x': 2, 'y': 0},
      {'x': 0, 'y': 1},
      {'x': 1, 'y': 1},
    ];

    final List<vm.Vector2> correctPositions = [
      vm.Vector2(100, 100),
      vm.Vector2(300, 100),
      vm.Vector2(500, 100),
      vm.Vector2(100, 300),
      vm.Vector2(300, 300),
    ];

    final fragments = List.generate(5, (i) {
      return PuzzleFragment(
        id: '${evidenceId}_frag_$i',
        evidenceId: evidenceId,
        fragmentNumber: i + 1,
        gridX: gridPositions[i]['x']!,
        gridY: gridPositions[i]['y']!,
        correctPosition: correctPositions[i],
        correctRotation: 0,
        arcId: arcId,
        narrativeSnippet: _getArc4NarrativeSnippet(i + 1),
      );
    });

    return PuzzleEvidence(
      id: evidenceId,
      arcId: arcId,
      title: 'Expediente: La Casa en Llamas',
      narrativeDescription:
          'Documentación del Juicio Final. Víctor es el único sujeto 100% real. '
          'No es un reflejo, no es una faceta. Es el hermano que Alex dejó morir. '
          'Los fragmentos revelan la verdad sin filtros: el coma, las 15 llamadas perdidas '
          'y el video de "Honor a Víctor" grabado por Alex mientras su hermano murió.',
      completeImagePath: 'assets/evidences/arc4_complete.png',
      fragments: fragments,
    );
  }

  static String _getArc4NarrativeSnippet(int fragmentNumber) {
    switch (fragmentNumber) {
      case 1:
        return 'INFORME MÉDICO - UCI HOSPITAL REGIONAL\n\n'
            'PACIENTE: Alex [APELLIDO REDACTADO]\n'
            'EDAD: 22 años\n'
            'INGRESO: [FECHA REDACTADA] - 03:17 AM\n\n'
            'MOTIVO DE INGRESO: Sobredosis de benzodiacepinas\n'
            'ESTADO ACTUAL: COMA INDUCIDO\n\n'
            'HISTORIAL RELEVANTE:\n'
            'Familiar reporta que el paciente estaba realizando una transmisión '
            'en vivo cuando perdió el conocimiento. La transmisión siguió activa '
            'durante 47 minutos después del colapso. Continuaron llegando '
            'comentarios y reacciones.\n\n'
            'NOTA DEL MÉDICO:\n'
            '"El paciente tiene una pantallla de teléfono rota en la mano. No '
            'podemos separarlo de ella. Cuando intentamos quitarla, su '
            'frecuencia cardíaca se eleva peligrosamente."\n\n'
            'ACOMPAÑANTE: Magnolia R. (Madre). Lleva 72 horas sin dormir.';
      case 2:
        return 'CAPTURA DE PANTALLA - TELÉFONO DE VÍCTOR\n\n'
            '[IMAGEN: Pantalla de llamadas]\n'
            'LLAMADAS PERDIDAS DE: "MI HERMANO ALEX"\n\n'
            '02:47 AM - Llamada perdida\n'
            '02:51 AM - Llamada perdida\n'
            '02:54 AM - Llamada perdida\n'
            '02:58 AM - Llamada perdida\n'
            '03:01 AM - Llamada perdida\n'
            '03:03 AM - Llamada perdida\n'
            '03:06 AM - Llamada perdida\n'
            '03:07 AM - Llamada perdida\n'
            '03:09 AM - Llamada perdida\n'
            '03:10 AM - Llamada perdida\n'
            '03:11 AM - Llamada perdida\n'
            '03:12 AM - Llamada perdida\n'
            '03:13 AM - Llamada perdida\n'
            '03:14 AM - Llamada perdida\n'
            '03:15 AM - Llamada perdida\n\n'
            '[Nota: Alex estaba en vivo con 12,847 espectadores durante ese periodo]\n'
            '[El video del directo tiene 2.4M de vistas totales]';
      case 3:
        return 'METADATA DE VIDEO - "LE DEDICO ESTO A MI HERMANO"\n\n'
            'Canal: Alex_Narra / Verificado\n'
            'Vistas: 2,047,338\n'
            'Likes: 198,452\n'
            'Ingresos por publicidad: \$14,892.00 USD\n\n'
            'DESCRIPCIÓN DEL VIDEO:\n'
            '"Hoy quiero hablar de algo personal. Mi hermano Víctor siempre '
            'fue mi mayor inspiración. Me enseñó que la fuerza viene desde '
            'adentro. Esta para ti, hermano. Te amo."\n\n'
            '[DATO EXTRAÍDO DEL HISTORIAL PRIVADO]\n'
            'Fecha de publicación: 72 horas después de la muerte de Víctor\n'
            'El video fue editado y subido mientras Alex estaba en camino al hospital\n\n'
            '[COMENTARIO CON MAS LIKES]\n'
            '"Me hiciste llorar ❤ Vuestro vínculo es increíble" - 45,231 likes\n\n'
            '[UNO DE LOS ÚNICOS COMENTARIOS NEGATIVOS]\n'
            '"No dejó ni enfriar el cuerpo." - 2 likes (eliminado por el canal)';
      case 4:
        return 'REGISTROS DE VOZ - CUARTO DE HOSPITAL\n\n'
            '[GRABACIÓN AUTOMÁTICA DEL MONITOR CARDÍACO]\n'
            'HORA: 04:23 AM\n\n'
            'MAGNOLIA: [Voz rota] Alex... Alex, soy yo. Mamá.\n\n'
            '[Silencio. Solo el pitido ritmico del monitor]\n\n'
            'MAGNOLIA: Víctor... Víctor se fue, mi amor. Hace tres horas. '
            'Se fue sin que pudieras despedirte. Se fue leyendo tus mensajes '
            'de texto del lunes pasado. Solo decían "Esta semana no puedo, '
            'tengo grabaciones."\n\n'
            '[Pausa larga. Llanto contenido]\n\n'
            'MAGNOLIA: Él te llamó quince veces esa noche. Quince. Yo conté. '
            'No sabía si enojarte o llorar. Ahora sé qué era: desesperación. '
            'Necesitaba escuchar tu voz una vez más.\n\n'
            '[Freq cardíaca de Alex sube. La máquina alerta]\n\n'
            'MAGNOLIA: [susurra] ¿Lo escuchas, Alex? Eso es él. Te está esperando.';
      case 5:
        return 'MENSAJE FINAL DEL SISTEMA\n\n'
            '[PROTOCOLO DE REVELACIÓN COMPLETADO]\n\n'
            'Los siguientes sujetos fueron procesados:\n'
            '> Lucía: Era tu envidia al mirarte\n'
            '> Adriana: Era tu intimidad vendida\n'
            '> Mateo: Era tu vacío llenado con ruido\n'
            '> Valeria: Era tu ambición sin escrúpulos\n'
            '> Carlos: Era tu ego que no cabía en el mundo\n'
            '> Miguel: Era tu cuerpo que imploraba detenerse\n\n'
            'Todos eran tú.\n\n'
            'Víctor no era un reflejo.\n'
            'Víctor era REAL.\n\n'
            'Y lo dejaste morir para no perder el DIRECTO.\n\n'
            '[FIN DE LA TRANSMISIÓN]\n'
            '--- ELIGE ---';
      default:
        return '';
    }
  }

  // Arc 5: Soberbia - Carlos
  static PuzzleEvidence _createArc5Evidence() {
    const evidenceId = 'arc5_pride_evidence';
    const arcId = 'pride';

    final List<Map<String, int>> gridPositions = [
      {'x': 0, 'y': 0},
      {'x': 1, 'y': 0},
      {'x': 2, 'y': 0},
      {'x': 0, 'y': 1},
      {'x': 1, 'y': 1},
    ];

    final List<vm.Vector2> correctPositions = [
      vm.Vector2(100, 100),
      vm.Vector2(300, 100),
      vm.Vector2(500, 100),
      vm.Vector2(100, 300),
      vm.Vector2(300, 300),
    ];

    final fragments = List.generate(5, (i) {
      return PuzzleFragment(
        id: '${evidenceId}_frag_$i',
        evidenceId: evidenceId,
        fragmentNumber: i + 1,
        gridX: gridPositions[i]['x']!,
        gridY: gridPositions[i]['y']!,
        correctPosition: correctPositions[i],
        correctRotation: 0,
        arcId: arcId,
        narrativeSnippet: _getArc5NarrativeSnippet(i + 1),
      );
    });

    return PuzzleEvidence(
      id: evidenceId,
      arcId: arcId,
      title: 'Expediente: Caso Carlos',
      narrativeDescription:
          'Documentación de la caída de Carlos, influencer multimillonario. Este expediente registra '
          'cómo sus propios secretos fueron utilizados para destruir su imperio. '
          'Las páginas detallan la exposición de su hipocresía.',
      completeImagePath: 'assets/evidences/arc5_complete.jpg',
      fragments: fragments,
    );
  }

  static String _getArc5NarrativeSnippet(int fragmentNumber) {
    switch (fragmentNumber) {
      case 1:
        return 'TRANSCRIPCIÓN DE COMUNICACIÓN PRIVADA\n\n'
            'CARLOS (A SU STAFF): Estos fans son tan estúpidos. '
            'Literalmente compran CUALQUIER cosa que les venda.\n\n'
            'STAFF: Deberíamos mantener esto en privado, señor.\n\n'
            'CARLOS: ¿Privado? La persona "Carlos" que ven es un producto. '
            'Una construcción. Mi verdadero yo nunca aparecería en cámara.\n\n'
            'CARLOS: [Viendo comentarios] "Eres mi inspiración" '
            '"Quiero ser como tú". Si supieran que soy hueco.';
      case 2:
        return 'ANÁLISIS DE CONTENIDO DUPLICADO\n\n'
            'INVESTIGACIÓN: Plagio de contenido\n\n'
            'RESULTADOS:\n'
            '- 73 videos de "contenido original" son copias de creadores pequeños\n'
            '- 15 "innovaciones revolucionarias" fueron robadas\n'
            '- 34 "escrituras propias" fueron compradas y presentadas como suyas\n\n'
            'Su marca de "clothing sostenible" usa manufactura con trabajo infantil.\n'
            'Su línea de "suplementos naturales" fue vetada en 3 países por falsas afirmaciones.';
      case 3:
        return 'DOCUMENTOS FINANCIEROS - ANÁLISIS\n\n'
            'TRANSFERENCIAS BANCARIAS:\n'
            '- Sobreprecio sistemático: \$2.3 millones\n'
            '- Donaciones falsamente reportadas: \$1.8 millones\n'
            '- Dinero bajo la mesa a moderadores: \$120,000\n\n'
            'RIQUEZA DECLARADA: \$85 millones\n'
            'RIQUEZA OBTENIDA LEGITIMAMENTE: \$8-12 millones\n\n'
            'RESTO OBTENIDO MEDIANTE: Fraude, explotación, robo.';
      case 4:
        return 'TESTIMONIOS DE SEGUIDORES\n\n'
            'SEGUIDOR 1: "Compré todos sus productos. Gasté \$4,000. '
            'Ahora sé que fue todo mentira. Se aprovechó de mi admiración."\n\n'
            'SEGUIDOR 2: "Construí mi autoestima en él. '
            'Cuando todo se reveló, fue como si me hubiera roto internamente."\n\n'
            'SEGUIDOR 3: "Mis padres compraban sus productos porque él dijo que eran seguros. '
            'Mi hermana desarrolló una reacción alérgica severa. Ahora demandamos."\n\n'
            'SEGUIDOR 4: "Dedicaba 10 horas por semana a su comunidad. '
            'Ahora todo eso se siente... contaminado."';
      case 5:
        return 'CARTA ENCONTRADA - BORRADOR\n\n'
            'Para mis fans,\n\n'
            'Todo fue un acto. La versión de mí que vieron no existe.\n\n'
            'Crecí pobre. Insignificante. Cuando descubrí Internet, descubrí que '
            'podía construirme a mí mismo. Que podía ser alguien IMPORTANTE.\n\n'
            'Empecé robando ideas porque tenía miedo de no tener ninguna propia. '
            'Después continué porque era fácil.\n\n'
            'Ahora que todo se está derrumbando, me estoy preguntando: ¿Quién soy realmente?\n\n'
            'Y la respuesta es: No lo sé.';
      default:
        return '';
    }
  }

  // Arc 6: Pereza - Miguel
  static PuzzleEvidence _createArc6Evidence() {
    const evidenceId = 'arc6_sloth_evidence';
    const arcId = 'sloth';

    final List<Map<String, int>> gridPositions = [
      {'x': 0, 'y': 0},
      {'x': 1, 'y': 0},
      {'x': 2, 'y': 0},
      {'x': 0, 'y': 1},
      {'x': 1, 'y': 1},
    ];

    final List<vm.Vector2> correctPositions = [
      vm.Vector2(100, 100),
      vm.Vector2(300, 100),
      vm.Vector2(500, 100),
      vm.Vector2(100, 300),
      vm.Vector2(300, 300),
    ];

    final fragments = List.generate(5, (i) {
      return PuzzleFragment(
        id: '${evidenceId}_frag_$i',
        evidenceId: evidenceId,
        fragmentNumber: i + 1,
        gridX: gridPositions[i]['x']!,
        gridY: gridPositions[i]['y']!,
        correctPosition: correctPositions[i],
        correctRotation: 0,
        arcId: arcId,
        narrativeSnippet: _getArc6NarrativeSnippet(i + 1),
      );
    });

    return PuzzleEvidence(
      id: evidenceId,
      arcId: arcId,
      title: 'Expediente: Caso Miguel',
      narrativeDescription:
          'Documentación de la negligencia crónica de Miguel que resultó en muertes. '
          'Este expediente registra cómo su falta de acción causó tragedias prevenibles.',
      completeImagePath: 'assets/evidences/arc6_complete.jpg',
      fragments: fragments,
    );
  }

  static String _getArc6NarrativeSnippet(int fragmentNumber) {
    switch (fragmentNumber) {
      case 1:
        return 'TRANSCRIPCIÓN 911 - VIOLENCIA DOMÉSTICA\n\n'
            'OPERADOR: 911, ¿cuál es su emergencia?\n\n'
            'TRABAJADOR: Hay un paciente sin oxígeno adecuado. '
            'El tubo está desconectado desde ayer. He reportado esto 4 veces.\n\n'
            'OPERADOR: ¿A quién reportaron esto?\n\n'
            'TRABAJADOR: A Miguel. Dice que "lo va a hacer luego". '
            'El paciente está muriendo.\n\n'
            'OPERADOR: ¿Dónde está Miguel ahora?\n\n'
            'TRABAJADOR: [Whisper] Durmiendo. En su oficina. '
            'Ha estado durmiendo toda la tarde.';
      case 2:
        return 'REGISTROS DE ANTECEDENTES\n\n'
            'CASO 1: Paciente Rosa M. - Infección severa\n'
            'RESPONSABLE: Miguel (notificado 3 veces, no actuó)\n'
            'RESULTADO: Amputación de pierna, muerte\n\n'
            'CASO 2: Paciente David L. - Medicación incorrecta\n'
            'RESPONSABLE: Miguel (no verificó)\n'
            'RESULTADO: Fallo renal, diálisis permanente\n\n'
            'CASO 3: Paciente Ana V., 8 años - Equipo descalibrado\n'
            'RESPONSABLE: Miguel (reportado 6 veces, se negó)\n'
            'RESULTADO: Infarto no detectado, muerte súbita\n\n'
            'PATRÓN: 47 incidentes. 12 muertes. 34 lesiones permanentes.';
      case 3:
        return 'ANÁLISIS PSICOLÓGICO\n\n'
            'DIAGNÓSTICO: Trastorno de Personalidad por Evitación\n\n'
            'SÍNTOMAS OBSERVADOS:\n'
            '- Falta total de empatía\n'
            '- Incapacidad para ser movido a acción\n'
            '- Negación sistemática de responsabilidad\n'
            '- Justificaciones crónicas ("No es mi culpa")\n\n'
            'CITA RELEVANTE:\n'
            '"Cuando me dicen que el paciente murió, siento... nada. '
            'Es como si lo que la gente siente no existiera para mí."';
      case 4:
        return 'TESTIMONIOS DE FAMILIAS\n\n'
            'FAMILIA DE ROSA:\n'
            '"Mi madre pidió ayuda. Miguel fue informado. Y luego se fue a dormir. '
            'Es como si la vida de mi madre valiera menos que una siesta."\n\n'
            'FAMILIA DE ANA:\n'
            '"Fue una niña. Murió porque un hombre estaba demasiado cansado '
            'para presionar un botón. ¿Cómo vivimos con eso?"\n\n'
            'OFICIAL DE POLICÍA:\n'
            '"He respondido 7 llamadas. Cada vez, sin evidencia clara, '
            'mis manos están atadas."';
      case 5:
        return 'IMPACTO SISTÉMICO\n\n'
            'MUERTES DIRECTAS: 12\n'
            'INCAPACIDADES PERMANENTES: 34\n'
            'ESTRÉS EN STAFF: 40% aumento en depresión\n'
            'CONFIANZA PÚBLICA: Destruida\n\n'
            'PREGUNTA FUNDAMENTAL:\n'
            '¿Cuál es la diferencia entre matar a alguien e ignorar su muerte?\n\n'
            'Miguel no blandió un arma. Simplemente no hizo nada.\n'
            'Y la gente murió.';
      default:
        return '';
    }
  }

  // Arc 7: Ira - Víctor
  static PuzzleEvidence _createArc7Evidence() {
    const evidenceId = 'arc7_wrath_evidence';
    const arcId = 'wrath';

    final List<Map<String, int>> gridPositions = [
      {'x': 0, 'y': 0},
      {'x': 1, 'y': 0},
      {'x': 2, 'y': 0},
      {'x': 0, 'y': 1},
      {'x': 1, 'y': 1},
    ];

    final List<vm.Vector2> correctPositions = [
      vm.Vector2(100, 100),
      vm.Vector2(300, 100),
      vm.Vector2(500, 100),
      vm.Vector2(100, 300),
      vm.Vector2(300, 300),
    ];

    final fragments = List.generate(5, (i) {
      return PuzzleFragment(
        id: '${evidenceId}_frag_$i',
        evidenceId: evidenceId,
        fragmentNumber: i + 1,
        gridX: gridPositions[i]['x']!,
        gridY: gridPositions[i]['y']!,
        correctPosition: correctPositions[i],
        correctRotation: 0,
        arcId: arcId,
        narrativeSnippet: _getArc7NarrativeSnippet(i + 1),
      );
    });

    return PuzzleEvidence(
      id: evidenceId,
      arcId: arcId,
      title: 'Expediente: Caso Víctor',
      narrativeDescription:
          'Documentación de la violencia extrema de Víctor. Este expediente registra '
          'cómo su cólera descontrolada destruyó vidas y familias.',
      completeImagePath: 'assets/evidences/arc7_complete.jpg',
      fragments: fragments,
    );
  }

  static String _getArc7NarrativeSnippet(int fragmentNumber) {
    switch (fragmentNumber) {
      case 1:
        return 'TRANSCRIPCIÓN 911 - VIOLENCIA DOMÉSTICA\n\n'
            'OPERADOR: 911, ¿cuál es su emergencia?\n\n'
            'VÍCTIMA: [Grito de dolor] Mi pareja... está fuera de control.\n\n'
            '[Sonido de vidrio rompiéndose]\n\n'
            'VÍCTOR: ¡TE VOY A MATAR!\n\n'
            'VÍCTIMA: [Gritando] ¡NO! ¡POR FAVOR! ¡LOS NIÑOS ESTÁN VIENDO!\n\n'
            'OPERADOR: ¿Están los niños en la habitación?\n\n'
            'VÍCTIMA: ¡SÍ! DOS NIÑOS. TIENEN 4 Y 6 AÑOS. ¡POR FAVOR VENGAN!';
      case 2:
        return 'INFORME MÉDICO - LESIONES REGISTRADAS\n\n'
            'VÍCTIMA PRIMARIA: Sandra C., 32 años\n\n'
            'LESIONES:\n'
            '- 3 costillas rotas\n'
            '- Fractura orbital (ojo izquierdo)\n'
            '- Traumatismo craneoencefálico\n'
            '- 27 hematomas\n'
            '- Laceraciones profundas\n'
            '- Quemadura de cigarrillo\n\n'
            'ANTECEDENTES: 13 visitas previas en 2 años. '
            'Patrón de abuso sistemático.\n\n'
            'RECUPERACIÓN: 60-70% de visión permanente (ojo izquierdo)';
      case 3:
        return 'LESIONES PSICOLÓGICAS - MENORES\n\n'
            'SOFÍA C., 6 años:\n'
            '- TEPT severo\n'
            '- Regresión del desarrollo\n'
            '- Fobia social extrema\n'
            '- Pesadillas recurrentes\n\n'
            'MIGUEL C., 4 años:\n'
            '- TEPT severo\n'
            '- Auto-lesión (se muerde)\n'
            '- Mutismo selectivo\n\n'
            'NOTA: Ambos testigos de violencia. '
            'Impacto psicológico será de por vida.';
      case 4:
        return 'ANTECEDENTES DE VÍCTOR\n\n'
            'INCIDENTES DOCUMENTADOS:\n'
            '- 23 reportes policiales (3 arrestos)\n'
            '- 8 órdenes de restricción (violadas 14 veces)\n'
            '- 4 sentencias carcelarias (8 meses cumplidos)\n'
            '- 47 incidentes de ira descontrolada\n\n'
            'VÍCTIMAS ANTERIORES:\n'
            '- Ex-pareja 1: Cicatriz facial permanente\n'
            '- Ex-pareja 2: Aborto espontáneo tras golpiza\n'
            '- 4 amigos reportan evitar contacto\n'
            '- Despedido de 6 empleos por agresión';
      case 5:
        return 'ANÁLISIS PSIQUIÁTRICO\n\n'
            'EVALUACIÓN CLÍNICA:\n'
            'Víctor presenta trastorno persistente de control de impulsos '
            'combinado con probable Trastorno de Personalidad Antisocial.\n\n'
            'CARACTERÍSTICAS:\n'
            '- Baja empatía\n'
            '- Impulsividad severa\n'
            '- Justificación sistemática\n'
            '- Falta de arrepentimiento genuino\n\n'
            'PRONÓSTICO: Bajo incluso con tratamiento.\n'
            'RIESGO DE ESCALACIÓN: Moderado a alto.';
      default:
        return '';
    }
  }
}
