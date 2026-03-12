# PROYECTO: PROTOCOLO DE CONEXIÓN (DISEÑO MULTIJUGADOR)

## 1. Concepto Central: "Usuario vs Algoritmo"
**Tipo:** 1v1 Asimétrico de Terror Psicológico.
**Premisa:** Un jugador es el **Usuario** atrapado en el nivel intentando escapar. El otro jugador es el **Algoritmo (IA)**, una entidad sin cuerpo que controla el entorno para eliminar la anomalía (el Usuario).

---

## 2. Roles y Objetivos

### JUGADOR 1: EL USUARIO (La Víctima)
**Vista:** Tercera persona (Igual que el modo historia).
**Objetivo:** Recolectar 3 "Llaves de Encriptación" (Evidencias) y llegar al "Puerto de Salida" antes de que su Cordura llegue a 0.
**Mecánicas:**
*   **Sigilo:** Moverse lento evita ser detectado en el radar del Algoritmo.
*   **Herramientas:**
    *   *VPN (Activa):* Te hace invisible al radar del Algoritmo por 5 segundos.
    *   *Antivirus (Pasiva):* Reduce la duración de los efectos de estado (glitches).
*   **Tensión:** No puedes ver al Algoritmo, pero sientes su presencia (vibración del teléfono, estática en pantalla).

### JUGADOR 2: EL ALGORITMO (El Cazador)
**Vista:** Cenital / Mapa Táctico (Estilo cámaras de seguridad o plano esquemático).
**Objetivo:** Drenar la Cordura del Usuario hasta 0 o impedir su escape hasta que se acabe el tiempo ("Purga del Sistema").
**Limitación:** No ves al Usuario en tiempo real. Solo ves "señales" (ondas de sonido) cuando corre o interactúa con objetos.
**Recurso:** "Datos" (Mana). Se recarga lentamente.

---

## 3. Habilidades del Algoritmo (La Intensidad)
El Algoritmo no ataca físicamente, ataca la mente y el dispositivo del Usuario.

| Habilidad | Coste | Efecto en el Usuario | Intensidad |
|-----------|-------|----------------------|------------|
| **PING DE LA MUERTE** | Bajo | **Vibración Real.** El teléfono del Usuario vibra bruscamente (simulando un latido fuerte). | Alta (Susto físico) |
| **GLITCH VISUAL** | Medio | Ciega parcialmente la pantalla del Usuario con el efecto `SanityGlitchOverlay` por 3s. | Media (Desorientación) |
| **LAG SPIKE** | Medio | Reduce la velocidad de movimiento del Usuario un 50% por 4s. | Media (Frustración) |
| **NOTIFICACIÓN FANTASMA**| Bajo | Suena un sonido de "enemigo cerca" o "pasos" en una dirección falsa. | Baja (Paranoia) |
| **MATERIALIZAR** | Alto | Invoca un enemigo (NPC) en una ubicación. Si el Usuario lo toca, pierde mucha cordura. | Muy Alta (Peligro) |

---

## 4. Dinámica de Juego "Ni tan fácil, ni tan difícil"

### El Balance (Loop de Juego)
1.  **Fase de Silencio:** El Usuario se mueve sigilosamente. El Algoritmo escanea el mapa buscando señales. Tensión pura.
2.  **Fase de Detección:** El Usuario comete un error (corre, toca un objeto). El Algoritmo ve una onda roja en el mapa.
3.  **Fase de Ataque:** El Algoritmo gasta sus "Datos" para lanzar un **Glitch Visual** + **Ping de la Muerte**.
4.  **Fase de Pánico:** El Usuario, ciego y con el teléfono vibrando, debe decidir si correr (haciendo más ruido) o esconderse (arriesgándose a que invoquen un enemigo encima).

### Factor de "Terror Real"
Usaremos el hardware del teléfono para romper la cuarta pared:
*   Si el Algoritmo usa "Ping de la Muerte", el teléfono del Usuario vibra.
*   Si el Usuario tiene poca cordura, la linterna (flash del celular real) podría parpadear (si es técnicamente posible/seguro).

---

## 5. Implementación Técnica (MVP)

### Arquitectura
*   **Backend:** Firebase Realtime Database (Suficiente para eventos por turnos/baja frecuencia).
*   **Sincronización:** No necesitamos sincronizar la posición exacta (x,y) cada milisegundo (que es difícil). Solo sincronizamos **Eventos**.

### Estructura de Datos (Firebase)
```json
match_id_123: {
  "status": "active",
  "user_state": {
    "sanity": 0.8,
    "evidence_count": 1,
    "last_noise_position": {"x": 200, "y": 300} // Solo se actualiza al hacer ruido
  },
  "algorithm_actions": {
    "trigger_glitch": timestamp, // El cliente del Usuario escucha esto y activa el overlay
    "trigger_vibration": timestamp,
    "spawn_enemy_at": {"x": 500, "y": 500}
  }
}
```

### Pasos para Implementar
1.  Crear `MultiplayerLobbyScreen` para crear/unirse a partida.
2.  Crear `AlgorithmGameScreen` (Nueva UI táctica para el jugador 2).
3.  Adaptar `ArcGameScreen` para escuchar eventos de Firebase y disparar `SanitySystem.takeDamage()` o `Vibration.vibrate()`.

---

## 6. Expansión Futura: "El Juicio Final"
Modo 2v1. Dos Usuarios cooperativos (Gula y Avaricia) intentando ayudarse. Si uno muere, se convierte en un "Fantasma Digital" que puede ayudar levemente al otro o traicionarlo para revivir.
