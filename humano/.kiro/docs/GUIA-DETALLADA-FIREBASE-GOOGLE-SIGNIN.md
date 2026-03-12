# 📱 Guía Detallada: Configurar Google Sign-In en Firebase

## 🎯 Objetivo
Configurar Firebase Console paso a paso para habilitar Google Sign-In en tu aplicación Flutter.

**Tiempo estimado**: 15-20 minutos

---

## 📋 Antes de Empezar

### Información que necesitarás:

```
SHA-1:   B4:E5:CA:B3:57:77:BD:9F:B7:43:87:23:60:57:AA:00:C7:E0:FB:2C
SHA-256: 41:4A:3B:8B:0E:87:96:14:62:1A:9D:01:42:DC:BC:83:3B:71:59:A0:81:5F:CD:96:76:C6:6C:C9:D1:BE:72:3F
```

**Copia estos valores ahora** - los necesitarás más adelante.

---

## 🔥 PARTE 1: Habilitar Google Sign-In

### Paso 1.1: Abrir Firebase Console

1. Abre tu navegador web (Chrome, Firefox, Edge, etc.)

2. Ve a: **https://console.firebase.google.com/**

3. Inicia sesión con tu cuenta de Google si no lo has hecho

4. Verás una lista de tus proyectos Firebase

### Paso 1.2: Seleccionar tu Proyecto

1. Busca tu proyecto en la lista (debería llamarse algo como "humano" o el nombre que le diste)

2. **Click en el nombre del proyecto** para abrirlo

3. Espera a que cargue el dashboard del proyecto

**Visual**: Deberías ver el dashboard principal con opciones como:
- Authentication
- Firestore Database
- Storage
- Hosting
- etc.

### Paso 1.3: Ir a Authentication

1. En el **menú lateral izquierdo**, busca "Authentication"

2. **Click en "Authentication"**

3. Si es la primera vez que usas Authentication:
   - Verás un botón grande que dice **"Get started"**
   - **Click en "Get started"**
   - Espera unos segundos mientras Firebase configura Authentication

4. Si ya has usado Authentication antes:
   - Verás directamente las pestañas: Users, Sign-in method, Templates, Usage

### Paso 1.4: Ir a Sign-in Method

1. En la parte superior, verás varias pestañas:
   - **Users**
   - **Sign-in method** ← Click aquí
   - Templates
   - Settings
   - Usage

2. **Click en la pestaña "Sign-in method"**

3. Verás una lista de proveedores de autenticación:
   - Email/Password
   - Phone
   - Google ← Este es el que necesitamos
   - Play Games
   - Game Center
   - Facebook
   - Twitter
   - GitHub
   - Yahoo
   - Microsoft
   - Apple
   - Anonymous

### Paso 1.5: Habilitar Google

1. **Busca "Google"** en la lista de proveedores

2. **Click en "Google"** (toda la fila es clickeable)

3. Se abrirá un panel lateral derecho con el título "Google"

4. Verás un **toggle switch** (interruptor) que dice "Enable"

5. **Click en el toggle para activarlo** (debe ponerse azul/verde)

6. Aparecerán campos adicionales:
   - **Project support email** (requerido)
   - Project public-facing name (opcional)

7. En **"Project support email"**:
   - Click en el dropdown
   - Selecciona tu email (el que usas para Firebase)

8. **Opcional**: En "Project public-facing name":
   - Puedes dejarlo como está
   - O cambiarlo a "Humano" o el nombre de tu app

9. **Click en el botón "Save"** (abajo a la derecha del panel)

10. Espera a que aparezca un mensaje de confirmación verde

11. **Click en la X** o fuera del panel para cerrarlo

**✅ Resultado**: Ahora deberías ver "Google" en la lista con un estado "Enabled" (habilitado)

---

## 🔑 PARTE 2: Agregar SHA Fingerprints

### Paso 2.1: Ir a Project Settings

1. En la **esquina superior izquierda**, busca el **ícono de engranaje ⚙️**
   - Está al lado del nombre de tu proyecto
   - Dice "Project Overview" arriba

2. **Click en el ícono de engranaje ⚙️**

3. En el menú desplegable, **click en "Project settings"**

4. Se abrirá la página de configuración del proyecto

### Paso 2.2: Encontrar tu App Android

1. En la página de Project Settings, verás varias pestañas en la parte superior:
   - General ← Deberías estar aquí
   - Service accounts
   - Usage and billing
   - Integrations
   - Cloud Messaging

2. **Scroll down** (desplázate hacia abajo) en la página

3. Verás una sección llamada **"Your apps"**

4. Deberías ver tu app Android con:
   - Un ícono de Android (robot verde)
   - El nombre del paquete (algo como `com.example.humano`)
   - Un botón "google-services.json"

