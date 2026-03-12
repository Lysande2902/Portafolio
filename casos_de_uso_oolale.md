# Casos de Uso del Sistema - Óolale App

Plataforma móvil para músicos y artistas que les permite conectar, colaborar, postularse a eventos y recibir contrataciones. Los casos de uso reflejan las pantallas y funciones reales implementadas en la aplicación Flutter.

---

## 1. Módulo de Acceso y Autenticación
_Pantallas: `login_screen`, `register_screen`, `forgot_password_screen`_

- **CU01 - Registrarse en la plataforma:** El usuario crea una cuenta nueva ingresando email y contraseña. El sistema crea el perfil automáticamente.
- **CU02 - Iniciar sesión:** El usuario accede con sus credenciales (email + contraseña) para entrar al sistema.
- **CU03 - Recuperar contraseña:** El usuario solicita restablecer su acceso; el sistema envía un enlace de recuperación al correo registrado.
- **CU04 - Cambiar contraseña:** El usuario autenticado ingresa su contraseña actual y establece una nueva desde Configuración.
- **CU05 - Cambiar email de la cuenta:** El usuario modifica su correo de acceso desde la pantalla de ajustes de cuenta.
- **CU06 - Cerrar sesión:** El usuario finaliza su sesión activa de forma segura y regresa a la pantalla de login.
- **CU07 - Suspender/eliminar cuenta:** El usuario puede suspender temporalmente su cuenta o eliminarla permanentemente desde Configuración.

---

## 2. Módulo de Perfil y Preferencias
_Pantallas: `profile_screen`, `edit_profile_screen`, `public_profile_screen`, `edit_musical_info_screen`, `edit_social_links_screen`, `edit_availability_rates_screen`_

- **CU08 - Crear y editar perfil personal:** Configurar foto de perfil, banner de fondo, nombre artístico, biografía y rider técnico.
- **CU09 - Gestionar información musical:** Definir instrumento(s) principal(es) (hasta 3) y géneros musicales dominados (hasta 5).
- **CU10 - Actualizar disponibilidad y tarifas ("Open to Work"):** Activar o desactivar la disponibilidad para contrataciones e indicar tarifas de trabajo.
- **CU11 - Gestionar redes sociales / links externos:** Agregar o editar links a Spotify, Instagram, SoundCloud y otras plataformas externas.
- **CU12 - Ver perfil propio:** Visualizar el perfil tal como lo ven otros usuarios (vista pública).
- **CU13 - Ver perfil público de otro músico:** Visualizar el perfil completo (bio, portafolio, calificaciones) de cualquier otro usuario de la plataforma.

---

## 3. Módulo de Portafolio y Multimedia
_Pantallas: `portfolio_screen`, `upload_media_screen`, `media_detail_screen`_

- **CU14 - Subir y publicar vídeos:** Cargar demostraciones de talento (grabaciones propias, covers) con título y descripción. Máx. 500 MB.
- **CU15 - Subir y publicar audios:** Agregar pistas de audio, maquetas o demos con metadatos (artista, género). Máx. 100 MB y 5 minutos de duración.
- **CU16 - Gestionar galería de imágenes:** Subir y ordenar fotos de conciertos, instrumentos, premios o equipos.
- **CU17 - Crear y gestionar Setlists:** Estructurar listas de canciones interpretables indicando duración, artista original y notas técnicas.
- **CU18 - Gestionar privacidad del portafolio:** Configurar si cada elemento de medios es visible de forma pública, privada o solo para conexiones.
- **CU19 - Ver detalle de un elemento de media:** Reproducir o visualizar en pantalla completa un video, audio o imagen del portafolio propio o ajeno.

---

## 4. Módulo de Discovery y Búsqueda
_Pantallas: `discovery_screen`, `search_screen`_

- **CU20 - Buscar músicos por instrumento:** Filtrar el directorio de usuarios por el instrumento que tocan.
- **CU21 - Buscar músicos por ubicación:** Encontrar artistas geográficamente próximos (ciudad, país).
- **CU22 - Buscar por nombre de artista:** Búsqueda textual directa sobre el nombre artístico registrado.
- **CU23 - Filtrar artistas por género musical:** Afinar los resultados del Discovery según estilos o géneros.

---

## 5. Módulo de Networking y Conexiones
_Pantallas: `connections_screen`, `connection_requests_screen`_

