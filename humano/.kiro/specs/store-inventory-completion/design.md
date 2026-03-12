# Documento de Diseño - Completar Tienda e Inventario

## Overview

Este diseño completa la implementación visual de la tienda in-game y crea un sistema de inventario separado. El sistema integrará todos los assets visuales (iconos de items, monedas, skins) y proporcionará una experiencia de usuario completa para gestionar compras y equipamiento.

### Objetivos Principales

1. Integrar todos los assets visuales en la tienda existente
2. Crear una pantalla de inventario separada y funcional
3. Implementar navegación fluida entre tienda e inventario
4. Mostrar información clara sobre dónde se usa cada item
5. Mantener consistencia visual en toda la aplicación

### Alcance

**Incluido:**
- Integración de iconos de monedas en toda la UI
- Integración de iconos de items consumibles
- Integración de sprites de skins
- Pantalla de inventario completa
- Sistema de categorización de items
- Información de uso de items
- Navegación entre tienda e inventario

**No Incluido:**
- Lógica de compra con Firebase (ya existe)
- Sistema de persistencia (ya existe)
- Compilación de spritesheets (assets ya existen)
- Sistema de pagos reales

## Architecture

### Estructura de Componentes

```
lib/
├── screens/
│   ├── store_screen.dart (existente - mejorar)
│   └── inventory_screen.dart (nuevo)
├── widgets/
│   ├── coin_display.dart (nuevo)
│   ├── item_icon.dart (nuevo)
│   ├── skin_preview.dart (nuevo)
│   ├── inventory_item_card.dart (nuevo)
│   └── usage_info_badge.dart (nuevo)
├── providers/
│   └── store_provider.dart (existente - extender)
└── data/
    └── models/
        └── inventory_item.dart (nuevo)
```


### Flujo de Datos

```
Usuario → StoreScreen/InventoryScreen
    ↓
StoreProvider (estado compartido)
    ↓
Widgets especializados (CoinDisplay, ItemIcon, etc.)
    ↓
Assets (imágenes desde assets/store/)
```

### Patrones de Diseño

1. **Provider Pattern**: Para gestión de estado compartido entre tienda e inventario
2. **Widget Composition**: Widgets reutilizables para iconos y displays
3. **Asset Management**: Carga centralizada de assets con fallbacks
4. **Category Pattern**: Organización por categorías en inventario

## Components and Interfaces

### 1. CoinDisplay Widget

Widget reutilizable para mostrar monedas con icono.

```dart
class CoinDisplay extends StatelessWidget {
  final int amount;
  final CoinDisplaySize size; // small, medium, large
  final bool clickable;
  final VoidCallback? onTap;
}
```

**Responsabilidades:**
- Mostrar cantidad de monedas con icono apropiado
- Seleccionar icono según cantidad (small/medium/large stack)
- Manejar interacción si es clickeable

### 2. ItemIcon Widget

Widget para mostrar iconos de items con fallback.

```dart
class ItemIcon extends StatelessWidget {
  final String itemId;
  final StoreItemType type;
  final double size;
  final bool showBadge;
}
```

**Responsabilidades:**
- Cargar icono desde assets según tipo de item
- Mostrar placeholder si el asset no existe
- Aplicar tamaño correcto
- Mostrar badges opcionales (premium, nuevo, etc.)

### 3. SkinPreview Widget

Widget para mostrar preview de skins con frame.

```dart
class SkinPreview extends StatelessWidget {
  final String skinId;
  final bool isEquipped;
  final bool isPremium;
  final VoidCallback? onTap;
}
```

**Responsabilidades:**
- Cargar sprite de skin desde assets
- Aplicar frame decorativo
- Mostrar indicador de equipado
- Aplicar efectos visuales para premium


### 4. InventoryScreen

Pantalla principal del inventario.

```dart
class InventoryScreen extends StatefulWidget {
  // Categorías: all, skins, items, battlepass
  String selectedCategory = 'all';
}
```

**Responsabilidades:**
- Mostrar items del usuario organizados por categoría
- Permitir filtrado por categoría
- Mostrar información de uso de cada item
- Navegar de regreso a la tienda
- Sincronizar con StoreProvider

### 5. InventoryItemCard Widget

Card para mostrar items en el inventario.

```dart
class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onEquip;
  final VoidCallback? onDetails;
}
```

**Responsabilidades:**
- Mostrar icono/sprite del item
- Mostrar nombre y descripción
- Mostrar información de uso
- Mostrar estado (equipado, cantidad, etc.)
- Permitir equipar/desequipar

### 6. UsageInfoBadge Widget

