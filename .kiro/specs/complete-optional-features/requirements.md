# Requirements Document

## Introduction

Este documento especifica las funcionalidades opcionales restantes para completar Óolale Mobile, una aplicación de networking musical desarrollada en Flutter/Dart con backend en Supabase. El proyecto está actualmente al 91% de completitud con el MVP funcional. Estas funcionalidades mejorarán la experiencia de usuario en tres áreas principales: mensajería en tiempo real, gestión completa de eventos, y perfiles de músico más detallados.

## Glossary

- **System**: La aplicación móvil Óolale Mobile (Flutter/Dart)
- **Supabase**: Backend como servicio (PostgreSQL + Realtime + Storage)
- **User**: Usuario autenticado de la aplicación
- **Musician**: Usuario con perfil de músico
- **Connection**: Relación bidireccional aceptada entre dos usuarios
- **Event**: Evento musical (concierto, ensayo, jam session)
- **Message**: Mensaje de texto enviado entre usuarios conectados
- **Realtime_Channel**: Canal de Supabase para comunicación en tiempo real
- **Profile**: Perfil de usuario con información personal y profesional
- **Notification**: Notificación push o in-app para el usuario
- **Invitation**: Invitación a un evento enviada a un músico
- **RSVP**: Confirmación o rechazo de asistencia a un evento
- **Rating**: Calificación dejada después de un evento
- **Media_Item**: Elemento multimedia (imagen, video, audio) en el portafolio

## Requirements

### Requirement 1: Sistema de Mensajes en Tiempo Real

**User Story:** Como usuario, quiero enviar y recibir mensajes instantáneamente, para que pueda comunicarme de manera fluida con otros músicos.

#### Acceptance Criteria

1. WHEN a user sends a message, THE System SHALL transmit it through Supabase Realtime channels
2. WHEN a message is received, THE System SHALL display it immediately without manual refresh
3. WHEN a user is typing, THE System SHALL broadcast a typing indicator to the recipient
4. WHEN the recipient sees the typing indicator, THE System SHALL display it for a maximum of 3 seconds
5. WHEN a message is delivered, THE System SHALL mark it with a delivery timestamp
6. WHEN a message is read by the recipient, THE System SHALL update the read status
7. WHEN a user opens a conversation, THE System SHALL mark all messages as read
8. WHEN a user sends an image, THE System SHALL upload it to Supabase Storage and send the URL
9. WHEN a user sends a file, THE System SHALL validate the file type and size before upload
10. WHEN a message fails to send, THE System SHALL display an error indicator and allow retry

### Requirement 2: Indicadores de Estado de Mensajes

**User Story:** Como usuario, quiero saber si mis mensajes han sido entregados y leídos, para tener contexto sobre la comunicación.

#### Acceptance Criteria

1. WHEN a message is sent, THE System SHALL display a "sent" indicator (single checkmark)
2. WHEN a message is delivered, THE System SHALL display a "delivered" indicator (double checkmark)
3. WHEN a message is read, THE System SHALL display a "read" indicator (colored double checkmark)
4. WHEN displaying message status, THE System SHALL use visual indicators consistent with the app theme
5. WHEN a user views their sent messages, THE System SHALL show the most recent status for each message

### Requirement 3: Envío de Multimedia en Mensajes

**User Story:** Como músico, quiero enviar imágenes y archivos de audio en mis conversaciones, para compartir mi trabajo y colaborar mejor.

#### Acceptance Criteria

1. WHEN a user selects an image, THE System SHALL compress it to a maximum of 2MB before upload
2. WHEN a user selects an audio file, THE System SHALL validate it is in a supported format (mp3, wav, m4a)
3. WHEN uploading media, THE System SHALL display a progress indicator
4. WHEN media upload completes, THE System SHALL send the message with the media URL
5. WHEN displaying media messages, THE System SHALL show thumbnails for images
6. WHEN displaying audio messages, THE System SHALL show a playback control
7. WHEN a user taps an image, THE System SHALL display it in full screen
8. IF media upload fails, THEN THE System SHALL display an error message and allow retry

