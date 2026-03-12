# Plan de Implementación - Completar Tienda e Inventario

## Fase 1: Configuración y Widgets Base

- [x] 1. Configurar assets en pubspec.yaml


  - Agregar todas las rutas de assets de `assets/store/`
  - Verificar que todos los archivos existan
  - Ejecutar `flutter pub get`
  - _Requirements: 10.1, 10.2, 10.5_




- [ ] 2. Crear clase de configuración de assets
  - [ ] 2.1 Crear `lib/data/config/store_assets.dart`
    - Definir constantes para rutas de monedas
    - Definir métodos para obtener rutas de items
    - Definir métodos para obtener rutas de skins
    - Definir ruta de placeholder
    - _Requirements: 9.1, 10.2_




- [ ] 2.2 Escribir property test para rutas de assets
  - **Property 13: Carga de assets válida**
  - **Validates: Requirements 9.1, 10.2, 10.5**

- [ ] 3. Crear widget CoinDisplay
  - [ ] 3.1 Implementar widget CoinDisplay
    - Crear `lib/widgets/coin_display.dart`
    - Implementar lógica de selección de icono según cantidad
    - Implementar variantes de tamaño (small, medium, large)
    - Implementar versión clickeable
    - _Requirements: 2.1, 2.2, 2.3, 2.5_

  - [ ] 3.2 Escribir property test para CoinDisplay
    - **Property 1: Iconos de monedas consistentes**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.5**




  - [ ] 3.3 Escribir unit tests para CoinDisplay
    - Test para cada tamaño de icono
    - Test para versión clickeable
    - Test para diferentes cantidades
    - _Requirements: 2.1, 2.2, 2.3_

- [ ] 4. Crear widget ItemIcon
  - [ ] 4.1 Implementar widget ItemIcon
    - Crear `lib/widgets/item_icon.dart`
    - Implementar carga de assets con fallback
    - Implementar badges opcionales
    - Implementar diferentes tamaños
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [-] 4.2 Escribir property test para ItemIcon



    - **Property 2: Todos los items tienen iconos**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**

  - [ ] 4.3 Escribir unit tests para ItemIcon
    - Test para carga exitosa de asset
    - Test para fallback a placeholder
    - Test para diferentes tipos de items
    - _Requirements: 3.1, 3.5_


- [ ] 5. Crear widget SkinPreview
  - [ ] 5.1 Implementar widget SkinPreview
    - Crear `lib/widgets/skin_preview.dart`
    - Implementar carga de sprites de skins
    - Implementar frame decorativo
    - Implementar efectos para premium
    - Implementar indicador de equipado
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [ ] 5.2 Escribir property tests para SkinPreview
    - **Property 3: Rutas de assets correctas por tipo**




    - **Property 4: Efectos visuales para items premium**
    - **Property 5: Indicadores de estado visibles**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**


  - [ ] 5.3 Escribir unit tests para SkinPreview
    - Test para skins de jugador
    - Test para skins de pecados

    - Test para efectos premium
    - Test para indicador de equipado
    - _Requirements: 4.1, 4.2, 4.3, 4.5_



## Fase 2: Integración en Tienda Existente

- [ ] 6. Integrar CoinDisplay en StoreScreen
  - [ ] 6.1 Reemplazar indicador de monedas en header
    - Usar CoinDisplay en lugar de código inline
    - Mantener funcionalidad clickeable
    - Verificar que navegue a CoinsPurchaseScreen
    - _Requirements: 2.1, 2.4_

  - [-] 6.2 Integrar CoinDisplay en cards de items


    - Reemplazar iconos de monedas en precios
    - Usar tamaño apropiado para cards
    - _Requirements: 2.2_

  - [ ] 6.3 Integrar CoinDisplay en banner de pase
    - Mostrar precio con icono correcto
    - Mostrar recompensas de monedas
    - _Requirements: 1.1, 2.5_

