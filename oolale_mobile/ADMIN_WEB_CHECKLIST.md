# Checklist de Integración para Panel de Administración Web

Este documento detalla los puntos clave de funcionalidad para el panel administrativo web. 

**INSTRUCCIÓN PARA EL DESARROLLADOR:**
Copia el contenido del "ANEXO TÉCNICO" al final de este archivo y pégalo en el chat de tu IA (Cursor, Chatgpt, etc.) para que entienda exactamente la estructura de la base de datos con la que estás trabajando.

---

## 1. Sistema de Reportes (Gestión de Moderación)
**Tabla Principal:** `reportes`

*   **Buzón de Entrada:** Listar reportes donde `estatus = 'pendiente'`.
*   **Relaciones:**
    *   `reportante_id` -> `auth.users(id)`
    *   `usuario_reportado_id` -> `auth.users(id)`
*   **Acciones:**
    *   Actualizar `estatus` a `'resuelto'` o `'desestimado'`.
    *   Si es grave, insertar en `usuarios_bloqueados` (tabla de bloqueos de sistema/usuarios).

## 2. Moderación de Contenido Multimedia
**Tabla Principal:** `archivos_multimedia`

*   **Auditoría:** Filtrar por `profile_id` (del usuario reportado).
*   **Visualización:** Usar el campo `url_recurso` para mostrar la imagen/video/audio.
*   **Acción:** Software Delete (actualizar `deleted_at`) para eliminar contenido ofensivo sin romper la integridad.

## 3. Gestión de Usuarios y Bloqueos
**Tablas:** `perfiles`, `usuarios_bloqueados`

*   **Perfil Completo:** Consultar tabla `perfiles` por `id` (UUID).
*   **Historial de Bloqueos:** Consultar `usuarios_bloqueados` donde `bloqueado_id` es el usuario sospechoso.
*   **Banear Usuario:** Insertar en `usuarios_bloqueados` con `moderador_id` = ID del admin.

## 4. Gestión de Eventos
**Tabla Principal:** `eventos`

*   **Dashboard:** Listar eventos ordenados por `created_at` desc.
*   **Moderación:** Capacidad de cambiar `estatus_bolo` a `'cancelado'` o `'suspendido'`.
*   **Detalle:** Mostrar `titulo_bolo`, `fecha_gig`, `lugar_nombre` y el organizador (`organizador_id` -> `perfiles.id`).

## 5. Finanzas (Wallet)
**Tabla Principal:** `tickets_pagos`

*   **Auditoría:** Listar pagos por `estatus` y `pasarela`.
*   **Total:** Sumar `monto_total` para reportes financieros.

---

# ANEXO TÉCNICO: PROMPT PARA IA (CONTEXTO DE DB)

*(Copia y pega esto en tu primera interacción con tu asistente de IA)*

```sql
-- CONTEXTO DE BASE DE DATOS SUPABASE (POSTGRESQL)
-- Usa este esquema para generar las consultas y tipos de datos del panel administrativo.

-- TABLAS PRINCIPALES
-- Perfiles de usuario (Datos públicos extendidos de auth.users)
CREATE TABLE public.perfiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id), -- Relación 1:1 con Auth
  email varchar UNIQUE,
  nombre_artistico varchar NOT NULL,
  rol_principal text DEFAULT 'musico', -- 'musico', 'organizador', etc.
  is_active boolean DEFAULT true,
  perfil_completo boolean DEFAULT false,
  verificado boolean DEFAULT false, -- Blue check
  avatar_url text,
  ubicacion text
);

-- Archivos (Fotos, Videos, Audios)
CREATE TABLE public.archivos_multimedia (
  id serial PRIMARY KEY,
  profile_id uuid REFERENCES public.perfiles(id),
  tipo varchar NOT NULL, -- 'imagen', 'video', 'audio'
  url_recurso varchar NOT NULL,
  visibilidad varchar DEFAULT 'publico',
  deleted_at timestamp -- Soft delete
);

-- Reportes (Sistema de denuncias)
CREATE TABLE public.reportes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reportante_id uuid REFERENCES auth.users(id),
  usuario_reportado_id uuid REFERENCES auth.users(id), -- FK a Auth, no Perfiles
  contenido_tipo text NOT NULL, -- 'perfil', 'evento', 'post'
  categoria text NOT NULL, -- 'spam', 'acoso', etc.
  descripcion text,
  estatus text DEFAULT 'pendiente', -- 'pendiente', 'resuelto'
  created_at timestamp DEFAULT now()
);

-- Eventos (Gigs)
CREATE TABLE public.eventos (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  titulo_bolo text NOT NULL,
  fecha_gig date,
  lugar_nombre text,
  organizador_id uuid REFERENCES public.perfiles(id),
  estatus_bolo text DEFAULT 'abierto', -- 'abierto', 'cerrado', 'cancelado'
  created_at timestamp DEFAULT now()
);

-- Bloqueos (Usuarios bloqueando usuarios)
CREATE TABLE public.usuarios_bloqueados (
  id serial PRIMARY KEY,
  usuario_id uuid REFERENCES public.perfiles(id), -- Quien bloquea
  bloqueado_id uuid REFERENCES public.perfiles(id), -- Quien es bloqueado
  activo boolean DEFAULT true,
  moderador_id uuid REFERENCES public.perfiles(id) -- Si es null, fue un usuario. Si tiene ID, fue un Admin.
);

-- Pagos (Wallet)
CREATE TABLE public.tickets_pagos (
  id bigint PRIMARY KEY,
  comprador_id uuid REFERENCES public.perfiles(id),
  monto_total numeric NOT NULL,
  estatus text NOT NULL, -- 'pagado', 'pendiente', 'fallido'
  pasarela text NOT NULL -- 'stripe', 'paypal'
);

-- NOTAS IMPORTANTES PARA LA IA:
-- 1. Los IDs de usuario son SIEMPRE UUIDs (Strings).
-- 2. La tabla 'perfiles' extiende 'auth.users'. Para información visual (nombre, foto) usa 'perfiles'.
-- 3. Para reportes, los FK apuntan a 'auth.users', así que podrías necesitar hacer join con 'perfiles' para mostrar nombres en el Admin Panel.
-- 4. 'usuarios_bloqueados' se usa tanto para bloqueos entre usuarios como para baneos de sistema (ver moderador_id).
```
