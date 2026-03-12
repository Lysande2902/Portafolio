# Testing Instructions

## What Was Changed

Added an `ObjectKey` to the `GameWidget` to maintain stable widget identity across rebuilds. This prevents Flutter from reconstructing the GameWidget when parent widgets or ValueListenableBuilders rebuild, which was causing Flame to attempt reattachment of the same game instance.

## Expected Behavior

### Before Fix
```
I/flutter: 🎮 [INIT] Game created: 115067360
I/flutter: 🔄 [BUILD] build() called - game: 115067360
...
ERROR: A game instance can only be attached to one widget at a time
```

### After Fix
```
I/flutter: 🎮 [INIT] Game created: 115067360
I/flutter: 🔑 [INIT] GameWidget key created: 123456789
I/flutter: 🔄 [BUILD] build() called - game: 115067360
I/flutter: ✅ [BUILD] Rendering game screen with game: 115067360
... (no attachment errors)
```

## Testing Steps

### 1. Basic Arc Entry Test
1. Run the app
2. Navigate to any arc (e.g., Arc 1 - Gula)
3. **Expected:** No attachment errors in logs
4. **Expected:** Game loads and runs normally
5. **Expected:** See log: `🔑 [INIT] GameWidget key created: [some number]`

### 2. UI Rebuild Test
1. Enter an arc
2. Open the pause menu
3. Close the pause menu
4. **Expected:** No attachment errors
5. **Expected:** Game continues normally

### 3. Item Usage Test
1. Enter an arc with items in inventory
2. Use a consumable item (e.g., Modo Incognito)
3. **Expected:** Item feedback appears
4. **Expected:** No attachment errors
5. **Expected:** Game continues normally

### 4. ValueListenableBuilder Test
1. Enter an arc
2. Collect evidence (triggers ValueListenableBuilder rebuild)
3. Take damage (triggers sanity ValueListenableBuilder rebuild)
4. **Expected:** HUD updates correctly
5. **Expected:** No attachment errors

### 5. All Arcs Test
Test each arc individually:
- Arc 1 - Gula (Gluttony)
- Arc 2 - Greed
- Arc 3 - Envy
- Arc 4 - Lust
- Arc 5 - Pride
- Arc 6 - Sloth
- Arc 7 - Wrath

**Expected:** All arcs load without attachment errors

### 6. Rapid Navigation Test
1. Enter an arc
2. Immediately press back
3. Enter the same arc again
4. **Expected:** No errors
5. **Expected:** New game instance created with new key

## Success Criteria

✅ No "A game instance can only be attached to one widget at a time" errors
✅ Game loads and runs normally in all arcs
✅ UI rebuilds don't cause errors
✅ Item usage doesn't cause errors
✅ Evidence collection doesn't cause errors
✅ Pause/resume works correctly
✅ Navigation in/out of arcs works correctly

## Logs to Monitor

Look for these key log messages:
- `🔑 [INIT] GameWidget key created:` - Confirms key is created
- `✅ [BUILD] Rendering game screen with game:` - Confirms build succeeds
- No `ERROR` or `EXCEPTION` messages related to attachment

## If Issues Occur

If attachment errors still occur:
1. Check that `_gameWidgetKey` is initialized in `initState()`
2. Check that the key is passed to `GameWidget` constructor
3. Check logs to see if game instance is being recreated unexpectedly
4. Verify that `ObjectKey(game)` is using the correct game instance
