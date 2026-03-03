# 📊 TABLAS RÁPIDAS DE REFERENCIA

**Fecha:** 22 de Enero 2026  
**Uso:** Consulta rápida durante desarrollo

---

## TABLA 1: TODAS LAS FUNCIONALIDADES (54 Total)

```
# MÓDULO: AUTENTICACIÓN (5 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Login Email/Pass               │ ✅  │ ✅   │ OK     │
│ Registro                       │ ❌  │ ✅   │ OK     │
│ Cambiar Contraseña             │ ✅  │ ❌   │ FALTA  │
│ Recuperar Contraseña           │ ❌  │ ❌   │ FALTA  │
│ 2FA/Autenticación Multifactor  │ ❌  │ ❌   │ FALTA  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 40% implementado

# MÓDULO: GESTIÓN DE PERFIL (4 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Ver Perfil Propio              │ ✅  │ ✅   │ OK     │
│ Editar Perfil Propio           │ ✅  │ ✅   │ OK     │
│ Ver Perfil de Otros            │ ❌  │ ✅   │ OK     │
│ Gestionar Perfiles (Admin)     │ ✅  │ ❌   │ ADMIN  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 50% implementado

# MÓDULO: BÚSQUEDA Y DESCUBRIMIENTO (4 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Búsqueda de Usuarios           │ ❌  │ ✅   │ MÓVIL  │
│ Filtrar por Instrumento        │ ❌  │ ✅   │ MÓVIL  │
│ Filtrar por Ubicación          │ ❌  │ ✅   │ MÓVIL  │
│ Conectar con Artistas          │ ❌  │ ✅   │ MÓVIL  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 0% web, 100% móvil

# MÓDULO: NETWORKING (4 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Ver Conexiones                 │ ❌  │ ✅   │ MÓVIL  │
│ Gestionar Solicitudes          │ ❌  │ ✅   │ MÓVIL  │
│ Aceptar/Rechazar Solicitud     │ ❌  │ ✅   │ MÓVIL  │
│ Eliminar Conexión              │ ❌  │ ✅   │ MÓVIL  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 0% web, 100% móvil

# MÓDULO: EVENTOS (4 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Crear Evento                   │ ❌  │ ✅   │ MÓVIL  │
│ Listar Eventos                 │ ❌  │ ✅   │ MÓVIL  │
│ Ver Detalle Evento             │ ❌  │ ✅   │ MÓVIL  │
│ Postularse al Lineup           │ ❌  │ ✅   │ MÓVIL  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 0% web, 100% móvil

# MÓDULO: MENSAJERÍA (3 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Chat en Tiempo Real            │ ❌  │ ✅   │ MÓVIL  │
│ Listado de Conversaciones      │ ❌  │ ✅   │ MÓVIL  │
│ Notificación de Mensajes       │ ❌  │ ✅   │ MÓVIL  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 0% web, 100% móvil

# MÓDULO: NOTIFICACIONES (1 feature)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Centro de Notificaciones       │ ❌  │ ✅   │ MÓVIL  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 0% web, 100% móvil

# MÓDULO: CATÁLOGOS (6 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Ver Géneros                    │ ✅  │ ✅   │ OK     │
│ Ver Instrumentos               │ ✅  │ ✅   │ OK     │
│ Ver Servicios                  │ ✅  │ ✅   │ OK     │
│ CRUD Géneros                   │ ✅  │ ❌   │ ADMIN  │
│ CRUD Instrumentos              │ ✅  │ ❌   │ ADMIN  │
│ CRUD Servicios                 │ ✅  │ ❌   │ ADMIN  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: Web 100%, Mobile 50%

# MÓDULO: SEGURIDAD (6 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Crear Reportes                 │ ❌  │ ✅   │ MÓVIL  │
│ Gestionar Reportes             │ ✅  │ ❌   │ ADMIN  │
│ Ver Estado de Reporte          │ ❌  │ ❌   │ FALTA  │
│ Bloquear Usuarios              │ ❌  │ ❌   │ FALTA  │
│ Ver Bloqueados                 │ ❌  │ ❌   │ FALTA  │
│ Rate Limiting                  │ ✅  │ ❌   │ FALTA  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: Web 33%, Mobile 17%

# MÓDULO: PAGOS (4 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Agregar Fondos                 │ ❌  │ ⚠️   │ UI     │
│ Retirar Fondos                 │ ❌  │ ⚠️   │ UI     │
│ Ver Saldo                      │ ❌  │ ⚠️   │ UI     │
│ Historial Transacciones        │ ❌  │ ⚠️   │ UI     │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 0% integración real

# MÓDULO: PREMIUM (4 features)
┌────────────────────────────────┬─────┬──────┬────────┐
│ Feature                        │ WEB │ MOB  │ Status │
├────────────────────────────────┼─────┼──────┼────────┤
│ Ver Planes                     │ ❌  │ ⚠️   │ UI     │
│ Comprar Suscripción            │ ❌  │ ⚠️   │ UI     │
│ Ver Beneficios                 │ ❌  │ ⚠️   │ UI     │
│ Gestionar Suscripción          │ ❌  │ ❌   │ FALTA  │
└────────────────────────────────┴─────┴──────┴────────┘
Status: 0% integración real

TOTALES
┌─────────────────┬──────┬────────┬──────────┐
│ Categoría       │ WEB  │ MOBILE │ Promedio │
├─────────────────┼──────┼────────┼──────────┤
│ Implementado    │ 19   │ 22     │ 41%      │
│ UI sin código   │ 0    │ 4      │ 7%       │
│ Falta           │ 35   │ 28     │ 52%      │
│ TOTAL           │ 54   │ 54     │ 100%     │
└─────────────────┴──────┴────────┴──────────┘
```

