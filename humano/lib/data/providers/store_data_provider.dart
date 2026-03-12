import '../models/store_item.dart';

class StoreDataProvider {
  // ============================================
  // COIN PACKAGES (Compra con dinero real)
  // ============================================
  // Los paquetes de monedas se manejan directamente en la UI de la tienda
  // con integración de Stripe

  // ============================================
  // BUNDLES (Paquetes de SEGS)
  // ============================================
  static final List<StoreItem> bundles = [
    // STARTER PACKS (2)
    StoreItem(
      id: 'bundle_starter',
      name: 'Pack Principiante',
      description: '3 items + 300 monedas',
      price: 800,
      type: StoreItemType.bundle,
      iconPath: 'assets/bundles/starter.png',
      bundleItems: {
        'firewall_digital': 1,
        'modo_incognito': 1,
        'item_trending': 1,
      },
      bundleCoins: 300,
    ),
    StoreItem(
      id: 'bundle_survival',
      name: 'Pack Supervivencia',
      description: '5 items + 600 monedas',
      price: 1800,
      type: StoreItemType.bundle,
      iconPath: 'assets/bundles/survival.png',
      bundleItems: {
        'firewall_digital': 2,
        'item_antivirus': 1,
        'item_backup': 1,
        'modo_incognito': 1,
      },
      bundleCoins: 600,
    ),

    // THEMED BUNDLES (3)
    StoreItem(
      id: 'bundle_stealth',
      name: 'Bundle Sigilo',
      description: '4 items sigilo',
      price: 4500,
      type: StoreItemType.bundle,
      iconPath: 'assets/bundles/stealth.png',
      isPremium: true,
      bundleItems: {
        'vpn_emocional': 2,
        'modo_incognito': 3,
        'item_camouflage': 2,
        'item_proxy': 2,
      },
      bundleCoins: 1000,
    ),
    StoreItem(
      id: 'bundle_defense',
      name: 'Bundle Defensa',
      description: '4 items defensa',
      price: 4000,
      type: StoreItemType.bundle,
      iconPath: 'assets/bundles/defense.png',
      isPremium: true,
      bundleItems: {
        'firewall_digital': 3,
        'alt_account': 2,
        'item_antivirus': 2,
        'item_backup': 2,
      },
      bundleCoins: 900,
    ),
    StoreItem(
      id: 'bundle_speed',
      name: 'Bundle Velocista',
      description: '4 items velocidad',
      price: 3800,
      type: StoreItemType.bundle,
      iconPath: 'assets/bundles/speed.png',
      isPremium: true,
      bundleItems: {
        'item_boost': 3,
        'item_trending': 2,
        'item_antidote': 2,
        'modo_incognito': 2,
      },
      bundleCoins: 850,
    ),

    // PREMIUM BUNDLE (1)
    StoreItem(
      id: 'bundle_complete',
      name: 'Pack Completo',
      description: '10 items variados + 1500 monedas',
      price: 8000,
      type: StoreItemType.bundle,
      iconPath: 'assets/bundles/premium.png',
      isPremium: true,
      bundleItems: {
        'vpn_emocional': 2,
        'firewall_digital': 3,
        'item_boost': 2,
        'item_antivirus': 2,
        'item_camouflage': 1,
      },
      bundleCoins: 1500,
    ),
  ];

