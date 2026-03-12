/// Configuración centralizada de rutas de assets de la tienda
class StoreAssets {
  // Prevenir instanciación
  StoreAssets._();

  // ==================== MONEDAS ====================
  
  /// Icono básico de moneda
  static const String coinIcon = 'assets/store/currency/coin_icon.png';
  
  /// Stack pequeño de monedas (para cantidades bajas)
  static const String coinStackSmall = 'assets/store/currency/coin_stack_small.png';
  
  /// Stack mediano de monedas (para cantidades medias)
  static const String coinStackMedium = 'assets/store/currency/coin_stack_medium.png';
  
  /// Stack grande de monedas (para cantidades altas)
  static const String coinStackLarge = 'assets/store/currency/coin_stack_large.png';

  /// Obtiene el icono de moneda apropiado según la cantidad
  static String getCoinIcon(int amount) {
    if (amount >= 1000) {
      return coinStackLarge;
    } else if (amount >= 100) {
      return coinStackMedium;
    } else if (amount >= 10) {
      return coinStackSmall;
    } else {
      return coinIcon;
    }
  }

  // ==================== BACKGROUNDS ====================
  
  /// Background principal de la tienda
  static const String storeBackground = 'assets/store/backgrounds/store_background.jpg';
  
  /// Background de la sección de skins
  static const String storeBackgroundSkins = 'assets/store/backgrounds/store_background_skins.jpg';
  
  /// Background de la sección de pase de batalla
  static const String storeBackgroundBattlepass = 'assets/store/backgrounds/store_background_battlepass.jpg';

  // ==================== ITEMS CONSUMIBLES ====================
  
  /// Obtiene la ruta del icono de un item consumible
  static String getConsumableIcon(String itemId) {
    return 'assets/store/items/consumables/$itemId.png';
  }

  // Items específicos
  static const String itemAltAccount = 'assets/store/items/consumables/item_alt_account.png';
  static const String itemFirewall = 'assets/store/items/consumables/item_firewall.png';
  static const String itemIncognitoMode = 'assets/store/items/consumables/item_incognito_mode.png';
  static const String itemRestoreSanity = 'assets/store/items/consumables/item_restore_sanity.png';
  static const String itemTrendingTopic = 'assets/store/items/consumables/item_trending_topic.png';
  static const String itemVpn = 'assets/store/items/consumables/item_vpn.png';

  // Frames de items
  static const String itemFrameCommon = 'assets/store/items/consumables/item_frame_common.png';
  static const String itemFramePremium = 'assets/store/items/consumables/item_frame_premium.png';

  // Badges de cantidad
  static const String itemQuantityBadgeX3 = 'assets/store/items/consumables/item_quantity_badge_x3.png';
  static const String itemQuantityBadgeX5 = 'assets/store/items/consumables/item_quantity_badge_x5.png';
  static const String itemQuantityBadgeX10 = 'assets/store/items/consumables/item_quantity_badge_x10.png';

  // ==================== SKINS DE JUGADOR ====================
  
  /// Obtiene la ruta del spritesheet de una skin de jugador
  static String getPlayerSkinSprite(String skinId) {
    return 'assets/store/skins/player/spritesheets/$skinId.png';
  }

  // Skins específicas de jugador
  static const String playerSkinAnonymous = 'assets/store/skins/player/spritesheets/player_skin_anonymous.png';
  static const String playerSkinInfluencer = 'assets/store/skins/player/spritesheets/player_skin_influencer.png';
  static const String playerSkinModerator = 'assets/store/skins/player/spritesheets/player_skin_moderator.png';
  static const String playerSkinTroll = 'assets/store/skins/player/spritesheets/player_skin_troll.png';
  static const String playerSkinGhostUser = 'assets/store/skins/player/spritesheets/player_skin_ghost_user.png';

  // ==================== SKINS DE PECADOS ====================
  
  /// Obtiene la ruta del spritesheet de una skin de pecado
  static String getSinSkinSprite(String skinId) {
    return 'assets/store/skins/sins/porcelain/$skinId.png';
  }

  // Skins específicas de pecados
  static const String sinGluttonyPorcelain = 'assets/store/skins/sins/porcelain/sin_gluttony_porcelain.png';
  static const String sinGluttonyGlitch = 'assets/store/skins/sins/porcelain/sin_gluttony_glitch.png';
  static const String sinGreedPorcelain = 'assets/store/skins/sins/porcelain/sin_greed_porcelain.png';
  static const String sinGreedGlitch = 'assets/store/skins/sins/porcelain/sin_greed_glitch.png';

  // ==================== PASE DE BATALLA ====================
  
  /// Banner del pase de batalla
  static const String battlepassBanner = 'assets/store/battlepass/ui/battlepass_banner.jpg';

  // ==================== PLACEHOLDER ====================
  
  /// Icono placeholder para cuando un asset no se puede cargar
  static const String placeholderIcon = 'assets/images/archi.png'; // Temporal, usar un placeholder real

  /// Verifica si una ruta de asset es válida (existe en la configuración)
  static bool isValidAssetPath(String path) {
    // Lista de todas las rutas válidas
    final validPaths = [
      coinIcon,
      coinStackSmall,
      coinStackMedium,
      coinStackLarge,
      storeBackground,
      storeBackgroundSkins,
      storeBackgroundBattlepass,
      itemAltAccount,
      itemFirewall,
      itemIncognitoMode,
      itemRestoreSanity,
      itemTrendingTopic,
      itemVpn,
      itemFrameCommon,
      itemFramePremium,
      itemQuantityBadgeX3,
      itemQuantityBadgeX5,
      itemQuantityBadgeX10,
      playerSkinAnonymous,
      playerSkinInfluencer,
      playerSkinModerator,
      playerSkinTroll,
      playerSkinGhostUser,
      sinGluttonyPorcelain,
      sinGluttonyGlitch,
      sinGreedPorcelain,
      sinGreedGlitch,
      battlepassBanner,
      placeholderIcon,
    ];
    
    return validPaths.contains(path) || 
           path.startsWith('assets/store/items/consumables/') ||
           path.startsWith('assets/store/skins/player/spritesheets/') ||
           path.startsWith('assets/store/skins/sins/porcelain/');
  }
}