---

## TABLA 2: DEPENDENCIAS ENTRE FEATURES

```
┌─────────────────────────────────────────────────────┐
│ CADENA DE DEPENDENCIAS (HACER EN ESTE ORDEN)        │
└─────────────────────────────────────────────────────┘

NIVEL 0 (Sin dependencias)
  1. Change Password ──────────────────────┐
  2. Forgot Password ──────────────────────┤
  3. Block Users ───────────────────────────┤
  4. Report Status Tracking ────────────────┤ 40 horas
  5. Setup Mercado Pago ────────────────────┘

NIVEL 1 (Necesitan Nivel 0)
  6. Add Funds ─────────────────────────────┐
  7. Withdraw Funds ────────────────────────┤ 50 horas
  8. Transaction History ───────────────────┘

NIVEL 2 (Necesitan Nivel 0-1)
  9. Planes Premium ────────────────────────┐
  10. Buy Subscription ──────────────────────┤ 38 horas
  11. Manage Subscription ──────────────────┘

NIVEL 3 (Necesitan todos)
  12. QA & Testing ─────────────────────────┐
  13. Deploy to Production ──────────────────┘ 20 horas
```

---

## TABLA 3: TABLA DE BASE DE DATOS

```
┌─────────────────────────────────────────────────────────────────┐
│ TABLAS SUPABASE - ESTADO ACTUAL                                 │
└─────────────────────────────────────────────────────────────────┘

TABLA             │ WEB CRUD│ MOB CRUD│ ESTADO   │ ACCIÓN
─────────────────┼─────────┼─────────┼──────────┼──────────────────
profiles          │ CRUD    │ R/W     │ ✅ OK   │ Nada
crews             │ -       │ CRUD    │ ✅ OK   │ Nada
gigs              │ -       │ CRUD    │ ✅ OK   │ Nada
gig_lineup        │ -       │ CRUD    │ ✅ OK   │ Nada
intercom          │ -       │ CRUD+RT │ ✅ OK   │ Nada
reports           │ R/Upd   │ Insert  │ ⚠️  OK  │ Nada (falta vista estado)
notifications     │ -       │ R/Upd   │ ✅ OK   │ Nada
hirings           │ -       │ CRUD    │ ✅ OK   │ Nada
tickets_pagos     │ -       │ R       │ ⚠️  OK  │ Nada (falta integración)
────────────────────────────────────────────────────────────────
generos           │ CRUD    │ R       │ ✅ OK   │ Nada
instrumentos      │ CRUD    │ R       │ ✅ OK   │ Nada
servicios         │ CRUD    │ R       │ ✅ OK   │ Nada
────────────────────────────────────────────────────────────────
audit_log         │ Insert  │ -       │ ✅ OK   │ Nada
admin_notes       │ CRUD    │ -       │ ✅ OK   │ Nada
────────────────────────────────────────────────────────────────

NUEVAS TABLAS A CREAR (CRÍTICO)
────────────────────────────────────────────────────────────────
bloqueados        │ -       │ CRUD    │ ❌ CREAR│ Semana 1
reporte_estados   │ -       │ R       │ ❌ CREAR│ Semana 1
suscripciones     │ -       │ CRUD    │ ❌ CREAR│ Semana 3
beneficios_prem   │ -       │ CRUD    │ ❌ CREAR│ Semana 3
retiradas         │ -       │ CRUD    │ ❌ CREAR│ Semana 2
```