- [ ] 7. Integrar ItemIcon en items consumibles
  - [ ] 7.1 Reemplazar placeholders en sección de items
    - Cargar iconos reales desde assets
    - Aplicar tamaño correcto (40x40)
    - Mantener diseño de cards existente
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ] 7.2 Integrar ItemIcon en recompensas del pase
    - Mostrar iconos de items en lista de recompensas
    - Usar tamaño pequeño para previews
    - _Requirements: 1.2_

- [ ] 8. Integrar SkinPreview en sección de skins
  - [ ] 8.1 Reemplazar placeholders en cards de skins
    - Cargar sprites reales de skins de jugador
    - Cargar sprites reales de skins de pecados
    - Aplicar efectos premium donde corresponda
    - Mostrar indicador de equipado
    - _Requirements: 4.1, 4.2, 4.3, 4.5_

  - [ ] 8.2 Integrar SkinPreview en recompensas del pase
    - Mostrar previews de skins en progreso
    - Usar tamaño apropiado para lista horizontal
    - _Requirements: 1.3, 1.5_




- [ ] 9. Mejorar visualización del pase de batalla
  - [ ] 9.1 Completar lista de recompensas
    - Mostrar todas las recompensas con iconos
    - Organizar por niveles
    - Indicar recompensas bloqueadas
    - _Requirements: 1.4_

  - [ ] 9.2 Escribir integration test para tienda mejorada
    - Test de navegación entre secciones
    - Test de visualización de todos los iconos
    - Test de interacción con elementos
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 3.1, 4.1_

- [ ] 10. Checkpoint - Verificar tienda completa
  - Asegurar que todos los tests pasen
  - Verificar que no haya errores de carga de assets
  - Verificar que la UI se vea profesional
  - Preguntar al usuario si hay dudas


## Fase 3: Sistema de Inventario

- [ ] 11. Crear modelo InventoryItem
  - [ ] 11.1 Implementar modelo InventoryItem
    - Crear `lib/data/models/inventory_item.dart`
    - Definir propiedades del modelo
    - Implementar método `getUsageText()`
    - Implementar método `getUsageIcon()`
    - Implementar método `canBeEquipped()`
    - _Requirements: 5.3, 6.2, 6.3, 6.4_

  - [ ] 11.2 Escribir property test para InventoryItem
    - **Property 7: Información de uso presente**
    - **Validates: Requirements 5.3, 6.2, 6.3, 6.4**

  - [ ] 11.3 Escribir unit tests para InventoryItem
    - Test para getUsageText() con diferentes tipos



    - Test para getUsageIcon() con diferentes tipos
    - Test para canBeEquipped()
    - _Requirements: 5.3, 6.2, 6.3, 6.4_

- [ ] 12. Extender StoreProvider para inventario
  - [ ] 12.1 Agregar métodos de inventario a StoreProvider
    - Agregar método `getInventoryItems()`
    - Agregar método `filterByCategory(String category)`
    - Agregar método `equipItem(String itemId)`
    - Agregar método `unequipItem(String itemId)`
    - Mantener sincronización con Firebase



    - _Requirements: 5.2, 7.4, 7.5, 8.1, 8.2_

  - [ ] 12.2 Escribir property tests para StoreProvider
    - **Property 6: Inventario completo**
    - **Property 9: Sincronización entre pantallas**
    - **Property 10: Categorización correcta**
    - **Validates: Requirements 5.2, 7.4, 7.5, 8.1, 8.2**

  - [ ] 12.3 Escribir unit tests para métodos de inventario
    - Test para getInventoryItems()
    - Test para filterByCategory()
    - Test para equipItem()
    - Test para unequipItem()
    - _Requirements: 5.2, 8.2_

- [ ] 13. Crear widget UsageInfoBadge
  - [ ] 13.1 Implementar widget UsageInfoBadge
    - Crear `lib/widgets/usage_info_badge.dart`
    - Implementar display de texto de uso
    - Implementar iconos apropiados



    - Mantener diseño consistente
    - _Requirements: 5.3, 6.1_

  - [ ] 13.2 Escribir unit tests para UsageInfoBadge
    - Test para diferentes textos de uso
    - Test para diferentes iconos
    - Test para estilos visuales
    - _Requirements: 5.3_

