# Requirements Document

## Introduction

Este documento define los requisitos para llevar la aplicación móvil Óolale del 80% al 100% de completitud. Óolale es una plataforma Flutter para músicos que permite conectar, colaborar y gestionar eventos musicales. Los 10 sistemas base ya están implementados (autenticación, perfiles, conexiones, calificaciones, reportes, bloqueos, rankings, notificaciones, búsqueda y mensajes básicos). Este spec se enfoca en las funcionalidades avanzadas necesarias para el lanzamiento en producción.

## Glossary

- **Sistema**: Componente funcional completo de la aplicación (ej: Sistema de Mensajes)
- **Óolale**: Nombre de la aplicación móvil para músicos
- **Usuario**: Músico registrado en la plataforma
- **Conexión**: Relación bidireccional aceptada entre dos usuarios
- **Evento**: Presentación musical organizada por uno o más usuarios
- **Multimedia**: Contenido de audio, video o imagen
- **Portafolio**: Colección de multimedia que representa el trabajo de un músico
- **Supabase**: Backend as a Service utilizado (PostgreSQL, Storage, Realtime)
- **Flutter**: Framework de desarrollo móvil multiplataforma
- **RLS**: Row Level Security - políticas de seguridad a nivel de fila en PostgreSQL
- **FCM**: Firebase Cloud Messaging - servicio de notificaciones push
- **Lineup**: Lista de músicos confirmados para un evento
- **Headliner**: Artista principal de un evento
- **Support**: Artista de soporte/apertura en un evento

## Requirements

### Requirement 1: Sistema de Mensajería en Tiempo Real Mejorado

**User Story:** Como usuario, quiero una experiencia de chat moderna y fluida, para que pueda comunicarme efectivamente con otros músicos.

#### Acceptance Criteria

1. WHEN un usuario está escribiendo un mensaje, THEN THE Sistema SHALL mostrar el indicador "escribiendo..." al otro usuario en tiempo real
2. WHEN un mensaje es enviado, THEN THE Sistema SHALL marcar el mensaje como "no leído" para el receptor
3. WHEN un usuario abre un chat, THEN THE Sistema SHALL marcar todos los mensajes como "leídos" automáticamente
4. WHEN un usuario envía una imagen, THEN THE Sistema SHALL mostrar un preview de la imagen en el chat
5. WHEN un usuario envía un archivo multimedia, THEN THE Sistema SHALL validar el tipo y tamaño del archivo antes de subirlo
6. WHEN la conexión de tiempo real se pierde, THEN THE Sistema SHALL reconectar automáticamente sin perder mensajes
7. WHEN un mensaje contiene multimedia, THEN THE Sistema SHALL comprimir las imágenes antes de subirlas
8. WHILE un usuario está en un chat, THE Sistema SHALL actualizar los mensajes en tiempo real sin recargar la pantalla

### Requirement 2: Sistema de Eventos Completo

**User Story:** Como músico, quiero gestionar eventos de forma completa (pasados, futuros, invitaciones, confirmaciones), para que pueda organizar y participar en presentaciones musicales.

#### Acceptance Criteria

1. WHEN un evento finaliza, THEN THE Sistema SHALL moverlo automáticamente al historial de eventos
2. WHEN un usuario accede al calendario, THEN THE Sistema SHALL mostrar eventos en vista mes, semana y día
3. WHEN un organizador invita a un músico, THEN THE Sistema SHALL crear una notificación de invitación para el músico invitado
4. WHEN un músico acepta una invitación, THEN THE Sistema SHALL agregarlo al lineup del evento
5. WHEN un músico rechaza una invitación, THEN THE Sistema SHALL notificar al organizador
6. WHEN un evento finaliza, THEN THE Sistema SHALL enviar una notificación automática para calificar a los participantes
7. WHEN se crea un evento, THEN THE Sistema SHALL permitir asignar roles (headliner, support) a los participantes
8. WHEN un usuario sube fotos de un evento, THEN THE Sistema SHALL crear una galería asociada al evento
9. WHILE un evento está activo, THE Sistema SHALL mostrar la lista de confirmados y pendientes
10. THE Sistema SHALL validar que las fechas de eventos sean futuras al momento de creación

### Requirement 3: Perfil de Músico Completo

**User Story:** Como músico, quiero completar mi perfil con información profesional detallada, para que otros usuarios conozcan mi experiencia y disponibilidad.