---

## TABLA 4: ENDPOINTS API NECESARIOS

```
┌────────────────────────────────────────────────────────────────┐
│ APIs FALTANTES EN WEB (Para que móvil funcione)                │
└────────────────────────────────────────────────────────────────┘

AUTENTICACIÓN
  POST /api/auth/change-password ................. [6h] Semana 1
  POST /api/auth/forgot-password ................. [8h] Semana 1
  POST /api/auth/reset-password .................. [4h] Semana 1

SEGURIDAD
  POST /api/block ................................ [3h] Semana 1
  GET /api/blocked ................................ [2h] Semana 1
  DELETE /api/block/:userId ....................... [2h] Semana 1
  GET /api/reports/:id/status ..................... [2h] Semana 1

PAGOS
  POST /api/payment .............................. [8h] Semana 2
  GET /api/wallet/balance ......................... [2h] Semana 2
  GET /api/wallet/history ......................... [3h] Semana 2
  POST /api/withdraw .............................. [6h] Semana 2

PREMIUM
  POST /api/subscribe ............................. [4h] Semana 3
  GET /api/subscription ........................... [2h] Semana 3
  PUT /api/subscription ........................... [3h] Semana 3
  DELETE /api/subscribe ........................... [2h] Semana 3

WEBHOOKS (Mercado Pago)
  POST /webhook/payment-success ................... [4h] Semana 2
  POST /webhook/subscription-renewal ............. [4h] Semana 3
  POST /webhook/subscription-cancelled ........... [3h] Semana 3

────────────────────────────────────────────────────────────────
TOTAL BACKEND: ~58 horas
```

---

## TABLA 5: ASIGNACIÓN DE TAREAS POR SEMANA

