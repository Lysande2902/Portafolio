/**
 * ENDPOINTS API PARA IMPLEMENTACIÓN FASE 1-2
 * Portfolio Multimedia, Reputación, Búsqueda Avanzada
 */

// ============================================================
// 1. PORTFOLIO MULTIMEDIA
// ============================================================

/**
 * POST /portfolio/media
 * Subir archivo de media (video, audio, imagen)
 * 
 * Headers:
 * - Authorization: Bearer <token>
 * - Content-Type: multipart/form-data
 */
router.post('/portfolio/media', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    const { titulo, descripcion, tipo, visibilidad } = req.body;
    const userId = req.user.id;

    // Validar
    if (!titulo || !tipo || !['video', 'audio', 'imagen'].includes(tipo)) {
      return res.status(400).json({ error: 'Parámetros inválidos' });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'No hay archivo' });
    }

    // Subir a S3/Supabase Storage
    const fileName = `${Date.now()}_${req.file.originalname}`;
    const path = `portfolio/${userId}/${tipo}/${fileName}`;

    const { data, error } = await supabase.storage
      .from('media')
      .upload(path, req.file.buffer);

    if (error) throw error;

    // Obtener URL pública
    const { data: urlData } = supabase.storage
      .from('media')
      .getPublicUrl(path);

    // Crear registro en BD
    const { data: mediaData, error: dbError } = await supabase
      .from('portfolio_media')
      .insert({
        profile_id: userId,
        tipo,
        titulo,
        descripcion: descripcion || '',
        url: urlData.publicUrl,
        visibilidad: visibilidad || 'privado',
        vistas: 0,
        descargas: 0,
        compartidos: 0,
        created_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (dbError) throw dbError;

    res.json({
      success: true,
      media: mediaData,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /portfolio/media/:userId
 * Obtener media del usuario (respeta privacidad)
 */
router.get('/portfolio/media/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.user?.id;

    // Obtener media (RLS policy maneja privacidad)
    const { data, error } = await supabase
      .from('portfolio_media')
      .select('id, tipo, titulo, descripcion, url, thumbnail_url, visibilidad, vistas, descargas, compartidos, created_at')
      .eq('profile_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    // Filtrar por privacidad en backend
    const filtered = data.filter(media => {
      if (media.visibilidad === 'publico') return true;
      if (currentUserId === userId) return true; // Owner ve todo
      if (media.visibilidad === 'privado') return false;
      // TODO: Para 'amigos', verificar relación
      return true;
    });

    // Incrementar vistas
    if (currentUserId !== userId) {
      await supabase
        .from('portfolio_media')
        .update({ vistas: 'vistas + 1' })
        .in('id', filtered.map(m => m.id));
    }

    res.json({
      success: true,
      total: filtered.length,
      media: filtered,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * DELETE /portfolio/media/:mediaId
 * Eliminar media (solo owner)
 */
router.delete('/portfolio/media/:mediaId', authenticateToken, async (req, res) => {
  try {
    const { mediaId } = req.params;
    const userId = req.user.id;

    // Verificar ownership
    const { data: media, error: getError } = await supabase
      .from('portfolio_media')
      .select('profile_id, url')
      .eq('id', mediaId)
      .single();

    if (getError || media.profile_id !== userId) {
      return res.status(403).json({ error: 'No autorizado' });
    }

    // Eliminar de Storage
    const path = media.url.split('/media/')[1];
    await supabase.storage.from('media').remove([path]);

    // Eliminar registro
    await supabase.from('portfolio_media').delete().eq('id', mediaId);

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /portfolio/media/:mediaId/download
 * Descargar media (incrementa contador)
 */
router.get('/portfolio/media/:mediaId/download', async (req, res) => {
  try {
    const { mediaId } = req.params;

    // Incrementar descargas
    await supabase
      .from('portfolio_media')
      .update({ descargas: 'descargas + 1' })
      .eq('id', mediaId);

    // TODO: Retornar el archivo
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============================================================
// 2. CALIFICACIONES Y REPUTACIÓN
// ============================================================

/**
 * POST /calificaciones
 * Crear nueva calificación
 */
router.post('/calificaciones', authenticateToken, async (req, res) => {
  try {
    const { para_usuario_id, estrellas, comentario, tipo_interaccion } = req.body;
    const de_usuario_id = req.user.id;

    // Validar
    if (!para_usuario_id || !estrellas || estrellas < 1 || estrellas > 5) {
      return res.status(400).json({ error: 'Parámetros inválidos' });
    }

    // Verificar que no se califique a sí mismo
    if (de_usuario_id === para_usuario_id) {
      return res.status(400).json({ error: 'No puedes calificarte a ti mismo' });
    }

    // Crear calificación
    const { data, error } = await supabase
      .from('calificaciones')
      .insert({
        de_usuario_id,
        para_usuario_id,
        estrellas,
        comentario: comentario || '',
        tipo_interaccion: tipo_interaccion || 'colaboracion',
        created_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw error;

    // El trigger SQL automáticamente actualiza:
    // - profiles.rating_promedio
    // - profiles.total_calificaciones
    // - puntuacion_reputacion

    res.json({
      success: true,
      calificacion: data,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /calificaciones/:userId
 * Obtener calificaciones de usuario
 */
router.get('/calificaciones/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    // Obtener calificaciones
    const { data, count, error } = await supabase
      .from('calificaciones')
      .select('*, de_usuario:de_usuario_id(nombre_artistico, foto_perfil)', { count: 'exact' })
      .eq('para_usuario_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    // Calcular distribución
    const distribucion = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    data.forEach(cal => {
      distribucion[cal.estrellas]++;
    });

    res.json({
      success: true,
      total: count,
      page,
      limit,
      distribucion,
      calificaciones: data,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /reputacion/:userId
 * Obtener datos completos de reputación
 */
router.get('/reputacion/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Obtener perfil + reputación
    const { data, error } = await supabase
      .from('profiles')
      .select(`
        id,
        nombre_artistico,
        foto_perfil,
        rating_promedio,
        total_calificaciones,
        verificado,
        puntuacion_reputacion!inner(
          puntuacion_final,
          dias_en_plataforma,
          tasa_respuesta,
          eventos_completados
        )
      `)
      .eq('id', userId)
      .single();

    if (error) throw error;

    // Obtener referencias verificadas
    const { data: referencias } = await supabase
      .from('referencias')
      .select('*')
      .eq('para_usuario_id', userId)
      .eq('verificado', true);

    res.json({
      success: true,
      usuario: {
        id: data.id,
        nombre_artistico: data.nombre_artistico,
        foto_perfil: data.foto_perfil,
        verificado: data.verificado,
      },
      reputacion: {
        rating_promedio: data.rating_promedio,
        total_calificaciones: data.total_calificaciones,
        ...data.puntuacion_reputacion[0],
        referencias_verificadas: referencias?.length || 0,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============================================================
// 3. BÚSQUEDA AVANZADA
// ============================================================

/**
 * POST /search/advanced
 * Búsqueda con filtros avanzados
 */
router.post('/search/advanced', async (req, res) => {
  try {
    const {
      q = '',
      filtros = {},
      ordenar = 'relevancia',
      page = 1,
      limit = 20,
    } = req.body;

    const offset = (page - 1) * limit;

    // Construir query base
    let query = supabase
      .from('profiles')
      .select(`
        id,
        nombre_artistico,
        foto_perfil,
        ubicacion,
        rating_promedio,
        total_calificaciones,
        ranking_tipo,
        verificado,
        open_to_work,
        bio,
        perfiles_instrumentos(instrumentos(id, nombre, nivel)),
        perfiles_generos(generos(id, nombre)),
        puntuacion_reputacion(puntuacion_final)
      `, { count: 'exact' });

    // Aplicar búsqueda de texto
    if (q) {
      query = query.or(`nombre_artistico.ilike.%${q}%,bio.ilike.%${q}%`);
    }

    // Aplicar filtros
    if (filtros.ubicacion) {
      query = query.ilike('ubicacion', `%${filtros.ubicacion}%`);
    }

    if (filtros.verificado !== undefined) {
      query = query.eq('verificado', filtros.verificado);
    }

    if (filtros.open_to_work !== undefined) {
      query = query.eq('open_to_work', filtros.open_to_work);
    }

    if (filtros.reputacion_minima !== undefined) {
      query = query.gte('rating_promedio', filtros.reputacion_minima);
    }

    // Ordenamiento
    let orderColumn = 'created_at';
    let ascending = false;
    
    switch (ordenar) {
      case 'rating':
        orderColumn = 'rating_promedio';
        ascending = false;
        break;
      case 'reciente':
        orderColumn = 'created_at';
        ascending = false;
        break;
      case 'ranking':
        // Priorizar por ranking
        orderColumn = 'ranking_tipo';
        break;
    }

    query = query.order(orderColumn, { ascending });

    // Ejecutar query
    const { data, count, error } = await query.range(offset, offset + limit - 1);

    if (error) throw error;

    // Aplicar filtros adicionales en memoria (generos, instrumentos, nivel, ranking)
    let filtered = data;

    if (filtros.generos && filtros.generos.length > 0) {
      filtered = filtered.filter(user => {
        const userGeneros = user.perfiles_generos.map(pg => pg.generos.id);
        return filtros.generos.some(g => userGeneros.includes(g));
      });
    }

    if (filtros.instrumentos && filtros.instrumentos.length > 0) {
      filtered = filtered.filter(user => {
        const userInstrumentos = user.perfiles_instrumentos.map(pi => pi.instrumentos.id);
        return filtros.instrumentos.some(i => userInstrumentos.includes(i));
      });
    }

    if (filtros.nivel) {
      filtered = filtered.filter(user => {
        return user.perfiles_instrumentos.some(pi => pi.instrumentos.nivel === filtros.nivel);
      });
    }

    if (filtros.ranking && filtros.ranking.length > 0) {
      filtered = filtered.filter(user => 
        user.ranking_tipo && filtros.ranking.includes(user.ranking_tipo)
      );
    }

    // Formatear respuesta
    const results = filtered.map(user => ({
      id: user.id,
      nombre_artistico: user.nombre_artistico,
      foto_perfil: user.foto_perfil,
      ubicacion: user.ubicacion,
      bio: user.bio,
      rating_promedio: user.rating_promedio,
      total_calificaciones: user.total_calificaciones,
      ranking_tipo: user.ranking_tipo,
      verificado: user.verificado,
      open_to_work: user.open_to_work,
      instrumentos: user.perfiles_instrumentos.map(pi => ({
        id: pi.instrumentos.id,
        nombre: pi.instrumentos.nombre,
        nivel: pi.instrumentos.nivel,
      })),
      generos: user.perfiles_generos.map(pg => ({
        id: pg.generos.id,
        nombre: pg.generos.nombre,
      })),
      reputacion_puntuacion: user.puntuacion_reputacion?.[0]?.puntuacion_final || 0,
    }));

    res.json({
      success: true,
      total: filtered.length,
      page,
      limit,
      resultados: results,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /search/generos
 * Obtener lista de géneros para filtros
 */
router.get('/search/generos', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('generos')
      .select('id, nombre');

    if (error) throw error;

    res.json({ success: true, generos: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /search/instrumentos
 * Obtener lista de instrumentos para filtros
 */
router.get('/search/instrumentos', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('instrumentos')
      .select('id, nombre, nivel');

    if (error) throw error;

    res.json({ success: true, instrumentos: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /search/ubicaciones
 * Autocompletar ubicaciones
 */
router.get('/search/ubicaciones', async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.length < 2) {
      return res.json({ success: true, ubicaciones: [] });
    }

    const { data, error } = await supabase
      .from('profiles')
      .select('ubicacion')
      .ilike('ubicacion', `%${q}%`)
      .limit(10);

    if (error) throw error;

    // Eliminar duplicados
    const ubicaciones = [...new Set(data.map(d => d.ubicacion).filter(Boolean))];

    res.json({ success: true, ubicaciones });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
