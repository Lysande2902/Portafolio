# 🪞 Arco 3: ENVIDIA - Referencia Rápida

## ✅ Implementación Completa

### Archivos Modificados
1. ✅ `lib/game/arcs/envy/components/chameleon_enemy.dart` → Renombrado a `MirrorEnemy`
2. ✅ `lib/game/arcs/envy/envy_arc_game.dart` → Actualizado con nueva mecánica
3. ✅ `lib/data/providers/arc_data_provider.dart` → Briefing actualizado

### Mecánica: Espejo Adaptativo

**Sistema de 3 Fases:**
- **Fase 1** (0-2 evidencias): Delay 1.0s, Speed 80%, Dash cada 12s
- **Fase 2** (3-4 evidencias): Delay 0.6s, Speed 100%, Dash cada 12s  
- **Fase 3** (5 evidencias): Delay 0.3s, Speed 110%, Dash cada 8s

**Características:**
- ✅ Enemigo imita movimientos del jugador con delay
- ✅ Se vuelve más rápido y agresivo con cada evidencia
- ✅ Dash directo hacia el jugador (velocidad x2)
- ✅ Zona de Envidia (enemigo 10% más rápido cerca del jugador)
- ✅ 3 escondites limitados (5 seg protección, 15 seg cooldown)
- ✅ 5 evidencias en posiciones estratégicas
- ✅ Feedback visual por fase (verde claro → verde intenso → verde neón)

### Dificultad
⭐⭐⭐⭐ (4/5) - Más difícil que Arcos 1 y 2

### Testing
```bash
flutter run
# Seleccionar Arco 3: ENVIDIA
# Verificar que el enemigo imita movimientos
# Verificar cambio de fase al recoger evidencias
# Verificar dash periódico
```

### Próximos Pasos
- Probar gameplay completo
- Ajustar balanceo si es necesario
- Añadir sprite animado (opcional)
- Continuar con Arco 4 (Lujuria)
