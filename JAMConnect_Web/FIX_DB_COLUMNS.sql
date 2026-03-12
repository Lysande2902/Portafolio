-- 🛠️ SCRIPT DE REPARACIÓN DE BASE DE DATOS
-- Ejecuta esto para agregar las columnas faltantes en tablas existentes.

-- 1. Agregar columnas faltantes a la tabla "Reportes"
ALTER TABLE "Reportes" 
ADD COLUMN IF NOT EXISTS "estado" VARCHAR(20) DEFAULT 'pendiente' CHECK ("estado" IN ('pendiente', 'en_revision', 'resuelto', 'descartado')),
ADD COLUMN IF NOT EXISTS "fecha_resolucion" TIMESTAMP,
ADD COLUMN IF NOT EXISTS "resolucion_nota" TEXT;

-- 2. Asegurar que la tabla "Perfiles" tenga las columnas de la Fase 2
ALTER TABLE "Perfiles" 
ADD COLUMN IF NOT EXISTS "enlace_soundcloud" TEXT,
ADD COLUMN IF NOT EXISTS "enlace_youtube" TEXT,
ADD COLUMN IF NOT EXISTS "enlace_website" TEXT,
ADD COLUMN IF NOT EXISTS "open_to_work" BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS "nivel_badge" VARCHAR(20) DEFAULT 'principiante',
ADD COLUMN IF NOT EXISTS "verificado" BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS "instrumento_principal" VARCHAR(100); -- Nuevo para Discovery

-- 3. Crear índices si faltan (mejora rendimiento)
CREATE INDEX IF NOT EXISTS idx_reportes_estado ON "Reportes"("estado");

-- 4. Mensaje de éxito
DO $$
BEGIN
    RAISE NOTICE 'Base de datos reparada exitosamente. Columnas faltantes agregadas.';
END $$;
