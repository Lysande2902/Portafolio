-- ============================================
-- TABLA: mensajes_evento
-- Descripción: Almacena mensajes del chat grupal de eventos
-- ============================================

CREATE TABLE IF NOT EXISTS mensajes_evento (
  id BIGSERIAL PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mensaje TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_mensajes_evento_event_id ON mensajes_evento(event_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_evento_user_id ON mensajes_evento(user_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_evento_created_at ON mensajes_evento(created_at DESC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE mensajes_evento ENABLE ROW LEVEL SECURITY;

-- Política: Los participantes confirmados del evento pueden ver todos los mensajes
CREATE POLICY "Participantes pueden ver mensajes del evento"
ON mensajes_evento
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM participantes_evento
    WHERE participantes_evento.event_id = mensajes_evento.event_id
    AND participantes_evento.user_id = auth.uid()
    AND participantes_evento.confirmed = true
  )
);

-- Política: Los participantes confirmados pueden enviar mensajes
CREATE POLICY "Participantes pueden enviar mensajes"
ON mensajes_evento
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM participantes_evento
    WHERE participantes_evento.event_id = mensajes_evento.event_id
    AND participantes_evento.user_id = auth.uid()
    AND participantes_evento.confirmed = true
  )
  AND user_id = auth.uid()
);

-- Política: Los usuarios pueden eliminar sus propios mensajes
CREATE POLICY "Usuarios pueden eliminar sus mensajes"
ON mensajes_evento
FOR DELETE
USING (user_id = auth.uid());

-- ============================================
-- REALTIME: Habilitar subscripciones en tiempo real
-- ============================================

-- Habilitar Realtime para la tabla
ALTER PUBLICATION supabase_realtime ADD TABLE mensajes_evento;

-- ============================================
-- COMENTARIOS
-- ============================================

COMMENT ON TABLE mensajes_evento IS 'Mensajes del chat grupal de eventos';
COMMENT ON COLUMN mensajes_evento.event_id IS 'ID del evento al que pertenece el mensaje';
COMMENT ON COLUMN mensajes_evento.user_id IS 'ID del usuario que envió el mensaje';
COMMENT ON COLUMN mensajes_evento.mensaje IS 'Contenido del mensaje';
COMMENT ON COLUMN mensajes_evento.created_at IS 'Fecha y hora de creación del mensaje';
