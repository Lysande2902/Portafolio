# 🎨 GUÍA: IMÁGENES DE EXPEDIENTES FUSIONADOS

## 📋 RESUMEN

Necesitas crear **4 imágenes** de expedientes para los arcos fusionados.

**Ubicación:** `humano/assets/evidences/`

**Formato:**
- Tipo: PNG o JPG
- Resolución: 1920x1080 (Full HD)
- Estilo: Collage oscuro, horror psicológico, VHS

---

## 🖼️ IMÁGENES NECESARIAS

### 1. `arc1_consumo_codicia.png`
**Arco:** Consumo y Codicia (Gula + Avaricia)  
**Víctimas:** Mateo + Valeria  
**Tema:** Excesos materiales

**Elementos visuales:**
- **Lado izquierdo (Gula):**
  - Platos de comida apilados
  - Restos de comida
  - Mesa desordenada
  - Ambiente de restaurante oscuro
  
- **Lado derecho (Avaricia):**
  - Billetes y monedas
  - Cajas de seguridad
  - Documentos bancarios
  - Ambiente de bóveda

**Paleta de colores:**
- Marrones oscuros (#1a0f0a)
- Grises azulados (#0a0a0f)
- Acentos rojos (#8B0000)

**Texto sugerido (overlay):**
```
CASO #001: CONSUMO Y CODICIA
Víctimas: Mateo R. / Valeria M.
Estado: EXPUESTO
```

---

### 2. `arc2_envidia_lujuria.png`
**Arco:** Envidia y Lujuria  
**Víctimas:** Lucía + Adriana  
**Tema:** Obsesiones tóxicas

**Elementos visuales:**
- **Lado izquierdo (Envidia):**
  - Espejos rotos
  - Fotos de redes sociales
  - Gimnasio oscuro
  - Reflejos distorsionados
  
- **Lado derecho (Lujuria):**
  - Luces de neón
  - Telarañas (metáfora de trampa)
  - Club nocturno
  - Sombras seductoras

**Paleta de colores:**
- Verdes neón (#00ff00)
- Rosas oscuros (#ff00ff)
- Negros profundos (#000000)

**Texto sugerido (overlay):**
```
CASO #002: ENVIDIA Y LUJURIA
Víctimas: Lucía S. / Adriana P.
Estado: ATRAPADAS
```

---

### 3. `arc3_soberbia_pereza.png`
**Arco:** Soberbia y Pereza  
**Víctimas:** Carlos + Miguel  
**Tema:** Arrogancia y negligencia

**Elementos visuales:**
- **Lado izquierdo (Soberbia):**
  - Trofeos y premios
  - Estudio lujoso
  - Corona o símbolo de poder
  - Ambiente dorado
  
- **Lado derecho (Pereza):**
  - Hospital abandonado
  - Camas vacías
  - Polvo y deterioro
  - Ambiente gris

**Paleta de colores:**
- Dorados oscuros (#8B7500)
- Grises apagados (#3a3a3a)
- Blancos sucios (#d0d0d0)

**Texto sugerido (overlay):**
```
CASO #003: SOBERBIA Y PEREZA
Víctimas: Carlos V. / Miguel A.
Estado: CAÍDOS
```

---

### 4. `arc4_ira.png`
**Arco:** Ira (Solo, arco final)  
**Víctima:** Víctor  
**Tema:** Violencia y furia

**Elementos visuales:**
- Casa en llamas
- Puños cerrados
- Sangre salpicada
- Fuego y destrucción
- Cenizas

**Paleta de colores:**
- Rojos intensos (#ff0000)
- Naranjas de fuego (#ff6600)
- Negros carbonizados (#0a0a0a)

**Texto sugerido (overlay):**
```
CASO #004: IRA
Víctima: Víctor T.
Estado: FINAL
```

---

## 🎨 ESTILO VISUAL

### Características comunes:

1. **Efecto VHS:**
   - Líneas de escaneo horizontales
   - Glitch ocasional
   - Colores ligeramente desaturados
   - Ruido de video

2. **Composición:**
   - Collage de 2 temas (excepto Arco 4)
   - División vertical 50/50
   - Transición sutil en el centro
   - Overlay de texto en la parte inferior

3. **Atmósfera:**
   - Oscuro y perturbador
   - Horror psicológico (no gore)
   - Sensación de vigilancia
   - Inquietante pero no explícito

4. **Elementos técnicos:**
   - Indicador REC en esquina superior derecha
   - Timestamp falso
   - Código de caso
   - Marca de agua "CONFIDENCIAL"

---

## 🛠️ HERRAMIENTAS SUGERIDAS

### Opción 1: Photoshop/GIMP
1. Crear canvas 1920x1080
2. Dividir en 2 secciones (arcos fusionados)
3. Añadir imágenes de stock (libres de derechos)
4. Aplicar filtros VHS
5. Añadir overlay de texto
6. Exportar como PNG

### Opción 2: Canva
1. Usar plantilla de collage
2. Buscar imágenes en biblioteca de Canva
3. Aplicar filtros oscuros
4. Añadir texto con fuente monoespaciada
5. Descargar en alta resolución

### Opción 3: IA Generativa (Midjourney/DALL-E)
**Prompt ejemplo para Arco 1:**
```
Dark horror collage split in two halves, left side: abandoned restaurant 
with piled dirty plates and food waste, right side: dark bank vault with 
scattered money and coins, VHS aesthetic, grainy, surveillance camera view, 
psychological horror, red and brown tones, 1920x1080 --ar 16:9 --style raw
```

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
humano/
└── assets/
    └── evidences/
        ├── arc1_consumo_codicia.png      (Nuevo)
        ├── arc2_envidia_lujuria.png      (Nuevo)
        ├── arc3_soberbia_pereza.png      (Nuevo)
        ├── arc4_ira.png                  (Nuevo)
        ├── arc1_complete.png             (Existente - puede reutilizarse)
        ├── arc2_complete.png             (Existente - puede reutilizarse)
        └── arc3_complete.jpg             (Existente - puede reutilizarse)
```

---

## 🔗 INTEGRACIÓN EN CÓDIGO

Las imágenes se cargan automáticamente desde `arc_data_provider.dart`:

```dart
Arc(
  id: 'arc_1_consumo_codicia',
  thumbnailPath: 'assets/images/arcs/consumo_codicia_thumb.png',
  // ...
)
```

**Nota:** También necesitas crear thumbnails (miniaturas) para la pantalla de selección de arcos:
- Tamaño: 400x300
- Ubicación: `assets/images/arcs/`
- Nombres:
  - `consumo_codicia_thumb.png`
  - `envidia_lujuria_thumb.png`
  - `soberbia_pereza_thumb.png`
  - `ira_thumb.png`

---

## ✅ CHECKLIST DE CREACIÓN

### Por cada imagen:

- [ ] Canvas 1920x1080 creado
- [ ] Tema visual definido
- [ ] Imágenes de stock seleccionadas (libres de derechos)
- [ ] División 50/50 aplicada (arcos fusionados)
- [ ] Filtro VHS aplicado
- [ ] Overlay de texto añadido
- [ ] Indicador REC añadido
- [ ] Timestamp añadido
- [ ] Marca "CONFIDENCIAL" añadida
- [ ] Exportado como PNG
- [ ] Copiado a `assets/evidences/`
- [ ] Thumbnail 400x300 creado
- [ ] Thumbnail copiado a `assets/images/arcs/`

---

## 🎯 PRIORIDAD

**CRÍTICO (Necesario para jugar):**
1. ✅ Arco 1: Consumo y Codicia
2. ⏳ Arco 2: Envidia y Lujuria
3. ⏳ Arco 3: Soberbia y Pereza
4. ⏳ Arco 4: Ira

**IMPORTANTE (Necesario para menú):**
- Thumbnails de todos los arcos

---

## 💡 TIPS

1. **Reutiliza assets existentes:** Puedes usar las imágenes actuales como base y modificarlas.

2. **Usa placeholders temporales:** Mientras creas las imágenes finales, usa rectángulos de colores sólidos con texto.

3. **Batch processing:** Crea todas las imágenes en una sesión para mantener consistencia visual.

4. **Backup:** Guarda las imágenes en formato PSD/XCF para poder editarlas después.

5. **Compresión:** Usa TinyPNG para reducir el tamaño sin perder calidad.

---

## 📊 ESPECIFICACIONES TÉCNICAS

| Propiedad | Valor |
|-----------|-------|
| Formato | PNG (preferido) o JPG |
| Resolución | 1920x1080 |
| Aspect Ratio | 16:9 |
| Tamaño máximo | 2MB por imagen |
| Color space | sRGB |
| Compresión | Lossless (PNG) o 90% (JPG) |

---

## 🔄 PROCESO DE ACTUALIZACIÓN

1. Crear imagen
2. Guardar en `assets/evidences/`
3. Crear thumbnail
4. Guardar en `assets/images/arcs/`
5. Ejecutar `flutter pub get`
6. Probar en juego
7. Ajustar si es necesario

---

**Fecha:** 27 de Enero de 2025  
**Estado:** Guía completa - Listo para crear imágenes