5. Si **NO ves tu app Android**:
   - Significa que no has agregado Firebase a tu proyecto Android
   - Necesitarás agregar la app primero
   - Click en "Add app" → Selecciona Android
   - Sigue el wizard de configuración
   - Luego vuelve a estos pasos

### Paso 2.3: Expandir Configuración de Android

1. **Click en tu app Android** (en cualquier parte de la tarjeta)

2. La tarjeta se expandirá mostrando más información:
   - Package name
   - App nickname
   - Debug signing certificate SHA-1
   - SHA certificate fingerprints ← Esta es la sección que necesitamos

3. **Scroll down** dentro de la tarjeta hasta ver **"SHA certificate fingerprints"**

### Paso 2.4: Agregar SHA-1

1. En la sección "SHA certificate fingerprints", verás:
   - Una lista de fingerprints (puede estar vacía)
   - Un botón **"Add fingerprint"**

2. **Click en "Add fingerprint"**

3. Aparecerá un campo de texto vacío

4. **Copia el SHA-1** de arriba:
   ```
   B4:E5:CA:B3:57:77:BD:9F:B7:43:87:23:60:57:AA:00:C7:E0:FB:2C
   ```

5. **Pega el SHA-1** en el campo de texto

6. **Presiona Enter** o **click fuera del campo**

7. El fingerprint se guardará automáticamente

8. Verás el SHA-1 agregado a la lista con:
   - El valor del fingerprint
   - La fecha de creación
   - Un ícono de papelera (para eliminar)

**✅ Resultado**: SHA-1 agregado correctamente

### Paso 2.5: Agregar SHA-256

1. **Click en "Add fingerprint"** nuevamente

2. Aparecerá otro campo de texto vacío

3. **Copia el SHA-256** de arriba:
   ```
   41:4A:3B:8B:0E:87:96:14:62:1A:9D:01:42:DC:BC:83:3B:71:59:A0:81:5F:CD:96:76:C6:6C:C9:D1:BE:72:3F
   ```

4. **Pega el SHA-256** en el campo de texto

5. **Presiona Enter** o **click fuera del campo**

6. El fingerprint se guardará automáticamente

7. Ahora deberías ver **DOS fingerprints** en la lista:
   - SHA-1 (más corto)
   - SHA-256 (más largo)

**✅ Resultado**: Ambos fingerprints agregados correctamente

---

## 📥 PARTE 3: Descargar google-services.json Actualizado

### Paso 3.1: Descargar el Archivo

1. **Todavía en la página de Project Settings**, en la tarjeta de tu app Android

2. En la parte superior de la tarjeta, verás un botón **"google-services.json"**

3. **Click en "google-services.json"**

4. El archivo se descargará automáticamente a tu carpeta de Descargas

5. **Espera** a que termine la descarga (debería ser instantáneo, es un archivo pequeño)

**✅ Resultado**: Archivo `google-services.json` descargado

### Paso 3.2: Ubicar el Archivo Descargado

1. Abre el **Explorador de Archivos** de Windows

2. Ve a tu carpeta de **Descargas**:
   - Puedes presionar `Windows + E` para abrir el explorador
   - Luego click en "Descargas" en el panel izquierdo

3. Busca el archivo **"google-services.json"**
   - Debería estar al principio (ordenado por fecha)
   - Tamaño: aproximadamente 1-3 KB

4. **Click derecho** en el archivo

5. Selecciona **"Copiar"** (o presiona `Ctrl + C`)

**✅ Resultado**: Archivo copiado al portapapeles

### Paso 3.3: Reemplazar el Archivo en tu Proyecto

1. En el **Explorador de Archivos**, navega a tu proyecto:
   ```
   C:\Users\acer\Caso2\humano\android\app\
   ```

2. **Forma rápida**:
   - En la barra de direcciones del explorador, pega:
     ```
     C:\Users\acer\Caso2\humano\android\app
     ```
   - Presiona Enter

3. Verás varios archivos y carpetas, incluyendo:
   - build.gradle
   - **google-services.json** ← Este es el que vamos a reemplazar
   - src/
   - etc.

4. **Busca el archivo "google-services.json"** existente

5. **Click derecho** en el archivo existente

6. Selecciona **"Eliminar"** o presiona `Delete`

7. Confirma la eliminación si Windows te pregunta

8. Ahora **pega el nuevo archivo**:
   - Click derecho en un espacio vacío
   - Selecciona **"Pegar"** (o presiona `Ctrl + V`)

9. El nuevo `google-services.json` se copiará a la carpeta

**✅ Resultado**: Archivo `google-services.json` actualizado en tu proyecto

---

