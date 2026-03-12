# 🎵 Oolale — App Móvil para Músicos

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" />
</p>

**Oolale** es una plataforma móvil para músicos y artistas que quieren conectar con otros, compartir su trabajo y colaborar en proyectos musicales — ya sea de forma profesional o como pasatiempo.

---

## 📋 Descripción del Proyecto

Oolale permite a músicos de cualquier nivel crear un perfil, publicar proyectos, descubrir otros artistas, conectar mediante mensajes en tiempo real, y participar en rankings de la comunidad. Está diseñada para ser el punto de encuentro de músicos que buscan colaboradores, bandas que necesitan integrantes, o simplemente artistas que quieren mostrar su trabajo.

### ✨ Módulos principales

| Módulo | Descripción |
|--------|-------------|
| 🔐 **Autenticación** | Registro e inicio de sesión seguro con sesiones persistentes |
| 🏠 **Dashboard** | Feed principal con proyectos y actividad de la comunidad |
| 🔍 **Descubrimiento** | Explora músicos y proyectos filtrados por instrumento, género y más |
| 👤 **Perfil** | Perfil de artista con bio, habilidades, proyectos e historial |
| 📁 **Portafolio** | Sube y muestra tus proyectos musicales (audio, video, imágenes) |
| 🤝 **Conexiones** | Sistema de seguimiento y conexión entre músicos |
| 💬 **Mensajes** | Chat en tiempo real con caché inteligente y modo offline |
| 🔔 **Notificaciones** | Push notifications con Firebase Cloud Messaging |
| 📅 **Eventos** | Crea y descubre eventos musicales locales |
| 🏆 **Rankings** | Clasificación de músicos y proyectos más activos |
| ⭐ **Valoraciones** | Sistema de calificaciones entre usuarios |
| 🎯 **Contrataciones** | Módulo para publicar y encontrar oportunidades laborales musicales |
| 💎 **Premium** | Plan de suscripción con funcionalidades avanzadas |
| 🚩 **Reportes** | Herramienta para reportar contenido inapropiado |
| ⚙️ **Ajustes** | Gestión de cuenta, privacidad y preferencias |

---

## 🛠️ Tecnologías Usadas

### Framework y lenguaje
- **Flutter** `^3.x` — Framework multiplataforma (Android, iOS, Web, Windows)
- **Dart** `^3.10.1` — Lenguaje de programación

### Backend y base de datos
- **Supabase** (`supabase_flutter ^2.8.3`) — Base de datos PostgreSQL, autenticación y almacenamiento en la nube
- **Firebase Core** + **Firebase Messaging** — Notificaciones push (FCM)

### Estado y navegación
- **Provider** `^6.1.5` — Gestión de estado
- **go_router** `^17.0.1` — Navegación declarativa

### Multimedia
- **video_player** + **chewie** — Reproducción de video
- **audioplayers** + **just_audio** — Reproducción de audio
- **image_picker** + **file_picker** — Selección de archivos
- **flutter_image_compress** — Compresión de imágenes

### UI y diseño
- **google_fonts** — Tipografías modernas
- **animate_do** — Animaciones fluidas
- **font_awesome_flutter** — Iconografía
- **flutter_staggered_grid_view** — Layouts de cuadrícula avanzados
- **table_calendar** — Calendario de eventos

### Utilidades
- **flutter_secure_storage** — Almacenamiento seguro de tokens
- **shared_preferences** + **sqflite** — Persistencia local y caché
- **connectivity_plus** — Detección de conectividad (modo offline)
- **dio** + **http** — Peticiones HTTP
- **url_launcher** + **share_plus** — Compartir contenido
- **permission_handler** — Gestión de permisos del dispositivo
- **flutter_local_notifications** — Notificaciones locales
- **intl** — Internacionalización y formatos de fecha

---

## 📂 Estructura del Proyecto

