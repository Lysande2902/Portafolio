# Documento de Requisitos - Completar Tienda e Inventario

## Introducción

Este documento define los requisitos para completar la implementación visual de la tienda in-game y crear un sistema de inventario separado. El sistema debe mostrar todos los assets visuales correctamente (iconos de items, monedas, skins) y proporcionar una pantalla de inventario donde los usuarios puedan ver sus compras y dónde se utilizan.

## Glosario

- **Sistema de Tienda**: La interfaz donde los usuarios pueden comprar items, skins y el pase de batalla
- **Sistema de Inventario**: Una pantalla separada donde los usuarios ven sus items comprados y equipados
- **Pase de Batalla**: Sistema de progresión premium con recompensas por niveles
- **Skin**: Apariencia visual del personaje del jugador o enemigos
- **Item Consumible**: Item de un solo uso que proporciona beneficios temporales
- **Moneda del Juego**: Moneda virtual usada para compras dentro del juego
- **Asset Visual**: Imagen o sprite usado en la interfaz de usuario

## Requisitos

### Requisito 1: Visualización Completa del Pase de Batalla

**Historia de Usuario:** Como jugador, quiero ver el banner del pase de batalla con todos sus elementos visuales (iconos de items, monedas, recompensas), para entender qué incluye antes de comprarlo.

#### Criterios de Aceptación

1. WHEN el sistema muestra el banner del pase de batalla THEN el sistema SHALL mostrar el icono de monedas usando el asset correspondiente
2. WHEN el sistema muestra recompensas del pase THEN el sistema SHALL mostrar iconos de items usando los assets correspondientes
3. WHEN el sistema muestra el progreso del pase THEN el sistema SHALL mostrar previews visuales de las próximas recompensas
4. WHEN el usuario navega a la sección de pase THEN el sistema SHALL mostrar una lista completa de recompensas con sus iconos
5. WHEN el sistema muestra skins en el pase THEN el sistema SHALL usar los sprites compilados de los skins

### Requisito 2: Iconos de Monedas en Toda la Tienda

**Historia de Usuario:** Como jugador, quiero ver iconos de monedas consistentes en toda la tienda, para identificar fácilmente los precios y mi saldo.

#### Criterios de Aceptación

1. WHEN el sistema muestra el saldo del usuario THEN el sistema SHALL usar el icono de moneda del asset `coin_icon.png`
2. WHEN el sistema muestra precios de items THEN el sistema SHALL mostrar el icono de moneda junto al precio
3. WHEN el sistema muestra paquetes de monedas THEN el sistema SHALL usar los assets `coin_stack_small.png`, `coin_stack_medium.png`, `coin_stack_large.png` según la cantidad
4. WHEN el usuario hace click en el indicador de monedas THEN el sistema SHALL navegar a la pantalla de compra de monedas
5. WHEN el sistema muestra recompensas de monedas THEN el sistema SHALL usar el icono apropiado según la cantidad

### Requisito 3: Visualización de Items Consumibles

**Historia de Usuario:** Como jugador, quiero ver iconos claros de los items consumibles en la tienda, para identificar rápidamente qué hace cada item.

#### Criterios de Aceptación

1. WHEN el sistema muestra items consumibles THEN el sistema SHALL cargar y mostrar los iconos desde `assets/store/items/consumables/`
2. WHEN el sistema muestra un item defensivo THEN el sistema SHALL usar el icono correspondiente del asset
3. WHEN el sistema muestra un item de sigilo THEN el sistema SHALL usar el icono correspondiente del asset
4. WHEN el sistema muestra un item ofensivo THEN el sistema SHALL usar el icono correspondiente del asset
5. WHEN el sistema no encuentra un icono THEN el sistema SHALL mostrar un placeholder genérico

### Requisito 4: Visualización de Skins

**Historia de Usuario:** Como jugador, quiero ver previews visuales de las skins en la tienda, para decidir cuáles comprar basándome en su apariencia.

#### Criterios de Aceptación

1. WHEN el sistema muestra una skin de jugador THEN el sistema SHALL cargar el sprite desde `assets/store/skins/player/`
2. WHEN el sistema muestra una skin de pecado THEN el sistema SHALL cargar el sprite desde `assets/store/skins/sins/`
3. WHEN el sistema muestra una skin premium THEN el sistema SHALL aplicar un borde y efecto visual distintivo
4. WHEN el sistema muestra una skin gratuita THEN el sistema SHALL indicar claramente que es gratuita
5. WHEN el sistema muestra una skin equipada THEN el sistema SHALL mostrar un indicador de "EQUIPADO"

### Requisito 5: Sistema de Inventario Separado

**Historia de Usuario:** Como jugador, quiero acceder a una pantalla de inventario separada, para ver todos mis items comprados y dónde se utilizan.