- **CU24 - Enviar solicitud de conexión:** Solicitar vincularse con otro músico desde su perfil público.
- **CU25 - Aceptar o rechazar solicitud de conexión:** Gestionar las peticiones entrantes desde la pestaña "Solicitudes Pendientes".
- **CU26 - Eliminar una conexión:** Quitar a un contacto de la red de vínculos activos.
- **CU27 - Ver lista de conexiones activas:** Revisar el directorio de contactos actuales y acceder a su perfil o chat desde ahí.

---

## 6. Módulo de Eventos
_Pantallas: `events_screen`, `create_event_screen`, `gig_detail_screen`, `event_lineup_screen`, `event_invitations_screen`, `manage_invitations_screen`, `invite_musicians_screen`, `confirm_attendance_screen`, `event_calendar_screen`, `event_history_screen`, `post_event_screen`, `event_group_chat_screen`_

- **CU28 - Crear un evento:** Publicar un evento (Jam, Concierto, Ensayo, etc.) indicando fecha, lugar, instrumento requerido, límite de participantes y flyer.
- **CU29 - Editar o cancelar un evento propio:** Modificar los detalles de un evento ya publicado o cancelarlo antes de que ocurra.
- **CU30 - Buscar y filtrar eventos disponibles:** Usar filtros de fecha, tipo de evento, ubicación e instrumento requerido para explorar vacantes activas.
- **CU31 - Ver el detalle de un evento:** Consultar información completa (fecha, lugar, lineup confirmado, organizador) antes de postularse.
- **CU32 - Postularse al lineup de un evento:** Enviar una solicitud de participación al organizador para cubrir el instrumento requerido.
- **CU33 - Confirmar asistencia a un evento:** El músico acepta formalmente una invitación directa o su postulación aprobada.
- **CU34 - Gestionar postulantes (como organizador):** Aceptar o rechazar músicos de la lista de postulantes al evento propio.
- **CU35 - Invitar músicos directamente a un evento:** El organizador busca y envía invitaciones directas a músicos específicos de la plataforma.
- **CU36 - Gestionar invitaciones recibidas:** El músico revisa las invitaciones directas de organizadores y las acepta o rechaza.
- **CU37 - Ver historial de eventos pasados:** Consultar los eventos finalizados en los que se participó o se organizó.
- **CU38 - Ver y usar el calendario de eventos:** Visualizar los próximos eventos en formato de calendario mensual/semanal.
- **CU39 - Registrar datos post-evento:** El organizador cierra el evento documentando asistencia final y resultado (para habilitar las calificaciones).
- **CU40 - Participar en el chat grupal del evento:** Comunicarse en tiempo real con todos los miembros del lineup confirmados en un evento.

---

## 7. Módulo de Contrataciones (Hiring)
_Pantalla: `hire_musician_screen`_

- **CU41 - Enviar oferta de trabajo directa (1-a-1):** Desde el perfil de un músico, proponer una contratación especificando descripción del trabajo, presupuesto y fecha.
- **CU42 - Gestionar ofertas recibidas:** Revisar los detalles de una propuesta entrante y Aceptarla o Rechazarla.
- **CU43 - Consultar ofertas enviadas:** Dar seguimiento al estado (Pendiente / Aceptado / Rechazado) de las propuestas que el usuario envió a otros.

---

## 8. Módulo de Mensajería en Tiempo Real
_Pantallas: `messages_screen`, `chat_screen`_

- **CU44 - Ver lista de conversaciones:** Acceder al historial de chats activos con sus últimos mensajes y estados de lectura.
- **CU45 - Iniciar o abrir un chat directo:** Abrir un hilo de conversación 1-a-1 con otra persona.
- **CU46 - Enviar mensajes multiformato:** Mandar mensajes de texto, audios de voz e imágenes adjuntas dentro del chat.
- **CU47 - Consultar estado de lectura de mensajes:** Verificar si el mensaje fue enviado, entregado o leído (sistema de ticks).

---

## 9. Módulo de Calificaciones y Reputación
_Pantallas: `ratings_screen` (en portfolio), `leave_rating_screen`, `view_ratings_screen`_

- **CU48 - Ver el historial de calificaciones propias:** Consultar el promedio de estrellas, la distribución y cada reseña recibida en el perfil.
- **CU49 - Calificar a otro usuario:** Evaluar (1 a 5 estrellas) al músico u organizador con quien se colaboró, tras finalizar un evento o contratación.
- **CU50 - Escribir una reseña escrita:** Acompañar la calificación con un comentario textual (máx. 300 caracteres), visible públicamente en el perfil del evaluado.
- **CU51 - Reportar una calificación injusta:** Notificar al equipo de soporte sobre una reseña malintencionada para solicitar su revisión y posible eliminación.

