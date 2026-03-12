-- ========================================================
-- 📱 GOD MODE SCRIPT: ESTRUCTURA ÓOLALE MOBILE v3.0
-- ========================================================

-- 1. EXTENSIONES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TIPOS DE DATOS (Enums)
DO $$ BEGIN
    CREATE TYPE rol_escena AS ENUM ('musico', 'banda', 'productor', 'fan');
    CREATE TYPE estado_reporte AS ENUM ('pendiente', 'resuelto', 'descartado', 'banneado');
    CREATE TYPE motivo_reporte AS ENUM ('spam', 'acoso', 'contenido_inapropiado', 'estafa', 'otro');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. PERFILES DE USUARIO (Profiles)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT, -- Espejo de auth.users
    nombre_completo TEXT,
    nombre_artistico TEXT,
    avatar_url TEXT,
    banner_url TEXT,
    bio_rider TEXT,
    ubicacion_base TEXT,
    rol_principal rol_escena DEFAULT 'musico',
    instrumento_principal TEXT, -- Vital para Discovery
    
    -- Redes y Portfolio (Fase 2)
    enlace_soundcloud TEXT,
    enlace_youtube TEXT,
    enlace_website TEXT,
    
    -- Estado
    open_to_work BOOLEAN DEFAULT FALSE,
    nivel_badge TEXT DEFAULT 'principiante', -- principiante, pro, maestro
    verificado BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. INVENTARIO (Gear)
CREATE TABLE IF NOT EXISTS public.gear (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    categoria TEXT, -- Guitarra, Ampli, etc
    foto_url TEXT,
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. EVENTOS (Gigs)
CREATE TABLE IF NOT EXISTS public.gigs (
    id SERIAL PRIMARY KEY,
    organizador_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    descripcion TEXT,
    tipo_evento TEXT, -- concierto, ensayo, jam
    ubicacion TEXT,
    fecha_hora TIMESTAMPTZ NOT NULL,
    flyer_url TEXT,
    setlist JSONB DEFAULT '[]'::jsonb, -- Lista de canciones
    estado TEXT DEFAULT 'programado',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. SEGURIDAD: REPORTES (Lo que faltaba)
CREATE TABLE IF NOT EXISTS public.reports (
    id SERIAL PRIMARY KEY,
    reporter_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    reported_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    motivo motivo_reporte NOT NULL,
    descripcion TEXT,
    evidencia_url TEXT,
    estado estado_reporte DEFAULT 'pendiente',
    resolucion_nota TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- 7. SEGURIDAD: BLOQUEOS
CREATE TABLE IF NOT EXISTS public.blocks (
    id SERIAL PRIMARY KEY,
    blocker_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    blocked_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);

-- 8. TRIGGER AUTOMÁTICO (Auth -> Profile)
-- Crea el perfil automáticamente cuando un usuario se registra
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, nombre_completo)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 9. HABILITAR SEGURIDAD (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE gigs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Políticas permisivas para desarrollo rápido (Ajustar en producción)
CREATE POLICY "Public Profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "User Edit Own Profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Public Gigs" ON gigs FOR SELECT USING (true);
CREATE POLICY "Authenticated Reports" ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