Badge que muestra dónde se usa un item.

```dart
class UsageInfoBadge extends StatelessWidget {
  final String usageText;
  final IconData icon;
}
```

**Responsabilidades:**
- Mostrar texto de uso de forma clara
- Usar iconos apropiados según contexto
- Mantener diseño consistente

## Data Models

### InventoryItem Model

```dart
class InventoryItem {
  final String id;
  final String name;
  final String description;
  final StoreItemType type;
  final String iconPath;
  final bool isEquipped;
  final int quantity; // Para consumibles
  final String usageInfo;
  final DateTime acquiredDate;
  
  // Métodos
  String getUsageText();
  IconData getUsageIcon();
  bool canBeEquipped();
}
```

### Asset Paths Configuration

```dart
class StoreAssets {
  // Monedas
  static const String coinIcon = 'assets/store/currency/coin_icon.png';
  static const String coinStackSmall = 'assets/store/currency/coin_stack_small.png';
  static const String coinStackMedium = 'assets/store/currency/coin_stack_medium.png';
  static const String coinStackLarge = 'assets/store/currency/coin_stack_large.png';
  
  // Items consumibles
  static String getConsumableIcon(String itemId) {
    return 'assets/store/items/consumables/$itemId.png';
  }
  
  // Skins
  static String getPlayerSkinSprite(String skinId) {
    return 'assets/store/skins/player/$skinId.png';
  }
  
  static String getSinSkinSprite(String skinId) {
    return 'assets/store/skins/sins/$skinId.png';
  }
  
  // Placeholder
  static const String placeholderIcon = 'assets/store/ui/placeholder.png';
}
```


## Correctness Properties

*Una propiedad es una característica o comportamiento que debe mantenerse verdadero en todas las ejecuciones válidas de un sistema - esencialmente, una declaración formal sobre lo que el sistema debe hacer. Las propiedades sirven como puente entre especificaciones legibles por humanos y garantías de corrección verificables por máquina.*

### Property 1: Iconos de monedas consistentes

*Para cualquier* componente que muestre monedas (saldo, precio, recompensa), el sistema debe usar el icono de moneda apropiado según la cantidad mostrada.

**Validates: Requirements 2.1, 2.2, 2.3, 2.5**

### Property 2: Todos los items tienen iconos

*Para cualquier* item mostrado en la tienda o inventario, el sistema debe mostrar un icono válido (ya sea el asset real o un placeholder).

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

### Property 3: Rutas de assets correctas por tipo

*Para cualquier* skin de jugador, el sistema debe cargar el sprite desde `assets/store/skins/player/`, y para cualquier skin de pecado, desde `assets/store/skins/sins/`.

**Validates: Requirements 4.1, 4.2**

### Property 4: Efectos visuales para items premium

*Para cualquier* item marcado como premium, el sistema debe aplicar efectos visuales distintivos (borde, sombra, badge).

**Validates: Requirements 4.3**

### Property 5: Indicadores de estado visibles

*Para cualquier* skin equipada, el sistema debe mostrar un indicador de "EQUIPADO", y para cualquier skin gratuita, debe indicar claramente que es gratuita.

**Validates: Requirements 4.4, 4.5, 5.4**

### Property 6: Inventario completo

*Para cualquier* conjunto de items que el usuario posea, el inventario debe listar todos los items sin omitir ninguno.

**Validates: Requirements 5.2**

### Property 7: Información de uso presente

*Para cualquier* item en el inventario, el sistema debe mostrar información sobre dónde se utiliza ese item.

**Validates: Requirements 5.3, 6.2, 6.3, 6.4**

### Property 8: Cantidades visibles para consumibles

*Para cualquier* item consumible en el inventario, el sistema debe mostrar la cantidad disponible.

**Validates: Requirements 5.5**

### Property 9: Sincronización entre pantallas

*Para cualquier* cambio de estado (compra, equipamiento), el sistema debe reflejar el cambio en ambas pantallas (tienda e inventario).

**Validates: Requirements 7.3, 7.4, 7.5**

### Property 10: Categorización correcta

*Para cualquier* item en el inventario, el sistema debe colocarlo en la categoría correcta (Skins, Items, Pase).

**Validates: Requirements 8.1, 8.2**

### Property 11: Separación de tipos de skins

*Para cualquier* conjunto de skins mostradas, el sistema debe separar correctamente las skins de jugador de las skins de pecados.

**Validates: Requirements 8.3**

### Property 12: Agrupación de consumibles

*Para cualquier* conjunto de items consumibles, el sistema debe agruparlos correctamente por tipo (defensivo, sigilo, ofensivo).

