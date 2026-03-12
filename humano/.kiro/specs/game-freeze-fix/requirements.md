# Requirements Document

## Introduction

El juego presenta un bug crítico donde se congela completamente en todos los arcos. El jugador puede caminar brevemente al inicio, pero luego el juego se atora y deja de responder. Este problema afecta la jugabilidad de todos los arcos (Gula, Avaricia, Envidia, Lujuria, Soberbia, Pereza, Ira) y hace el juego injugable.

## Glossary

- **Game**: La instancia del juego Flame (GluttonyArcGame, GreedArcGame, etc.)
- **Freeze**: Estado donde el juego deja de responder a inputs y no actualiza la pantalla
- **GameWidget**: El widget de Flutter que contiene y renderiza el juego Flame
- **UI Update Timer**: Timer que actualiza periódicamente el estado de la UI
- **Game Loop**: El ciclo de actualización del juego Flame (update/render)

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero que el juego funcione sin congelarse, para poder completar los arcos sin interrupciones.

#### Acceptance Criteria

1. WHEN el jugador inicia cualquier arco THEN el sistema SHALL mantener el juego ejecutándose sin congelarse
2. WHEN el jugador se mueve por el mapa THEN el sistema SHALL procesar los inputs continuamente sin pausas
3. WHEN el juego está en ejecución THEN el sistema SHALL actualizar la pantalla a 60 FPS sin interrupciones
4. WHEN ocurre un error en el game loop THEN el sistema SHALL registrar el error y continuar ejecutándose
5. WHEN el jugador interactúa con objetos del juego THEN el sistema SHALL responder inmediatamente sin congelarse

### Requirement 2

**User Story:** Como desarrollador, quiero identificar la causa del congelamiento, para poder implementar una solución efectiva.

#### Acceptance Criteria

1. WHEN el juego se congela THEN el sistema SHALL registrar logs detallados del estado del juego
2. WHEN se inicia el juego THEN el sistema SHALL validar que todos los componentes estén correctamente inicializados
3. WHEN ocurre un deadlock THEN el sistema SHALL detectarlo y registrar información de diagnóstico
4. WHEN el UI update timer se ejecuta THEN el sistema SHALL verificar que no cause bloqueos en el game loop
5. WHEN se crean componentes del juego THEN el sistema SHALL validar que no haya referencias circulares

### Requirement 3

**User Story:** Como jugador, quiero que el juego se recupere automáticamente de errores menores, para no perder mi progreso.

#### Acceptance Criteria

1. WHEN ocurre un error no crítico THEN el sistema SHALL continuar ejecutándose sin congelar el juego
2. WHEN un componente falla THEN el sistema SHALL remover el componente problemático y continuar
3. WHEN el game loop se ralentiza THEN el sistema SHALL ajustar la frecuencia de actualización automáticamente
4. WHEN la memoria está baja THEN el sistema SHALL liberar recursos no esenciales
5. WHEN se detecta un posible congelamiento THEN el sistema SHALL reiniciar el componente afectado

### Requirement 4

**User Story:** Como desarrollador, quiero separar correctamente el ciclo de vida de Flutter y Flame, para evitar conflictos de sincronización.

#### Acceptance Criteria

1. WHEN se actualiza el estado de Flutter THEN el sistema SHALL no bloquear el game loop de Flame
2. WHEN el game loop de Flame se ejecuta THEN el sistema SHALL no forzar rebuilds innecesarios de Flutter
3. WHEN se usa setState THEN el sistema SHALL ejecutarlo de forma asíncrona sin bloquear el juego
4. WHEN el UI update timer se ejecuta THEN el sistema SHALL usar un mecanismo que no interfiera con Flame
5. WHEN se crean widgets overlay THEN el sistema SHALL renderizarlos sin pausar el juego