```
oolale_mobile/
├── lib/
│   ├── main.dart               # Punto de entrada + configuración de rutas
│   ├── config/                 # Constantes, temas y configuración global
│   ├── models/                 # Modelos de datos (User, Project, Event...)
│   ├── providers/              # Gestión de estado con Provider
│   ├── services/               # Lógica de negocio y llamadas a la API
│   │   ├── api_service.dart        # Servicio base de peticiones HTTP
│   │   ├── profile_service.dart    # Gestión de perfiles
│   │   ├── event_service.dart      # Gestión de eventos
│   │   ├── media_service.dart      # Subida y gestión de media
│   │   ├── notification_service.dart # Notificaciones push y locales
│   │   ├── realtime_service.dart   # Comunicación en tiempo real (Supabase)
│   │   ├── cache_service.dart      # Caché inteligente
│   │   ├── connectivity_service.dart # Detección de red (offline mode)
│   │   └── ...
│   ├── screens/                # Pantallas de la aplicación
│   │   ├── auth/               # Login y registro
│   │   ├── dashboard/          # Feed principal
│   │   ├── discovery/          # Explorar músicos y proyectos
│   │   ├── profile/            # Perfil de usuario
│   │   ├── portfolio/          # Portafolio del artista
│   │   ├── connections/        # Conexiones y seguidores
│   │   ├── messages/           # Chat en tiempo real
│   │   ├── events/             # Eventos musicales
│   │   ├── rankings/           # Ranking de la comunidad
│   │   ├── hiring/             # Oportunidades laborales
│   │   ├── premium/            # Suscripción premium
│   │   ├── notifications/      # Centro de notificaciones
│   │   ├── ratings/            # Valoraciones
│   │   ├── reports/            # Reportes de contenido
│   │   └── settings/           # Ajustes de cuenta
│   ├── widgets/                # Componentes reutilizables
│   └── utils/                  # Helpers y utilidades
├── assets/
│   └── images/
│       └── logo.png            # Logo de Oolale
├── android/                    # Configuración nativa Android
├── ios/                        # Configuración nativa iOS
└── pubspec.yaml
```

---

## 🖼️ Capturas de Pantalla

> *Próximamente — screenshots de las pantallas principales.*

<!-- Para agregar capturas, descomenta y edita:
<p align="center">
  <img src="./docs/screenshots/login.png" alt="Login" width="220" />
  <img src="./docs/screenshots/dashboard.png" alt="Dashboard" width="220" />
  <img src="./docs/screenshots/profile.png" alt="Perfil" width="220" />
  <img src="./docs/screenshots/discovery.png" alt="Descubrimiento" width="220" />
  <img src="./docs/screenshots/messages.png" alt="Mensajes" width="220" />
</p>
-->

---

## 🚀 Cómo Ejecutarlo

### Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Dart `^3.10.1`)
- Android Studio / Xcode (para emuladores)
- Un dispositivo físico **o** emulador configurado
- Cuenta en [Supabase](https://supabase.com/) con el proyecto configurado
- Proyecto en [Firebase](https://firebase.google.com/) (para notificaciones push)

### 1. Clonar el repositorio

```bash
git clone https://github.com/Lysande2902/oolale_mobile.git
cd oolale_mobile
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

Coloca tu archivo `google-services.json` en `android/app/` y `GoogleService-Info.plist` en `ios/Runner/`.

### 4. Configurar Supabase

Edita el archivo de configuración con tus credenciales de Supabase:

```dart
// lib/config/supabase_config.dart
const supabaseUrl = 'TU_SUPABASE_URL';
const supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';
```

### 5. Ejecutar la aplicación

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar en un dispositivo específico
flutter run -d <device_id>
```

### 6. Build para producción

```bash
# Android (APK)
flutter build apk --release

# Android (App Bundle para Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🏗️ Arquitectura

El proyecto sigue el patrón **MVVM** adaptado a Flutter:

```
Vista (Screens/Widgets)
    ↕ escucha cambios
Providers (Estado)
    ↕ llama a
Services (Lógica de negocio)
    ↕ consulta/modifica
Supabase / Firebase (Backend)
```

- **Screens** → Presentación
- **Providers** → Estado y reactividad con `ChangeNotifier`
- **Services** → Lógica de negocio, llamadas API y base de datos
- **Models** → Estructuras de datos tipadas

---

## 👩‍💻 Autora

**Yeng Lee Salas Jiménez**

[![GitHub](https://img.shields.io/badge/GitHub-Lysande2902-181717?style=for-the-badge&logo=github)](https://github.com/Lysande2902)

---

> Este proyecto es la app móvil de **Oolale**. El panel administrativo web está disponible en [JAMConnect_Web](https://github.com/Lysande2902/JAMConnect_Web).