#### Acceptance Criteria

1. WHEN un usuario edita su perfil, THEN THE Sistema SHALL permitir seleccionar múltiples géneros musicales
2. WHEN un usuario ingresa años de experiencia, THEN THE Sistema SHALL validar que sea un número positivo
3. WHEN un usuario configura su disponibilidad, THEN THE Sistema SHALL permitir marcar días y horarios disponibles en un calendario
4. WHEN un usuario ingresa tarifas, THEN THE Sistema SHALL validar que sean valores numéricos positivos
5. WHEN un usuario agrega links de redes sociales, THEN THE Sistema SHALL validar que sean URLs válidas
6. WHEN un usuario completa campos del perfil, THEN THE Sistema SHALL calcular y mostrar el porcentaje de completitud
7. THE Sistema SHALL mostrar el país del usuario en su perfil público
8. THE Sistema SHALL permitir seleccionar múltiples idiomas que el usuario habla
9. WHEN el perfil está incompleto, THEN THE Sistema SHALL mostrar una barra de progreso visual
10. THE Sistema SHALL requerir al menos 60% de completitud para aparecer en búsquedas destacadas

### Requirement 4: Portafolio Multimedia Avanzado

**User Story:** Como músico, quiero gestionar mi portafolio multimedia de forma profesional, para que pueda mostrar mi trabajo de manera organizada y atractiva.

#### Acceptance Criteria

1. WHEN un usuario sube un video, THEN THE Sistema SHALL permitir reproducirlo directamente en la aplicación
2. WHEN un usuario sube audio, THEN THE Sistema SHALL mostrar controles de reproducción con barra de progreso
3. WHEN un usuario organiza fotos, THEN THE Sistema SHALL permitir crear álbumes temáticos
4. WHEN un usuario agrega multimedia, THEN THE Sistema SHALL requerir título y permitir descripción opcional
5. WHEN un usuario tiene múltiples archivos multimedia, THEN THE Sistema SHALL permitir reordenarlos mediante drag-and-drop
6. WHEN un usuario selecciona una foto de portada, THEN THE Sistema SHALL destacarla en la parte superior del perfil
7. WHEN un usuario toca una foto, THEN THE Sistema SHALL abrir un lightbox de pantalla completa con gestos de zoom
8. THE Sistema SHALL comprimir videos antes de subirlos para optimizar almacenamiento
9. THE Sistema SHALL validar formatos de archivo permitidos (jpg, png, mp4, mp3, wav)
10. THE Sistema SHALL limitar el tamaño máximo de archivos (videos: 100MB, audios: 50MB, imágenes: 10MB)

### Requirement 5: Optimización de Rendimiento

**User Story:** Como usuario, quiero que la aplicación sea rápida y eficiente, para que pueda usarla sin demoras ni consumo excesivo de datos.

#### Acceptance Criteria

1. WHEN se consultan listas de datos, THEN THE Sistema SHALL implementar paginación de 20 elementos por página
2. WHEN se cargan imágenes, THEN THE Sistema SHALL usar lazy loading para cargar solo las visibles
3. WHEN se suben imágenes, THEN THE Sistema SHALL comprimirlas automáticamente manteniendo calidad aceptable
4. THE Sistema SHALL crear índices en columnas frecuentemente consultadas (user_id, created_at, event_date)
5. THE Sistema SHALL implementar caché local para perfiles visitados recientemente
6. THE Sistema SHALL implementar caché local para listas de conexiones
7. WHEN se realizan búsquedas, THEN THE Sistema SHALL usar índices de texto completo en PostgreSQL
8. THE Sistema SHALL implementar políticas RLS completas en todas las tablas de Supabase
9. WHEN se cargan feeds, THEN THE Sistema SHALL limitar consultas a los últimos 30 días por defecto
10. THE Sistema SHALL implementar debouncing en campos de búsqueda con 300ms de delay

### Requirement 6: Preparación para Producción

**User Story:** Como desarrollador, quiero preparar la aplicación para lanzamiento en stores, para que cumpla con todos los requisitos de publicación.

#### Acceptance Criteria