**Validates: Requirements 8.4**

### Property 13: Carga de assets válida

*Para cualquier* asset que el sistema intente cargar, la ruta debe ser válida y apuntar a un archivo existente en `assets/store/`.

**Validates: Requirements 9.1, 10.2, 10.5**

### Property 14: Tamaños de iconos apropiados

*Para cualquier* contexto donde se muestre un icono, el sistema debe aplicar el tamaño apropiado según ese contexto.

**Validates: Requirements 9.3**

### Property 15: Frames correctos en spritesheets

*Para cualquier* animación de skin, el sistema debe aplicar el frame correcto del spritesheet según el estado de la animación.

**Validates: Requirements 9.4**


## Error Handling

### Asset Loading Errors

**Escenario**: Un asset no puede ser cargado (archivo no existe, ruta incorrecta, etc.)

**Manejo**:
1. Registrar error en consola con detalles (ruta, tipo de asset)
2. Mostrar placeholder genérico
3. Continuar ejecución sin crashear
4. Notificar al usuario solo si es crítico

```dart
Future<ImageProvider> loadAssetWithFallback(String path) async {
  try {
    // Verificar si el asset existe
    await rootBundle.load(path);
    return AssetImage(path);
  } catch (e) {
    debugPrint('Error loading asset: $path - $e');
    return AssetImage(StoreAssets.placeholderIcon);
  }
}
```

### Empty Inventory

**Escenario**: El usuario no tiene items en su inventario

**Manejo**:
1. Mostrar mensaje amigable: "Tu inventario está vacío"
2. Mostrar botón para ir a la tienda
3. Mostrar ilustración o icono decorativo
4. No mostrar error, es un estado válido

### Missing Usage Information

**Escenario**: Un item no tiene información de uso definida

**Manejo**:
1. Mostrar texto genérico: "Item disponible"
2. Registrar warning en desarrollo
3. No bloquear la UI

### Navigation State Loss

**Escenario**: El estado de scroll o selección se pierde al navegar

**Manejo**:
1. Usar PageStorage para preservar scroll
2. Guardar selección en Provider
3. Restaurar estado al regresar

## Testing Strategy

### Unit Tests

**Widgets a testear:**
- `CoinDisplay`: Verifica que muestre el icono correcto según cantidad
- `ItemIcon`: Verifica carga de assets y fallback a placeholder
- `SkinPreview`: Verifica carga de sprites y efectos premium
- `InventoryItemCard`: Verifica display de información completa
- `UsageInfoBadge`: Verifica texto e iconos correctos

**Providers a testear:**
- `StoreProvider.loadInventory()`: Verifica carga correcta de items
- `StoreProvider.equipItem()`: Verifica cambio de estado
- `StoreProvider.filterByCategory()`: Verifica filtrado correcto

**Modelos a testear:**
- `InventoryItem.getUsageText()`: Verifica texto según tipo
- `InventoryItem.canBeEquipped()`: Verifica lógica de equipamiento

### Property-Based Tests

Se utilizará el paquete `test` de Dart con generadores personalizados para property testing.

**Configuración:**
- Mínimo 100 iteraciones por propiedad
- Generadores para items, skins, cantidades de monedas
- Seeds aleatorias para reproducibilidad

**Properties a implementar:**
- Property 1-15 como se definieron arriba
- Cada property en su propio test
- Tags con referencias a requisitos

### Integration Tests

**Flujos a testear:**
1. Navegación tienda → inventario → tienda
2. Compra de item → aparece en inventario
3. Equipar skin → se refleja en ambas pantallas
4. Filtrar por categoría → solo muestra items correctos

### Widget Tests

**Pantallas completas:**
- `InventoryScreen`: Verifica renderizado completo
- `StoreScreen` (mejorada): Verifica integración de nuevos widgets


## UI/UX Specifications

### Inventory Screen Layout

```
┌─────────────────────────────────────┐
│ [←] INVENTARIO        [🛒] Tienda   │ Header
├─────────────────────────────────────┤
│ [Todo] [Skins] [Items] [Pase]       │ Category Tabs
├─────────────────────────────────────┤
│                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐      │
│  │ Skin │  │ Skin │  │ Item │      │
│  │ Icon │  │ Icon │  │ Icon │      │
│  │      │  │      │  │      │      │
│  │ Name │  │ Name │  │ Name │      │
│  │ [✓]  │  │ [ ]  │  │ x5   │      │ Grid de Items
│  │ Uso  │  │ Uso  │  │ Uso  │      │
│  └──────┘  └──────┘  └──────┘      │
│                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐      │
│  │ ...  │  │ ...  │  │ ...  │      │
│  └──────┘  └──────┘  └──────┘      │
│                                     │
└─────────────────────────────────────┘
```