### Requirement 4: Historial de Eventos

**User Story:** Como músico, quiero ver los eventos en los que he participado, para llevar un registro de mi trayectoria profesional.

#### Acceptance Criteria

1. WHEN a user accesses event history, THE System SHALL display all past events where they participated
2. WHEN displaying past events, THE System SHALL order them by date (most recent first)
3. WHEN a user views a past event, THE System SHALL show event details and participants
4. WHEN a past event is displayed, THE System SHALL show if the user left a rating
5. WHEN a user has not rated participants, THE System SHALL display a prompt to leave ratings

### Requirement 5: Calendario de Eventos Próximos

**User Story:** Como músico, quiero ver mis eventos próximos en un calendario, para organizar mejor mi agenda.

#### Acceptance Criteria

1. WHEN a user accesses the calendar, THE System SHALL display events in a monthly view
2. WHEN displaying the calendar, THE System SHALL highlight dates with confirmed events
3. WHEN a user taps a date, THE System SHALL show all events for that day
4. WHEN displaying upcoming events, THE System SHALL show confirmation status (confirmed/pending)
5. WHEN an event is within 24 hours, THE System SHALL display a visual indicator

### Requirement 6: Sistema de Invitaciones a Eventos

**User Story:** Como organizador de eventos, quiero invitar músicos específicos a mis eventos, para formar el lineup ideal.

#### Acceptance Criteria

1. WHEN an organizer creates an event, THE System SHALL allow selecting musicians to invite
2. WHEN sending invitations, THE System SHALL create a notification for each invited musician
3. WHEN a musician receives an invitation, THE System SHALL display it in their notifications
4. WHEN displaying an invitation, THE System SHALL show event details and organizer information
5. WHEN an invitation is sent, THE System SHALL record it with status "pending"

### Requirement 7: Confirmación de Asistencia (RSVP)

**User Story:** Como músico invitado, quiero confirmar o rechazar invitaciones a eventos, para que el organizador sepa mi disponibilidad.

#### Acceptance Criteria

1. WHEN a musician views an invitation, THE System SHALL display options to accept or decline
2. WHEN a musician accepts an invitation, THE System SHALL update the invitation status to "accepted"
3. WHEN a musician declines an invitation, THE System SHALL update the invitation status to "declined"
4. WHEN an RSVP is submitted, THE System SHALL notify the event organizer
5. WHEN an invitation is accepted, THE System SHALL add the musician to the event lineup
6. WHEN an invitation is declined, THE System SHALL remove the musician from pending invitations

### Requirement 8: Notificaciones de Eventos

**User Story:** Como usuario, quiero recibir notificaciones sobre eventos, para estar informado de cambios y recordatorios.

#### Acceptance Criteria

1. WHEN a user is invited to an event, THE System SHALL send a push notification
2. WHEN an event is 24 hours away, THE System SHALL send a reminder notification
3. WHEN an event is updated, THE System SHALL notify all confirmed participants
4. WHEN an event is cancelled, THE System SHALL notify all participants immediately
5. WHEN a notification is sent, THE System SHALL store it in the notifications table

### Requirement 9: Calificaciones Post-Evento

**User Story:** Como músico, quiero calificar a otros participantes después de un evento, para construir reputación en la plataforma.

#### Acceptance Criteria

1. WHEN an event ends, THE System SHALL prompt participants to leave ratings
2. WHEN leaving a rating, THE System SHALL verify the user participated in the event
3. WHEN submitting a rating, THE System SHALL require a star rating (1-5)
4. WHEN submitting a rating, THE System SHALL allow an optional comment
5. WHEN a rating is submitted, THE System SHALL update the recipient's average rating
6. WHEN a user has already rated a participant, THE System SHALL prevent duplicate ratings

### Requirement 10: Perfil de Músico - Géneros Musicales

