# Requirements Document

## Introduction

Este documento define los requerimientos para rediseñar el flujo de autenticación de la aplicación "The Quiescent Heart". El flujo incluye tres pantallas principales: una pantalla de splash inicial con branding elegante, una pantalla de carga con animación del corazón, y una pantalla de autenticación con video de fondo oscurecido y animaciones sutiles.

## Glossary

- **Splash Screen**: Pantalla inicial que muestra el branding de la aplicación (logo y nombre de la empresa)
- **Loading Screen**: Pantalla de transición que muestra una animación de carga mientras se inicializan recursos
- **Auth Screen**: Pantalla de autenticación que contiene formularios de inicio de sesión y registro
- **Video Background**: Video en bucle que se reproduce como fondo de la pantalla de autenticación
- **Heart Logo**: Logo de corazón de la aplicación ubicado en assets/images/heart.png
- **Overlay**: Capa semitransparente oscura aplicada sobre el video de fondo
- **Application**: La aplicación móvil "The Quiescent Heart"

## Requirements

### Requirement 1

**User Story:** Como usuario, quiero ver una pantalla de splash elegante al abrir la aplicación, para tener una primera impresión profesional de la marca.

#### Acceptance Criteria

1. WHEN the Application launches, THE Splash Screen SHALL display a white background
2. WHILE the Splash Screen is visible, THE Application SHALL display the Heart Logo centered on the screen
3. WHILE the Splash Screen is visible, THE Application SHALL display the text "The Quiescent Heart" below the Heart Logo with elegant typography
4. THE Splash Screen SHALL remain visible for a duration between 2 and 3 seconds
5. WHEN the Splash Screen duration completes, THE Application SHALL transition to the Loading Screen

### Requirement 2

**User Story:** Como usuario, quiero ver una animación de carga después del splash, para saber que la aplicación está inicializando correctamente.

#### Acceptance Criteria

1. WHEN the Loading Screen appears, THE Application SHALL display the Heart Logo with a rotating animation
2. WHILE the Loading Screen is active, THE Heart Logo SHALL complete one full rotation every 2 seconds
3. THE Loading Screen SHALL remain visible while authentication resources are being initialized
4. WHEN initialization completes, THE Application SHALL transition to the Auth Screen

### Requirement 3

**User Story:** Como usuario, quiero ver un fondo de video atractivo en la pantalla de autenticación, para tener una experiencia visual agradable mientras inicio sesión o creo mi cuenta.

#### Acceptance Criteria

1. WHEN the Auth Screen loads, THE Application SHALL play the video file "Whisk_gto5q2y1ujmhzdn00so3ydotumn2qtlyqzyx0yy.mp4" as background
2. WHILE the video is playing, THE Application SHALL loop the video continuously without interruption
3. WHILE the video is playing, THE Application SHALL apply a dark Overlay with opacity between 0.5 and 0.7 to ensure text readability
4. THE video SHALL play without audio
5. THE video SHALL scale to fill the entire screen while maintaining aspect ratio

### Requirement 4

**User Story:** Como usuario, quiero que los formularios de autenticación sean legibles y no se vean obstruidos por el fondo, para poder completar el registro o inicio de sesión fácilmente.

#### Acceptance Criteria

1. WHILE the Auth Screen is visible, THE Application SHALL display login and registration forms over the Video Background
2. THE Application SHALL ensure all text fields and buttons have sufficient contrast against the darkened Video Background
3. WHILE the user interacts with forms, THE Video Background SHALL continue playing without affecting form responsiveness
4. THE Application SHALL display subtle animations on the Auth Screen that do not interfere with form interaction

### Requirement 5

**User Story:** Como usuario, quiero que las transiciones entre pantallas sean suaves, para tener una experiencia fluida al usar la aplicación.

#### Acceptance Criteria

1. WHEN transitioning from Splash Screen to Loading Screen, THE Application SHALL use a fade transition with duration of 300 milliseconds
2. WHEN transitioning from Loading Screen to Auth Screen, THE Application SHALL use a fade transition with duration of 300 milliseconds
3. THE Application SHALL ensure no visual glitches occur during screen transitions
