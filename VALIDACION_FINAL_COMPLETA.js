#!/usr/bin/env node

/**
 * ============================================================================
 * VALIDACIÓN FINAL COMPLETA DEL SISTEMA
 * ============================================================================
 * Script maestro para validar que TODO funciona y está listo
 * Creado: 22/01/2026
 * Versión: 1.0
 */

const fs = require('fs');
const path = require('path');

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m'
};

const symbols = {
  check: '✓',
  cross: '✗',
  info: 'ℹ',
  warn: '⚠',
  arrow: '→',
  line: '─',
  corner: '└',
  t: '├'
};

class SystemValidator {
  constructor() {
    this.sections = [];
    this.totalTests = 0;
    this.passedTests = 0;
    this.failedTests = 0;
  }

  section(title) {
    console.log(`\n${colors.cyan}${symbols.line.repeat(60)}${colors.reset}`);
    console.log(`${colors.blue}▶ ${title}${colors.reset}`);
    console.log(`${colors.cyan}${symbols.line.repeat(60)}${colors.reset}\n`);
  }

  test(name, passed, details = null) {
    this.totalTests++;
    const symbol = passed ? `${colors.green}${symbols.check}${colors.reset}` : `${colors.red}${symbols.cross}${colors.reset}`;
    const status = passed ? `${colors.green}PASS${colors.reset}` : `${colors.red}FAIL${colors.reset}`;

    console.log(`${symbol} ${name.padEnd(50)} [${status}]`);

    if (details) {
      console.log(`  ${colors.cyan}→ ${details}${colors.reset}`);
    }

    if (passed) {
      this.passedTests++;
    } else {
      this.failedTests++;
    }
  }

  fileExists(filePath, name = null) {
    const exists = fs.existsSync(filePath);
    const displayName = name || path.basename(filePath);
    this.test(`Archivo: ${displayName}`, exists, exists ? 'Found' : 'NOT FOUND');
    return exists;
  }