### Color Scheme

Mantener consistencia con la tienda existente:

```dart
// Colores principales
const wineRed = Color(0xFF8B0000);      // Bordes, botones
const lightRed = Color(0xFFE57373);     // Premium, highlights
const darkRed = Color(0xFFCD5C5C);      // Monedas, acentos
const black = Colors.black;              // Fondo
const grey = Color(0xFF424242);          // Deshabilitado
```

### Typography

```dart
// Usar Google Fonts - Courier Prime
final titleStyle = GoogleFonts.courierPrime(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final bodyStyle = GoogleFonts.courierPrime(
  fontSize: 10,
  color: Colors.grey[400],
);

final badgeStyle = GoogleFonts.courierPrime(
  fontSize: 8,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);
```

### Spacing and Sizing

```dart
// Espaciado
const smallPadding = 4.0;
const mediumPadding = 8.0;
const largePadding = 16.0;

// Tamaños de iconos
const smallIconSize = 16.0;
const mediumIconSize = 24.0;
const largeIconSize = 48.0;

// Tamaños de cards
const inventoryCardWidth = 100.0;
const inventoryCardHeight = 140.0;
```

### Animations

```dart
// Transiciones suaves
const defaultDuration = Duration(milliseconds: 200);
const defaultCurve = Curves.easeInOut;

// Animaciones de equipamiento
const equipAnimationDuration = Duration(milliseconds: 300);
const equipAnimationCurve = Curves.elasticOut;
```

## Implementation Notes

### Asset Preloading

Para mejorar el rendimiento, precargar assets comunes al iniciar la app:

```dart
Future<void> precacheStoreAssets(BuildContext context) async {
  await precacheImage(AssetImage(StoreAssets.coinIcon), context);
  await precacheImage(AssetImage(StoreAssets.coinStackSmall), context);
  await precacheImage(AssetImage(StoreAssets.coinStackMedium), context);
  await precacheImage(AssetImage(StoreAssets.coinStackLarge), context);
  // ... otros assets comunes
}
```

### Memory Management

- Usar `Image.asset()` con `cacheWidth` y `cacheHeight` para optimizar memoria
- Liberar recursos al salir de pantallas
- Usar `AutomaticKeepAliveClientMixin` solo cuando sea necesario

### Accessibility

- Todos los iconos deben tener `semanticLabel`
- Botones deben tener tamaño mínimo de 44x44
- Contraste de colores debe cumplir WCAG AA
- Soporte para lectores de pantalla

### Platform Considerations

- Usar `Platform.isAndroid` / `Platform.isIOS` para ajustes específicos
- Respetar safe areas en todas las pantallas
- Adaptar tamaños según densidad de pantalla

## Dependencies

### Existing Dependencies (ya en pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  google_fonts: ^6.1.0
  flame: ^1.18.0
```

### No New Dependencies Required

Todas las funcionalidades se pueden implementar con las dependencias existentes.

## Migration Strategy

### Phase 1: Widgets Reutilizables

1. Crear `CoinDisplay` widget
2. Crear `ItemIcon` widget
3. Crear `SkinPreview` widget
4. Testear widgets individualmente

### Phase 2: Integración en Tienda

1. Reemplazar iconos placeholder en `StoreScreen`
2. Integrar `CoinDisplay` en header y cards
3. Integrar `ItemIcon` en items consumibles
4. Integrar `SkinPreview` en skins
5. Testear tienda completa

### Phase 3: Pantalla de Inventario

1. Crear `InventoryScreen`
2. Crear `InventoryItemCard` widget
3. Crear `UsageInfoBadge` widget
4. Implementar navegación
5. Testear inventario completo

### Phase 4: Sincronización

1. Extender `StoreProvider` con métodos de inventario
2. Implementar sincronización entre pantallas
3. Testear flujos completos
4. Optimizar rendimiento

## Success Criteria

✅ Todos los iconos de monedas se muestran correctamente
✅ Todos los items tienen iconos (reales o placeholder)
✅ Todas las skins muestran sus sprites
✅ La pantalla de inventario es funcional y navegable
✅ La información de uso es clara y precisa
✅ La navegación entre tienda e inventario es fluida
✅ El estado se sincroniza correctamente entre pantallas
✅ No hay errores de carga de assets
✅ El rendimiento es óptimo (60 FPS)
✅ Todos los tests pasan
