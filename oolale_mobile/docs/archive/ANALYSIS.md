# Análisis de Estado - ÓOLALE Mobile

Este documento detalla el análisis actual de la aplicación, identificando faltantes, errores, inconsistencias y áreas de mejora, enfocándose en las solicitudes recientes.

## 1. Integración de Pagos (MercadoPago)
**Estado Actual:**
- Existe un `PaymentService` con un método `initiateMercadoPagoPayment`, pero es una simulación (`mock`).
- La pantalla de suscripción (`SubscriptionScreen`) tiene botones de "Suscribirse" que abren un diálogo de "Próximamente".
- No hay integración real con el SDK de MercadoPago o con un backend que genere las preferencias de pago.

**Faltantes:**
- Implementar la llamada real a la API de MercadoPago (o backend intermedio) para obtener el `init_point` (URL de pago).
- Manejar los esquemas de URL (Deep Links) para detectar cuando el usuario regresa de pagar (éxito/fallo).
- Actualizar el estado del usuario a "Premium" en la base de datos (Supabase) tras el pago exitoso.

## 2. Reproductor de Video (Video Player)
**Estado Actual:**
- `VideoPlayerWidget` es funcional para reproducir, pausar y ajustar volumen.
- El botón de pantalla completa muestra un mensaje "Fullscreen próximamente".

**Faltantes:**
- Implementar la lógica de pantalla completa. Esto requiere rotar la orientación del dispositivo o navegar a una nueva ruta que ocupe toda la pantalla y oculte las barras de sistema.

## 3. Tamaño de Fuente (Configuración)
**Estado Actual:**
- Existe `FontSizeScreen` que permite al usuario seleccionar un porcentaje de escala (0.8x a 1.5x) y guarda el valor en `AccessibilityProvider`.
- **ERROR CRÍTICO:** La aplicación (`MaterialApp` en `main.dart`) **no escucha** los cambios de `AccessibilityProvider` para actualizar el `TextTheme`. Por lo tanto, la configuración no tiene efecto visual en la app.

**Corrección Necesaria:**
- Modificar `main.dart` para aplicar el `fontScale` del `AccessibilityProvider` al tema global.

## 4. Análisis de "Cosas que faltan" e Inconsistencias (Lógica y UX)

### A. Registro y Autenticación
- **Flujo de Roles:** En `RegisterScreen`, existe un mapa de roles (`_roles`) con opciones como "Banda", "Productor", etc., pero la lógica de registro (`_handleRegister`) fuerza el rol a "musico".
  - *Recomendación:* Restaurar la selección de rol en la UI o limpiar el código muerto si ya no se usa.
- **Validación de Correo:** En `LoginScreen`, hay validación básica, pero sería ideal verificar existencia antes de intentar login para mejorar UX (aunque AuthProvider maneja el error).

### B. Navegación y Rutas
- **Search:** No hay una ruta global `/search`, aunque existe `UserSearchScreen` integrada como tab en `HomeScreen`. Esto es aceptable pero limita la capacidad de hacer "deep linking" directo a la búsqueda.
- **Manejo de Errores Global:** `ErrorApp` solo se usa en el inicio (`main`). Si ocurre un error no capturado durante el uso, la app podría quedarse en pantalla gris/roja. Falta un `ErrorBoundary` global dentro de `MaterialApp`.

### C. UI/UX "Premium"
- **Placeholders:** Aún hay comentarios de "TODO" en servicios clave como `PaymentService`.
- **Feed:** El feed (`HomeScreen`) mezcla lógica de "Eventos urgentes" y "Artistas destacados" con una rotación compleja. Si no hay datos (ej. app nueva), puede verse vacío. El fallback actual carga eventos "futuros" cualquiera, lo cual es bueno, pero podría mejorarse con un mensaje de "Sé el primero en crear un evento".

### D. Reporte de Errores
- El usuario solicitó "cosas que no tienen lógica".
  - **Botón de Pánico/Soporte:** En `Configuration`, hay muchas opciones. Falta quizás un acceso más directo a soporte si algo falla críticamente.

## Plan de Acción Inmediato
1. **Corregir Tamaño de Fuente**: Habilitar la funcionalidad en `main.dart` para que el ajuste sea real.
2. **Video Player Fullscreen**: Implementar la vista de pantalla completa.
3. **Pagos MercadoPago**: Habilitar la redirección a la URL de pago (aunque sea simulada por ahora si no hay backend, pero funcional en flujo) y manejar el retorno.
