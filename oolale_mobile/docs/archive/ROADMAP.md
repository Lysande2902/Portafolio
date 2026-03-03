# 🗺️ ROADMAP DE PRODUCCIÓN: Óolale Mobile

Este plan divide el desarrollo en "Sets" o fases lógicas para asegurar que la aplicación sea robusta, premium y funcional desde la primera toma.

---

## 🎸 SET 1: EL SOUNDCHECK (Infraestructura y Auth)
**Objetivo:** Establecer la base técnica y el acceso al "backstage".

1.  **Sincronización de Base de Datos:**
    *   Ejecutar `SUPABASE_SETUP.sql v3.0` en el Dashboard de Supabase.
    *   Verificar que los Triggers de auto-perfil funcionen correctamente.
2.  **Auth & Onboarding Artist:**
    *   Actualizar flujo de Registro para incluir la elección de **Rol de Escena** (Músico, Banda, etc.).
    *   Refinar `AuthProvider` para recuperar el Perfil (EPK) completo después del login.
3.  **UI Core Refresh:**
    *   Implementar gradientes "Studio-Glow" y componentes Glassmorphism finales en las pantallas base.

---

## 🎤 SET 2: EL EPK & THE CREW (Perfiles y Networking)
**Objetivo:** Permitir que los músicos se encuentren y conecten.

1.  **EPK Editor (Mi Perfil):**
    *   Interfaz para editar Gear (Instrumentos), Influencias (Géneros) y Redes Sociales.
    *   Carga de Avatar y Banner artístico.
2.  **A&R Search (Buscador):**
    *   Filtros realistas por instrumento, género musical y ubicación.
3.  **Crews (Conexiones):**
    *   Lógica para "unirse a la crew" (conectar) de otro artista.
    *   Notificación de nuevas conexiones.

---

## 🎫 SET 3: THE GIG BOARD (Módulo de Eventos)
**Objetivo:** Gestionar la cartelera y la asistencia.

1.  **The Board (Visualización):**
    *   Lista de Gigs con estética de "Flyer de Festival".
    *   Mapa interactivo usando las coordenadas de Supabase.
2.  **Promotor Mode (Creación):**
    *   Formulario de publicación de Gigs con Rider Técnico y Flyer.
3.  **Lineup System:**
    *   Botón de "Confirmar asistencia" o "Postularme al Lineup".
    *   Lista de confirmados visible para el organizador.

---

## 💸 SET 4: THE BOX OFFICE (Monetización)
**Objetivo:** Integrar los flujos de dinero.

1.  **PayPal Engine:**
    *   Integración para suscripciones Headliner (PRO).
2.  **Mercado Pago SDK:**
    *   Flujo para pagos locales de tickets o impulsos.
3.  **Ticket Ledger:**
    *   Vista de historial de transacciones y estados de pago.

---

## 🚀 SET 5: EL ESTRENO (Pulido y Lanzamiento)
*   **Intercom (Chat):** Finalizar el sistema de mensajería rítmica.
*   **Notificaciones Push:** Alertas de bolos y mensajes.
*   **Beta Test:** Pruebas con músicos reales para feedback de UX.

---

### 🚦 ¿Qué canal abrimos primero?
**Opción A:** Empezar con el **SET 1 (Auth & Roles)** para asegurar que cada usuario tenga su perfil configurado correctamente desde el inicio.
**Opción B:** Saltar al **SET 3 (The Gig Board)** si lo que urge es ver la dinámica de eventos.
