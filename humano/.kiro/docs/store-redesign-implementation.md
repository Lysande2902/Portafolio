# 🏪 Implementación del Rediseño de la Tienda

## ✅ Completado

### 1. Estructura de Datos

**Archivo:** `lib/data/providers/store_data_provider.dart`

- **12 Items Consumibles** organizados en 3 categorías:
  - 4 Defensivos (Firewall, Alt Account, Antivirus, Backup)
  - 4 Sigilo (VPN, Incógnito, Camuflaje, Proxy)
  - 4 Ofensivos/Utilidad (Trending, DDoS, Boost, Antídoto)

- **9 Skins** organizadas en 3 rarezas:
  - 3 Básicas (Anonymous, Influencer, Moderador)
  - 3 Premium (Troll, Ghost, Hacker)
  - 3 Temáticas (Gourmet, Banquero, Ermitaño)

- **6 Bundles**:
  - 2 Starter Packs
  - 3 Themed Bundles
  - 1 Premium Bundle

- **1 Battle Pass**: Temporada 1 "El Juicio Digital"

**Total: 28 items** (sin contar el Battle Pass)

---

### 2. Modelo de Datos

**Archivo:** `lib/data/models/store_item.dart`

**Campos agregados:**
- `category` (String?) - Para items: defensive, stealth, offensive
- `rarity` (String?) - Para skins: basic, premium, thematic
- `bundle` (StoreItemType) - Nuevo tipo agregado al enum

---

### 3. UI de la Tienda

**Archivo:** `lib/screens/store_screen.dart`

**Implementado:**

#### Layout General
- Menú lateral (80px) con 5 categorías
- Área de contenido con grid de 3 columnas
- Header con balance de monedas clickeable

#### Categorías

**DESTACADO (Featured)**
- Grid 3x2 = 6 items
- Mix de bundles, items nuevos, skin premium y battle pass
- Sin scroll

**ITEMS (Consumables)**
- Grid 3x4 = 12 items
- Con scroll vertical
- Cards compactos (100x120px aprox)

**SKINS**
- Grid 3x3 = 9 skins
- Con scroll ligero
- Cards con preview de personaje

**ESPECIAL (Bundles)**
- Grid 3x2 = 6 bundles
- Sin scroll
- Cards con contenido detallado

**PASE (Battle Pass)**
- Vista única con scroll
- Banner premium
- Barra de progreso
- Scroll horizontal de recompensas
- 2 opciones de compra (monedas / dinero real)
- Lista de beneficios

---

### 4. Diseño de Cards

**Card Estándar:**
- Tamaño: ~100x120px
- Icono: 40x40px
- Nombre: 2 líneas max
- Descripción: 2 líneas max
- Precio con icono de moneda
- Botón "COMPRAR" / "EQUIPADO"
- Badge "PREMIUM" para items premium
- Borde dorado para items premium