## 🧹 PARTE 4: Limpiar y Reconstruir el Proyecto

### Paso 4.1: Abrir Terminal

1. Abre **PowerShell** o **Command Prompt**

2. **Forma rápida**:
   - Presiona `Windows + R`
   - Escribe `powershell`
   - Presiona Enter

3. Navega a tu proyecto:
   ```powershell
   cd C:\Users\acer\Caso2\humano
   ```

4. Presiona Enter

**✅ Resultado**: Estás en el directorio del proyecto

### Paso 4.2: Limpiar el Proyecto

1. Ejecuta el comando:
   ```powershell
   flutter clean
   ```

2. Presiona Enter

3. Verás mensajes como:
   ```
   Deleting build...
   Deleting .dart_tool...
   Deleting .flutter-plugins...
   Deleting .flutter-plugins-dependencies...
   ```

4. **Espera** a que termine (5-10 segundos)

**✅ Resultado**: Proyecto limpiado

### Paso 4.3: Obtener Dependencias

1. Ejecuta el comando:
   ```powershell
   flutter pub get
   ```

2. Presiona Enter

3. Verás mensajes como:
   ```
   Running "flutter pub get" in humano...
   Resolving dependencies...
   + cupertino_icons 1.0.8
   + firebase_auth 5.3.3
   + google_sign_in 6.2.1
   ...
   Changed X dependencies!
   ```

4. **Espera** a que termine (10-30 segundos)

**✅ Resultado**: Dependencias actualizadas

### Paso 4.4: Ejecutar la App

1. **Conecta tu dispositivo Android** o **inicia un emulador**

2. Verifica que el dispositivo esté conectado:
   ```powershell
   flutter devices
   ```

3. Deberías ver tu dispositivo en la lista

4. Ejecuta la app:
   ```powershell
   flutter run
   ```

5. Presiona Enter

6. **Espera** a que compile y se instale (1-3 minutos la primera vez)

7. La app se abrirá automáticamente en tu dispositivo

**✅ Resultado**: App ejecutándose con Google Sign-In configurado

---

## 🧪 PARTE 5: Probar Google Sign-In

### Paso 5.1: Abrir la Pantalla de Login

1. La app debería abrir automáticamente en la pantalla de login

2. Si no, navega a la pantalla de login

3. Deberías ver:
   - Campos de "IDENTIDAD" y "CÓDIGO DE ACCESO"
   - Botón **"[ ACCEDER ]"** (rojo)
   - Botón **"[ GOOGLE ]"** (azul) ← Este es el nuevo
   - Link "No estás registrado..."

### Paso 5.2: Hacer Click en el Botón de Google

1. **Click en el botón "[ GOOGLE ]"** (el azul)

2. Deberías ver:
   - Un diálogo de carga (loading)
   - O directamente el selector de cuenta de Google

3. **Si aparece un error**:
   - Lee el mensaje de error
   - Ve a la sección de Troubleshooting más abajo

### Paso 5.3: Seleccionar Cuenta de Google

1. Aparecerá un diálogo con tus cuentas de Google

2. **Selecciona la cuenta** que quieres usar

3. Si es la primera vez:
   - Google puede pedir permisos
   - Lee los permisos
   - Click en **"Permitir"** o **"Allow"**

4. **Espera** mientras Google autentica (2-5 segundos)

### Paso 5.4: Verificar Autenticación Exitosa

1. Si todo funciona correctamente:
   - La app navegará automáticamente a **MenuScreen**
   - Verás el menú principal del juego
   - ¡Estás autenticado!

2. Si hay un error:
   - Verás una notificación roja en la parte superior
   - Lee el mensaje de error
   - Ve a la sección de Troubleshooting

**✅ Resultado**: Google Sign-In funcionando correctamente

---

## 🎉 ¡Configuración Completa!

Si llegaste hasta aquí y todo funcionó, **¡felicidades!** 🎊

Tu aplicación ahora tiene Google Sign-In completamente funcional.

---

## 🐛 Troubleshooting Detallado

### Error: "PlatformException(sign_in_failed)"

**Causa**: SHA-1/SHA-256 no agregados correctamente o google-services.json no actualizado

**Solución paso a paso**:

1. **Verificar SHA Fingerprints en Firebase**:
   - Ve a Firebase Console
   - Project Settings → Your apps → Android
   - Verifica que veas AMBOS fingerprints:
     - SHA-1: `B4:E5:CA:B3:...`
     - SHA-256: `41:4A:3B:8B:...`
   - Si no están, agrégalos siguiendo PARTE 2

2. **Verificar google-services.json**:
   - Abre `C:\Users\acer\Caso2\humano\android\app\google-services.json`
   - Verifica que la fecha de modificación sea reciente (hoy)
   - Si no, descarga nuevamente siguiendo PARTE 3

