# Portafolio de Proyectos - Yeng Lee Salas Jiménez

## Descripción del Proyecto

Este repositorio sirve como mi portafolio personal y profesional de desarrollo de software. Aquí alojo los proyectos completos en los que he trabajado, organizados por carpetas. El objetivo es centralizar mi código y recursos, demostrando mis habilidades para analizar problemas, diseñar arquitecturas e implementar soluciones tecnológicas.

**Proyecto Actual Destacado: Oolale (JAMConnect)**  
Actualmente, el portafolio engloba el proyecto completo de **Oolale**, una plataforma social y colaborativa para músicos y artistas. El código se divide en dos módulos principales:

1. **`oolale_mobile/`**: Aplicación móvil multiplataforma para interactuar con la red social.
2. **`JAMConnect_Web/`**: Backend, API y Panel Administrativo Web para gestionar la plataforma completa.

*(A medida que desarrolle nuevas soluciones, se agregarán a este mismo repositorio).*

---

## Tecnologías usadas

A lo largo de los proyectos contenidos en este portafolio, se aplican diferentes lenguajes y herramientas para construir arquitecturas completas (desde la base de datos hasta interfaces móviles y web):

*   **Desarrollo Móvil (Frontend):** Flutter, Dart, Provider, GoRouter
*   **Desarrollo Web y Servidor (Backend):** Node.js, Express.js, EJS, HTML, CSS
*   **Bases de Datos y Herramientas Cloud:** Supabase (PostgreSQL), Firebase (Notificaciones Push)
*   **Seguridad y Sesiones:** JWT, bcrypt, express-session, helmet
*   **Control de Versiones y Diseño:** Git, GitHub, Arquitectura MVC y MVVM

---

## Capturas o gifs

> *En esta sección irán las capturas de demostración de los múltiples proyectos del portafolio. A continuación, puedes añadir evidencia visual del funcionamiento de Oolale App y Web.*

*(Próximamente: Sube las imágenes a una carpeta del repositorio y pon los enlaces aquí abajo)*

<!-- Ejemplo de cómo activarlo:
### Oolale App
![Feed Principal](./capturas/oolale_feed.png) 
![Perfil de Usuario](./capturas/oolale_perfil.png)

### Panel Web Admin
![Dashboard](./capturas/panel_dashboard.gif)
-->

---

## Cómo ejecutarlo

Dado que este repositorio contiene múltiples proyectos y arquitecturas, cada subproyecto tiene su propia forma de ser iniciado. Las instrucciones detalladas están dentro de la carpeta de cada proyecto, pero aquí tienes una guía rápida:

### 1. Ejecutar la App Móvil (Oolale Flutter)
Para correr la aplicación móvil, asegúrate de tener el SDK de Flutter instalado, navega a la carpeta correspondiente e inicia el emulador o dispositivo:
```bash
cd oolale_mobile
flutter pub get
flutter run
```
👉 *Para leer la documentación técnica completa, reglas de Firebase y Supabase, revisa su propio [README de la App Móvil](./oolale_mobile/README.md).*

### 2. Ejecutar el Panel Web (Node.js)
Para arrancar el panel administrativo y los servicios del backend, necesitarás tener Node.js instalado:
```bash
cd JAMConnect_Web
npm install
npm run dev
```
👉 *Para ver variables de entorno necesarias y configuración de la base de datos SQL, revisa su propio [README del Panel Administrativo](./JAMConnect_Web/README.md).*
