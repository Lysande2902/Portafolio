# Design Document

## Overview

This design addresses two UI polish improvements: removing the redundant continue button from the arc intro screen and redesigning the tutorial button in the pause menu for a more subtle, refined appearance. The changes focus on reducing visual clutter and improving the overall user experience.

## Architecture

The solution involves modifications to two existing UI components:

1. **ArcIntroScreen** (`lib/screens/arc_intro_screen.dart`): Remove the bottom continue button widget while maintaining the skip button and auto-continue functionality
2. **PauseMenu** (`lib/game/ui/pause_menu.dart`): Redesign the tutorial button to use a more subtle, text-based style

Both changes are isolated to their respective UI components and do not affect game logic or state management.

## Components and Interfaces

### ArcIntroScreen Modifications

**Current Structure:**
- Typewriter text animation in center
- Skip button in top-right corner
- Continue button at bottom (appears when animation completes)
- Auto-continue timer (2 seconds after completion)

**Modified Structure:**
- Typewriter text animation in center
- Skip button in top-right corner
- Auto-continue timer (2 seconds after completion)
- **Removed:** Continue button at bottom

### PauseMenu Modifications

**Current Button Hierarchy:**
1. Continue button (primary - red background)
2. Tutorial button (secondary - cyan outlined)
3. Exit button (secondary - white outlined)

**Modified Button Hierarchy:**
1. Continue button (primary - red background)
2. Tutorial button (subtle text-only)
3. Exit button (secondary - white outlined)

## Data Models

No data model changes required. All modifications are purely presentational.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Auto-continue exclusivity
*For any* arc intro screen state, when the typewriter animation completes, the screen should auto-continue after 2 seconds without requiring user interaction
**Validates: Requirements 1.1, 1.3**

### Property 2: Single skip mechanism
*For any* arc intro screen state, the only manual skip mechanism should be the top-right skip button
**Validates: Requirements 1.2**

### Property 3: Tutorial button visual subordination
*For any* pause menu rendering, the tutorial button should have less visual weight than the continue and exit buttons
**Validates: Requirements 2.3, 2.5**

## Error Handling

No new error conditions are introduced. Existing error handling remains unchanged:
- Timer cancellation on widget disposal
- Mounted checks before state updates
- Null safety for optional callbacks

## Testing Strategy

### Unit Testing

**ArcIntroScreen Tests:**
- Verify continue button widget is not present in widget tree
- Verify skip button remains functional
- Verify auto-continue timer triggers correctly
- Verify smooth transition after timer completion

**PauseMenu Tests:**
- Verify tutorial button uses text-only style
- Verify tutorial button callback functionality
- Verify visual hierarchy is maintained
- Verify button layout and spacing

### Property-Based Testing

Not applicable for these UI-only changes. Visual regression testing would be more appropriate but is outside the scope of unit testing.

### Manual Testing

- Visual inspection of arc intro screen without continue button
- Verify auto-continue works after 2 seconds
- Visual inspection of pause menu with subtle tutorial button
- Verify all pause menu buttons remain functional

## Implementation Notes

### ArcIntroScreen Changes

Remove the `Positioned` widget containing the "TOCA PARA CONTINUAR" button from the Stack. The auto-continue functionality already exists and will handle the transition.

### PauseMenu Changes

Replace the `OutlinedButton` for the tutorial with a `TextButton` using a minimal style:
- No border
- No background
- Smaller font size
- Muted color (grey)
- Reduced padding
- Optional: Add small icon for visual interest without prominence

The button should appear as a subtle option rather than a prominent action, similar to a "forgot password" link on a login form.