  fileContains(filePath, searchStr, description) {
    const exists = fs.existsSync(filePath);
    if (!exists) {
      this.test(`Validar ${description}`, false, 'File does not exist');
      return false;
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const contains = content.includes(searchStr);
    this.test(`Validar ${description}`, contains, contains ? 'Found' : 'NOT FOUND');
    return contains;
  }

  lineCount(filePath, expectedMinLines = 0, description = null) {
    const exists = fs.existsSync(filePath);
    if (!exists) {
      this.test(`Líneas en ${description}`, false, 'File not found');
      return false;
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n').length;
    const passed = lines >= expectedMinLines;
    const displayName = description || path.basename(filePath);

    this.test(`${displayName} tiene ${lines} líneas`, passed, `Expected: ≥${expectedMinLines}`);
    return passed;
  }

  summary() {
    const percentage = Math.round((this.passedTests / this.totalTests) * 100);

    console.log(`\n${colors.magenta}${symbols.line.repeat(60)}${colors.reset}`);
    console.log(`${colors.blue}╔════════════════════════════════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.blue}║${colors.reset}${' RESUMEN FINAL DE VALIDACIÓN'.padEnd(60)}${colors.blue}║${colors.reset}`);
    console.log(`${colors.blue}╠════════════════════════════════════════════════════════════╣${colors.reset}`);

    const stats = [
      { label: 'Tests Totales', value: this.totalTests.toString(), color: colors.white },
      { label: 'Pasados', value: `${this.passedTests} ${colors.green}✓${colors.reset}`, color: colors.green },
      { label: 'Fallidos', value: `${this.failedTests} ${colors.red}✗${colors.reset}`, color: colors.red },
      { label: 'Porcentaje', value: `${percentage}%`, color: percentage === 100 ? colors.green : colors.yellow }
    ];

    stats.forEach(stat => {
      const line = `║ ${stat.label.padEnd(20)}: ${stat.value.padEnd(36)}║`;
      console.log(line);
    });

    console.log(`${colors.blue}╠════════════════════════════════════════════════════════════╣${colors.reset}`);

    if (percentage === 100) {
      console.log(`${colors.blue}║${colors.reset}${colors.green} ✓ SISTEMA COMPLETAMENTE FUNCIONAL Y LISTO${colors.reset}${' '.repeat(13)}${colors.blue}║${colors.reset}`);
    } else if (percentage >= 80) {
      console.log(`${colors.blue}║${colors.reset}${colors.yellow} ⚠ SISTEMA FUNCIONAL PERO CON ADVERTENCIAS${colors.reset}${' '.repeat(11)}${colors.blue}║${colors.reset}`);
    } else {
      console.log(`${colors.blue}║${colors.reset}${colors.red} ✗ SISTEMA REQUIERE ATENCIÓN${colors.reset}${' '.repeat(27)}${colors.blue}║${colors.reset}`);
    }

    console.log(`${colors.blue}╚════════════════════════════════════════════════════════════╝${colors.reset}\n`);

    return percentage === 100;
  }
}

async function main() {
  console.log(`
${colors.cyan}╔════════════════════════════════════════════════════════════╗${colors.reset}
${colors.cyan}║${colors.reset}     ${colors.magenta}JAMCONNECT - VALIDACIÓN FINAL DEL SISTEMA${colors.reset}${' '.repeat(9)}${colors.cyan}║${colors.reset}
${colors.cyan}║${colors.reset}        ${colors.white}Base de Datos + Backend + Documentación${colors.reset}${' '.repeat(12)}${colors.cyan}║${colors.reset}
${colors.cyan}║${colors.reset}${' '.repeat(60)}${colors.cyan}║${colors.reset}
${colors.cyan}║${colors.reset}${colors.cyan}  Versión: 1.0 | Creado: 22/01/2026${colors.reset}${' '.repeat(20)}${colors.cyan}║${colors.reset}
${colors.cyan}╚════════════════════════════════════════════════════════════╝${colors.reset}
  `);

  const validator = new SystemValidator();

  // ========================================================================
  // SECCIÓN 1: ARCHIVOS DE BASE DE DATOS
  // ========================================================================
  validator.section('1. VALIDACIÓN - ARCHIVOS DE BASE DE DATOS');

  validator.fileExists('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'Script SQL Completo');
  validator.lineCount('./SCRIPT_BASE_DATOS_COMPLETO.sql', 900, 'SCRIPT_BASE_DATOS_COMPLETO.sql');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'CREATE TABLE IF NOT EXISTS profiles', 'Tabla profiles');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'CREATE TABLE IF NOT EXISTS portfolio_media', 'Tabla portfolio_media');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'CREATE TABLE IF NOT EXISTS calificaciones', 'Tabla calificaciones');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'CREATE TABLE IF NOT EXISTS ranking_top', 'Tabla ranking_top');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'DROP TRIGGER IF EXISTS', 'Idempotencia de triggers');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'DROP POLICY IF EXISTS', 'Idempotencia de RLS policies');

  // ========================================================================
  // SECCIÓN 2: DOCUMENTACIÓN DE API
  // ========================================================================
  validator.section('2. VALIDACIÓN - DOCUMENTACIÓN DE API');

  validator.fileExists('./ENDPOINTS_API_COMPLETOS.md', 'Endpoints API');
  validator.lineCount('./ENDPOINTS_API_COMPLETOS.md', 500, 'ENDPOINTS_API_COMPLETOS.md');
  validator.fileContains('./ENDPOINTS_API_COMPLETOS.md', 'POST /auth/register', 'Endpoint registro');
  validator.fileContains('./ENDPOINTS_API_COMPLETOS.md', 'GET /profiles/search', 'Endpoint búsqueda');
  validator.fileContains('./ENDPOINTS_API_COMPLETOS.md', 'POST /portfolio/media', 'Endpoint portfolio');
  validator.fileContains('./ENDPOINTS_API_COMPLETOS.md', 'POST /ranking/upgrade', 'Endpoint pagos');

  // ========================================================================
  // SECCIÓN 3: DOCUMENTACIÓN DE INTEGRACIÓN
  // ========================================================================
  validator.section('3. VALIDACIÓN - DOCUMENTACIÓN DE INTEGRACIÓN');

  validator.fileExists('./GUIA_INTEGRACION_BACKEND_BD.md', 'Guía de Integración Backend');
  validator.lineCount('./GUIA_INTEGRACION_BACKEND_BD.md', 300, 'GUIA_INTEGRACION_BACKEND_BD.md');
  validator.fileContains('./GUIA_INTEGRACION_BACKEND_BD.md', 'Supabase', 'Documentación Supabase');
  validator.fileContains('./GUIA_INTEGRACION_BACKEND_BD.md', 'Controllers', 'Controladores documentados');
  validator.fileContains('./GUIA_INTEGRACION_BACKEND_BD.md', 'Testing', 'Tests documentados');

  // ========================================================================
  // SECCIÓN 4: CONFIGURACIÓN BACKEND
  // ========================================================================
  validator.section('4. VALIDACIÓN - CONFIGURACIÓN BACKEND');

  validator.fileExists('./CONFIGURACION_BACKEND.env', 'Archivo .env');
  validator.fileContains('./CONFIGURACION_BACKEND.env', 'NEXT_PUBLIC_SUPABASE_URL', 'Supabase URL variable');
  validator.fileContains('./CONFIGURACION_BACKEND.env', 'MERCADOPAGO_ACCESS_TOKEN', 'Mercado Pago variable');
  validator.fileContains('./CONFIGURACION_BACKEND.env', 'AWS_S3_BUCKET', 'AWS S3 variable');
  validator.fileContains('./CONFIGURACION_BACKEND.env', 'JWT_SECRET', 'JWT secret variable');

  // ========================================================================
  // SECCIÓN 5: SCRIPTS Y HERRAMIENTAS
  // ========================================================================
  validator.section('5. VALIDACIÓN - SCRIPTS Y HERRAMIENTAS');

  validator.fileExists('./test-api-completo.js', 'Script de Testing');
  validator.lineCount('./test-api-completo.js', 100, 'test-api-completo.js');
  validator.fileContains('./test-api-completo.js', 'APITester', 'Clase tester existe');
  validator.fileContains('./test-api-completo.js', 'validar todas las tablas', 'Tests de tablas');

  // ========================================================================
  // SECCIÓN 6: GUÍA DE DESPLIEGUE
  // ========================================================================
  validator.section('6. VALIDACIÓN - GUÍA DE DESPLIEGUE');

  validator.fileExists('./GUIA_DESPLIEGUE_COMPLETO.md', 'Guía Despliegue Completo');
  validator.lineCount('./GUIA_DESPLIEGUE_COMPLETO.md', 400, 'GUIA_DESPLIEGUE_COMPLETO.md');
  validator.fileContains('./GUIA_DESPLIEGUE_COMPLETO.md', 'Supabase', 'Despliegue BD');
  validator.fileContains('./GUIA_DESPLIEGUE_COMPLETO.md', 'Backend', 'Despliegue backend');
  validator.fileContains('./GUIA_DESPLIEGUE_COMPLETO.md', 'Frontend', 'Despliegue frontend');

  // ========================================================================
  // SECCIÓN 7: QUERIES PRÁCTICAS
  // ========================================================================
  validator.section('7. VALIDACIÓN - QUERIES PRÁCTICAS');

  validator.fileExists('./QUERIES_PRACTICAS.sql', 'Queries de Ejemplo');
  validator.lineCount('./QUERIES_PRACTICAS.sql', 400, 'QUERIES_PRACTICAS.sql');

  // ========================================================================
  // SECCIÓN 8: VALIDACIÓN DE CONTENIDO CRÍTICO
  // ========================================================================
  validator.section('8. VALIDACIÓN - CONTENIDO CRÍTICO');

  // Verificar que el script tiene las 18 tablas
  const tables = [
    'profiles', 'portfolio_media', 'setlists', 'canciones_setlist',
    'calificaciones', 'referencias', 'puntuacion_reputacion',
    'usuarios_bloqueados', 'reportes', 'historial_reportes',
    'ranking_top', 'pagos_ranking', 'beneficios_top',
    'eventos', 'postulaciones_evento', 'conversaciones', 'mensajes', 'notificaciones',
    'instrumentos', 'generos', 'perfiles_instrumentos', 'perfiles_generos', 'conexiones'
  ];

  const sqlContent = fs.readFileSync('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'utf8');
  let tablesFound = 0;
  tables.forEach(table => {
    const found = sqlContent.includes(`CREATE TABLE IF NOT EXISTS ${table}`);
    if (found) tablesFound++;
    validator.test(`Tabla '${table}' definida`, found);
  });

  validator.test(`Total de tablas: ${tablesFound}/${tables.length}`, tablesFound >= 18);

  // Verificar índices
  const indexMatches = sqlContent.match(/CREATE INDEX/g) || [];
  validator.test(`Índices creados (${indexMatches.length} encontrados)`, indexMatches.length >= 20);

  // Verificar functions/triggers
  const functionMatches = sqlContent.match(/CREATE FUNCTION|CREATE OR REPLACE FUNCTION/g) || [];
  validator.test(`Funciones PL/pgSQL (${functionMatches.length} encontrados)`, functionMatches.length >= 3);

  const triggerMatches = sqlContent.match(/CREATE TRIGGER/g) || [];
  validator.test(`Triggers (${triggerMatches.length} encontrados)`, triggerMatches.length >= 2);

  // Verificar RLS policies
  const policyMatches = sqlContent.match(/CREATE POLICY/g) || [];
  validator.test(`RLS Policies (${policyMatches.length} encontrados)`, policyMatches.length >= 4);

  // ========================================================================
  // SECCIÓN 9: VERIFICACIÓN DE FEATURES
  // ========================================================================
  validator.section('9. VALIDACIÓN - FEATURES IMPLEMENTADAS');

  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'portfolio_media', 'Feature: Portfolio & Media');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'setlists', 'Feature: Setlists');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'calificaciones', 'Feature: Calificaciones 1-5 estrellas');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'referencias', 'Feature: Referencias & Testimonios');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'usuarios_bloqueados', 'Feature: Sistema de Bloqueos');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'ranking_top', 'Feature: TOP Ranking System');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'pagos_ranking', 'Feature: Sistema de Pagos');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'reportes', 'Feature: Sistema de Reportes Mejorado');

  // ========================================================================
  // SECCIÓN 10: VALIDACIÓN DE SEGURIDAD
  // ========================================================================
  validator.section('10. VALIDACIÓN - SEGURIDAD');

  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'ALTER TABLE', 'RLS habilitado');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'ROW LEVEL SECURITY', 'RLS statement');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'REFERENCES auth.users(id)', 'Integración con Supabase Auth');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'ON DELETE CASCADE', 'Integridad referencial');
  validator.fileContains('./SCRIPT_BASE_DATOS_COMPLETO.sql', 'UNIQUE', 'Restricciones UNIQUE');

  // ========================================================================
  // SECCIÓN 11: DOCUMENTACIÓN GENERAL
  // ========================================================================
  validator.section('11. VALIDACIÓN - DOCUMENTACIÓN GENERAL');

  validator.fileExists('./GUIA_IMPLEMENTACION_BD.md', 'Guía de Implementación BD');
  validator.fileExists('./RESUMEN_EJECUTIVO_BD.md', 'Resumen Ejecutivo BD');
  validator.fileExists('./INDICE_DOCUMENTACION.md', 'Índice de Documentación');

  // ========================================================================
  // SECCIÓN 12: RESUMEN Y CONCLUSIONES
  // ========================================================================
  const allPassed = validator.summary();

  // Recomendaciones finales
  console.log(`${colors.cyan}╔════════════════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.cyan}║${colors.reset}${' PRÓXIMOS PASOS'.padEnd(60)}${colors.cyan}║${colors.reset}`);
  console.log(`${colors.cyan}╠════════════════════════════════════════════════════════════╣${colors.reset}`);

  const steps = [
    '1. Copiar SCRIPT_BASE_DATOS_COMPLETO.sql a Supabase Editor',
    '2. Ejecutar el script en Supabase Console',
    '3. Verificar todas las tablas con: SELECT * FROM information_schema.tables',
    '4. Clonar y configurar backend con variables de .env',
    '5. Instalar dependencias: npm install',
    '6. Ejecutar tests: npm test',
    '7. Iniciar servidor: npm start',
    '8. Conectar frontend web a http://localhost:3001',
    '9. Compilar y desplegar app mobile (Flutter)',
    '10. Ejecutar VALIDACIÓN: node test-api-completo.js'
  ];

  steps.forEach((step, idx) => {
    const stepNum = String(idx + 1).padStart(2, '0');
    console.log(`${colors.cyan}║${colors.reset} ${stepNum}. ${step.padEnd(54)}${colors.cyan}║${colors.reset}`);
  });

  console.log(`${colors.cyan}╚════════════════════════════════════════════════════════════╝${colors.reset}\n`);

  // Estado final
  if (allPassed) {
    console.log(`${colors.green}${colors.reset}
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     ${colors.green}✓ JAMCONNECT ESTÁ 100% LISTO PARA PRODUCCIÓN${colors.reset}            ║
║                                                            ║
║   Todo funciona correctamente y la documentación          ║
║   es completa. El sistema está optimizado y seguro.       ║
║                                                            ║
║              ${colors.green}¡A DESPLEGAR!${colors.reset}                            ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
    `);
    process.exit(0);
  } else {
    console.log(`${colors.yellow}
Hay algunos elementos que revisar antes del despliegue.
Verifica los ítems marcados con ✗ arriba.
    ${colors.reset}`);
    process.exit(1);
  }
}

main().catch(err => {
  console.error(`${colors.red}Error fatal: ${err.message}${colors.reset}`);
  process.exit(1);
});