1. WHEN se instala la aplicación, THEN THE Sistema SHALL mostrar un splash screen con el logo de Óolale
2. WHEN se recibe una notificación push, THEN THE Sistema SHALL usar Firebase Cloud Messaging
3. THE Sistema SHALL incluir iconos de aplicación en todos los tamaños requeridos (Android: 48-512dp, iOS: 20-1024pt)
4. THE Sistema SHALL rastrear eventos clave con Firebase Analytics (registro, login, creación de evento, envío de mensaje)
5. THE Sistema SHALL incluir Privacy Policy accesible desde configuración
6. THE Sistema SHALL incluir Terms of Service accesibles desde configuración
7. THE Sistema SHALL generar builds de producción firmados (Android: AAB, iOS: IPA)
8. THE Sistema SHALL incluir al menos 5 screenshots por plataforma para las stores
9. THE Sistema SHALL incluir descripción de la app en español e inglés
10. WHEN ocurre un error crítico, THEN THE Sistema SHALL registrarlo en Firebase Crashlytics
11. THE Sistema SHALL implementar versionado semántico (ej: 1.0.0)
12. THE Sistema SHALL incluir documentación técnica completa en el repositorio

### Requirement 7: Seguridad y Privacidad

**User Story:** Como usuario, quiero que mis datos estén protegidos, para que pueda usar la aplicación con confianza.

#### Acceptance Criteria

1. THE Sistema SHALL implementar políticas RLS que impidan acceso no autorizado a datos de otros usuarios
2. WHEN un usuario sube multimedia, THEN THE Sistema SHALL validar que solo el propietario pueda eliminarla
3. WHEN se accede a mensajes, THEN THE Sistema SHALL verificar que el usuario sea parte de la conversación
4. THE Sistema SHALL encriptar tokens de autenticación en almacenamiento local
5. WHEN se elimina una cuenta, THEN THE Sistema SHALL eliminar todos los datos personales del usuario
6. THE Sistema SHALL implementar rate limiting en endpoints críticos (login, registro, envío de mensajes)
7. WHEN se detectan múltiples intentos fallidos de login, THEN THE Sistema SHALL bloquear temporalmente la cuenta
8. THE Sistema SHALL validar y sanitizar todas las entradas de usuario antes de guardarlas

### Requirement 8: Internacionalización

**User Story:** Como usuario, quiero usar la aplicación en mi idioma preferido, para que pueda entender todas las funcionalidades.

#### Acceptance Criteria

1. THE Sistema SHALL soportar español e inglés como idiomas principales
2. WHEN un usuario cambia el idioma, THEN THE Sistema SHALL actualizar toda la interfaz inmediatamente
3. THE Sistema SHALL detectar el idioma del dispositivo y usarlo por defecto
4. WHEN se muestran fechas, THEN THE Sistema SHALL formatearlas según el locale del usuario
5. WHEN se muestran números, THEN THE Sistema SHALL formatearlos según el locale del usuario
6. THE Sistema SHALL almacenar la preferencia de idioma del usuario en su perfil

### Requirement 9: Accesibilidad

**User Story:** Como usuario con necesidades especiales, quiero poder usar la aplicación cómodamente, para que pueda acceder a todas las funcionalidades.

#### Acceptance Criteria

1. THE Sistema SHALL soportar tamaños de fuente ajustables (pequeño, mediano, grande, extra grande)
2. WHEN un usuario cambia el tamaño de fuente, THEN THE Sistema SHALL aplicarlo en toda la aplicación
3. THE Sistema SHALL mantener contraste mínimo de 4.5:1 entre texto y fondo
4. THE Sistema SHALL incluir labels descriptivos para lectores de pantalla
5. THE Sistema SHALL permitir navegación completa mediante teclado en campos de formulario
6. WHEN se muestran imágenes importantes, THEN THE Sistema SHALL incluir texto alternativo descriptivo

### Requirement 10: Gestión de Caché y Datos

**User Story:** Como usuario, quiero controlar el uso de datos y almacenamiento, para que pueda optimizar el consumo según mi plan de datos.

#### Acceptance Criteria

1. WHEN un usuario accede a configuración, THEN THE Sistema SHALL mostrar el tamaño actual de caché
2. WHEN un usuario limpia la caché, THEN THE Sistema SHALL eliminar imágenes y datos temporales
3. THE Sistema SHALL permitir configurar descarga automática de multimedia (siempre, solo WiFi, nunca)
4. THE Sistema SHALL permitir configurar calidad de carga de imágenes (alta, media, baja)
5. WHEN se usa datos móviles, THEN THE Sistema SHALL respetar las preferencias de descarga automática
6. THE Sistema SHALL mostrar estadísticas de uso de datos en los últimos 30 días