```
┌────────────────────────────────────────────────────────────────┐
│ MATRIZ DE ASIGNACIÓN RECOMENDADA (3 Devs)                      │
└────────────────────────────────────────────────────────────────┘

SEMANA 1: SEGURIDAD
┌─────────────────────┬──────────┬─────────┬─────────┬──────────┐
│ Tarea               │ Horas    │ Dev 1   │ Dev 2   │ Dev 3    │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ Change Password     │ 8h       │ ✅ 8h   │         │          │
│ Forgot Password     │ 12h      │         │ ✅ 12h  │          │
│ Block Users         │ 12h      │         │         │ ✅ 12h   │
│ Report Status       │ 8h       │ ✅ 8h   │         │          │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ TOTAL SEMANA 1      │ 40h      │ 16h     │ 12h     │ 12h      │
└─────────────────────┴──────────┴─────────┴─────────┴──────────┘

SEMANA 2: PAGOS
┌─────────────────────┬──────────┬─────────┬─────────┬──────────┐
│ Tarea               │ Horas    │ Dev 1   │ Dev 2   │ Dev 3    │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ Setup Mercado Pago  │ 4h       │ ✅ 4h   │         │          │
│ Add Funds           │ 14h      │         │ ✅ 14h  │          │
│ Withdraw            │ 14h      │         │         │ ✅ 14h   │
│ Transaction History │ 7h       │ ✅ 7h   │         │          │
│ Webhooks & Testing  │ 11h      │ ✅ 11h  │         │          │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ TOTAL SEMANA 2      │ 50h      │ 22h     │ 14h     │ 14h      │
└─────────────────────┴──────────┴─────────┴─────────┴──────────┘

SEMANA 3: PREMIUM
┌─────────────────────┬──────────┬─────────┬─────────┬──────────┐
│ Tarea               │ Horas    │ Dev 1   │ Dev 2   │ Dev 3    │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ Setup Subscriptions │ 3h       │ ✅ 3h   │         │          │
│ Planes Screen       │ 8h       │         │ ✅ 8h   │          │
│ Buy Subscription    │ 8h       │         │ ✅ 8h   │          │
│ Manage Subscription │ 8h       │         │         │ ✅ 8h    │
│ Activate Benefits   │ 8h       │ ✅ 8h   │         │          │
│ Webhooks & Testing  │ 7h       │ ✅ 7h   │         │          │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ TOTAL SEMANA 3      │ 42h      │ 18h     │ 16h     │ 8h       │
└─────────────────────┴──────────┴─────────┴─────────┴──────────┘

SEMANA 4: QA & DEPLOY
┌─────────────────────┬──────────┬─────────┬─────────┬──────────┐
│ Tarea               │ Horas    │ Dev 1   │ Dev 2   │ Dev 3    │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ Testing completo    │ 12h      │ 4h      │ 4h      │ 4h       │
│ Bug fixes           │ 6h       │ 2h      │ 2h      │ 2h       │
│ Deploy              │ 4h       │ ✅ 4h   │         │          │
├─────────────────────┼──────────┼─────────┼─────────┼──────────┤
│ TOTAL SEMANA 4      │ 22h      │ 10h     │ 6h      │ 6h       │
└─────────────────────┴──────────┴─────────┴─────────┴──────────┘

TOTALES GENERALES
┌────────────────────────────────────────────────────────────────┐
│ Dev 1:  66 horas  (Lider + Críticos)                          │
│ Dev 2:  48 horas  (Pagos + UX)                                │
│ Dev 3:  40 horas  (Seguridad + Premium)                       │
│ TOTAL: 154 horas ~ 4 semanas a ritmo normal                    │
└────────────────────────────────────────────────────────────────┘
```

---

## TABLA 6: CHECKLIST DE DEPLOYMENT

```
ANTES DE SUBIR A PRODUCCIÓN
┌──────────────────────────────────────────────────────┐
│ ✅ = Hecho | ❌ = Pendiente | ⚠️  = Revisar          │
└──────────────────────────────────────────────────────┘

TESTING
  ❌ Unit tests: 100% green
  ❌ Widget tests: Todas las pantallas
  ❌ Integration tests: Flujos críticos
  ❌ Testing manual Android: OK
  ❌ Testing manual iOS: OK
  ❌ Offline mode: Funciona
  ❌ Slow network: Funciona

CÓDIGO
  ❌ No warnings en consola
  ❌ Código formateado
  ❌ Comentarios actualizados
  ❌ Variables .env configuradas
  ❌ No credentials en código

BASES DE DATOS
  ❌ Migrations ejecutadas
  ❌ Índices creados
  ❌ Triggers SQL instalados
  ❌ Respaldos creados

SERVICIOS EXTERNOS
  ❌ Mercado Pago en producción
  ❌ Webhooks configurados
  ❌ Supabase en producción
  ❌ URLs correctas

VERSIONING
  ❌ Version app incrementada (1.0.1)
  ❌ CHANGELOG actualizado
  ❌ Build APK/IPA testeado

DOCUMENTACIÓN
  ❌ README actualizado
  ❌ API docs actualizados
  ❌ Guía de deploy escrita
  ❌ Runbook de emergencia

MONITOREO
  ❌ Logs configurados
  ❌ Alertas configuradas
  ❌ Dashboard de métricas
  ❌ Plan de rollback

EQUIPO
  ❌ Team briefing completado
  ❌ On-call definido
  ❌ Comunicación con usuarios
  ❌ Escalation procedures
```

---

**Generado:** 22 de Enero 2026  
**Uso:** Referencia rápida durante desarrollo  
**Mantener actualizado:** ✅ Importante