  // ============================================
  // HARDWARE VISUAL (TEMAS)
  // ============================================
  static final List<StoreItem> visualThemes = [
    StoreItem(
      id: 'theme_matrix',
      name: 'KERNEL_MATRIZ',
      description: 'Interfaz en verde fósforo clásico.',
      price: 1200,
      type: StoreItemType.theme,
      iconPath: 'assets/store/theme_matrix.png',
    ),
    StoreItem(
      id: 'theme_amber',
      name: 'NODO_AMBAR',
      description: 'Estética retro de terminal de los 80.',
      price: 1200,
      type: StoreItemType.theme,
      iconPath: 'assets/store/theme_amber.png',
    ),
    StoreItem(
      id: 'theme_cyber',
      name: 'PROTOCOLO_NEÓN',
      description: 'Colores vibrantes cian y magenta.',
      price: 1500,
      type: StoreItemType.theme,
      iconPath: 'assets/store/theme_cyber.png',
      isPremium: true,
    ),
    StoreItem(
      id: 'theme_ghost',
      name: 'NAVEGADOR_ESPECTRAL',
      description: 'Interfase minimalista en plata y blanco.',
      price: 1800,
      type: StoreItemType.theme,
      iconPath: 'assets/store/theme_ghost.png',
      isPremium: true,
    ),
    StoreItem(
      id: 'theme_blood',
      name: 'SINCRONIZADOR_CARMESÍ',
      description: 'Estética de alta alerta en tonos rojo sangre.',
      price: 2200,
      type: StoreItemType.theme,
      iconPath: 'assets/store/theme_blood.png',
      isPremium: true,
    ),
  ];

  // ============================================
  // PROTOCOLOS DE RED (VENTAJAS)
  // ============================================
  static final List<StoreItem> protocols = [
    StoreItem(
      id: 'protocol_vpn',
      name: 'VPN_EMOCIONAL',
      description: 'Reduce la velocidad de detección en un 15%.',
      price: 2000,
      type: StoreItemType.protocol,
      iconPath: 'assets/store/protocol_vpn.png',
    ),
    StoreItem(
      id: 'protocol_firewall',
      name: 'FIREWALL_NEURONAL',
      description: 'Reduce el daño a la estabilidad en un 10%.',
      price: 2500,
      type: StoreItemType.protocol,
      iconPath: 'assets/store/protocol_firewall.png',
      isPremium: true,
    ),
  ];

  // ============================================
  // CONTENIDO NARRATIVO
  // ============================================
  static final List<StoreItem> narrativeContent = [
    StoreItem(
      id: 'lore_system_tutorial',
      name: 'MANUAL_DE_ORIENTACIÓN_NOS',
      description: 'Guía esencial para nuevos Testigos del sistema.',
      price: 0,
      type: StoreItemType.narrative,
      iconPath: 'assets/store/lore_tutorial.png',
      loreContent: 'BIENVENIDO AL SISTEMA WITNESS-OS.\n\nSu tarea como Testigo es procesar los núcleos neuronales de los sujetos asignados. \n\n1. ESTABILIDAD: Durante el hackeo, su mente estará expuesta al trauma del sujeto. Si el temporizador llega a cero, el kernel colapsará y la sesión terminará.\n\n2. PROTOCOLOS: Utilice el VPN EMOCIONAL para ocultar su rastro y ganar tiempo. El FIREWALL NEURONAL absorberá el impacto de los errores de ejecución.\n\n3. EVIDENCIAS: El Juicio requiere pruebas. Encuentre fragmentos de memoria para construir el caso. El Juez lo observa todo.',
      loreImages: ['assets/images/lore/orientation.png'],
    ),
    StoreItem(
      id: 'lore_victor_logs',
      name: 'DIARIOS_DE_VÍCTOR',
      description: 'Grabaciones de voz sobre el origen del juicio.',
      price: 800,
      type: StoreItemType.narrative,
      iconPath: 'assets/store/lore_victor.png',
      loreContent: 'DÍA 412. La conexión con Alex es más profunda de lo que anticipamos. No es solo un puente neuronal; es una transferencia involuntaria de trauma. Si ella sufre en el juicio, yo lo siento aquí. El sistema WitnessOS no fue diseñado para juzgar humanos, sino para destilar la conciencia pura. ¿En qué nos hemos convertido? Si el Juez se entera de que estoy escribiendo esto...',
      loreImages: ['assets/images/lore/victor.png'],
    ),
    StoreItem(
      id: 'lore_subject_files',
      name: 'EXPEDIENTES_BORRADOS',
      description: 'Fotos y datos privados de los sujetos antes de morir.',
      price: 1000,
      type: StoreItemType.narrative,
      iconPath: 'assets/store/lore_subjects.png',
      loreContent: 'SUJETO 07: Daniel V. Estado: Desconectado. Causa: Colapso por Envidia de Nivel 4. Daniel no pudo soportar ver su propia vida a través de los ojos de los demás. Lo que el sistema le mostró no fue su realidad, sino una versión corrupta diseñada para quebrarlo. Encontramos su terminal encendida durante 72 horas seguidas antes del fallo del kernel. Nadie sobrevive al espejo de WitnessOS.',
      loreImages: ['assets/images/lore/subjects.png'],
    ),
    StoreItem(
      id: 'lore_protocol_manual',
      name: 'MANUAL_DE_PROTOCOLOS',
      description: 'Especificaciones técnicas de las defensas de red.',
      price: 1500,
      type: StoreItemType.narrative,
      iconPath: 'assets/store/lore_manual.png',
      isPremium: true,
      loreContent: 'PROTOCOLO VPN_EMOCIONAL: Emplea un túnel de datos cifrado que enmascara las fluctuaciones de dopamina del usuario, haciendo que el kernel de WitnessOS tarde más en triangular el origen de la anomalía. \n\nPROTOCOLO FIREWALL_NEURONAL: Despliega una barrera de redundancia sináptica. Cuando ocurre un error de ejecución, el Firewall absorbe la carga estática, evitando que la estabilidad mental se degrade al ritmo nominal. ADVERTENCIA: La exposición prolongada puede causar despersonalización.',
      loreImages: ['assets/images/lore/protocols.png'],
    ),
  ];