**Paleta de Colores:**
- Fondo: Negro (#0A0A0A)
- Cards: Negro transparente (0.6 opacity)
- Bordes: Vino tinto (#8B0000)
- Acentos: Rojo coral (#CD5C5C)
- Premium: Dorado (#FFD700)
- Texto: Blanco / Gris

---

## 🎨 Pixel Arts Necesarios

### Items Consumibles (12 assets - 32x32px)

**Defensivos:**
1. `assets/items/firewall.png` - Escudo digital con red
2. `assets/items/alt_account.png` - Corazón con cruz médica
3. `assets/items/antivirus.png` - Píldora con símbolo protección
4. `assets/items/backup.png` - Disco con flecha circular

**Sigilo:**
5. `assets/items/vpn.png` - Máscara/capucha oscura
6. `assets/items/incognito.png` - Gafas de sol
7. `assets/items/camouflage.png` - Patrón camuflaje digital
8. `assets/items/proxy.png` - Silueta fantasma duplicada

**Ofensivos:**
9. `assets/items/trending.png` - Teléfono con notificación
10. `assets/items/ddos.png` - Rayo eléctrico
11. `assets/items/boost.png` - Flecha velocidad
12. `assets/items/antidote.png` - Jeringa/frasco médico

---

### Skins (9 assets - 64x64px)

**Básicas:**
13. `assets/skins/anonymous.png` - Máscara Guy Fawkes
14. `assets/skins/influencer.png` - Personaje con cámara
15. `assets/skins/moderator.png` - Personaje con escudo

**Premium:**
16. `assets/skins/troll.png` - Cara con ojos rojos
17. `assets/skins/ghost.png` - Figura traslúcida
18. `assets/skins/hacker.png` - Hoodie con código

**Temáticas:**
19. `assets/skins/gourmet.png` - Chef oscuro
20. `assets/skins/banker.png` - Traje roto
21. `assets/skins/hermit.png` - Pijama

---

### Bundles (6 assets - 48x48px)

22. `assets/bundles/starter.png` - Caja pequeña abierta
23. `assets/bundles/survival.png` - Mochila supervivencia
24. `assets/bundles/stealth.png` - Caja con símbolo sigilo
25. `assets/bundles/defense.png` - Caja con escudo
26. `assets/bundles/speed.png` - Caja con rayo
27. `assets/bundles/premium.png` - Cofre dorado

---

### Battle Pass (1 asset - 128x64px)

28. `assets/battlepass/banner.png` - Banner épico "T1"

---

## 📱 Especificaciones Técnicas

### Grid Layout
- **Columnas:** 3
- **Aspect Ratio:** 0.8
- **Spacing:** 8px
- **Padding:** 12px

### Card Dimensions
- **Ancho:** ~100px (calculado automáticamente)
- **Alto:** ~120px
- **Border Radius:** 8px
- **Border Width:** 1px (2px para premium)

### Typography
- **Font:** Courier Prime (Google Fonts)
- **Tamaños:**
  - Título card: 10px
  - Descripción: 8px
  - Precio: 12px
  - Botón: 9px
  - Badge: 8px

---

## 🔄 Próximos Pasos

### Fase 1: Assets
- [ ] Crear los 28 pixel arts
- [ ] Colocar en carpetas correspondientes
- [ ] Actualizar rutas en `store_data_provider.dart`

### Fase 2: Funcionalidad
- [ ] Implementar lógica de compra
- [ ] Conectar con sistema de monedas
- [ ] Guardar items comprados en Firebase
- [ ] Implementar sistema de inventario
- [ ] Verificar ownership de items

### Fase 3: Battle Pass
- [ ] Sistema de progresión (XP/niveles)
- [ ] Desbloqueo de recompensas
- [ ] Tracking de nivel actual
- [ ] Cinemáticas de recompensas

### Fase 4: Polish
- [ ] Animaciones de compra
- [ ] Efectos de hover/tap
- [ ] Sonidos de UI
- [ ] Partículas para items premium
- [ ] Confirmación de compra

---

## 🎯 Notas de Diseño

### Filosofía
- **Minimalista:** Sin saturación visual
- **Compacto:** Aprovecha espacio móvil
- **Claro:** Fácil navegación
- **Premium:** Items especiales destacan

### Decisiones Clave
- Grid de 3 columnas (óptimo para móvil)
- Cards compactos pero legibles
- Scroll solo donde necesario
- Menú lateral siempre visible
- Battle Pass con diseño especial

### Balance
- 12 consumibles (suficiente variedad)
- 9 skins (3 por rareza)
- 6 bundles (ofertas atractivas)
- 1 battle pass (foco en temporada)

**Total: 28 items únicos + 1 battle pass = 29 productos**

---

## 📊 Métricas de Diseño

| Métrica | Valor | Razón |
|---------|-------|-------|
| Items por categoría | 6-12 | No abrumar, suficiente variedad |
| Columnas grid | 3 | Óptimo para móvil |
| Tamaño card | 100x120px | Compacto pero legible |
| Menú lateral | 80px | Siempre visible, no invasivo |
| Pixel art items | 32x32px | Detalle suficiente, carga rápida |
| Pixel art skins | 64x64px | Mayor detalle para personajes |

---

**Última actualización:** Noviembre 2024  
**Estado:** ✅ Estructura completa, esperando pixel arts