---

## 10. Módulo de Notificaciones
_Pantalla: `notifications_screen`_

- **CU52 - Ver centro de notificaciones:** Recibir y consultar alertas del sistema (solicitudes de conexión, mensajes nuevos, estados de eventos, estados de ofertas).
- **CU53 - Interactuar con una notificación:** Presionar una notificación para navegar directamente a la pantalla relacionada (ej. abrir chat, ver el evento, revisar oferta).

---

## 11. Módulo de Rankings
_Pantalla: `rankings_screen`_

- **CU54 - Ver el ranking general de músicos:** Consultar la clasificación pública de usuarios según su reputación, actividad y nivel TOP en la plataforma.

---

## 12. Módulo de Sistema TOP & Premium (Monetización)
_Pantalla: `subscription_screen`_

- **CU55 - Adquirir un nivel de visibilidad (TOP/PRO/LEGEND):** Seleccionar un plan de ranking, elegir método de pago y activar mayor exposición en búsquedas por periodo limitado (30 o 90 días).
- **CU56 - Renovar o cambiar nivel de ranking:** Prorrogar la visibilidad activa o subir/bajar de categoría (ej. de PRO a TOP #1) al momento de renovar.
- **CU57 - Cancelar la renovación del ranking:** Indicarle al sistema que no renueve automáticamente, dejando que el plan expire al terminar su periodo sin penalidad.

---

## 13. Módulo de Seguridad y Moderación
_Pantallas: `create_report_screen`, `report_content_screen`, `blocked_users_screen`_

- **CU58 - Reportar un usuario, mensaje o contenido:** Enviar un ticket de denuncia al equipo de soporte categorizando la falta (abuso, spam, estafa, acoso, etc.) y adjuntando evidencias.
- **CU59 - Hacer seguimiento de un reporte enviado:** Consultar el estado de las denuncias propias (En revisión → Confirmado → Rechazado → Resuelto).
- **CU60 - Bloquear a un usuario:** Impedir que otro usuario pueda ver el perfil, enviar mensajes ni postularse a los eventos propios.
- **CU61 - Desbloquear a un usuario:** Revertir el bloqueo desde la lista de usuarios bloqueados en Configuración.

---

## 14. Módulo de Configuración y Ajustes
_Pantallas: `settings_screen`, `account_settings_screen`, `notifications_settings_screen`, `privacy_settings_screen`, `language_screen`, `accessibility_screen`, `help_center_screen`, `terms_screen`, `privacy_policy_screen`_

- **CU62 - Gestionar ajustes de notificaciones:** Activar o desactivar alertas por tipo (mensajes, eventos, conexiones, ofertas, email).
- **CU63 - Configurar privacidad del perfil:** Definir quién puede ver el perfil (todos / solo conexiones / nadie) y quién puede enviar mensajes directos.
- **CU64 - Cambiar idioma de la aplicación:** Seleccionar el idioma preferido de la interfaz (Español, Inglés, Portugués).
- **CU65 - Configurar accesibilidad:** Ajustar tamaño de fuente y opciones de sonido/vibración para adaptar la app a las necesidades del usuario.
- **CU66 - Consultar el Centro de Ayuda:** Acceder a preguntas frecuentes, contactar a soporte por email o reportar un error de la aplicación.
- **CU67 - Leer Términos y Condiciones / Política de Privacidad:** Acceder a los documentos legales de la plataforma desde la app.

---

## 15. Módulo de Wallet y Finanzas
_Pantalla: `wallet_screen`_

- **CU68 - Consultar saldo de la Wallet:** Ver el saldo disponible acumulado por contrataciones aceptadas y completadas.
- **CU69 - Gestionar métodos de pago:** Agregar o eliminar tarjetas de crédito/débito u otros métodos para pagos y cobros dentro de la plataforma.
- **CU70 - Retirar fondos de la Wallet:** Solicitar la transferencia del saldo ganado hacia una cuenta bancaria personal (acreditado en 3-5 días hábiles).
- **CU71 - Consultar historial de transacciones:** Ver el registro completo de movimientos: ingresos por contratos, pagos por planes TOP y retiros realizados.

---

> **Total de Casos de Uso:** 71 | **Total de Módulos:** 15
>
> Todos los casos de uso corresponden a pantallas y funciones reales implementadas en el proyecto Flutter (`oolale_mobile/lib/screens/`).