  // ============================================
  // MÚSICA DE FONDO (TRACKS)
  // ============================================
  static final List<StoreItem> backgroundMusic = [
    StoreItem(
      id: 'music_reflections',
      name: 'MEMORIA',
      description: 'Melodía melancólica del primer arco.',
      price: 0,
      type: StoreItemType.music,
      iconPath: 'assets/store/music_generic.png',
    ),
    StoreItem(
      id: 'music_excess',
      name: 'EXCESO',
      description: 'Ritmos pesados de consumo desenfrenado.',
      price: 0,
      type: StoreItemType.music,
      iconPath: 'assets/store/music_generic.png',
    ),
    StoreItem(
      id: 'music_spotlight',
      name: 'FOCO',
      description: 'Música tensa de escrutinio público.',
      price: 1500,
      type: StoreItemType.music,
      iconPath: 'assets/store/music_generic.png',
    ),
    StoreItem(
      id: 'music_ashes',
      name: 'CENIZAS',
      description: 'El tema final del colapso del kernel.',
      price: 2000,
      type: StoreItemType.music,
      iconPath: 'assets/store/music_generic.png',
    ),
    StoreItem(
      id: 'music_witness',
      name: 'NÚCLEO',
      description: 'El tema principal del sistema original.',
      price: 3500,
      type: StoreItemType.music,
      iconPath: 'assets/store/music_generic.png',
      isPremium: true,
    ),
  ];

  // ============================================
  // BATTLE PASS (1 item)
  // ============================================
  static final StoreItem battlePass = StoreItem(
    id: 'battle_pass',
    name: 'ACCESO TOTAL',
    description: 'PROGRESIÓN: EL JUEZ',
    price: 2500, // Precio en SEGS
    type: StoreItemType.battlePass,
    iconPath: 'assets/battlepass/banner.png',
    isPremium: true,
  );

  // ============================================
  // ALL ITEMS COMBINED
  // ============================================
  static final List<StoreItem> allItems = [
    ...bundles,
    ...visualThemes,
    ...protocols,
    ...narrativeContent,
    ...backgroundMusic,
    battlePass,
  ];

  /// Get all items of a specific type
  List<StoreItem> getItemsByType(StoreItemType type) {
    return allItems.where((item) => item.type == type).toList();
  }

  /// Get item by ID
  StoreItem? getItemById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all items
  List<StoreItem> getAllItems() {
    return List.unmodifiable(allItems);
  }

  /// Get count by type
  int getCountByType(StoreItemType type) {
    return allItems.where((item) => item.type == type).length;
  }
}
