const express = require('express');
const router = express.Router();
const supabase = require('../config/db');
const bcrypt = require('bcrypt'); // Mantenemos bcrypt si es auth custom, o usamos Supabase Auth
const jwt = require('jsonwebtoken');

// Secret para JWT
const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_mobile_key_12345';

// Middleware para verificar Token JWT
const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) return res.status(401).json({ success: false, message: 'Token requerido' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ success: false, message: 'Token inválido' });
        req.user = user; // user.id será el UUID
        next();
    });
};

/* =========================================
   🔑 AUTHENTICATION (Adaptado a 'profiles')
   ========================================= */

// POST /api/auth/login
router.post('/auth/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // Opción 1: Autenticación nativa Supabase (Recomendada)
        const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (authError) {
            // Fallback: Si usas auth custom sobre tabla, busca en profiles (solo si tiene password, que no suele tener).
            // Asumimos que quieres usar Supabase Auth real ahora.
            return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
        }

        const user = authData.user;
        const token = authData.session.access_token; // Usar token de Supabase

        // Obtener datos del perfil
        const { data: profile } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single();

        const userData = {
            id: user.id,
            name: profile?.nombre_completo || user.email,
            email: user.email,
            photo: profile?.avatar_url
        };

        // Devolvemos el token de sesión de Supabase (o nuestro JWT si prefieres)
        res.json({ success: true, token, user: userData });

    } catch (e) {
        console.error('Login Error:', e);
        res.status(500).json({ success: false, message: 'Error del servidor' });
    }
});

// POST /api/auth/register
router.post('/auth/register', async (req, res) => {
    const { email, password, fullName } = req.body;

    try {
        // Registro en Supabase Auth
        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: { full_name: fullName } // Esto dispara el trigger handle_new_user
            }
        });

        if (error) return res.status(400).json({ success: false, message: error.message });

        const newUser = data.user;
        const token = data.session?.access_token;

        const userData = {
            id: newUser.id,
            name: fullName,
            email: newUser.email,
            photo: null
        };

        res.json({ success: true, token, user: userData, message: 'Registro exitoso' });

    } catch (e) {
        console.error('Register Error:', e);
        res.status(500).json({ success: false, message: 'Error al registrar usuario' });
    }
});

/* =========================================
   🛡️ SECURITY SYSTEM (Reports & Blocks)
   ========================================= */

// POST /api/report
router.post('/report', verifyToken, async (req, res) => {
    const { reportedUserId, reason, description } = req.body;
    const reporterId = req.user.id;

    try {
        const { error } = await supabase.from('reports').insert([{
            reporter_id: reporterId,
            reported_id: reportedUserId,
            motivo: reason,
            descripcion: description,
            estado: 'pendiente'
        }]);

        if (error) throw error;
        res.json({ success: true, message: 'Reporte enviado correctamente' });
    } catch (e) {
        res.status(500).json({ success: false, message: 'Error al crear reporte' });
    }
});

// POST /api/block
router.post('/block', verifyToken, async (req, res) => {
    const { blockedUserId } = req.body;
    const blockerId = req.user.id; // Asumiendo que el middleware decodifica el ID

    try {
        const { error } = await supabase.from('blocks').insert([{
            blocker_id: blockerId,
            blocked_id: blockedUserId
        }]);

        if (error) {
            if (error.code === '23505') return res.json({ success: true, message: 'Ya estaba bloqueado' });
            throw error;
        }
        res.json({ success: true, message: 'Usuario bloqueado' });
    } catch (e) {
        res.status(500).json({ success: false, message: 'Error al bloquear' });
    }
});

/* =========================================
   🎒 GEAR & PROFILE PRO
   ========================================= */

// PUT /api/profile/pro
router.put('/profile/pro', verifyToken, async (req, res) => {
    const { soundcloud, youtube, website, openToWork } = req.body;

    try {
        const { error } = await supabase
            .from('profiles')
            .update({
                enlace_soundcloud: soundcloud,
                enlace_youtube: youtube,
                enlace_website: website,
                open_to_work: openToWork
            })
            .eq('id', req.user.id);

        if (error) throw error;
        res.json({ success: true, message: 'Perfil actualizado' });
    } catch (e) {
        res.status(500).json({ success: false, message: 'Error al actualizar perfil' });
    }
});

// GET /api/gear/:id_perfil
router.get('/gear/:id_perfil', async (req, res) => {
    try {
        // Nota: Ajustar a 'gear_catalog' + 'perfil_gear' si usas el esquema estricto.
        // Aquí mantengo compatibilidad con el esquema 'gear' simple del script V3.
        const { data, error } = await supabase
            .from('gear')
            .select('*')
            .eq('profile_id', req.params.id_perfil);

        if (error) throw error;
        res.json(data);
    } catch (e) {
        res.status(500).json({ success: false, message: 'Error al obtener gear' });
    }
});

// POST /api/gear
router.post('/gear', verifyToken, async (req, res) => {
    const { nombre, categoria, descripcion } = req.body;

    try {
        const { error } = await supabase
            .from('gear')
            .insert([{
                profile_id: req.user.id,
                nombre,
                categoria,
                descripcion
            }]);

        if (error) throw error;
        res.json({ success: true, message: 'Equipo agregado' });
    } catch (e) {
        res.status(500).json({ success: false, message: 'Error al guardar equipo' });
    }
});


/* =========================================
   🔍 DISCOVERY SYSTEM
   ========================================= */

// GET /api/search
// Buscar usuarios por nombre, instrumento o género
router.get('/search', async (req, res) => {
    const { q, type } = req.query;

    try {
        let query = supabase
            .from('profiles')
            .select('id, nombre_completo, nombre_artistico, avatar_url, nivel_badge, instrumento_principal, ubicacion_base, open_to_work');

        if (q) {
            // Buscamos en nombre, nombre artístico, ubicación o instrumento
            query = query.or(`nombre_artistico.ilike.%${q}%,nombre_completo.ilike.%${q}%,instrumento_principal.ilike.%${q}%`);
        }

        if (type === 'open_to_work') {
            query = query.eq('open_to_work', true);
        }

        const { data, error } = await query.limit(20);

        if (error) throw error;
        res.json(data);
    } catch (e) {
        console.error('Search error:', e);
        res.status(500).json({ success: false, message: 'Error en búsqueda' });
    }
});

module.exports = router;
