# 🚀 Guía de Despliegue de Reglas de Firebase

## 📋 Resumen de Cambios

Se han actualizado las reglas de Firestore con mejoras críticas de seguridad:

### ✅ Mejoras Implementadas

1. **Funciones Helper Reutilizables**
   - `isAuthenticated()`: Verifica autenticación
   - `isOwner(userId)`: Verifica propiedad de recursos
   - `isValidString(value)`: Valida strings no vacíos
   - `isValidNumber(value)`: Valida números >= 0

2. **Validación de Usuarios**
   - Estructura de datos validada
   - Límite de monedas: 999,999
   - Validación de inventario completa

3. **Transacciones Seguras**
   - Solo el dueño puede acceder a sus transacciones
   - Límite de monto: $1,000 USD
   - Monedas permitidas: usd, mxn, eur
   - Transacciones completadas inmutables

4. **Partidas Multijugador Protegidas**
   - Solo participantes pueden modificar
   - Host y guest no pueden cambiarse
   - Estados validados: waiting, active, finished

5. **Leaderboard Validado**
   - Nombres limitados a 30 caracteres
   - Validación de scores y estadísticas
   - Solo el dueño puede actualizar su entrada

---

## 🔧 Pasos para Desplegar

### 1. Verificar Cambios Locales

```bash
# Ver las reglas actuales
cat firestore.rules
```

### 2. Probar en Emulador (RECOMENDADO)

```bash
# Iniciar emulador de Firestore
firebase emulators:start --only firestore

# En otra terminal, ejecutar tests
flutter test
```

### 3. Desplegar a Firebase

```bash
# Desplegar solo las reglas (sin afectar otras configuraciones)
firebase deploy --only firestore:rules
```

### 4. Verificar en Consola de Firebase

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar proyecto: **condicion-humano**
3. Ir a **Firestore Database** > **Rules**
4. Verificar que las reglas se hayan actualizado

---

## ⚠️ Consideraciones Importantes

### Antes de Desplegar

1. **Backup de Reglas Anteriores**: Firebase mantiene un historial, pero es buena práctica guardar una copia
2. **Testing**: Prueba las reglas en el emulador primero
3. **Datos Existentes**: Verifica que los datos existentes cumplan con las nuevas validaciones

### Posibles Problemas

#### ❌ Error: "Permission Denied"

Si los usuarios reportan errores de permisos después del despliegue:

1. Verifica que el usuario esté autenticado
2. Verifica que el `userId` en los datos coincida con `request.auth.uid`
3. Revisa los logs de Firebase: `firebase firestore:logs`

#### ❌ Error: "Validation Failed"

Si las escrituras fallan por validación:

1. Verifica que los datos incluyan todos los campos requeridos
2. Verifica que los valores estén dentro de los límites
3. Verifica que los tipos de datos sean correctos

---

## 🧪 Testing de Reglas

### Test Manual en Emulador

```bash
# 1. Iniciar emulador
firebase emulators:start --only firestore

# 2. En otra terminal, probar operaciones
flutter run
```

### Verificar Operaciones Comunes

- ✅ Usuario puede leer sus propios datos
- ✅ Usuario puede actualizar su inventario
- ✅ Usuario puede crear transacciones
- ✅ Usuario puede unirse a partidas
- ✅ Usuario puede actualizar su entrada en leaderboard
- ❌ Usuario NO puede leer datos de otros usuarios
- ❌ Usuario NO puede modificar transacciones de otros
- ❌ Usuario NO puede modificar partidas donde no participa

---

## 📊 Monitoreo Post-Despliegue

### Ver Logs de Seguridad

```bash
# Ver logs en tiempo real
firebase firestore:logs

# Filtrar solo errores de permisos
firebase firestore:logs | grep "permission-denied"
```

### Métricas a Monitorear

1. **Errores de Permisos**: Deben ser mínimos después del despliegue
2. **Operaciones Rechazadas**: Verificar que sean intentos legítimos de acceso no autorizado
3. **Performance**: Las validaciones no deben afectar significativamente el rendimiento

---

## 🔄 Rollback (Si es Necesario)

Si necesitas revertir los cambios:

```bash
# 1. Ver historial de reglas en Firebase Console
# 2. Seleccionar versión anterior
# 3. Hacer clic en "Publish"

# O restaurar desde backup local
git checkout HEAD~1 firestore.rules
firebase deploy --only firestore:rules
```

---

## 📝 Checklist de Despliegue

- [ ] Backup de reglas anteriores guardado
- [ ] Reglas probadas en emulador local
- [ ] Tests de Flutter pasando
- [ ] Reglas desplegadas a Firebase
- [ ] Verificado en Firebase Console
- [ ] Monitoreo de logs activo
- [ ] Usuarios notificados (si aplica)
- [ ] Documentación actualizada

---

## 🆘 Soporte

Si encuentras problemas:

1. Revisa los logs: `firebase firestore:logs`
2. Verifica la documentación: `FIREBASE_DATABASE_DOCUMENTATION.md`
3. Consulta la [documentación oficial de Firebase](https://firebase.google.com/docs/firestore/security/get-started)

---

**Proyecto**: CONDICIÓN: HUMANO  
**Firebase Project ID**: condicion-humano  
**Versión de Reglas**: 2.1  
**Fecha**: Diciembre 5, 2024
