# 🎵 JAMConnect Web — Panel Administrativo

<p align="center">
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/EJS-B4CA65?style=for-the-badge&logo=ejs&logoColor=black" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
</p>

Panel web administrativo para la plataforma **Oolale** (antes JAMConnect), una red social para músicos y artistas. Permite gestionar usuarios, moderar contenido, revisar reportes y consultar estadísticas desde una interfaz segura y centralizada.

---

## 📋 Descripción del Proyecto

**JAMConnect Web Admin** es una aplicación web full-stack que actúa como el centro de control de la plataforma Oolale. Fue construida con arquitectura **MVC** usando Node.js + Express en el backend y EJS como motor de plantillas.

### ✨ Funcionalidades principales

| Módulo | Descripción |
|--------|-------------|
| 🔐 **Autenticación** | Login seguro con sesiones, bcrypt y rate limiting |
| 📊 **Dashboard** | Métricas en tiempo real: usuarios, proyectos, actividad |
| 👥 **Gestión de Usuarios** | Ver, editar, suspender y eliminar cuentas |
| 📁 **Gestión de Proyectos** | Moderar proyectos musicales publicados por usuarios |
| 🚨 **Reportes** | Revisar y resolver reportes de contenido inapropiado |
| 📝 **Notas Internas** | Sistema de notas para el equipo administrativo |
| 🔍 **Auditoría** | Registro completo de todas las acciones administrativas |
| 🛡️ **Seguridad** | Cabeceras HTTP (Helmet), protección contra fuerza bruta, hashing |

---

## 🛠️ Tecnologías Usadas

### Backend
- **Node.js** — Entorno de ejecución
- **Express.js** — Framework web
- **Supabase** (`@supabase/supabase-js`) — Base de datos PostgreSQL en la nube
- **bcrypt** — Hashing seguro de contraseñas
- **jsonwebtoken** — Generación y validación de tokens JWT
- **express-session** — Gestión de sesiones
- **express-rate-limit** — Protección contra ataques de fuerza bruta
- **helmet** — Seguridad en cabeceras HTTP
- **node-cache** — Caché en memoria para optimizar el dashboard
- **morgan** — Logger de peticiones HTTP
- **dotenv** — Gestión de variables de entorno

### Frontend
- **EJS** — Motor de plantillas HTML dinámico
- **CSS3** — Variables, Flexbox y Grid para el diseño
- **Bootstrap Icons** — Iconografía

### DevOps / Herramientas
- **nodemon** — Recarga automática en desarrollo

---

## 📂 Estructura del Proyecto

```
JAMConnect_Web/
├── src/
│   ├── app.js              # Punto de entrada de la aplicación
│   ├── config/
│   │   └── db.js           # Configuración del cliente Supabase
│   ├── routes/
│   │   ├── admin.js        # Lógica principal del panel admin (700+ líneas)
│   │   ├── api.js          # Endpoints de la API REST
│   │   └── index.js        # Rutas públicas (Landing)
│   ├── views/
│   │   ├── admin/
│   │   │   ├── dashboard.ejs       # Vista del dashboard
│   │   │   ├── users.ejs           # Gestión de usuarios
│   │   │   ├── reports.ejs         # Módulo de reportes
│   │   │   ├── audit_log.ejs       # Registro de auditoría
│   │   │   ├── notes.ejs           # Notas internas
│   │   │   ├── login.ejs           # Pantalla de login
│   │   │   └── ...                 # Otras vistas
│   │   ├── admin_layout.ejs        # Layout maestro del panel
│   │   └── layout.ejs              # Layout público
│   ├── public/
│   │   ├── css/            # Estilos (admin.css, landing.css)
│   │   └── img/            # Assets e imágenes
│   └── scripts/            # Scripts de utilidad (crear admin, seeds)
├── .env.example            # Plantilla de variables de entorno
├── package.json
└── SETUP_ADMIN_TABLES.sql  # Script SQL de inicialización
```

---

## 🖼️ Capturas de Pantalla

> *Próximamente — screenshots del dashboard, módulo de usuarios y reportes.*

<!-- Para agregar capturas, descomenta y edita:
<p align="center">
  <img src="./screenshots/dashboard.png" alt="Dashboard" width="700" />
  <img src="./screenshots/users.png" alt="Gestión de usuarios" width="700" />
  <img src="./screenshots/reports.png" alt="Módulo de reportes" width="700" />
</p>
-->

---

## 🚀 Cómo Ejecutarlo

### Requisitos previos

- [Node.js](https://nodejs.org/) v14 o superior
- Una cuenta en [Supabase](https://supabase.com/) con el proyecto configurado

### 1. Clonar el repositorio

```bash
git clone https://github.com/Lysande2902/JAMConnect_Web.git
cd JAMConnect_Web
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=tu_url_de_supabase
SUPABASE_KEY=tu_api_key_de_supabase
SESSION_SECRET=una_cadena_secreta_larga_y_segura
PORT=4000
```

### 4. Inicializar la base de datos

Ejecuta los scripts SQL en tu panel de Supabase:

1. `SETUP_ADMIN_TABLES.sql` — Crea las tablas del panel admin
2. `OPTIMIZE_DB.sql` — Aplica índices y optimizaciones

### 5. Crear el primer administrador

```bash
node src/scripts/create_admin.js
```

### 6. Ejecutar en desarrollo

```bash
npm run dev
```

### 7. Ejecutar en producción

```bash
npm start
```

La aplicación estará disponible en: `http://localhost:4000`

---

## 🔒 Seguridad

Este proyecto implementa múltiples capas de seguridad:

- **Hashing de contraseñas** con `bcrypt` (salt rounds: 10)
- **Protección de cabeceras HTTP** con `helmet`
- **Rate limiting** en endpoints de login (protección contra fuerza bruta)
- **Sesiones seguras** con `express-session`
- **Auditoría completa** de todas las acciones administrativas

---

## 👩‍💻 Autora

**Yeng Lee Salas Jiménez**

[![GitHub](https://img.shields.io/badge/GitHub-Lysande2902-181717?style=for-the-badge&logo=github)](https://github.com/Lysande2902)

---

> Este proyecto es el panel administrativo de **Oolale**, una plataforma para que músicos encuentren colaboradores, compartan su trabajo y conecten con otros artistas.
