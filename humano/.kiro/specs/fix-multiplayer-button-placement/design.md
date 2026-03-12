# Design Document

## Overview

Este diseño corrige la ubicación incorrecta del botón de multijugador moviendo el botón "PROTOCOLO MULTIJUGADOR [BETA]" desde ArcSelectionScreen hacia MenuScreen, donde debe estar ubicado debajo del botón PLAY principal.

## Architecture

La solución involucra dos pantallas principales:

1. **MenuScreen** - Agregar el botón de multijugador funcional
2. **ArcSelectionScreen** - Remover el botón de multijugador existente

El flujo de navegación será:
```
MenuScreen (Lobby Principal)
  ├─> PLAY → ArcSelectionScreen
  └─> MULTIPLAYER → MultiplayerLobbyScreen
```

## Components and Interfaces

### MenuScreen Modifications

**Ubicación del botón:**
- El botón de multijugador se ubicará en el centro de la pantalla, debajo del botón PLAY principal
- Usará el componente `_buildSecondaryButton` existente para mantener consistencia visual

**Navegación:**
- Al hacer clic, navegará a `MultiplayerLobbyScreen` usando `MaterialPageRoute`

### ArcSelectionScreen Modifications

**Remoción del botón:**
- Eliminar el widget `Padding` que contiene el `TextButton.icon` con el texto "PROTOCOLO MULTIJUGADOR [BETA]"
- Este widget está ubicado después del `PageView.builder` de arcos

## Data Models

No se requieren cambios en modelos de datos. Esta es una modificación puramente de UI.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Multiplayer button presence in MenuScreen
*For any* state of MenuScreen, the multiplayer button should be visible and positioned below the PLAY button
**Validates: Requirements 1.1**

### Property 2: Multiplayer button navigation
*For any* click event on the multiplayer button in MenuScreen, the system should navigate to MultiplayerLobbyScreen
**Validates: Requirements 1.2**

### Property 3: Multiplayer button absence in ArcSelectionScreen
*For any* state of ArcSelectionScreen, the multiplayer button should not be present in the widget tree
**Validates: Requirements 1.3**

## Error Handling

No se requiere manejo de errores especial. La navegación usa el sistema estándar de Flutter que maneja errores de navegación automáticamente.

## Testing Strategy

### Unit Testing

Se escribirán unit tests para verificar:
- Que MenuScreen contiene el botón de multijugador
- Que ArcSelectionScreen no contiene el botón de multijugador
- Que el botón navega correctamente a MultiplayerLobbyScreen

### Property-Based Testing

No se requieren property-based tests para esta funcionalidad ya que es una modificación simple de UI sin lógica compleja o generación de datos aleatorios.

### Manual Testing

1. Abrir la aplicación y verificar que MenuScreen muestra el botón de multijugador
2. Hacer clic en el botón y verificar navegación a MultiplayerLobbyScreen
3. Navegar a ArcSelectionScreen y verificar que no hay botón de multijugador
4. Verificar que el estilo visual es consistente con otros botones secundarios