- [ ] 14. Crear widget InventoryItemCard
  - [ ] 14.1 Implementar widget InventoryItemCard
    - Crear `lib/widgets/inventory_item_card.dart`
    - Integrar ItemIcon/SkinPreview según tipo
    - Mostrar nombre y descripción
    - Integrar UsageInfoBadge
    - Mostrar estado (equipado, cantidad)
    - Implementar botón de equipar/desequipar
    - _Requirements: 5.3, 5.4, 5.5_

  - [ ] 14.2 Escribir property tests para InventoryItemCard
    - **Property 5: Indicadores de estado visibles**
    - **Property 8: Cantidades visibles para consumibles**
    - **Validates: Requirements 5.4, 5.5**

  - [ ] 14.3 Escribir unit tests para InventoryItemCard
    - Test para diferentes tipos de items
    - Test para estado equipado
    - Test para cantidades de consumibles
    - Test para interacción de equipar
    - _Requirements: 5.3, 5.4, 5.5_


- [ ] 15. Crear pantalla InventoryScreen
  - [ ] 15.1 Implementar estructura base de InventoryScreen
    - Crear `lib/screens/inventory_screen.dart`
    - Implementar header con navegación
    - Implementar tabs de categorías
    - Implementar área de contenido con scroll
    - _Requirements: 5.1, 7.1, 7.2, 8.1_

  - [ ] 15.2 Implementar sistema de categorías
    - Implementar filtrado por categoría (Todo, Skins, Items, Pase)
    - Conectar con StoreProvider.filterByCategory()
    - Mantener estado de categoría seleccionada
    - _Requirements: 8.1, 8.2_

  - [ ] 15.3 Implementar grid de items
    - Cargar items desde StoreProvider
    - Renderizar InventoryItemCard para cada item
    - Implementar layout responsive
    - Manejar inventario vacío
    - _Requirements: 5.2, 8.5_

  - [ ] 15.4 Implementar separación de skins
    - Separar skins de jugador y skins de pecados
    - Mostrar secciones con títulos
    - _Requirements: 8.3_

  - [ ] 15.5 Implementar agrupación de consumibles
    - Agrupar por tipo (defensivo, sigilo, ofensivo)
    - Mostrar secciones con títulos
    - _Requirements: 8.4_

  - [ ] 15.6 Escribir property tests para InventoryScreen
    - **Property 11: Separación de tipos de skins**
    - **Property 12: Agrupación de consumibles**
    - **Validates: Requirements 8.3, 8.4**

  - [ ] 15.7 Escribir widget tests para InventoryScreen
    - Test para renderizado completo
    - Test para cambio de categorías
    - Test para inventario vacío
    - Test para diferentes tipos de items
    - _Requirements: 5.1, 5.2, 8.1, 8.2, 8.5_

- [ ] 16. Implementar navegación entre tienda e inventario
  - [ ] 16.1 Agregar botón de inventario en StoreScreen
    - Agregar botón en header de tienda
    - Implementar navegación a InventoryScreen
    - Usar icono distintivo
    - _Requirements: 7.1_

  - [ ] 16.2 Agregar botón de tienda en InventoryScreen
    - Agregar botón en header de inventario
    - Implementar navegación de regreso
    - _Requirements: 7.2_

  - [ ] 16.3 Implementar preservación de estado
    - Usar PageStorage para scroll
    - Guardar categoría seleccionada en Provider
    - Restaurar estado al navegar
    - _Requirements: 7.3_

  - [ ] 16.4 Escribir integration tests para navegación
    - Test de navegación tienda → inventario → tienda
    - Test de preservación de estado
    - Test de sincronización después de compra
    - Test de sincronización después de equipar
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 17. Checkpoint - Verificar inventario completo
  - Asegurar que todos los tests pasen
  - Verificar navegación fluida
  - Verificar sincronización entre pantallas
  - Preguntar al usuario si hay dudas


## Fase 4: Optimización y Pulido