**User Story:** Como músico, quiero especificar los géneros musicales que toco, para que otros usuarios encuentren músicos con estilos compatibles.

#### Acceptance Criteria

1. WHEN editing profile, THE System SHALL display a list of musical genres
2. WHEN selecting genres, THE System SHALL allow multiple selections
3. WHEN saving genres, THE System SHALL store them in the user's profile
4. WHEN displaying a profile, THE System SHALL show all selected genres
5. WHEN searching musicians, THE System SHALL allow filtering by genre

### Requirement 11: Perfil de Músico - Experiencia y Disponibilidad

**User Story:** Como músico, quiero indicar mi experiencia y disponibilidad, para que los organizadores sepan si soy adecuado para sus eventos.

#### Acceptance Criteria

1. WHEN editing profile, THE System SHALL allow entering years of experience
2. WHEN editing profile, THE System SHALL allow selecting available days and time ranges
3. WHEN saving availability, THE System SHALL store it in a structured format
4. WHEN displaying a profile, THE System SHALL show experience level and availability
5. WHEN searching musicians, THE System SHALL allow filtering by availability

### Requirement 12: Perfil de Músico - Tarifa Base

**User Story:** Como músico profesional, quiero indicar mi tarifa base, para que los organizadores conozcan mis expectativas económicas.

#### Acceptance Criteria

1. WHEN editing profile, THE System SHALL allow entering a base rate amount
2. WHEN entering a rate, THE System SHALL allow selecting currency (MXN, USD)
3. WHEN saving the rate, THE System SHALL store it as a numeric value with currency
4. WHEN displaying a profile, THE System SHALL show the rate if the user has set it
5. WHERE a user has not set a rate, THE System SHALL display "Tarifa por consultar"

### Requirement 13: Perfil de Músico - Redes Sociales

**User Story:** Como músico, quiero vincular mis redes sociales, para que otros usuarios puedan ver más de mi trabajo.

#### Acceptance Criteria

1. WHEN editing profile, THE System SHALL allow entering URLs for Instagram, YouTube, Spotify, and SoundCloud
2. WHEN saving social links, THE System SHALL validate each URL format
3. WHEN displaying a profile, THE System SHALL show icons for each linked social network
4. WHEN a user taps a social icon, THE System SHALL open the URL in an external browser
5. IF a URL is invalid, THEN THE System SHALL display a validation error

### Requirement 14: Portafolio Multimedia Mejorado

**User Story:** Como músico, quiero subir múltiples videos y audios a mi portafolio, para mostrar mi trabajo de manera profesional.

#### Acceptance Criteria

1. WHEN editing portfolio, THE System SHALL allow uploading multiple media items
2. WHEN uploading media, THE System SHALL support images, videos (mp4), and audio (mp3, wav)
3. WHEN uploading a video, THE System SHALL validate the file size is under 50MB
4. WHEN uploading audio, THE System SHALL validate the file size is under 10MB
5. WHEN displaying portfolio, THE System SHALL show media items in a grid layout
6. WHEN a user taps a media item, THE System SHALL display it in a media viewer
7. WHEN viewing portfolio, THE System SHALL allow deleting media items
8. WHEN deleting media, THE System SHALL remove it from Supabase Storage

### Requirement 15: Cálculo de Perfil Completo

**User Story:** Como usuario, quiero ver qué porcentaje de mi perfil está completo, para saber qué información me falta agregar.

#### Acceptance Criteria

1. WHEN displaying a profile, THE System SHALL calculate the completion percentage
2. WHEN calculating completion, THE System SHALL consider: name, bio, location, instrument, photo, genres, experience, availability, rate, social links, and portfolio items
3. WHEN the profile is incomplete, THE System SHALL display the percentage with a progress bar
4. WHEN the profile is 100% complete, THE System SHALL display a "Perfil Completo" badge
5. WHEN viewing own profile, THE System SHALL show suggestions for missing fields