3. **Limpiar y reconstruir**:
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Reiniciar el dispositivo/emulador**:
   - A veces los cambios requieren reinicio
   - Cierra el emulador completamente
   - Vuelve a abrirlo
   - Ejecuta `flutter run` nuevamente

### Error: "Google Sign-In not configured"

**Causa**: Google Sign-In no habilitado en Firebase Console

**Solución**:
1. Ve a Firebase Console
2. Authentication → Sign-in method
3. Verifica que "Google" esté "Enabled"
4. Si no, sigue PARTE 1 completa

### Error: "ERROR_ABORTED_BY_USER"

**Causa**: Usuario canceló el inicio de sesión

**Solución**: Este es un comportamiento normal, no es un error real. El usuario simplemente cerró el diálogo de Google.

### Botón de Google no aparece

**Causa**: Error en el código o compilación

**Solución**:
1. Verifica que el archivo `lib/screens/auth_screen.dart` tenga el botón de Google
2. Ejecuta:
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

### Selector de cuenta no se abre

**Causa**: Problema con Google Play Services

**Solución**:
1. Verifica que Google Play Services esté actualizado en tu dispositivo
2. Ve a Configuración → Apps → Google Play Services → Actualizar
3. Reinicia el dispositivo
4. Intenta nuevamente

### Error: "Network error"

**Causa**: Sin conexión a internet

**Solución**:
1. Verifica tu conexión a internet
2. Intenta abrir un navegador web
3. Si funciona, intenta Google Sign-In nuevamente

---

## 📊 Checklist Final

Marca cada item cuando lo completes:

### Configuración de Firebase
- [ ] Firebase Console abierto
- [ ] Proyecto seleccionado
- [ ] Authentication → Sign-in method abierto
- [ ] Google habilitado
- [ ] Support email agregado
- [ ] Cambios guardados

### SHA Fingerprints
- [ ] Project Settings abierto
- [ ] App Android encontrada
- [ ] SHA-1 agregado: `B4:E5:CA:B3:...`
- [ ] SHA-256 agregado: `41:4A:3B:8B:...`
- [ ] Ambos fingerprints visibles en la lista

### Archivo de Configuración
- [ ] google-services.json descargado
- [ ] Archivo ubicado en Descargas
- [ ] Archivo antiguo eliminado de `android/app/`
- [ ] Archivo nuevo copiado a `android/app/`
- [ ] Fecha de modificación es reciente

### Compilación
- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] `flutter run` ejecutado
- [ ] App compilada sin errores
- [ ] App instalada en dispositivo

### Testing
- [ ] Pantalla de login visible
- [ ] Botón "[ GOOGLE ]" visible (azul)
- [ ] Click en botón funciona
- [ ] Selector de cuenta se abre
- [ ] Cuenta seleccionada
- [ ] Autenticación exitosa
- [ ] Navegación a MenuScreen
- [ ] Usuario autenticado

---

## 📞 Soporte Adicional

Si después de seguir todos estos pasos aún tienes problemas:

1. **Revisa los logs**:
   ```powershell
   flutter run --verbose
   ```
   Busca mensajes de error específicos

2. **Consulta la documentación**:
   - [Firebase Authentication](https://firebase.google.com/docs/auth)
   - [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)

3. **Verifica versiones**:
   ```powershell
   flutter doctor -v
   ```
   Asegúrate de tener Flutter actualizado

---

## 🎯 Resumen de Tiempos

| Parte | Tiempo Estimado |
|-------|----------------|
| PARTE 1: Habilitar Google Sign-In | 3-5 minutos |
| PARTE 2: Agregar SHA Fingerprints | 2-3 minutos |
| PARTE 3: Descargar google-services.json | 1-2 minutos |
| PARTE 4: Limpiar y Reconstruir | 2-3 minutos |
| PARTE 5: Probar Google Sign-In | 1-2 minutos |
| **TOTAL** | **10-15 minutos** |

---

## 📅 Información del Documento

- **Fecha de creación**: 24 de noviembre de 2025
- **Versión**: 1.0.0 - Guía Detallada
- **Autor**: Kiro AI Assistant
- **Proyecto**: Humano - Google Sign-In Implementation

---

## ✅ ¡Éxito!

Si completaste todos los pasos, tu aplicación ahora tiene Google Sign-In completamente funcional.

Los usuarios pueden:
- ✅ Hacer click en "[ GOOGLE ]"
- ✅ Seleccionar su cuenta de Google
- ✅ Autenticarse sin crear contraseña
- ✅ Acceder al juego inmediatamente

**¡El sistema está listo para producción!** 🚀