#### Criterios de Aceptación

1. WHEN el usuario navega al inventario THEN el sistema SHALL mostrar una pantalla separada con un icono distintivo
2. WHEN el sistema muestra el inventario THEN el sistema SHALL listar todos los items que el usuario posee
3. WHEN el sistema muestra un item en el inventario THEN el sistema SHALL indicar dónde se utiliza ese item
4. WHEN el sistema muestra una skin en el inventario THEN el sistema SHALL mostrar si está equipada actualmente
5. WHEN el sistema muestra items consumibles en el inventario THEN el sistema SHALL mostrar la cantidad disponible

### Requisito 6: Información de Uso de Items

**Historia de Usuario:** Como jugador, quiero saber dónde y cómo se usa cada item de mi inventario, para entender su propósito y cuándo equiparlo.

#### Criterios de Aceptación

1. WHEN el usuario selecciona un item en el inventario THEN el sistema SHALL mostrar una descripción de dónde se usa
2. WHEN el sistema muestra una skin de jugador THEN el sistema SHALL indicar "Se usa en: Todos los arcos"
3. WHEN el sistema muestra una skin de pecado THEN el sistema SHALL indicar "Se usa en: Modo multijugador - Arco X"
4. WHEN el sistema muestra un item consumible THEN el sistema SHALL indicar "Se usa en: Durante el gameplay"
5. WHEN el sistema muestra el pase de batalla THEN el sistema SHALL indicar "Activo durante toda la temporada"

### Requisito 7: Navegación entre Tienda e Inventario

**Historia de Usuario:** Como jugador, quiero navegar fácilmente entre la tienda y mi inventario, para comparar lo que tengo con lo que puedo comprar.

#### Criterios de Aceptación

1. WHEN el usuario está en la tienda THEN el sistema SHALL mostrar un botón para acceder al inventario
2. WHEN el usuario está en el inventario THEN el sistema SHALL mostrar un botón para regresar a la tienda
3. WHEN el usuario navega entre pantallas THEN el sistema SHALL mantener el estado de scroll y selección
4. WHEN el usuario compra un item THEN el sistema SHALL actualizar el inventario automáticamente
5. WHEN el usuario equipa un item THEN el sistema SHALL reflejar el cambio en ambas pantallas

### Requisito 8: Organización del Inventario

**Historia de Usuario:** Como jugador, quiero que mi inventario esté organizado por categorías, para encontrar rápidamente lo que busco.

#### Criterios de Aceptación

1. WHEN el sistema muestra el inventario THEN el sistema SHALL organizar items en categorías: Skins, Items, Pase
2. WHEN el usuario selecciona una categoría THEN el sistema SHALL filtrar y mostrar solo items de esa categoría
3. WHEN el sistema muestra skins THEN el sistema SHALL separar skins de jugador y skins de pecados
4. WHEN el sistema muestra items consumibles THEN el sistema SHALL agruparlos por tipo (defensivo, sigilo, ofensivo)
5. WHEN el inventario está vacío THEN el sistema SHALL mostrar un mensaje indicando que no hay items

### Requisito 9: Integración de Assets Visuales

**Historia de Usuario:** Como desarrollador, quiero que todos los assets visuales estén correctamente integrados en el código, para que la tienda y el inventario se vean profesionales.

#### Criterios de Aceptación

1. WHEN el sistema carga la tienda THEN el sistema SHALL cargar todos los assets desde las rutas correctas en `assets/store/`
2. WHEN el sistema no puede cargar un asset THEN el sistema SHALL usar un placeholder y registrar un error
3. WHEN el sistema muestra iconos THEN el sistema SHALL aplicar el tamaño correcto según el contexto
4. WHEN el sistema muestra sprites de skins THEN el sistema SHALL aplicar el frame correcto del spritesheet
5. WHEN el sistema carga assets THEN el sistema SHALL cachear las imágenes para mejorar el rendimiento

### Requisito 10: Configuración de Assets en pubspec.yaml

**Historia de Usuario:** Como desarrollador, quiero que todos los assets estén correctamente declarados en pubspec.yaml, para que Flutter pueda cargarlos sin errores.

#### Criterios de Aceptación

1. WHEN el sistema compila el proyecto THEN el sistema SHALL incluir todos los assets de `assets/store/`
2. WHEN el sistema declara assets THEN el sistema SHALL usar rutas relativas correctas
3. WHEN el sistema agrupa assets THEN el sistema SHALL declarar carpetas completas cuando sea apropiado
4. WHEN el sistema actualiza assets THEN el sistema SHALL ejecutar `flutter pub get` para actualizar
5. WHEN el sistema verifica assets THEN el sistema SHALL confirmar que todos los archivos existen