- [ ] 18. Implementar preloading de assets
  - [ ] 18.1 Crear función de precarga
    - Crear función `precacheStoreAssets()`
    - Precargar iconos de monedas
    - Precargar iconos comunes de items
    - Precargar sprites de skins más usadas
    - _Requirements: 9.5_

  - [ ] 18.2 Integrar precarga en app startup
    - Llamar precarga en splash screen o main
    - Mostrar indicador de carga si es necesario
    - _Requirements: 9.5_

- [ ] 19. Optimizar rendimiento
  - [ ] 19.1 Implementar optimizaciones de memoria
    - Usar cacheWidth y cacheHeight en imágenes
    - Liberar recursos al salir de pantallas
    - Optimizar tamaños de assets
    - _Requirements: 9.5_

  - [ ] 19.2 Implementar lazy loading
    - Cargar items del inventario bajo demanda
    - Usar ListView.builder para listas largas
    - _Requirements: 5.2_

  - [ ] 19.3 Escribir performance tests
    - Test de tiempo de carga de pantallas
    - Test de uso de memoria
    - Test de frame rate (60 FPS)
    - _Requirements: 9.5_

- [ ] 20. Implementar accesibilidad
  - [ ] 20.1 Agregar semantic labels
    - Agregar labels a todos los iconos
    - Agregar labels a botones
    - Agregar labels a cards interactivos
    - _Requirements: UI/UX_

  - [ ] 20.2 Verificar tamaños mínimos
    - Asegurar botones de 44x44 mínimo
    - Verificar áreas táctiles
    - _Requirements: UI/UX_

  - [ ] 20.3 Verificar contraste de colores
    - Verificar que cumpla WCAG AA
    - Ajustar colores si es necesario
    - _Requirements: UI/UX_

  - [ ] 20.4 Escribir accessibility tests
    - Test de semantic labels
    - Test de tamaños de botones
    - Test de contraste
    - _Requirements: UI/UX_

- [ ] 21. Pulir UI/UX
  - [ ] 21.1 Implementar animaciones
    - Animación de equipar/desequipar
    - Transiciones entre pantallas
    - Animaciones de carga
    - _Requirements: UI/UX_

  - [ ] 21.2 Ajustar espaciado y alineación
    - Verificar consistencia visual
    - Ajustar padding y margins
    - Verificar en diferentes tamaños de pantalla
    - _Requirements: UI/UX_

  - [ ] 21.3 Implementar feedback visual
    - Efectos de hover/press en botones
    - Indicadores de carga
    - Mensajes de confirmación
    - _Requirements: UI/UX_

- [ ] 22. Testing final y corrección de bugs
  - [ ] 22.1 Ejecutar todos los tests
    - Ejecutar unit tests
    - Ejecutar property tests
    - Ejecutar integration tests
    - Ejecutar widget tests
    - Corregir cualquier fallo

  - [ ] 22.2 Testing manual completo
    - Probar todos los flujos de usuario
    - Probar en diferentes dispositivos
    - Probar con diferentes tamaños de inventario
    - Verificar manejo de errores

  - [ ] 22.3 Verificar assets
    - Confirmar que todos los assets se cargan
    - Verificar que placeholders funcionan
    - Verificar que no hay assets faltantes
    - _Requirements: 9.1, 9.2_

- [ ] 23. Checkpoint final
  - Asegurar que todos los tests pasen
  - Verificar que la implementación cumple todos los requisitos
  - Verificar que no hay errores ni warnings
  - Preguntar al usuario si hay dudas o ajustes finales

## Resumen de Tareas

**Total de tareas principales**: 23
**Total de subtareas**: 78 (todas requeridas)
**Tareas de testing incluidas**: 20

**Distribución por fase:**
- Fase 1 (Widgets Base): 5 tareas principales
- Fase 2 (Integración Tienda): 5 tareas principales
- Fase 3 (Sistema Inventario): 7 tareas principales
- Fase 4 (Optimización): 6 tareas principales

**Tiempo estimado**: 30-35 horas de desarrollo (incluyendo testing completo)
