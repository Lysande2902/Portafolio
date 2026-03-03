# ============================================================================
# GUÍA DE INTEGRACIÓN BACKEND-BASE DE DATOS
# ============================================================================
# Documentación completa para integrar el backend con la base de datos
# Creado: 22/01/2026
# Versión: 1.0

## 📋 TABLA DE CONTENIDOS
1. [Requisitos Previos](#requisitos-previos)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Configuración Inicial](#configuración-inicial)
4. [Integración con Supabase](#integración-con-supabase)
5. [Ejemplos de Código](#ejemplos-de-código)
6. [Testing](#testing)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

---

## REQUISITOS PREVIOS

### Herramientas Necesarias
- Node.js 16+ 
- PostgreSQL client (psql)
- Git
- npm o yarn
- Postman o Insomnia (para testing de API)

### Cuentas Necesarias
- Supabase (ya creada con DB)
- Mercado Pago (para pagos)
- AWS S3 o similar (para media storage)
- SendGrid (para emails)

### Librerías Principales
```bash
npm install @supabase/supabase-js
npm install express cors dotenv
npm install jsonwebtoken bcrypt
npm install nodemailer sendgrid
npm install aws-sdk
npm install axios mercadopago
npm install pg
npm install joi (validación)
```

---

## ESTRUCTURA DEL PROYECTO

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js
│   │   ├── supabase.js
│   │   ├── auth.js
│   │   ├── storage.js
│   │   └── email.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── profiles.js
│   │   ├── portfolio.js
│   │   ├── ratings.js
│   │   ├── events.js
│   │   ├── payments.js
│   │   ├── messages.js
│   │   ├── notifications.js
│   │   └── admin.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── profileController.js
│   │   ├── portfolioController.js
│   │   ├── ratingController.js
│   │   ├── paymentController.js
│   │   └── [más...]
│   ├── models/
│   │   ├── User.js
│   │   ├── Profile.js
│   │   ├── PortfolioMedia.js
│   │   ├── Rating.js
│   │   ├── Event.js
│   │   └── [más...]
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── errorHandler.js
│   │   ├── validation.js
│   │   ├── logger.js
│   │   └── rateLimit.js
│   ├── utils/
│   │   ├── helpers.js
│   │   ├── validators.js
│   │   ├── formatters.js
│   │   └── constants.js
│   ├── services/
│   │   ├── emailService.js
│   │   ├── storageService.js
│   │   ├── paymentService.js
│   │   └── notificationService.js
│   └── app.js
├── tests/
│   ├── auth.test.js
│   ├── profiles.test.js
│   ├── portfolio.test.js
│   ├── ratings.test.js
│   └── integration.test.js
├── scripts/
│   ├── seed-db.js
│   ├── migrate.js
│   ├── validate-schema.js
│   └── test-api.js
├── .env
├── .env.example
├── .gitignore
├── package.json
└── server.js
```

---

## CONFIGURACIÓN INICIAL

### 1. Clonar Repositorio y Dependencias
```bash
git clone <repo-url>
cd backend
npm install
```

### 2. Configurar Variables de Entorno
```bash
cp .env.example .env
# Editar .env con tus credenciales
```

### 3. Verificar Conexión a Supabase
```bash
node scripts/validate-schema.js
```

### 4. Crear Tablas (si no existen)
```bash
psql -h <SUPABASE_HOST> -U <USER> -d <DB> -f SCRIPT_BASE_DATOS_COMPLETO.sql
```

---

## INTEGRACIÓN CON SUPABASE

### Crear Cliente de Supabase
```javascript
// src/config/supabase.js
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

module.exports = { supabase, supabaseAdmin };
```

### Modelo de Usuario
```javascript
// src/models/User.js
const { supabaseAdmin } = require('../config/supabase');

class User {
  static async findById(id) {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  }

  static async findByEmail(email) {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('email', email)
      .single();
    
    if (error) throw error;
    return data;
  }

  static async create(userData) {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .insert([userData])
      .select();
    
    if (error) throw error;
    return data[0];
  }

  static async update(id, updates) {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .update(updates)
      .eq('id', id)
      .select();
    
    if (error) throw error;
    return data[0];
  }

  static async delete(id) {
    const { error } = await supabaseAdmin
      .from('profiles')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
    return true;
  }
}

module.exports = User;
```

### Autenticación
```javascript
// src/middleware/auth.js
const jwt = require('jsonwebtoken');
const { supabaseAdmin } = require('../config/supabase');

const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'Token requerido' });
    }

    // Verificar con Supabase
    const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
    
    if (error || !user) {
      return res.status(401).json({ error: 'Token inválido' });
    }

    req.user = user;
    req.userId = user.id;
    next();
  } catch (error) {
    res.status(500).json({ error: 'Error en autenticación' });
  }
};

module.exports = { authMiddleware };
```

### Controlador de Perfiles
```javascript
// src/controllers/profileController.js
const User = require('../models/User');

exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { nombre_artistico, bio, ubicacion, pais } = req.body;
    
    const updated = await User.update(req.userId, {
      nombre_artistico,
      bio,
      ubicacion,
      pais,
      updated_at: new Date()
    });
    
    res.json(updated);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.searchProfiles = async (req, res) => {
  try {
    const { q, ubicacion, genero, instrumento, page = 1, limit = 20 } = req.query;
    
    let query = supabaseAdmin
      .from('profiles')
      .select('*');
    
    if (q) {
      query = query.ilike('nombre_artistico', `%${q}%`);
    }
    if (ubicacion) {
      query = query.eq('ubicacion', ubicacion);
    }
    
    const from = (page - 1) * limit;
    const to = from + limit - 1;
    
    const { data, count } = await query.range(from, to);
    
    res.json({
      total: count,
      page,
      limit,
      data
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

---

## EJEMPLOS DE CÓDIGO

### Registrar Usuario
```javascript
// Endpoint POST /auth/register
const register = async (req, res) => {
  try {
    const { email, password, nombre_artistico, pais } = req.body;

    // Crear usuario en auth.users
    const { data: { user }, error: authError } = await supabaseAdmin.auth.admin
      .createUser({
        email,
        password,
        email_confirm: true
      });

    if (authError) throw authError;

    // Crear perfil en profiles table
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .insert([{
        id: user.id,
        email,
        nombre_artistico,
        pais,
        created_at: new Date()
      }])
      .select();

    res.status(201).json({ user: profile[0] });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};
```

### Subir Media al Portafolio
```javascript
// Endpoint POST /portfolio/media
const uploadMedia = async (req, res) => {
  try {
    const { titulo, descripcion, tipo, visibilidad } = req.body;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ error: 'Archivo requerido' });
    }

    // Subir archivo a Storage
    const fileName = `${req.userId}/${Date.now()}_${file.originalname}`;
    const { data, error: uploadError } = await supabaseAdmin.storage
      .from('portfolio-media')
      .upload(fileName, file.buffer, {
        contentType: file.mimetype
      });

    if (uploadError) throw uploadError;

    // Crear registro en portfolio_media
    const { data: media } = await supabaseAdmin
      .from('portfolio_media')
      .insert([{
        profile_id: req.userId,
        tipo,
        titulo,
        descripcion,
        url_recurso: data.path,
        visibilidad: visibilidad || 'publico',
        created_at: new Date()
      }])
      .select();

    res.status(201).json(media[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

### Crear Calificación
```javascript
// Endpoint POST /calificaciones
const createRating = async (req, res) => {
  try {
    const { para_usuario_id, estrellas, comentario, tipo_interaccion } = req.body;

    if (estrellas < 1 || estrellas > 5) {
      return res.status(400).json({ error: 'Estrellas debe estar entre 1 y 5' });
    }

    const { data: rating } = await supabaseAdmin
      .from('calificaciones')
      .insert([{
        de_usuario_id: req.userId,
        para_usuario_id,
        estrellas,
        comentario,
        tipo_interaccion,
        created_at: new Date()
      }])
      .select();

    // El trigger se encargará de actualizar el rating_promedio en profiles
    res.status(201).json(rating[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

### Procesar Pago TOP
```javascript
// Endpoint POST /ranking/upgrade
const upgradeToTop = async (req, res) => {
  try {
    const { nivel, duracion_dias, metodo_pago } = req.body;
    
    // Calcular monto
    const montos = {
      'pro': 9.99,
      'top1': 29.99,
      'legend': 99.99
    };
    
    const monto = montos[nivel];

    if (!monto) {
      return res.status(400).json({ error: 'Nivel inválido' });
    }

    if (metodo_pago === 'mercadopago') {
      // Crear preferencia en Mercado Pago
      const preference = {
        items: [{
          title: `JAMConnect ${nivel.toUpperCase()}`,
          quantity: 1,
          unit_price: monto
        }],
        back_urls: {
          success: process.env.PAYMENT_SUCCESS_URL,
          failure: process.env.PAYMENT_CANCEL_URL
        },
        external_reference: `user_${req.userId}_${nivel}`
      };

      const response = await mercadoPagoClient.preferences.create(preference);

      // Guardar intención de pago
      const { data: pago } = await supabaseAdmin
        .from('pagos_ranking')
        .insert([{
          profile_id: req.userId,
          nivel,
          monto,
          duracion_dias,
          metodo_pago,
          transaccion_id: response.id,
          estado: 'pendiente',
          created_at: new Date()
        }])
        .select();

      res.json({
        id: pago[0].id,
        url_pago: response.init_point
      });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

---

## TESTING

### Test de Conexión a Base de Datos
```javascript
// scripts/test-connection.js
const { supabaseAdmin } = require('../src/config/supabase');

async function testConnection() {
  try {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .select('COUNT(*)')
      .limit(1);

    if (error) throw error;

    console.log('✅ Conexión a base de datos exitosa');
    console.log('Tabla profiles accesible');
  } catch (error) {
    console.error('❌ Error de conexión:', error.message);
    process.exit(1);
  }
}

testConnection();
```

### Test de API con Postman
```
# Registrar
POST http://localhost:3001/api/v1/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Test@1234",
  "nombre_artistico": "Test Artist",
  "pais": "Argentina"
}

# Respuesta esperada: 201
{
  "user": { ... },
  "token": "eyJhbGc..."
}
```

### Test Automatizado
```javascript
// tests/integration.test.js
const request = require('supertest');
const app = require('../src/app');

describe('API Integration', () => {
  let token;
  let userId;

  test('Register user', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({
        email: 'test@test.com',
        password: 'Test@1234',
        nombre_artistico: 'Test Artist'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.token).toBeDefined();
    token = res.body.token;
    userId = res.body.user.id;
  });

  test('Get profile', async () => {
    const res = await request(app)
      .get('/api/v1/profiles/me')
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(userId);
  });

  test('Update profile', async () => {
    const res = await request(app)
      .put('/api/v1/profiles/me')
      .set('Authorization', `Bearer ${token}`)
      .send({
        bio: 'Musician from Argentina',
        ubicacion: 'Buenos Aires'
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.bio).toBe('Musician from Argentina');
  });
});
```

---

## DEPLOYMENT

### Opción 1: Heroku
```bash
# 1. Instalar Heroku CLI
npm install -g heroku

# 2. Login
heroku login

# 3. Crear app
heroku create jamconnect-api

# 4. Configurar variables de entorno
heroku config:set NODE_ENV=production
heroku config:set NEXT_PUBLIC_SUPABASE_URL=...
heroku config:set SUPABASE_SERVICE_ROLE_KEY=...

# 5. Deploy
git push heroku main
```

### Opción 2: Docker
```dockerfile
# Dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3001

CMD ["node", "server.js"]
```

```bash
# Build
docker build -t jamconnect-api .

# Run
docker run -p 3001:3001 \
  -e NEXT_PUBLIC_SUPABASE_URL=... \
  -e SUPABASE_SERVICE_ROLE_KEY=... \
  jamconnect-api
```

### Opción 3: AWS EC2
```bash
# 1. SSH a instancia
ssh -i key.pem ec2-user@instance-ip

# 2. Instalar Node
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
sudo yum install -y nodejs

# 3. Clonar repo y instalar deps
git clone <repo>
cd backend
npm install

# 4. Configurar PM2 para ejecución continua
npm install -g pm2
pm2 start server.js --name "jamconnect-api"
pm2 startup
pm2 save

# 5. Configurar nginx como reverse proxy
sudo yum install nginx
# Editar /etc/nginx/nginx.conf...
sudo systemctl start nginx
```

---

## TROUBLESHOOTING

### Error: "Table does not exist"
**Solución:**
```bash
# Verificar que el script SQL se ejecutó correctamente
psql -h <host> -U <user> -d <db> -c "SELECT * FROM profiles LIMIT 1;"

# Si no existe, ejecutar el script
psql -h <host> -U <user> -d <db> -f SCRIPT_BASE_DATOS_COMPLETO.sql
```

### Error: "Column 'X' does not exist"
**Solución:**
```bash
# Verificar estructura de tabla
\d profiles

# Asegurar que la migración se completó
npm run migrate
```

### Error: "Unauthorized: invalid API key"
**Solución:**
- Verificar NEXT_PUBLIC_SUPABASE_URL en .env
- Verificar SUPABASE_SERVICE_ROLE_KEY es correcto
- No confundir ANON_KEY con SERVICE_ROLE_KEY

### Error: "Connection timeout"
**Solución:**
```bash
# Aumentar timeout en .env
DATABASE_CONNECTION_TIMEOUT=30000

# Verificar firewall permite puerto 5432
telnet <host> 5432
```

### Error: "Rate limit exceeded"
**Solución:**
- Aumentar RATE_LIMIT_MAX_REQUESTS en .env
- Implementar caché en Redis
- Agregar backoff exponencial en cliente

---

## VALIDACIÓN FINAL

Checklist antes de ir a producción:

- [ ] Base de datos conectada y verificada
- [ ] Variables de entorno correctas
- [ ] JWT tokens funcionando
- [ ] Autenticación con Supabase funcional
- [ ] Endpoints principales probados
- [ ] Media upload funcionando
- [ ] Pagos integrando correctamente
- [ ] Notificaciones enviándose
- [ ] CORS configurado correctamente
- [ ] Rate limiting activo
- [ ] Logs configurados
- [ ] Error handling implementado
- [ ] Tests pasando 100%
- [ ] Documentación actualizada
- [ ] SSL/HTTPS habilitado
- [ ] Backups configurados

---

## RECURSOS ÚTILES

- Documentación Supabase: https://supabase.com/docs
- API REST Documentation: Consultar ENDPOINTS_API_COMPLETOS.md
- Ejemplos de código: /examples directory
- FAQ: https://supabase.com/docs/faq

---

**Última actualización:** 22/01/2026  
**Versión:** 1.0
