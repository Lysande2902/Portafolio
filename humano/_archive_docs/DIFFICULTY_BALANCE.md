# ⚖️ BALANCE DE DIFICULTAD - ANÁLISIS Y AJUSTES

## 📊 ESTADO ACTUAL

### **Arco 1: Gula**

**Jugador:**
- Velocidad base: 180.0
- Tamaño: 40x60

**Enemigo:**
- Velocidad patrulla: 60.0
- Velocidad persecución: 85.0
- Rango detección: 200.0
- Rango captura: 40.0

**Proyectiles:**
- Cooldown: 3.0s
- Rango disparo: 250.0
- Velocidad: 200.0
- Daño: 15% cordura

**Cordura:**
- Inicial: 100%
- Drenaje escondido: Sí
- Muerte: 0%

**Evidencia:**
- Total: 5
- Rango recolección: 50.0

---

## 🎮 CURVA DE DIFICULTAD PROPUESTA

### **Progresión:**
1. **Inicio (0-1 evidencia):** Fácil - Jugador aprende mecánicas
2. **Medio (2-3 evidencia):** Normal - Enemigo más agresivo
3. **Final (4-5 evidencia):** Difícil - Máxima presión

---

## ⚙️ AJUSTES RECOMENDADOS

### **OPCIÓN A: BALANCEADO (Recomendado)**

**Jugador:**
- ✅ Velocidad: 180.0 (mantener)
- ✅ Tamaño: 40x60 (mantener)

**Enemigo:**
- ⚖️ Velocidad patrulla: 60.0 → **70.0** (+16%)
- ⚖️ Velocidad persecución: 85.0 → **100.0** (+17%)
- ⚖️ Rango detección: 200.0 → **220.0** (+10%)
- ✅ Rango captura: 40.0 (mantener)

**Proyectiles:**
- ⚖️ Cooldown: 3.0s → **4.0s** (menos spam)
- ⚖️ Rango disparo: 250.0 → **230.0** (menos alcance)
- ✅ Velocidad: 200.0 (mantener)
- ⚖️ Daño: 15% → **12%** (menos castigo)

**Cordura:**
- ✅ Inicial: 100% (mantener)
- ⚖️ Drenaje escondido: Reducir a 50%
- ✅ Muerte: 0% (mantener)

**Evidencia:**
- ✅ Total: 5 (mantener)
- ✅ Rango: 50.0 (mantener)

---

### **OPCIÓN B: DIFÍCIL (Para jugadores experimentados)**

**Enemigo:**
- Velocidad patrulla: 80.0
- Velocidad persecución: 110.0
- Rango detección: 240.0

**Proyectiles:**
- Cooldown: 2.5s
- Daño: 18%

---

### **OPCIÓN C: FÁCIL (Para principiantes)**

**Enemigo:**
- Velocidad patrulla: 55.0
- Velocidad persecución: 80.0
- Rango detección: 180.0

**Proyectiles:**
- Cooldown: 5.0s
- Daño: 10%

---

## 📈 PROGRESIÓN POR ARCO

### **Arco 1: Gula** (Tutorial)
- Dificultad: ⭐⭐☆☆☆
- Enemigo más lento
- Más escondites
- Proyectiles menos frecuentes

### **Arco 2: Avaricia** (Normal)
- Dificultad: ⭐⭐⭐☆☆
- Enemigo velocidad normal
- Escondites normales
- Proyectiles normales

### **Arco 3: Envidia** (Difícil)
- Dificultad: ⭐⭐⭐⭐☆
- Enemigo con fases (aumenta velocidad)
- Menos escondites
- Proyectiles más frecuentes

---

## 🎯 IMPLEMENTACIÓN RECOMENDADA

Voy a implementar la **OPCIÓN A: BALANCEADO** que ofrece:
- Desafío justo
- Curva de aprendizaje suave
- Recompensa por habilidad
- No frustrante

---

## 📝 NOTAS DE DISEÑO

### **Filosofía de Balance:**
1. **Jugador debe sentirse poderoso** pero no invencible
2. **Enemigo debe ser amenazante** pero no imposible
3. **Errores deben castigarse** pero permitir recuperación
4. **Habilidad debe recompensarse** con victoria consistente

### **Métricas de Éxito:**
- Tasa de victoria: 60-70% (jugadores promedio)
- Tiempo promedio: 3-5 minutos por arco
- Muertes promedio: 1-2 antes de ganar
- Uso de escondites: 2-3 veces por partida

---

**Fecha:** 2025-12-05
**Versión:** 1.0 - Balanceado
